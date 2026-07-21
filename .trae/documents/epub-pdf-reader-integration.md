# EPUB/PDF 阅读器集成计划

## Summary

在不新增底部导航项、不改变现有图片、视频、音乐、浏览和我的五个入口语义的前提下，将 EPUB/PDF 纳入现有 `MediaType` 数据流，采用“浏览”页顶部类型切换策略展示图书书架；从“我的”页增加独立“图书设置”入口；扫描结果继续受通用设置中的扫描文件夹控制，并将阅读进度、书签和封面缓存写入独立 Drift 表。

一期目标平台为 Windows、Android、iOS、macOS、Linux。阅读器组件采用：

- `epub_view` `3.2.0`：纯 Flutter EPUB 渲染，支持 Windows、Android、iOS、macOS、Linux 和 Web，GitHub：<https://github.com/ScerIO/packages.flutter/tree/main/packages/epub_view>。
- `pdfx` `2.9.2`：基于 PDFium/原生渲染器的 PDF 文档和页面控件，支持 Windows、Android、iOS、macOS 和 Web，GitHub：<https://github.com/ScerIO/packages.flutter/tree/main/packages/pdfx>。

## Current State Analysis

- 底部导航在 `lib/features/home/home_screen.dart` 中固定为五页，使用 `PageView` 和 `NavigationBar`；不应新增第六项，以免破坏现有索引、页面缓存和用户习惯。
- “浏览”页为 `lib/features/folders/folders_screen.dart`，当前按文件夹/相册/日期分组展示媒体卡片；适合增加顶层类型切换，并在图书类型下切换到书架视图。
- `MediaType` 目前只有 `image`、`video`、`audio`；`MediaItem.fromPath` 和 `MediaScannerService` 已集中处理扩展名识别，新增 `book` 类型可让 EPUB/PDF 自动进入现有扫描、数据库和刷新链路。
- `MediaNotifier` 已监听 `settingsProvider.scanFolders`，首次扫描、后台增量刷新和文件夹 watcher 均使用同一批扫描目录；图书不应创建独立扫描目录配置。
- `MediaItems` 已保存路径、文件名、类型、修改时间、缩略图等通用字段；阅读进度、CFI、页码和书签属于图书特有状态，应新增独立表，避免污染通用媒体模型。
- 设置入口在 `lib/features/settings/settings_screen.dart`，具体设置分类在 `settings_category_screen.dart`；通用扫描文件夹已经通过 `FilePicker` 配置并触发媒体重新扫描。
- Drift 数据库当前 schema version 为 5，生成文件由 `build_runner` 维护；新增表后需要升级到 version 6 并重新生成 `app_database.g.dart`。
- 当前项目使用 Riverpod、Drift、`file_picker`、`path_provider` 和 Material 组件，可沿用现有 Provider、服务和命令式 `MaterialPageRoute` 模式，不引入新的路由框架。

## Proposed Changes

### 1. 依赖与平台准备

修改 `pubspec.yaml`：

- 增加 `epub_view: ^3.2.0`。
- 增加 `pdfx: ^2.9.2`。
- 复用现有 `path`、`path_provider`、`file_picker`、`drift` 和 `flutter_riverpod`。
- 执行依赖解析，检查当前 Dart/Flutter SDK 与两个组件的兼容性。

Windows 构建中为 `pdfx` 执行其 Windows 安装步骤，按组件要求确认 `windows/CMakeLists.txt` 中的 PDFium 版本配置；不修改第三方插件缓存文件。

### 2. 扩展统一媒体模型和扫描

修改 `lib/models/media_type.dart`：

- 新增 `MediaType.book`。
- 增加图书轮廓图标和填充图标。

修改 `lib/models/media_item.dart`：

- 将 `epub`、`pdf` 纳入扩展名识别并映射到 `MediaType.book`。
- 保留 `extension`，供阅读器选择 EPUB 或 PDF 实现。
- 保持现有 JSON 序列化兼容；新增 enum 后读取旧媒体记录不改变既有行为。

修改 `lib/services/media_scanner_service.dart`：

