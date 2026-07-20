use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::UNIX_EPOCH;

use flutter_rust_bridge::frb;
use lofty::{prelude::*, probe::Probe};
use serde::Deserialize;
use std::io::BufReader;
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
    pub artwork_path: Option<String>,
    pub thumbnail_path: Option<String>,
    pub image_width: Option<i32>,
    pub image_height: Option<i32>,
    pub image_date_taken: Option<String>,
    pub image_camera_make: Option<String>,
    pub image_camera_model: Option<String>,
    pub image_gps_lat: Option<f64>,
    pub image_gps_lng: Option<f64>,
    pub image_iso: Option<i32>,
    pub image_focal_length: Option<f64>,
    pub image_f_number: Option<f64>,
    pub video_width: Option<i32>,
    pub video_height: Option<i32>,
    pub video_codec: Option<String>,
    pub video_fps: Option<f64>,
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
pub fn extract_audio_cover(path: String, output_path: String) -> bool {
    let tagged_file = match Probe::open(Path::new(&path)).and_then(|probe| probe.read()) {
        Ok(file) => file,
        Err(_) => return false,
    };
    let tag = tagged_file.primary_tag().or_else(|| tagged_file.first_tag());
    let picture = match tag.and_then(|value| value.pictures().first()) {
        Some(picture) => picture,
        None => return false,
    };
    fs::write(output_path, picture.data()).is_ok()
}

#[frb]
pub fn extract_video_cover(path: String, output_path: String, time_ms: u32) -> bool {
    let seek = format!("{}ms", time_ms);
    Command::new("ffmpeg")
        .args([
            "-y",
            "-ss",
            &seek,
            "-i",
            &path,
            "-frames:v",
            "1",
            "-vf",
            "scale='min(1280,iw)':-2",
            &output_path,
        ])
        .output()
        .map(|result| result.status.success() && Path::new(&output_path).is_file())
        .unwrap_or(false)
}

/// ffprobe JSON stream output — only the fields we need.
#[derive(Deserialize)]
struct FfprobeStream {
    #[serde(rename = "codec_type")]
    codec_type: Option<String>,
    #[serde(rename = "codec_name")]
    codec_name: Option<String>,
    width: Option<i32>,
    height: Option<i32>,
    #[serde(rename = "r_frame_rate")]
    r_frame_rate: Option<String>,
}

/// ffprobe `-show_streams` root object.
#[derive(Deserialize)]
struct FfprobeOutput {
    streams: Vec<FfprobeStream>,
}

fn read_video_metadata(path: &Path) -> (Option<i32>, Option<i32>, Option<String>, Option<f64>) {
    let output = match Command::new("ffprobe")
        .args([
            "-v",
            "quiet",
            "-print_format",
            "json",
            "-show_streams",
            &path.to_string_lossy(),
        ])
        .output()
    {
        Ok(o) if o.status.success() => o.stdout,
        _ => return (None, None, None, None),
    };

    let parsed: FfprobeOutput = match serde_json::from_slice(&output) {
        Ok(p) => p,
        Err(_) => return (None, None, None, None),
    };

    let video_stream = parsed
        .streams
        .iter()
        .find(|s| s.codec_type.as_deref() == Some("video"));

    match video_stream {
        Some(stream) => {
            let fps = stream.r_frame_rate.as_ref().and_then(|s| parse_fps(s));
            (stream.width, stream.height, stream.codec_name.clone(), fps)
        }
        None => (None, None, None, None),
    }
}

fn parse_fps(fps_str: &str) -> Option<f64> {
    let parts: Vec<&str> = fps_str.split('/').collect();
    if parts.len() == 2 {
        let num: f64 = parts[0].parse().ok()?;
        let den: f64 = parts[1].parse().ok()?;
        if den > 0.0 {
            Some(num / den)
        } else {
            None
        }
    } else {
        parts[0].parse::<f64>().ok()
    }
}

/// Generate a 300px-wide JPEG thumbnail for the given image file.
/// Returns the output file path on success, None on failure.
/// Currently a no-op; thumbnail generation is deferred to the Dart side
/// for broader format support and to avoid additional crate dependencies.
fn generate_thumbnail(_path: &Path, _cache_dir: &str, _size: i64, _modified_ms: i64) -> Option<String> {
    None
}

