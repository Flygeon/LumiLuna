# Tasks

## Task 1: Rust 依赖与数据结构扩展
在 `rust/Cargo.toml` 中添加 `image` 和 `kamadak-exif` 依赖，扩展 `RustMediaItem` 结构体添加缩略图/EXIF/视频元数据字段。

- [x] 添加 `image = "0.25"` 和 `kamadak-exif = "0.6"` 到 Cargo.toml
- [x] 扩展 `RustMediaItem` 添加所有可选字段（thumbnail_path, image_*, video_*）
- [x] 重新生成 FRB 绑定（`flutter_rust_bridge_codegen generate`）

**依赖**: 无
**验证**: `cargo build` 通过

## Task 2: Rust 图片缩略图生成 + EXIF 提取
在 `media_scan.rs` 的 `walk()` 函数中，对图片文件执行缩略图生成和 EXIF 提取。

- [x] 实现 `generate_thumbnail(path, cache_dir) -> Option<String>`
- [x] 实现 `read_exif(path) -> (width, height, date, make, model, lat, lng, iso, focal, fnumber)`
- [x] 在 `walk()` 中，遇到图片文件时调用以上两个函数
- [x] 缓存目录通过参数传入（从 Dart 下发）
- [x] 缩略图文件名使用 XXH3 哈希

**依赖**: Task 1
**验证**: 单元测试验证缩略图文件生成和 EXIF 读取

## Task 3: Rust 视频元数据提取
在 `media_scan.rs` 中添加 ffprobe 调用提取视频元数据。

- [x] 实现 `read_video_metadata(path) -> (width, height, codec, fps)`
- [x] 在 `walk()` 中，遇到视频文件时调用此函数
- [x] 错误安全：ffprobe 不存在或失败时返回 None

**依赖**: Task 1
**验证**: 单元测试验证视频元数据解析

## Task 4: Rust 音频封面提取整合
修改 `walk()` 中音频处理逻辑，在扫描时直接提取封面并写入缓存。

- [x] 在 `read_audio_metadata` 中扩展返回封面数据
- [x] 实现封面写入缓存目录的逻辑
- [x] 将 `artwork_path` 存入 `RustMediaItem`

**依赖**: Task 1
**验证**: 扫描后封面文件存在于缓存目录

## Task 5: Database Schema v5 迁移
- [x] 在 `MediaItems` 表添加新字段
- [x] 更新 `schemaVersion` 从 4 到 5
- [x] 添加 `onUpgrade` 迁移逻辑
- [x] 更新 `_mediaItemFromRow` 和 `MediaItemsCompanion`

**依赖**: 无
**验证**: 数据库迁移后数据完整

## Task 6: Dart Model 与 Service 层更新
- [x] 更新 `MediaItem` model 添加所有新字段
- [x] 更新 `RustScannerService._toMediaItem` 映射新字段
- [x] 简化 `MediaScannerService._enrichAudioMetadataParallel`（移除封面提取逻辑）
- [x] 修复 `_processAudioChunk` 中的哈希碰撞

**依赖**: Task 5
**验证**: 扫描后数据正确写入数据库

## Task 7: 统一缓存管理器
- [x] 创建 `CacheManager` 类，管理 `<app_support>/lumiluna_cache/` 下的所有缓存
- [x] 子目录：`thumbnails/`, `video_thumbs/`, `artwork/`
- [x] 启动时执行自动清理
- [x] 提供 `clearAll()` 和 `getCacheSize()` 方法
- [x] 废弃 `ScanCacheManager`

**依赖**: Task 6
**验证**: 缓存清理后文件被正确删除

## Task 8: 图片缩略图加载优化
- [x] `MediaThumbnail` 中优先使用 `item.thumbnailPath`
- [x] 无缓存时回退到当前逻辑
- [x] `_VideoThumbnail._cacheKey` 使用一致性哈希
- [x] 视频缩略图路径优先走数据库中的缓存路径

**依赖**: Task 6, Task 7
**验证**: 网格视图中缩略图显示正常

## Task 9: 图片详情对话框
- [x] 创建 `ImageDetailDialog` Widget
- [x] 在 `MediaContextSheet` 中添加"详情"选项
- [x] 添加 i18n 字符串（中文 + 英文）

**依赖**: Task 6
**验证**: 长按图片 → 详情 → 显示所有元数据

## Task 10: 视频播放器元数据显示
- [x] 在 `VideoPlayerScreen` 中添加信息覆盖层
- [x] 显示：分辨率、编码器、FPS、文件大小
- [x] 使用半透明背景的 Badge 布局

**依赖**: Task 6
**验证**: 播放视频时元数据可见

## Task 11: 设置界面缓存管理增强
- [x] 更新 `SettingsScreen._clearCache` 使用 `CacheManager`
- [x] 显示缓存大小预览

**依赖**: Task 7
**验证**: 设置界面清缓存功能正常工作

# Task Dependencies
- Task 1 ← 基础依赖
- Task 2 ← Task 1
- Task 3 ← Task 1
- Task 4 ← Task 1
- Task 5 ← 无（可并行于 Task 1-4）
- Task 6 ← Task 5
- Task 7 ← Task 6
- Task 8 ← Task 6, Task 7
- Task 9 ← Task 6
- Task 10 ← Task 6
- Task 11 ← Task 7

# 并行执行建议
- **首批并行**: Task 1 (Rust 扩展), Task 5 (数据库迁移)
- **次批并行**: Task 2, Task 3, Task 4 (三者独立的 Rust 功能)
- **第三批并行**: Task 6 (Dart 层), Task 7 (缓存管理器)
- **末批并行**: Task 8, Task 9, Task 10, Task 11 (UI 层)