- 让 Dart 扫描和 Rust 扫描都识别 EPUB/PDF。
- 图书扫描只记录通用文件信息，不在扫描主流程中解析完整正文。
- 在扫描或首次书架展示阶段调用图书元数据/封面服务：EPUB 解析内置标题、作者、封面资源；PDF 渲染第一页作为封面。
- 封面写入应用缓存目录，缓存 key 使用规范化路径、文件大小和修改时间，避免文件变化后读取旧封面。
- 保证封面提取失败不阻断扫描，书架使用格式化占位封面。
- 保持当前 `scanFolders`、增量 hash 和 folder watcher 逻辑；扫描目录中的 EPUB/PDF 自动随普通媒体一起进入数据库。

如 Rust 扫描器暂不支持图书扩展名，先由 Dart fallback 或在扫描结果中补充图书文件，不能让 Rust 路径静默漏掉 EPUB/PDF。

新增 `lib/services/book_metadata_service.dart`，负责：

- 根据扩展名提取 EPUB/PDF 标题、作者、页数/章节等书架元数据。
- 计算和读取封面缓存路径。
- 控制按需、有限并发的封面生成，避免大批 PDF 首次打开时阻塞 UI。

### 3. 新增图书阅读数据表

修改 `lib/services/database/app_database.dart`：

- 新增 `BookReadingStates` 表，主键为 `mediaPath`，字段包含 `mediaPath`、`format`、`title`、`author`、`coverPath`、`progress`、`epubCfi`、`pdfPage`、`updatedAt`。
- 新增 `BookBookmarks` 表，主键为 `mediaPath + locator`，字段包含 `mediaPath`、`locator`、`title`、`excerpt`、`createdAt`。
- 将 schema version 从 5 升到 6，并在升级逻辑中创建新表；不删除或重写现有媒体数据。
- 增加按路径读取/写入阅读状态、按路径读取/新增/删除书签的方法。
- 为书架查询提供只读图书列表和最近阅读排序能力，优先从 `MediaItems` 获取文件，再左连接图书阅读状态。

重新生成 `lib/services/database/app_database.g.dart`，禁止手工编辑生成文件。

### 4. 图书 Provider 和扫描结果整合

新增 `lib/providers/book_provider.dart`：

- 从 `mediaProvider` 筛选 `MediaType.book`，并结合数据库阅读状态生成书架卡片数据。
- 监听通用扫描文件夹和 `mediaProvider` 刷新结果，文件夹改变后自动更新书架。
- 提供最近阅读、全部图书和当前图书阅读状态查询。
- 提供保存 EPUB CFI/PDF 页码、保存进度、添加/删除书签的方法。

新增必要的图书模型文件，例如 `lib/models/book_reading_state.dart` 和 `lib/models/book_bookmark.dart`，保持模型与 Drift DAO 解耦。

### 5. 浏览页顶部类型切换与实体书架

修改 `lib/features/folders/folders_screen.dart`：

- 在原有分组选择器上方或同一顶部控制区加入媒体类型切换，保留原有文件夹/相册/日期功能。
- 选择“图书”时不改变底部导航，只在当前“浏览”页切换到书架内容；选择其他类型时继续使用现有 `_FolderCard` 和 `FolderDetailScreen`。
- 图书模式使用独立 `BookShelfView`，避免将书架布局硬塞入普通文件夹卡片。

新增 `lib/features/books/book_shelf_view.dart`：

- 使用响应式网格展示实体书架风格卡片：封面比例、底部书脊/书名、作者、阅读进度和格式徽标。
- 优先展示缓存封面；未生成时使用 EPUB/PDF 区分的静态占位封面。
- 支持搜索/排序入口时复用现有媒体筛选思路，不改变全局媒体排序设置的既有含义。
- 点击卡片进入 `BookReaderScreen`；长按或更多菜单提供继续阅读、收藏/移除书签等操作。
- 采用 `GridView.builder`、`RepaintBoundary` 和缓存图片，避免书架大批量重绘。

### 6. 阅读器页面和统一打开分发

新增 `lib/features/books/book_reader_screen.dart`：

- 根据 `MediaItem.extension` 选择 EPUB 或 PDF 阅读器。
- EPUB 使用 `EpubController`/`EpubView`，监听章节变化和 CFI 定位，保存 `epubCfi` 与归一化进度。
- PDF 使用 `PdfController`/`PdfView` 或适配 Windows 的 PDF 控件，监听页码并保存 `pdfPage` 与进度。
- 使用统一顶部工具栏提供目录/页码、书签、设置和返回；阅读内容区不与底部导航并列，进入阅读器后使用全屏次级页面。
- 阅读器销毁、切换书籍或页面变化节流时保存状态，避免每个滚动事件写数据库。
- 书签 locator 对 EPUB 使用 CFI，对 PDF 使用页码字符串，统一展示为书签列表。
- 对损坏文件、密码/解析失败、缺失封面和组件平台不支持提供可恢复错误页。