fn gps_to_f64(
    exif: &exif::Exif,
    tag: exif::Tag,
    ref_tag: exif::Tag,
    negative_ref_char: char,
) -> Option<f64> {
    let field = exif.get_field(tag, exif::In::PRIMARY)?;
    let ref_field = exif.get_field(ref_tag, exif::In::PRIMARY)?;
    let components: Vec<f64> = match field.value {
        exif::Value::Rational(ref vals) => vals.iter().map(|v| v.to_num::<f64>()).collect(),
        _ => return None,
    };
    if components.len() != 3 {
        return None;
    }
    let mut coord = components[0] + components[1] / 60.0 + components[2] / 3600.0;
    let ref_display = ref_field.display_value().to_string();
    if ref_display.contains(negative_ref_char) {
        coord = -coord;
    }
    Some(coord)
}

/// Read EXIF metadata from an image file.
/// Returns (width, height, date_taken, camera_make, camera_model,
///          gps_lat, gps_lng, iso, focal_length, f_number).
fn read_exif(
    path: &Path,
) -> (
    Option<i32>,
    Option<i32>,
    Option<String>,
    Option<String>,
    Option<String>,
    Option<f64>,
    Option<f64>,
    Option<i32>,
    Option<f64>,
    Option<f64>,
) {
    let file = match std::fs::File::open(path) {
        Ok(f) => f,
        Err(_) => {
            return (None, None, None, None, None, None, None, None, None, None);
        }
    };
    let mut bufreader = BufReader::new(file);
    let exif = match exif::Reader::new().read_from_container(&mut bufreader) {
        Ok(e) => e,
        Err(_) => {
            return (None, None, None, None, None, None, None, None, None, None);
        }
    };

    let width = exif
        .get_field(exif::Tag::PixelXDimension, exif::In::PRIMARY)
        .and_then(|f| f.value.get_uint(0))
        .map(|v| v as i32);
    let height = exif
        .get_field(exif::Tag::PixelYDimension, exif::In::PRIMARY)
        .and_then(|f| f.value.get_uint(0))
        .map(|v| v as i32);
    let date_taken = exif
        .get_field(exif::Tag::DateTimeOriginal, exif::In::PRIMARY)
        .map(|f| f.display_value().to_string());
    let camera_make = exif
        .get_field(exif::Tag::Make, exif::In::PRIMARY)
        .map(|f| f.display_value().to_string());
    let camera_model = exif
        .get_field(exif::Tag::Model, exif::In::PRIMARY)
        .map(|f| f.display_value().to_string());
    let gps_lat = gps_to_f64(&exif, exif::Tag::GPSLatitude, exif::Tag::GPSLatitudeRef, 'S');
    let gps_lng = gps_to_f64(
        &exif,
        exif::Tag::GPSLongitude,
        exif::Tag::GPSLongitudeRef,
        'W',
    );
    let iso = exif
        .get_field(exif::Tag::PhotographicSensitivity, exif::In::PRIMARY)
        .and_then(|f| f.value.get_uint(0))
        .map(|v| v as i32);
    let focal_length = exif
        .get_field(exif::Tag::FocalLength, exif::In::PRIMARY)
        .and_then(|f| match f.value {
            exif::Value::Rational(ref vals) => vals.first().map(|v| v.to_num::<f64>()),
            _ => None,
        });
    let f_number = exif
        .get_field(exif::Tag::FNumber, exif::In::PRIMARY)
        .and_then(|f| match f.value {
            exif::Value::Rational(ref vals) => vals.first().map(|v| v.to_num::<f64>()),
            _ => None,
        });

    (
        width,
        height,
        date_taken,
        camera_make,
        camera_model,
        gps_lat,
        gps_lng,
        iso,
        focal_length,
        f_number,
    )
}

#[frb]
pub fn scan_media(folders: Vec<String>, max_depth: u32, cache_dir: String) -> Vec<RustMediaItem> {
    let mut items = Vec::new();
    let mut seen = std::collections::HashSet::new();
    for folder in folders {
        walk(Path::new(&folder), 0, max_depth, &mut seen, &mut items, &cache_dir);
    }
    items.sort_by(|a, b| b.modified_ms.cmp(&a.modified_ms));
    items
}

