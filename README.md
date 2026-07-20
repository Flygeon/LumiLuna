<div align="center">

# LumiLuna

### 光影 · 媒体库

基于 Flutter 和 Material 3 构建的本地媒体库应用。

在一个简洁的界面中浏览、整理和播放图片、视频与音乐。

[![Build](https://github.com/Flygeon/LumiLuna/actions/workflows/build-windows.yml/badge.svg)](https://github.com/Flygeon/LumiLuna/actions/workflows/build-windows.yml)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-lightgrey)](#平台支持)

</div>

---

## 项目简介

LumiLuna 是一款面向 Windows 和 Android 的本地文件系统媒体库。应用通过扫描用户指定的本地目录建立媒体索引，不依赖云端相册或流媒体服务。

当前版本：`1.0.2`

项目重点包括：

- 使用本地文件夹管理图片、视频和音乐
- 通过 SQLite 保存媒体索引、标签、收藏与播放记录
- 为不同媒体类型提供独立且适配场景的查看与播放体验
- 使用 Material 3、明暗主题和响应式布局适配桌面与移动端

## 功能概览

### 浏览与搜索

- 后台 isolate 递归扫描本地文件夹并自动识别媒体类型
- 支持网格视图和列表视图
- 支持按文件夹、相册或日期分组
- 支持按文件名、标题、艺术家、专辑和文件夹路径搜索
- 支持按名称、修改时间、文件大小和时长排序
- 支持下拉刷新、重新扫描和加载失败重试
- Windows 支持将文件拖入应用导入，并跳过已存在的媒体

### 图片、视频与音乐

- 图片：分页浏览、全屏查看、捏合缩放和双击缩放
- 视频：播放/暂停、进度控制、全屏、上一项/下一项和 `0.5x`–`2.0x` 倍速
- 音乐：专辑封面、歌曲信息、进度拖动、播放列表、上一首/下一首、循环、随机和播放速度
- 视频和音乐使用 `media_kit` 播放；图片使用独立的图片查看器
- 音乐播放器在宽窗口下提供封面、控制区与歌词/队列布局，在窄窗口下提供适合移动端的分页交互

### 歌词

- 支持外部歌词加载和自定义 LRC 解析
- 支持歌词与播放进度同步滚动
- 支持点击歌词跳转到对应播放位置
- 支持原文、原文加翻译切换
- 支持当前行高亮、非当前行模糊和歌词字号调节

### 整理与管理

- 收藏媒体并在收藏页集中查看
- 创建和管理标签、分类组、收藏集与播放列表
- 支持播放历史，并按最近播放时间排序
- 支持多选和批量操作
- 支持将媒体移入 LumiLuna 回收站、恢复、永久删除和清空回收站

### 个性化设置

- 支持系统、浅色和深色主题
- 支持主题色选择；Android 支持动态取色
- 支持中文、英文和跟随系统语言
- 支持图片/视频布局密度、分组方式、排序方式和扫描目录设置
- 支持清理缓存、查看版本信息和第三方许可证
- 桌面端支持空格/媒体播放键、方向键等快捷操作

## 媒体扫描规则

应用默认扫描以下目录；也可以在设置中添加自定义目录：

- Android：`Pictures`、`DCIM`、`Movies`、`Music`
- Windows：用户目录下的 `Pictures`、`Videos`、`Music`
- 找不到默认目录时，应用会回退到应用文档目录

扫描规则如下：

- 递归深度上限为 8 层
- 跳过隐藏目录
- 文件扩展名识别不区分大小写
- 图片支持 `jpg`、`jpeg`、`png`、`gif`、`bmp`、`webp`、`heic`、`heif`、`tiff`、`tif`、`ico`
- 视频支持 `mp4`、`mkv`、`avi`、`mov`、`wmv`、`flv`、`webm`、`m4v`、`mpeg`、`mpg`、`ts`、`3gp`
- 音频支持 `mp3`、`flac`、`wav`、`aac`、`m4a`、`ogg`、`wma`、`opus`、`aiff`、`ape`

应用会读取音频标题、艺术家、专辑、时长和嵌入封面，并生成图片、视频和音频封面缓存，以减少重复处理和内存占用。数据库和应用缓存存放在系统分配的应用支持目录中。

## 数据与隐私

LumiLuna 的核心数据来源是本地文件系统：媒体文件不会因为被扫描而复制到应用目录，也不需要上传到云端。

- Drift + SQLite 保存媒体索引、标签、收藏集、播放列表、扫描目录和播放历史
- `shared_preferences` 保存主题、语言、视图、分组、排序和播放器界面偏好
- 应用支持目录保存数据库、缩略图/封面缓存和崩溃日志
- 删除媒体时，应用提供独立的回收站管理流程；永久删除前请确认文件是否仍需保留

## 平台支持

| 平台 | 状态 | 说明 |
| --- | --- | --- |
| Windows | ✅ 主力平台 | 支持桌面布局、拖放导入和键盘操作 |
| Android | ✅ 支持 | 支持移动端布局、本地媒体目录和触控交互 |
| macOS | ⚠️ 未验证 | 当前未作为已验证发布平台 |
| Linux | ⚠️ 未验证 | 当前未作为已验证发布平台 |
| Web | ❌ 不支持 | 依赖 `dart:io`、SQLite/FFI 和原生媒体能力 |

## 技术栈

| 领域 | 技术 |
| --- | --- |
| UI | Flutter、Material 3 |
| 状态管理 | `flutter_riverpod` |
| 音视频播放 | `media_kit`、`media_kit_video`、`media_kit_libs_video` |
| 本地扫描 | `dart:io`、`file_picker`、`watcher`、`desktop_drop` |
| 数据持久化 | Drift、SQLite、`sqlite3_flutter_libs`、`shared_preferences` |
| 视频缩略图 | `fc_native_video_thumbnail` |
| 音频元数据 | `audio_metadata_reader` |
| 歌词 | `flutter_lyric` 和项目自定义 LRC 解析器 |
| 国际化 | Flutter `gen-l10n`、ARB 资源 |

## 项目结构

```text
lib/
├── main.dart                 # 应用初始化、播放器和数据库初始化、异常处理
├── app.dart                  # Material 3 主题、语言和全局快捷键
├── core/                     # 常量、主题和格式化工具
├── models/                   # 媒体、文件夹、标签、收藏集、播放列表和歌词模型
├── services/                 # 扫描、数据库、设置、缓存、歌词、权限和回收站服务
├── providers/                # Riverpod 状态管理
├── features/                 # 启动、引导、主页、媒体、文件夹、播放器和设置页面
└── widgets/                 # 缩略图、网格/列表、多选操作栏和通用状态组件

test/
├── media_item_test.dart      # 媒体模型、筛选和播放器状态测试
├── category_database_test.dart # Drift 分类数据库测试
└── lyrics_parser_test.dart   # 歌词解析测试
```

## 本地开发

### 环境要求

- Flutter `>=3.19.0`，stable channel
- Dart `>=3.3.0 <4.0.0`
- Windows：安装 Visual Studio 的 C++ 桌面开发组件
- Android：安装 Android SDK，具体最低版本跟随 Flutter 工程配置

### 安装与运行

```bash
flutter pub get
flutter run -d windows
flutter run -d <device-id>
```

首次启动后，进入“设置 → 扫描文件夹”添加媒体目录；如果不添加，应用会尝试扫描平台默认目录。

### 代码检查与测试

```bash
flutter analyze
flutter test
flutter build windows --release
```

## CI 构建

工作流文件：`.github/workflows/build-windows.yml`

当前 GitHub Actions 会在推送到 `main`/`master`、创建 Pull Request 或手动触发时执行：

- 构建 Windows x64 release，并打包为 `lumiluna-windows-x64.zip`
- 构建 Android split-per-ABI release APK：`arm64-v8a`、`armeabi-v7a` 和 `x86_64`
- 上传 Windows 和 Android 构建产物，保留 30 天
- 执行 `flutter analyze`；当前分析步骤允许 warning 或 info 不阻断工作流

自动创建 GitHub Release 的 job 当前处于禁用状态，因此 README 不提供预编译安装包或 Release 可用性的承诺。若需要使用构建结果，请从对应 workflow 的 Artifacts 下载。

## 已知限制

- 应用只扫描配置的本地目录，不是系统级媒体索引
- Web 平台不支持
- macOS 和 Linux 尚未作为已验证平台
- 当前 CI 主要提供 Windows zip 和 Android APK 构建产物，不代表已有正式安装包
- 实际播放能力取决于 `media_kit` 及底层播放器对具体编码格式的支持
- Android release 构建目前使用工程配置中的签名设置，发布到应用商店前需要配置正式签名

## 许可证

当前仓库未包含根目录 `LICENSE` 文件，因此暂不声明具体开源许可证。使用或分发前，请先确认项目维护者提供的授权范围。

<div align="center">

Made with Flutter ❤

</div>
