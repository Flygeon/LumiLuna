# 缓存机制优化与元数据增强 Spec

## Why

当前 LumiLuna 的缓存系统分散且缺乏自动清理：

| 缓存类型 | 存储位置 | 问题 |
|---|---|---|
| 图片解码 | 内存（Flutter LRU） | 每次浏览都解码原图，无持久化缩略图 |
| 视频缩略图 | `<temp>/lumiluna_thumbs/` | 运行时按需生成，首屏显示延迟 |
| 音频封面 | `<temp>/lumiluna_artwork/` | `path.hashCode` 命名存在哈希碰撞风险 |
| 扫描结果缓存 (`ScanCacheManager`) | `<app_support>/lumiluna_cache.json` | 主流程已改用 SQLite，此代码已废弃 |
| 无自动清理 | — | 缓存无限增长，仅支持手动清理 |

同时关键元数据（图片 EXIF、视频编码信息）从未被提取，无法在 UI 中展示。

## What Changes

### 1. Rust：图片缩略图扫描时预生成
- 在 `walk()` 函数中，对图片文件用 `image` crate 解码并缩放到 300px，写入统一缓存目录
- 缓存路径存入 `RustMediaItem.thumbnail_path`

### 2. Rust：EXIF 图片元数据提取
- 在 `walk()` 中，对图片文件用 `kamadak-exif` crate 读取 EXIF 元数据
- 返回字段：宽高、拍摄日期、相机品牌/型号、GPS 坐标、ISO、焦距、光圈

### 3. Rust：视频元数据提取
- 新函数 `read_video_metadata()` 调用 `ffprobe` 读取视频容器信息
- 在 `walk()` 中，对视频文件调用此函数
- 返回字段：宽高、编码器、FPS

### 4. Rust：音频封面提取整合到扫描流程
- 在 `walk()` 中，对音频文件用 `lofty` 提取封面并写入缓存
- 移除 Dart 端 `_enrichAudioMetadataParallel` 中的封面提取逻辑

### 5. RustMediaItem 扩展
添加可选字段：
- `thumbnail_path: Option<String>`
- `image_width: Option<i32>`, `image_height: Option<i32>`
- `image_date_taken: Option<String>`
- `image_camera_make: Option<String>`, `image_camera_model: Option<String>`
- `image_gps_lat: Option<f64>`, `image_gps_lng: Option<f64>`
- `image_iso: Option<i32>`, `image_focal_length: Option<f64>`, `image_f_number: Option<f64>`
- `video_width: Option<i32>`, `video_height: Option<i32>`
- `video_codec: Option<String>`
- `video_fps: Option<f64>`

### 6. Database Schema v5
- 添加 `thumbnail_path`, `image_*`, `video_*` 字段到 `MediaItems` 表
- 添加数据库迁移

### 7. 缩略图机制优化
- `MediaThumbnail` 优先使用数据库中缓存的缩略图路径
- 无缓存时回退到当前逻辑（全尺寸解码或运行时生成）
- 替换 FNV-1a 哈希为 XXH3（与 Rust 一致）

### 8. 图片详情对话框
- 在 `MediaContextSheet` 中添加"详情"选项
- 弹出对话框显示：文件信息 + EXIF 元数据 + 图片预览

### 9. 视频播放器元数据显示
- 在 `VideoPlayerScreen` 中添加信息覆盖层，展示分辨率、编码器、FPS

### 10. 统一缓存目录与自动清理
- 所有缓存集中到 `<app_support>/lumiluna_cache/`（按类型分子目录）
- 启动时检查缓存文件有效性（对比文件哈希），删除无效条目
- 设置中"清理缓存"删除所有缓存目录
- 废弃 `ScanCacheManager`（JSON 缓存文件）并移除相关代码

### 11. 修复音频封面哈希碰撞
- 使用 Rust `stableHash` 替代 `path.hashCode` 作为封面文件命名

## Impact

### Affected Capabilities
- 媒体扫描（Rust `walk()` 扩展）
- 数据库（schema migration v4→v5）
- 缩略图渲染（`MediaThumbnail`、`_VideoThumbnail`）
- 上下文菜单（`MediaContextSheet`）
- 视频播放器（`VideoPlayerScreen`）
- 设置界面（`SettingsScreen` 缓存清理增强）
- 国际化（新增 UI 字符串）