#[frb]
pub fn scan_media_batch(
    folders: Vec<String>,
    max_depth: u32,
    cache_dir: String,
    offset: u32,
    limit: u32,
) -> Vec<RustMediaItem> {
    let items = scan_media(folders, max_depth, cache_dir);
    let start = (offset as usize).min(items.len());
    let end = (start + limit as usize).min(items.len());
    items[start..end].to_vec()
}

#[frb]
pub fn scan_media_batches(
    folders: Vec<String>,
    max_depth: u32,
    cache_dir: String,
    batch_size: u32,
) -> Vec<Vec<RustMediaItem>> {
    let items = scan_media(folders, max_depth, cache_dir);
    let size = batch_size.max(1) as usize;
    items.chunks(size).map(|batch| batch.to_vec()).collect()
}

fn walk(
    directory: &Path,
    depth: u32,
    max_depth: u32,
    seen: &mut std::collections::HashSet<PathBuf>,
    output: &mut Vec<RustMediaItem>,
    cache_dir: &str,
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
                walk(&path, depth + 1, max_depth, seen, output, cache_dir);
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
        let (title, artist, album, duration_ms, artwork_path) = if media_type == "audio" {
            read_audio_metadata(&path, cache_dir)
        } else {
            (None, None, None, None, None)
        };
        let (thumbnail_path, image_width, image_height, image_date_taken,
             image_camera_make, image_camera_model, image_gps_lat, image_gps_lng,
             image_iso, image_focal_length, image_f_number) = if media_type == "image" {
            let thumb = generate_thumbnail(&path, cache_dir, size, modified_ms);
            let exif = read_exif(&path);
            (thumb, exif.0, exif.1, exif.2, exif.3, exif.4, exif.5, exif.6, exif.7, exif.8, exif.9)
        } else {
            (None, None, None, None, None, None, None, None, None, None, None)
        };
        let (video_width, video_height, video_codec, video_fps) = if media_type == "video" {
            read_video_metadata(&path)
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
            artwork_path,
            thumbnail_path,
            image_width,
            image_height,
            image_date_taken,
            image_camera_make,
            image_camera_model,
            image_gps_lat,
            image_gps_lng,
            image_iso,
            image_focal_length,
            image_f_number,
            video_width,
            video_height,
            video_codec,
            video_fps,
        });
    }
}

fn ext_for_mime(mime: &lofty::MimeType) -> &str {
    match mime {
        lofty::MimeType::Png => "png",
        lofty::MimeType::Jpeg => "jpg",
        lofty::MimeType::Bmp => "bmp",
        lofty::MimeType::Gif => "gif",
        lofty::MimeType::Tiff => "tiff",
        _ => "jpg",
    }
}

fn read_audio_metadata(path: &Path, cache_dir: &str) -> (Option<String>, Option<String>, Option<String>, Option<i64>, Option<String>) {
    let tagged_file = match Probe::open(path).and_then(|probe| probe.read()) {
        Ok(file) => file,
        Err(_) => return (None, None, None, None, None),
    };
    let tag = tagged_file.primary_tag().or_else(|| tagged_file.first_tag());
    let properties = tagged_file.properties();
    let artwork_path = tag.and_then(|t| {
        t.pictures().first().map(|pic| {
            let ext = pic.mime_type().map(|m| ext_for_mime(m)).unwrap_or("jpg");
            let hash = xxh3_64(path.to_string_lossy().as_bytes());
            let artwork_dir = format!("{}/artwork", cache_dir);
            std::fs::create_dir_all(&artwork_dir).ok();
            let dest = format!("{}/{:016x}.{}", artwork_dir, hash, ext);
            std::fs::write(&dest, pic.data()).ok();
            dest
        })
    });
    (
        tag.and_then(|tag| tag.title().map(|value| value.into_owned())),
        tag.and_then(|tag| tag.artist().map(|value| value.into_owned())),
        tag.and_then(|tag| tag.album().map(|value| value.into_owned())),
        Some(properties.duration().as_millis().min(i64::MAX as u128) as i64),
        artwork_path,
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

        let items = scan_media(vec![root.to_string_lossy().into_owned()], 8, String::new());
        assert_eq!(items.len(), 2);
        assert!(items.iter().any(|item| item.media_type == "image"));
        assert!(items.iter().any(|item| item.media_type == "audio"));

        let _ = std::fs::remove_dir_all(root);
    }
}
