# LumiLuna

LumiLuna（光影 · 媒体库）是一个基于 Flutter + Material 3 的本地媒体库桌面应用，自动扫描并浏览、播放本机的**图片、视频和音乐**。面向 Windows 桌面，通过 GitHub Actions 编译。

## 功能特性

- **媒体浏览**：后台 isolate 递归扫描本地文件夹，按图片 / 视频 / 音乐自动分类；支持**网格视图 / 列表视图**一键切换；缩略图限尺寸解码，从容应对大量媒体文件。
- **集合播放**：
  - 图片 — 全屏左右滑动浏览，支持捏合 / 双击缩放；
  - 视频 — 基于 `media_kit` 的统一播放器，打开时载入整个视频列表，**连续自动播放**；
  - 音乐 — 独立"正在播放"界面，含进度条、上一首 / 下一首、循环、播放列表跳转。
  - 三类媒体共享同一个 `media_kit` 播放引擎，可无缝切换。
- **媒体管理**：按**相册 / 文件夹 / 日期**分组浏览；顶部搜索栏按文件名实时筛选。
- **界面设计**：`MaterialApp` + Material 3，底部导航栏（`NavigationBar`，M3 版 BottomNavigationBar）切换媒体类型；支持**深色 / 浅色 / 跟随系统**主题；响应式网格列数适配不同窗口尺寸。
- **偏好持久化**：主题、视图模式、分组方式、扫描文件夹通过 `shared_preferences` 保存。

## 技术栈

| 关注点 | 方案 |
| --- | --- |
| UI | Flutter + Material 3 (`useMaterial3: true`) |
| 状态管理 | `flutter_riverpod` |
| 音视频播放 | `media_kit` / `media_kit_video`（原生支持 Windows 桌面音视频） |
| 媒体扫描 | `dart:io` 递归扫描 + `file_picker` 选择自定义文件夹 |
| 持久化 | `shared_preferences` |
| 格式化 | `intl` |

> **平台说明**：主流的 `photo_manager` 相册插件不支持 Windows 桌面，因此本应用在 Windows 上采用"扫描本地文件系统媒体文件夹"的方式：默认扫描用户目录下的 `Pictures` / `Videos` / `Music`，并允许在设置中添加任意自定义文件夹。

## 项目结构

```
lib/
├── main.dart                     # 入口：初始化 media_kit 与设置服务
├── app.dart                      # MaterialApp / 主题 / 首页
├── core/
│   ├── constants/app_constants.dart   # 支持的扩展名、布局与缓存常量
│   ├── theme/app_theme.dart           # Material 3 明暗主题
│   └── utils/format_utils.dart        # 文件大小 / 日期 / 时长格式化
├── models/
│   ├── media_type.dart           # 媒体类型枚举
│   ├── media_item.dart           # 单个媒体文件模型
│   └── media_folder.dart         # 分组模型 + GroupMode 枚举
├── services/
│   ├── media_scanner_service.dart     # 后台 isolate 扫描
│   └── settings_service.dart          # SharedPreferences 封装
├── providers/                    # Riverpod 状态层
│   ├── settings_provider.dart
│   ├── media_provider.dart
│   ├── filter_provider.dart      # 搜索 / 分组派生
│   └── player_provider.dart      # media_kit 播放控制器
├── features/
│   ├── home/home_screen.dart          # 底部导航 + 搜索 + 工具栏
│   ├── media/media_type_screen.dart   # 各类型通用列表页
│   ├── folders/                       # 分组页 + 文件夹详情
│   ├── player/                        # 图片查看器 / 视频 / 音乐播放器
│   └── settings/settings_screen.dart  # 主题 / 视图 / 分组 / 扫描文件夹
└── widgets/                      # 通用组件（缩略图 / 网格 / 列表 / 空态）
```

## 本地运行

```bash
flutter pub get
flutter run -d windows
```

首次运行请到 **设置 → 扫描文件夹** 添加媒体目录（若不添加，则扫描默认的图片/视频/音乐目录）。

## 在 GitHub Actions 上编译

仓库仅保存**源码**，不包含 `windows/` 平台脚手架。CI 会在编译时用 `flutter create --platforms=windows` 现场生成平台层，再执行 `flutter build windows --release`，最终打包为 `lumiluna-windows.zip` 上传为 artifact。

工作流文件：`.github/workflows/build-windows.yml`（推送到 `main`/`master` 或手动触发）。

## 说明

- 视频缩略图抽帧、音乐 ID3 封面/艺术家为后续可选增强项，当前版本用类型图标占位。
- 扫描递归深度上限见 `AppConstants.maxScanDepth`，以防超大目录树造成卡顿。
