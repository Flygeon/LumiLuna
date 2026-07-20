# Checklist

## Rust 层

- [x] Task 1: `Cargo.toml` 新增 `image` + `kamadak-exif` 依赖
- [x] Task 1: `RustMediaItem` 扩展包含所有新字段
- [x] Task 1: FRB 绑定重新生成
- [x] Task 2: 图片文件扫描时生成 300px 缩略图并写入缓存目录
- [x] Task 2: 缩略图文件名使用 XXH3 哈希
- [x] Task 2: EXIF 元数据（宽高、拍摄日期、相机型号、GPS、ISO、焦距、光圈）正确提取
- [x] Task 3: ffprobe 调用正确解析视频元数据（宽高、编码器、FPS）
- [x] Task 3: ffprobe 不可用时优雅降级（返回 None）
- [x] Task 4: 音频文件扫描时提取封面并写入缓存目录
- [x] Task 4: `artwork_path` 存入 `RustMediaItem`

## 数据库层

- [x] Task 5: `MediaItems` 表包含所有新字段
- [x] Task 5: `schemaVersion` 更新为 5
- [x] Task 5: `onUpgrade` 迁移逻辑正确（v4→v5 添加列）
- [x] Task 5: `_mediaItemFromRow` 映射所有新字段
- [x] Task 5: `MediaItemsCompanion` 包含新字段

## Dart 服务层

- [x] Task 6: `MediaItem` model 包含所有新字段、`copyWith`、`toJson`/`fromJson`
- [x] Task 6: `RustScannerService._toMediaItem` 正确映射新字段
- [x] Task 6: `_enrichAudioMetadataParallel` 移除封面提取逻辑（只保留元数据回退）
- [x] Task 6: 音频封面文件名使用 `stableHash` 而非 `path.hashCode`

## 缓存管理器

- [x] Task 7: `CacheManager` 类实现，管理 `<app_support>/lumiluna_cache/` 目录
- [x] Task 7: 缓存目录结构：`thumbnails/`, `video_thumbs/`, `artwork/`
- [x] Task 7: 启动时自动清理（对比哈希，删除无效文件）
- [x] Task 7: `clearAll()` 和 `getCacheSize()` 方法实现
- [x] Task 7: `ScanCacheManager` 已移除，无残留引用

## UI 层

- [x] Task 8: `MediaThumbnail` 优先使用 `item.thumbnailPath`
- [x] Task 8: `_VideoThumbnail._cacheKey` 使用 XXH3 哈希
- [x] Task 8: 视频缩略图优先走数据库缓存路径
- [x] Task 9: `ImageDetailDialog` 显示文件信息 + EXIF + 预览
- [x] Task 9: `MediaContextSheet` 对图片类型显示"详情"入口
- [x] Task 9: 中英文 i18n 字符串添加
- [x] Task 10: `VideoPlayerScreen` 显示分辨率、编码器、FPS 等元数据
- [x] Task 11: `SettingsScreen` 使用 `CacheManager` 清理缓存
- [x] Task 11: 清理缓存时显示释放空间大小
