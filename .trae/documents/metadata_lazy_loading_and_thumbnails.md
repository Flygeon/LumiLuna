# 元数据延迟加载 + 缩略图生成 Plan

## Summary

解决内存膨胀的两个问题：
1. **`MediaItem` 瘦身**：将 14 个 EXIF/视频元数据字段拆出到 `MediaMetadata` 类，按需从数据库加载
2. **图片缩略图生成**：在 Rust 中用 `image` crate 扫描时生成 300px 缩略图并写入缓存

## Current State Analysis

### 内存问题根因

`MediaItem`（`lib/models/media_item.dart`）当前有 27 个字段，其中 14 个是仅用于详情页/播放器的元数据：

| MediaItem 核心字段 (13) | EXIF/视频元数据 (14) |
|---|---|
| path, name, type, size, modified | imageWidth, imageHeight |
| fileHash, isFavorite, folderPath | imageDateTaken, imageCameraMake/Model |
| title, artist, album, durationMs | imageGpsLat/Lng, imageIso |
| artworkPath, **thumbnailPath** | imageFocalLength, imageFNumber |
| | videoWidth, videoHeight, videoCodec, videoFps |

`thumbnailPath` 保留在 `MediaItem` 中——网格视图需要它来显示缩略图。

### 缩略图现状

`generate_thumbnail`（`rust/src/api/media_scan.rs:167`）是 no-op 返回 `None`。`MediaThumbnail`（`lib/widgets/media_thumbnail.dart`）对图片用 `Image.file()` 解码原图，无持久缓存。

### 元数据消费者

| 消费者 | 使用的元数据字段 |
|---|---|
| `ImageDetailDialog`（`lib/widgets/image_detail_dialog.dart`） | imageWidth/Height, imageDateTaken, imageCameraMake/Model, imageGpsLat/Lng, imageIso, imageFocalLength, imageFNumber |
| `VideoPlayerScreen._VideoInfoBadge`（`lib/features/player/video_player_screen.dart`） | videoWidth/Height, videoCodec, videoFps, size |
| `MediaThumbnail`（`lib/widgets/media_thumbnail.dart`） | thumbnailPath（保留在 MediaItem） |

### 数据库

`MediaItems` 表（`lib/services/database/app_database.dart`）已包含全部字段。Schema 不变。

### Rust 扫描

`walk()`（`rust/src/api/media_scan.rs:317`）对 image 类型调用 `read_exif()` + `generate_thumbnail()`，对 video 类型调用 `read_video_metadata()`。数据在 `RustMediaItem` 中整体返回。

## Proposed Changes

### Step 1: 创建 MediaMetadata 模型

**文件**: `lib/models/media_metadata.dart`（新建）

从 `MediaItem` 拆出 14 个字段：

```dart
class MediaMetadata {
  final String mediaPath;  // 与 MediaItem.path 关联
  final int? imageWidth;
  final int? imageHeight;
  final String? imageDateTaken;
  final String? imageCameraMake;
  final String? imageCameraModel;
  final double? imageGpsLat;
  final double? imageGpsLng;
  final int? imageIso;
  final double? imageFocalLength;
  final double? imageFNumber;
  final int? videoWidth;
  final int? videoHeight;
  final String? videoCodec;
  final double? videoFps;

  const MediaMetadata({...});
  factory MediaMetadata.fromMediaItemRow(MediaItemRow row); // 从数据库行构造
  Map<String, dynamic> toJson();
  factory MediaMetadata.fromJson(Map<String, dynamic> json);
}
```

### Step 2: MediaItem 瘦身

**文件**: `lib/models/media_item.dart`

移除 14 个元数据字段、构造函数参数、`copyWith` 参数、`toJson`/`fromJson`。

保留的字段：path, name, type, size, modified, fileHash, title, artist, album, durationMs, artworkPath, isFavorite, folderPath, thumbnailPath

### Step 3: 数据库延迟加载

**文件**: `lib/services/database/app_database.dart`

新增方法：
```dart
Future<MediaMetadata?> getMediaMetadata(String path);
```

查询已存在的列，构造 `MediaMetadata`：
```dart
final row = await (select(mediaItems)..where((t) => t.path.equals(path))).getSingleOrNull();
if (row == null) return null;
return MediaMetadata.fromMediaItemRow(row);
```

同时简化 `_mediaItemFromRow`，不再映射元数据字段。

### Step 4: Riverpod Provider

**文件**: `lib/providers/media_metadata_provider.dart`（新建）

