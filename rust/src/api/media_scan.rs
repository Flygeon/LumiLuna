use std::fs;
use std::path::{Path, PathBuf};
use std::time::UNIX_EPOCH;

use flutter_rust_bridge::frb;
use lofty::{prelude::*, probe::Probe};
use xxhash_rust::xxh3::xxh3_64;

#[frb]
#[derive(Clone)]
pub struct RustMediaItem {
    pub path: String,
    pub name: String,
    pub media_type: String,
    pub size: i64,
    pub modified_ms: i64,
    pub file_hash: u64,
    pub title: Option<String>,
    pub artist: Option<String>,
    pub album: Option<String>,
    pub duration_ms: Option<i64>,
}

#[frb]
pub fn ping() -> String {
    "pong".to_string()
}

#[frb]
pub fn stable_hash(path: String) -> u64 {
    xxh3_64(path.as_bytes())
}

#[frb]
pub fn stable_file_hash(path: String, size: i64, modified_ms: i64) -> u64 {
    let value = format!("{}\0{}\0{}", path, size, modified_ms);
    xxh3_64(value.as_bytes())
}

#[frb]
pub fn scan_media(folders: Vec<String>, max_depth: u32) -> Vec<RustMediaItem> {
    let mut items = Vec::new();
    let mut seen = std::collections::HashSet::new();
    for folder in folders {
        walk(Path::new(&folder), 0, max_depth, &mut seen, &mut items);
    }
    items.sort_by(|a, b| b.modified_ms.cmp(&a.modified_ms));
    items
}

#[frb]
pub fn scan_media_batch(
    folders: Vec<String>,
    max_depth: u32,
    offset: u32,
    limit: u32,
) -> Vec<RustMediaItem> {
    let items = scan_media(folders, max_depth);
    let start = (offset as usize).min(items.len());
    let end = (start + limit as usize).min(items.len());
    items[start..end].to_vec()
}

#[frb]
pub fn scan_media_batches(
    folders: Vec<String>,
    max_depth: u32,
    batch_size: u32,
) -> Vec<Vec<RustMediaItem>> {
    let items = scan_media(folders, max_depth);
    let size = batch_size.max(1) as usize;
    items.chunks(size).map(|batch| batch.to_vec()).collect()
}

fn walk(
    directory: &Path,
    depth: u32,
    max_depth: u32,
    seen: &mut std::collections::HashSet<PathBuf>,
    output: &mut Vec<RustMediaItem>,
) {
    if depth > max_depth {
        return;
    }
    let entries = match fs::read_dir(directory) {
        Ok(entries) => entries,
        Err(_) => return,
    };
    for entry in entries.flatten() {
        let path = entry.path();
        let name = match path.file_name().and_then(|value| value.to_str()) {
            Some(name) => name,
            None => continue,
        };
        if path.is_dir() {
            if !name.starts_with('.') {
                walk(&path, depth + 1, max_depth, seen, output);
            }
            continue;
        }
        if !path.is_file() || name.starts_with('.') {
            continue;
        }
        let canonical = match fs::canonicalize(&path) {
            Ok(path) => path,
            Err(_) => continue,
        };
        if !seen.insert(canonical) {
            continue;
        }
        let media_type = match media_type(&path) {
            Some(value) => value,
            None => continue,
        };
        let metadata = match fs::metadata(&path) {
            Ok(metadata) => metadata,
            Err(_) => continue,
        };
        let modified_ms = metadata
            .modified()
            .ok()
            .and_then(|time| time.duration_since(UNIX_EPOCH).ok())
            .map(|duration| duration.as_millis().min(i64::MAX as u128) as i64)
            .unwrap_or(0);
        let size = metadata.len().min(i64::MAX as u64) as i64;
        let file_hash = stable_file_hash(
            path.to_string_lossy().into_owned(),
            size,
            modified_ms,
        );
        let (title, artist, album, duration_ms) = if media_type == "audio" {
            read_audio_metadata(&path)
        } else {
            (None, None, None, None)
        };
        output.push(RustMediaItem {
            path: path.to_string_lossy().into_owned(),
            name: name.to_owned(),
            media_type: media_type.to_owned(),
            size,
            modified_ms,
            file_hash,
            title,
            artist,
            album,
            duration_ms,
        });
    }
}

fn read_audio_metadata(path: &Path) -> (Option<String>, Option<String>, Option<String>, Option<i64>) {
    let tagged_file = match Probe::open(path).and_then(|probe| probe.read()) {
        Ok(file) => file,
        Err(_) => return (None, None, None, None),
    };
    let tag = tagged_file.primary_tag().or_else(|| tagged_file.first_tag());
    let properties = tagged_file.properties();
    (
        tag.and_then(|tag| tag.title().map(|value| value.into_owned())),
        tag.and_then(|tag| tag.artist().map(|value| value.into_owned())),
        tag.and_then(|tag| tag.album().map(|value| value.into_owned())),
        Some(properties.duration().as_millis().min(i64::MAX as u128) as i64),
    )
}

fn media_type(path: &Path) -> Option<&'static str> {
    let extension = path.extension()?.to_str()?.to_ascii_lowercase();
    if matches!(extension.as_str(), "jpg" | "jpeg" | "png" | "gif" | "bmp" | "webp" | "heic" | "heif" | "tiff" | "tif" | "ico") {
        return Some("image");
    }
    if matches!(extension.as_str(), "mp4" | "mkv" | "avi" | "mov" | "wmv" | "flv" | "webm" | "m4v" | "mpeg" | "mpg" | "ts" | "3gp") {
        return Some("video");
    }
    if matches!(extension.as_str(), "mp3" | "flac" | "wav" | "aac" | "m4a" | "ogg" | "wma" | "opus" | "aiff" | "ape") {
        return Some("audio");
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs::{create_dir_all, write};

    #[test]
    fn ping_returns_pong() {
        assert_eq!(ping(), "pong");
    }

    #[test]
    fn stable_hash_is_deterministic() {
        assert_eq!(stable_hash("same-path".to_string()), stable_hash("same-path".to_string()));
        assert_ne!(stable_hash("a".to_string()), stable_hash("b".to_string()));
    }

    #[test]
    fn scan_media_filters_and_deduplicates_files() {
        let root = std::env::temp_dir().join(format!("lumiluna-scan-{}", std::process::id()));
        let nested = root.join("nested");
        create_dir_all(&nested).unwrap();
        write(root.join("image.jpg"), b"image").unwrap();
        write(nested.join("song.mp3"), b"audio").unwrap();
        write(nested.join("notes.txt"), b"text").unwrap();

        let items = scan_media(vec![root.to_string_lossy().into_owned()], 8);
        assert_eq!(items.len(), 2);
        assert!(items.iter().any(|item| item.media_type == "image"));
        assert!(items.iter().any(|item| item.media_type == "audio"));

        let _ = std::fs::remove_dir_all(root);
    }
}
