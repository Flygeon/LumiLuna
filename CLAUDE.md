# CLAUDE.md

本文档为 Claude Code（claude.ai/code）在处理此仓库代码时提供指引。

## 常用命令

```bash
flutter pub get                    # 安装依赖
flutter run -d windows             # 在 Windows 桌面运行
flutter analyze                    # 静态分析（不将 infos/warnings 视为 fatal）
flutter test                       # 运行测试（当前尚无测试）
flutter gen-l10n                   # 从 .arb 文件重新生成 AppLocalizations
flutter build windows --release    # Release 构建（CI 中也执行此命令）
flutter create --platforms=windows --project-name lumiluna .  # 引导生成 Windows 平台文件
```

国际化使用 `flutter gen-l10n`（在 `l10n.yaml` 中配置），读取 `lib/l10n/*.arb` 并生成 `lib/l10n/generated/`。编辑 `.arb` 文件后务必运行 `flutter gen-l10n`。

## 项目概览

LumiLuna（光影 · 媒体库）是一个基于 Flutter + Material 3 的 Windows 桌面应用，可扫描本地文件夹并浏览/播放图片、视频和音乐。音视频共享同一个 `media_kit` 播放器，状态管理使用 `flutter_riverpod`。

## 架构

### 数据流

```
SettingsService (SharedPreferences)
  └─ settingsProvider (StateNotifier<AppSettings>)
       ├─ scanFolders → mediaProvider (AsyncNotifier) → MediaScannerService (后台 isolate)
       ├─ isGridView  → MediaTypeScreen / FoldersScreen
       └─ groupMode   → filter_provider.dart (groupedMediaProvider)
```

### 关键层次

- **`lib/models/`** — 不可变数据类：`MediaItem`（文件路径、元数据）、`MediaFolder`（分组）、`MediaType`（枚举）
- **`lib/services/`** — `MediaScannerService`（在 isolate 中递归遍历文件系统 + 通过 `audio_metadata_reader` 补充音频元数据）、`SettingsService`（SharedPreferences 封装）
- **`lib/providers/`** — 连接服务与 UI 的 Riverpod providers：
  - `media_provider.dart` — `mediaProvider`（所有项目）、`mediaByTypeProvider`（按类型筛选）、`mediaCountsProvider`（计数）
  - `filter_provider.dart` — `searchQueryProvider`、`searchedMediaProvider`、`groupedMediaProvider`
  - `player_provider.dart` — `PlaybackController`（拥有单个共享的 `media_kit.Player`）、`playbackControllerProvider`
  - `settings_provider.dart` — `AppSettings` + `SettingsNotifier`
  - `tab_provider.dart` — `activeTypeProvider`、`tabAnimatingProvider`（在 Tab 切换动画期间推迟繁重工作）
- **`lib/features/`** — 各页面：首页、媒体浏览、文件夹、播放器（图片/视频/音乐）、设置
- **`lib/widgets/`** — 可复用组件：`MediaThumbnail`、`MediaGridView`、`MediaListView`、`AsyncView`、`EmptyState`
- **`lib/l10n/`** — `app_en.arb`、`app_zh.arb`、生成的本地化文件，以及便捷访问的扩展方法（`context.l10n`）

### Tab 系统（4 个标签页）

1. 图片 — `MediaTypeScreen(type: MediaType.image)`
2. 视频 — `MediaTypeScreen(type: MediaType.video)`
3. 音乐 — `MediaTypeScreen(type: MediaType.audio)`
4. 文件夹 — `FoldersScreen`（按相册/文件夹/日期分组）

Tab 切换使用 `PageView`，带有 320ms 的 `easeInOutCubic` 滑动动画。当 `tabAnimatingProvider` 为 true 时，视频缩略图提取会被推迟。

### 播放器架构

一个 `media_kit.Player` 实例位于 `PlaybackController`（Riverpod StateNotifier）中。`VideoPlayerScreen` 和 `MusicPlayerScreen` 共享此实例。图片使用普通的 `PageView` + `InteractiveViewer`（不涉及 media_kit）。

- 图片查看器：可滑动的 `PageView`，通过 `InteractiveViewer` 支持捏合/缩放
- 视频播放器：`media_kit_video.Video` 组件搭配 `AdaptiveVideoControls`，播放列表自动续播
- 音乐播放器：自定义 UI，包含进度条、传输控制（上一首/播放暂停/下一首/停止/循环）、播放列表

### 媒体扫描

`MediaScannerService.scan(folders)` 通过 `compute()` 在后台 isolate 中运行 `_scanIsolate`，然后在主 isolate 上使用 `audio_metadata_reader` 补充音频元数据。默认文件夹：`$USERPROFILE/Pictures`、`/Videos`、`/Music`。可在设置中通过 `file_picker` 配置。最大递归深度：8 层。隐藏目录（以 `.` 开头）会被跳过。

### 缩略图策略

- **图片**：以 `cacheWidth: 300` 解码以节省内存
- **视频**：`fc_native_video_thumbnail` 提取一帧（推迟到该 tab 处于激活状态且动画结束后才执行）；缓存到 `%TEMP%/lumiluna_thumbs/`
- **音频**：扫描期间将嵌入的封面艺术缓存到 `%TEMP%/lumiluna_artwork/`；无封面时回退为带主题的图标占位

### 关键依赖

| 包 | 用途 |
|---|---|
| `flutter_riverpod` | 状态管理 |
| `media_kit` / `media_kit_video` | 音视频播放 |
| `fc_native_video_thumbnail` | 视频帧提取 |
| `audio_metadata_reader` | 音频标签读取（纯 Dart，无需原生构建步骤） |
| `shared_preferences` | 持久化设置 |
| `file_picker` | 设置中选择文件夹 |
| `path_provider` | 缩略图/缓存的临时目录 |
| `intl` | 日期/时间格式化 |
| `package_info_plus` | 关于页面的版本信息 |

### CI 流水线

`.github/workflows/build-windows.yml`：
- 检出代码
- 配置 Flutter stable 版本
- 通过 `flutter create --platforms=windows` 生成 `windows/` 平台文件
- 运行 `flutter pub get`
- 运行 `flutter analyze`（非 fatal，即使有 warning 也继续）
- 执行 `flutter build windows --release`
- 将 `build/windows/x64/runner/Release/` 打包为 `lumiluna-windows.zip`
- 上传为工作流产物（保留 30 天）

### 编码约定

- 优先使用 `const` 构造器、`final` 局部变量和 `super.key` 参数
- 使用 `extension L10nX on BuildContext`（`context.l10n.xxx`）进行本地化访问
- 组件按文件对应一个类的方式组织；私有类放在同一文件中
- Linter：`flutter_lints/flutter.yaml`，启用了 `prefer_final_locals`、`prefer_const_declarations`、`avoid_unnecessary_containers`、`sized_box_for_whitespace`
- `avoid_print` 为 warning 级别（非 error）—— 开发期间允许使用 debug 打印
- 错误通常在扫描层面被捕获并吞掉，而不是崩溃
- `Analysis_options.yaml` 排除了 `*.g.dart` 和 `*.freezed.dart`（目前未使用）