```dart
final mediaMetadataProvider = FutureProvider.family<MediaMetadata?, String>((ref, path) async {
  final db = ref.read(appDatabaseProvider);
  return db.getMediaMetadata(path);
});
```

### Step 5: 更新消费者

**文件**: `lib/widgets/image_detail_dialog.dart`

- 移除 `MediaItem` 上的字段直接访问
- 改为通过 `ref.watch(mediaMetadataProvider(item.path))` 获取数据
- 若元数据尚未加载完成，显示加载状态
- 需要将 `ImageDetailDialog` 改为 `ConsumerStatefulWidget` 或在调用处传递元数据

**文件**: `lib/features/player/video_player_screen.dart`

- 类似改动，通过 provider 获取 `videoWidth`/`videoHeight`/`videoCodec`/`videoFps`

**文件**: `lib/features/settings/settings_screen.dart`（清理缓存部分）
- 涉及 `await widget.onClear()` 的 `VoidCallback` 改成 `Future<void> Function()`（之前已做）

**文件**: `lib/widgets/media_context_sheet.dart`
- 已添加 `MediaType` import（之前已修复）

### Step 6: Rust 缩略图生成

**文件**: `rust/Cargo.toml`

添加：
```toml
image = { version = "0.24", default-features = false, features = ["jpeg", "png", "webp", "gif", "bmp"] }
```

使用 `0.24` 而非 `0.25` 以获得更稳定的 API。

**文件**: `rust/src/api/media_scan.rs`

替换 `generate_thumbnail` no-op 为实际实现：
```rust
fn generate_thumbnail(path: &Path, cache_dir: &str, size: i64, modified_ms: i64) -> Option<String> {
    let img = image::open(path).ok()?;
    let thumb_dir = format!("{}/thumbnails", cache_dir);
    std::fs::create_dir_all(&thumb_dir).ok()?;
    let hash = xxh3_64(
        format!("{}\0{}\0{}", path.to_string_lossy(), size, modified_ms).as_bytes(),
    );
    let output_path = format!("{}/{:016x}.jpg", thumb_dir, hash);
    let (w, h) = (img.width(), img.height());
    let max_width = 300u32;
    let thumb = if w > max_width {
        let ratio = max_width as f64 / w as f64;
        let new_h = (h as f64 * ratio).round() as u32;
        img.resize(max_width, new_h.max(1), image::imageops::FilterType::Lanczos3)
    } else {
        img
    };
    thumb.save(&output_path).ok()?;
    Some(output_path)
}
```

**文件**: `rust/src/frb_generated.rs`
**文件**: `lib/src/rust/frb_generated.dart`
**文件**: `lib/src/rust/frb_generated.io.dart`
**文件**: `lib/src/rust/frb_generated.web.dart`

`image` crate 的添加只影响 `generate_thumbnail` 函数内部的编译，不影响 FRB 生成的接口代码。所以 FRB 绑定文件无需更改。

**文件**: `lib/services/media_scanner_service.dart`

Rust 扫描路径（`_scanWithRust`）无需改动——`thumbnail_path` 字段已经在 `RustMediaItem` 中且会被 `_toMediaItem` 映射。

### Step 7: media_thumbnail.dart 适配

`thumbnailPath` 保留在 `MediaItem` 中，`MediaThumbnail` 代码无需改动。它已经优先使用 `item.thumbnailPath` 并回退到原图解码。

### Step 8: 验证

1. `cargo check` 通过
2. Dart 静态分析通过
3. 编译后运行时：图片网格视图中缩略图显示正常
4. 图片详情对话框显示 EXIF 数据
5. 视频播放器显示分辨率/编码器/FPS
6. 内存占用较之前降低（MediaItem 对象变小）

## Assumptions & Decisions

- **数据库 schema 保持不变**：列已存在，只是加载时机变晚
- **`thumbnailPath` 保留在 MediaItem**：因为网格视图差量渲染时需要，不适合延迟加载
- **音频元数据（title/artist/album/durationMs）保留在 MediaItem**：搜索和分组功能频繁访问
- **`image` crate 用 0.24 版**：避免 0.25 的潜在 API 问题，功能一致
- **缩略图质量使用默认 JPEG 75**：足够 300px 预览图使用

## Verification

- [ ] `cargo check` 无错误
- [ ] `flutter analyze` 无错误  
- [ ] `flutter build windows --release` 成功
- [ ] 网格视图中图片显示缩略图而非原图
- [ ] 图片长按菜单 → 详情显示所有 EXIF 字段
- [ ] 视频播放器显示元数据 Badge
- [ ] 新扫描时缩略图文件出现在缓存目录中