修改 `lib/features/media/media_type_screen.dart` 的统一打开逻辑：

- `MediaType.book` 分支跳转到 `BookReaderScreen`。
- 现有图片、视频、音频分支保持原实现不变。

### 7. 我的页面图书设置

修改 `lib/features/settings/settings_screen.dart`：

- 增加“图书设置”菜单项，使用 `Icons.menu_book_outlined`，打开独立 `BookSettingsScreen`。

新增 `lib/features/settings/book_settings_screen.dart`：

- 阅读主题：浅色、深色、护眼/羊皮纸等 EPUB/PDF 阅读器主题映射。
- 字体大小：使用离散 Slider 或 SegmentedButton，保存到设置服务。
- 页面布局：滚动模式/分页模式，按组件能力分别映射；PDF 只显示可用布局选项。
- 设置变更后立即持久化，重新打开阅读器时恢复。

修改 `lib/providers/settings_provider.dart` 与 `lib/services/settings_service.dart`：

- 新增图书主题、字体大小和页面布局枚举/字段、读取默认值和 setter。
- 使用 `SharedPreferences` 持久化，保持旧版本缺失 key 时使用默认值。

### 8. 交互与兼容约束

- 不新增第六个底部导航项。
- 不改变现有五个底部页面的名称、顺序和媒体功能。
- “浏览 → 图书”是图书主入口；“我的 → 图书设置”只负责偏好，不承载书架列表。
- 通用扫描文件夹为空时沿用当前默认目录策略；配置目录后 EPUB/PDF 自动加入统一媒体扫描结果。
- EPUB/PDF 的扫描、封面生成和元数据解析均不能阻塞首屏显示；优先展示已有数据库数据和占位封面。
- 在 Windows、Android、iOS、macOS、Linux 分别检查文件路径、PDFium/原生 PDF 依赖、EPUB 本地文件加载和权限差异。

## Assumptions & Decisions

- 已确定采用现有 `MediaType` 新增 `book`，而不是独立 Book 扫描模型。
- 已确定使用“浏览”页顶部类型切换，不扩展底部导航。
- 已确定阅读进度和书签持久化，采用独立 Drift 表。
- 已确定一期目标为 Windows + 移动端，macOS/Linux 作为当前组件支持范围一并保持可编译。
- 已确定图书封面提取后写入缓存，后续优先读取缓存；提取失败使用占位图。
- 已确定图书设置一期只包含阅读主题、字体大小、页面布局；自动保存进度属于功能行为，不作为可关闭设置；阅读方向暂不开放独立配置。
- `epub_view` 和 `pdfx` 的版本以调研时最新稳定版本为基线，但实际落地前需执行 `flutter pub outdated` 并确认与项目 Flutter/Dart SDK 的解析结果。
- 不在本次范围内实现 DRM、在线书城、云同步、全文搜索、批注和跨设备同步。

## Verification

1. 执行 `flutter pub get` 和 `flutter pub outdated`，确认 `epub_view`、`pdfx` 与现有依赖无冲突。
2. 执行 `dart run build_runner build --delete-conflicting-outputs`，确认 Drift 生成代码成功。
3. 执行 `flutter analyze`，确认新增 MediaType、Provider、数据库迁移和平台依赖无诊断错误。
4. 使用临时测试目录放置 EPUB、PDF、图片、视频和音频，验证扫描文件夹变更后五类资源均正确进入数据库且删除/重命名同步正常。
5. 验证书架封面优先读取缓存；首次生成失败、文件修改后缓存失效、重复刷新不会生成重复任务。
6. 验证 EPUB 打开、章节跳转、CFI 恢复、PDF 打开、页码恢复、书签新增/删除和进度写入。
7. 验证图书设置的主题、字号、布局在关闭并重新打开阅读器后保持；图片、视频、音乐现有设置不受影响。
8. 在 Windows、Android、iOS、macOS、Linux 分别执行对应构建或静态检查；Windows 重点验证 PDFium 安装步骤和 release 构建。
9. 使用 Flutter DevTools 检查书架首屏、封面生成和阅读器翻页期间的 UI/Raster 帧耗时，确保扫描和封面解析不在 UI 线程集中执行。
