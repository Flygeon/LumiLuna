<div align="center">

# LumiLuna

### 光影 · 媒体库

A cross-platform local media library built with Flutter + Material 3.

Browse, organize, and play your **images, videos, and music** — all in one place.

[![Build](https://github.com/Flygeon/LumiLuna/actions/workflows/build-windows.yml/badge.svg)](https://github.com/Flygeon/LumiLuna/actions/workflows/build-windows.yml)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-lightgrey)](#平台支持)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## ✨ 功能特性

### 媒体浏览
- 后台 isolate 递归扫描本地文件夹，按**图片 / 视频 / 音乐**自动分类
- **网格视图 / 列表视图**一键切换
- 按**相册 / 文件夹 / 日期**分组浏览
- 顶部搜索栏按文件名实时筛选
- 缩略图限尺寸解码，从容应对大量媒体文件

### 集合播放
- **图片** — 全屏左右滑动浏览，支持捏合 / 双击缩放
- **视频** — 基于 `media_kit` 的统一播放器，打开时载入整个视频列表，**连续自动播放**
- **音乐** — 独立"正在播放"界面，含进度条、上一首 / 下一首、循环、随机播放、播放列表跳转
- **歌词** — Apple Music 风格歌词滚动，支持双语翻译（原文 + 译文切换）
- 三类媒体共享同一个 `media_kit` 播放引擎，可无缝切换

### 媒体管理
- 按相册 / 文件夹 / 日期分组浏览
- 多选批量操作：收藏、删除（移至回收站）
- 媒体元数据读取（音乐 ID3 标签、视频缩略图抽帧）
- 本地 SQLite 数据库（drift）持久化收藏与媒体信息

### 界面设计
- `MaterialApp` + Material 3
- 底部导航栏（`NavigationBar`，M3 版 BottomNavigationBar）切换媒体类型
- **深色 / 浅色 / 跟随系统**主题
- 响应式布局：桌面端双栏（播放器 + 队列/歌词），移动端 PageView 滑动切换
- 桌面端支持拖拽文件夹导入、键盘快捷键

### 偏好持久化
- 主题、视图模式、分组方式、扫描文件夹通过 `shared_preferences` 保存

---

## 🛠 技术栈

| 关注点 | 方案 |
| --- | --- |
| UI 框架 | Flutter + Material 3 (`useMaterial3: true`) |
| 状态管理 | `flutter_riverpod` |
| 音视频播放 | `media_kit` / `media_kit_video`（原生支持 Windows + Android） |
| 媒体扫描 | `dart:io` 递归扫描 + `file_picker` 选择自定义文件夹 |
| 数据持久化 | `drift` (SQLite) + `shared_preferences` |
| 视频缩略图 | `fc_native_video_thumbnail`（原生抽帧） |
| 音乐元数据 | `audio_metadata_reader`（纯 Dart，无原生依赖） |
| 歌词渲染 | `flutter_lyric`（Apple Music 风格，支持翻译） |
| 格式化 | `intl` |

---

## 📁 项目结构

```
lib/
├── main.dart                     # 入口：初始化 media_kit、错误捕获、crash_log
├── app.dart                      # MaterialApp / 主题 / 首页
├── core/
│   ├── constants/app_constants.dart   # 扩展名、布局、缓存常量
│   ├── theme/app_theme.dart           # Material 3 明暗主题
│   └── utils/format_utils.dart        # 文件大小 / 日期 / 时长格式化
├── models/
│   ├── media_type.dart           # 媒体类型枚举
│   ├── media_item.dart           # 单个媒体文件模型
│   └── media_folder.dart         # 分组模型 + GroupMode 枚举
├── services/
│   ├── media_scanner_service.dart     # 后台 isolate 扫描
│   ├── settings_service.dart          # SharedPreferences 封装
│   ├── trash_manager.dart            # 回收站管理
│   ├── lyrics_service.dart           # 歌词加载
│   └── lyrics_translation_service.dart # 歌词翻译查找
├── providers/                    # Riverpod 状态层
│   ├── settings_provider.dart
│   ├── media_provider.dart
│   ├── player_provider.dart      # media_kit 播放控制器（含 shuffle）
│   ├── lyrics_provider.dart      # 歌词状态
│   └── selection_provider.dart   # 多选状态
├── features/
│   ├── splash/splash_screen.dart       # 启动动画
│   ├── home/home_screen.dart          # 底部导航 + 搜索 + 工具栏
│   ├── media/media_type_screen.dart   # 各类型通用列表页
│   ├── folders/                       # 分组页 + 文件夹详情
│   ├── player/music_player_screen.dart # 音乐播放器（含歌词）
│   ├── onboarding/onboarding_screen.dart # 首次引导
│   └── settings/settings_screen.dart  # 主题 / 视图 / 分组 / 扫描文件夹
└── widgets/                      # 通用组件（缩略图 / 网格 / 列表 / 空态 / 批量操作栏）
```

---

## 🚀 本地运行

### 环境要求
- Flutter ≥ 3.19 (stable channel)
- Dart ≥ 3.3
- Windows: Visual Studio with C++ desktop workload
- Android: Android SDK (API 21+)

### 运行

```bash
flutter pub get
flutter run                # 自动选择已连接设备
flutter run -d windows     # 指定 Windows 桌面
flutter run -d <device-id> # 指定 Android 设备
```

首次运行请到 **设置 → 扫描文件夹** 添加媒体目录（若不添加，则扫描默认的图片 / 视频 / 音乐目录）。

---

## 📦 下载

预编译版本由 GitHub Actions 自动构建并发布到 [Releases](https://github.com/Flygeon/LumiLuna/releases)：

- **Windows**：`lumiluna-windows`（x64，解压即用）
- **Android**：`lumiluna-android-arm64` / `arm32` / `x86_64` APK（按 CPU 架构选择）

每次推送到 `master` 分支会自动触发构建并创建新 Release。

---

## 🔧 CI/CD

工作流文件：`.github/workflows/build-windows.yml`

- **触发**：推送到 `main`/`master` 分支、PR、手动触发
- **构建矩阵**：Windows (x64) + Android (arm64 / arm32 / x86_64)
- **自动发布**：构建成功后自动创建 GitHub Release 并附加产物（仅 push 触发，PR 不发布）

---

## 🌐 平台支持

| 平台 | 状态 | 说明 |
| --- | --- | --- |
| Windows | ✅ 主力平台 | 原生支持，桌面体验优化 |
| Android | ✅ 支持 | 移动端布局，长按多选，PageView 滑动 |
| Linux / macOS | ⚠️ 未测试 | 理论可编译，未做适配 |
| Web | ❌ 不支持 | 依赖 `dart:ffi`，无法在 Web 运行 |

> 主流的 `photo_manager` 相册插件不支持 Windows 桌面，因此本应用采用"扫描本地文件系统媒体文件夹"的方式：默认扫描用户目录下的 `Pictures` / `Videos` / `Music`，并允许在设置中添加任意自定义文件夹。

---

## 📝 说明

- 扫描递归深度上限见 `AppConstants.maxScanDepth`，以防超大目录树造成卡顿
- 崩溃日志写入应用支持目录的 `crash_log.txt`，便于排查问题
- 歌词支持内嵌（ID3/FLAC）和外置 `.lrc` 文件，翻译文件按 `.zh.lrc` / `.translation.lrc` 等优先级查找

---

<div align="center">

Made with Flutter ❤

</div>