### Affected Code
| File | Change |
|---|---|
| `rust/src/api/media_scan.rs` | 扩展 `walk()`, 新增 `RustMediaItem` 字段, 新增 ffprobe 函数 |
| `rust/Cargo.toml` | 新增 `image`, `kamadak-exif` 依赖 |
| `lib/services/database/app_database.dart` | Schema v5, 新字段, 迁移 |
| `lib/models/media_item.dart` | 新增字段 |
| `lib/services/media_scanner_service.dart` | 简化音频封面提取 |
| `lib/services/rust_scanner_service.dart` | 新字段映射 |
| `lib/widgets/media_thumbnail.dart` | 优先使用缓存缩略图 |
| `lib/widgets/media_context_sheet.dart` | 添加"详情"选项 |
| `lib/features/player/video_player_screen.dart` | 添加视频元数据显示 |
| `lib/features/settings/settings_screen.dart` | 增强缓存清理 |
| `lib/services/cache_manager.dart` | 实现统一缓存管理器 |
| `lib/core/constants/app_constants.dart` | 缓存目录常量 |
| `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb` | 新增字符串 |

## ADDED Requirements

### Requirement: 图片缩略图预生成
The system SHALL generate 300px-wide thumbnails for image files during scan.

#### Scenario: Success case
- **WHEN** Rust `walk()` encounters an image file (jpg/png/webp/etc.)
- **THEN** it decodes the image, resizes to max 300px width (keeping aspect ratio), writes JPEG to `<cache_dir>/thumbnails/<xxh3_hex>.jpg`
- **THEN** `RustMediaItem.thumbnail_path` contains the absolute path to the cached thumbnail

### Requirement: EXIF 元数据提取与展示
The system SHALL extract EXIF metadata from image files and display it in a detail dialog.

#### Scenario: Scan phase
- **WHEN** Rust `walk()` encounters an image file
- **THEN** it reads EXIF data: dimensions, date taken, camera make/model, GPS, ISO, focal length, f-number
- **THEN** these values are stored in `RustMediaItem` and persisted to database

#### Scenario: UI display
- **WHEN** user long-presses an image item and selects "详情"
- **THEN** a dialog shows file info (name, size, modified, dimensions) and EXIF data (if available)

### Requirement: 视频元数据预提取
The system SHALL extract video metadata (resolution, codec, FPS) during scan.

#### Scenario: Scan phase
- **WHEN** Rust `walk()` encounters a video file
- **THEN** it calls `ffprobe` to read width, height, codec name, FPS
- **THEN** these values are stored in `RustMediaItem` and persisted to database

#### Scenario: UI display
- **WHEN** user plays a video in `VideoPlayerScreen`
- **THEN** metadata badges (resolution, codec, FPS) are shown in the player overlay

### Requirement: 统一缓存管理
The system SHALL manage all cached files in a single directory hierarchy with automatic stale detection.

#### Scenario: Cache directory structure
- **GIVEN** the cache is initialized
- **THEN** `<app_support>/lumiluna_cache/thumbnails/` contains image thumbnails
- **THEN** `<app_support>/lumiluna_cache/video_thumbs/` contains video thumbnails
- **THEN** `<app_support>/lumiluna_cache/artwork/` contains audio cover art
- **THEN** each cached file is named `<xxh3_hex>.<ext>`

#### Scenario: Automatic stale detection
- **WHEN** app starts
- **THEN** `CacheManager` scans cache files, computes the expected filename for each known media item, and deletes files whose hash doesn't match any known item

#### Scenario: Manual cleanup
- **WHEN** user taps "清理缓存" in settings
- **THEN** all cache directories are deleted and freed space is reported

### Requirement: 移除废弃代码
The system SHALL remove `ScanCacheManager` which is no longer used.

#### Scenario: Cleanup
- **GIVEN** `ScanCacheManager` (`lib/services/cache_manager.dart`) is dead code
- **WHEN** the migration is complete
- **THEN** the file is removed
- **THEN** all references to `ScanCacheManager` are removed from the codebase

### Requirement: 修复封面哈希碰撞
The system SHALL use XXH3 stable hash instead of `path.hashCode` for artwork filenames.

#### Scenario: Audio cover art naming
- **GIVEN** the old code used `item.path.hashCode.abs().toString()` in `_processAudioChunk`
- **WHEN** the audio cover is extracted
- **THEN** the filename is derived from Rust's `stableHash(path)` to avoid collisions

## MODIFIED Requirements

### Requirement: 音频元数据丰富流程
**修改前**: Dart isolates (`_enrichAudioMetadataParallel`) 在扫描后重新读取音频文件提取封面。
**修改后**: Rust `walk()` 在扫描时直接用 `lofty` 提取封面写入缓存，Dart 端只需读取已存在的缓存路径。

### Requirement: 缩略图加载路径
**修改前**: 图片 `→` `Image.file()` 直解码原图；视频 `→` 运行时按需生成。
**修改后**: 图片 `→` `Image.file(thumbnail_path)` 优先走缓存；视频 `→` `Image.file(video_thumbnail_path)` 优先走缓存。

## REMOVED Requirements

### Requirement: ScanCacheManager
**Reason**: 主流程已转向 SQLite 数据库作为持久化存储，JSON 缓存文件不再被读取或写入，属于死代码。
**Migration**: 移除 `lib/services/cache_manager.dart` 及所有 import 和引用。
