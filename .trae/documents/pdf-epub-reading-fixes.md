# PDF/EPUB 阅读问题分析与实施计划

## Summary

修复 PDF 阅读后返回书架导致图书永久消失的问题，确保 EPUB 经过同样的进入、阅读、返回、刷新和重启流程后仍然存在；同时为 PDF 和 EPUB 增加统一的鼠标点击/滚轮交互，并新增可持久化的左右/上下翻页模式设置。保持现有五个底部导航、扫描文件夹入口、`MediaType.book`、书架入口和 `epub_pro`/`pdfx` 依赖不变。

## Current State Analysis

- [media_provider.dart](file:///c:/blog/media_library/lib/providers/media_provider.dart) 启动时先从 Drift `mediaItems` 加载，再异步扫描并调用 `syncMediaItems`；扫描异常会被 `_performRefresh` 静默吞掉，用户看不到失败原因。
- [app_database.dart](file:///c:/blog/media_library/lib/services/database/app_database.dart) 的 `syncMediaItems` 会按扫描目录计算 `stale`，将扫描结果中不存在的文件从 `mediaItems` 删除；这在扫描结果为空、扫描权限暂时失败、路径格式不一致或扫描器漏识别 PDF/EPUB 时会永久删除记录。
- `removeMediaItems` 目前只删除媒体表及播放/收藏关联，没有证明文件确实被删除或扫描结果完整；这正是“阅读返回后消失且重启无法恢复”的主要数据丢失路径。
- `BookReadingStates` 与 `BookBookmarks` 已存在，但阅读页 [book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart) 没有读取/写入 PDF 页码、百分比或 EPUB 位置；阅读器控制器也未绑定进度监听。
- PDF 当前直接使用 `PdfView(controller: ...)`，没有鼠标点击区域、鼠标滚轮策略、拖动/分页模式适配或桌面焦点处理。
- EPUB 当前用 `ListView.builder` 展示全部章节纯文本，未使用 `bookLayout`；天然可滚轮，但没有左右分页模式、点击翻页和阅读位置保存。
- 图书设置已有 `bookTheme`、`bookFontSize`、`bookLayout`，但缺少独立 `BookPageMode`，因此无法持久化左右/上下翻页偏好。
- 当前项目目标包括 Windows、Android、iOS；鼠标行为只在桌面/有鼠标设备时启用，触屏滑动和原有滚动行为必须保留。

## Root Cause Analysis

### 图书消失

1. 阅读页返回时本身没有删除媒体记录；消失发生在返回后书架重建、watcher 触发或异步 `_refreshIndex` 完成时。
2. `syncMediaItems` 把“当前扫描结果为空”解释为“扫描目录内所有文件都已消失”，从而将 PDF/EPUB 行标记为 stale 并删除。
3. 扫描器异常、权限暂时不可用、路径大小写/分隔符不一致、Rust/Dart 扫描路径漏掉图书扩展名，都会制造不完整结果。
4. 阅读状态表不能保护 `MediaItems` 行；即使进度仍在 `BookReadingStates`，书架只筛选 `mediaProvider` 的媒体列表，媒体行删除后仍不可见。
5. `mediaProvider` 先返回数据库数据再异步刷新，异步刷新失败被吞掉，导致用户无法区分“暂时扫描失败”和“文件真的被删除”。

### EPUB 风险

EPUB 与 PDF 使用同一 `MediaType.book` 和同一同步链路，因此不会因为格式不同而天然安全；只要扩展名识别、扫描结果完整性或路径归一化出现问题，EPUB 同样会被 stale 清理。修复应放在通用同步层，并分别验证两种扩展名。

## Proposed Changes

### 1. 保护扫描数据

修改 [app_database.dart](file:///c:/blog/media_library/lib/services/database/app_database.dart)：

- 将 `syncMediaItems` 增加 `scanCompleted`、`scanError` 或等价扫描完整性参数。
- 只有扫描任务明确完成、目标目录可访问、结果不是异常空结果时，才允许计算并删除 stale 记录。
- 空结果、权限异常、解析异常、Rust fallback 失败时只保留现有记录并返回错误状态，不删除 `MediaItems`。
- 删除 stale 前逐个确认文件不存在；文件存在但未出现在结果中时保留记录。
- 删除媒体记录时同步清理对应的书签/阅读状态只在文件确认不存在且用户配置允许清理时执行；默认先保留阅读状态，便于文件恢复后继续阅读。
- 对路径使用统一 `_normalizePath`，同时修复扫描结果和数据库查询的大小写/分隔符比较。

修改 [media_scanner_service.dart](file:///c:/blog/media_library/lib/services/media_scanner_service.dart) 和 Rust 扫描适配层：

- 返回扫描完成标志、可访问目录集合、发现文件数和错误信息，而不是只返回列表。
- PDF/EPUB 扩展名识别失败或元数据解析失败只影响对应文件，不使全量扫描结果被当作空结果。
- 读取目录失败时标记扫描不完整，禁止数据库清理。

修改 [media_provider.dart](file:///c:/blog/media_library/lib/providers/media_provider.dart)：

- `_performRefresh` 只有在扫描完整成功时调用 stale 同步。
- 扫描失败时保持现有 state，不使用空列表覆盖书架。
- 暴露刷新错误/扫描状态，刷新控件显示“扫描失败，已保留现有图书”。
- 避免阅读页返回瞬间启动并发刷新覆盖状态；使用已有 `_refreshTask`，并在任务完成后从数据库重新加载。

### 2. 阅读状态与恢复

修改 [book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart)：

- 初始化时按 `mediaPath` 读取 `BookReadingStates`。
- PDF 使用保存的 `pdfPage` 初始化 `PdfController`; 监听页码变化并计算 `progress = page / pageCount`。
- 页面变化采用节流写入，并在 `dispose`/返回前执行最终保存。
- EPUB 保存章节索引和章节内百分比；如果 `epub_pro` 暴露 CFI，则同时保存 CFI，否则使用章节索引 + 百分比的兼容定位结构。
- 书架卡片读取阅读状态显示进度，媒体记录与阅读状态分离，返回后不因页面销毁丢失。
- 将 PDF/EPUB 阅读器的初始化、监听、保存封装为同一 `BookReadingStateService`，避免两种格式分别遗漏保存。

### 3. EPUB 兼容性回归

保留 `epub_pro` 作为解析器，新增测试夹具和解析接口：

- EPUB 2 中文小说：验证标题、作者、章节、中文编码。
- EPUB 3 小说：验证导航、Spine、图片和章节顺序。
- EPUB 漫画：验证内置图片资源和大图片章节不会导致媒体行删除。
- 缺少封面/不完整 NCX 的 EPUB：验证能进入阅读页或显示错误，但不会从书架消失。
- 扫描文件夹同时包含 PDF、EPUB、图片、音频和视频，验证同步只删除确认不存在的文件。

### 4. 鼠标交互

新增 [book_reader_input.dart](file:///c:/blog/media_library/lib/features/books/book_reader_input.dart)：

- 使用 `Listener`/`MouseRegion` 识别鼠标滚轮，不依赖触屏手势。
- 左右模式：点击内容区左/右半区调用上一页/下一页；滚轮按 viewport 高度滚动或翻页。
- 上下模式：滚轮执行固定比例/视口高度滚动；点击上半区/下半区执行上一屏/下一屏。
- 保留触屏 `GestureDetector` 的滑动和点击，鼠标事件与触屏事件不重复触发。
- 桌面显示可用鼠标指针和 hover 区域反馈；移动端不显示额外鼠标提示。
- PDF 模式通过 `PdfController.nextPage/previousPage` 或滚动位置控制；EPUB 模式通过 `ScrollController` 或章节分页控制。

### 5. 翻页模式设置

修改 [settings_provider.dart](file:///c:/blog/media_library/lib/providers/settings_provider.dart)：

- 新增 `BookPageMode { horizontal, vertical }`。
- 在 `AppSettings` 增加 `bookPageMode`，默认 `horizontal`，通过 `copyWith`、初始化读取和 setter 完整传递。

修改 [settings_service.dart](file:///c:/blog/media_library/lib/services/settings_service.dart) 和 [app_constants.dart](file:///c:/blog/media_library/lib/core/constants/app_constants.dart)：

- 新增 `prefBookPageMode` key。
- 使用 `SharedPreferences` 保存/读取模式；旧版本缺少 key 时回退左右模式。

修改 [book_settings_screen.dart](file:///c:/blog/media_library/lib/features/settings/book_settings_screen.dart)：

- 增加“翻页模式”设置项：左右翻页、上下翻页。
- 设置更新后立即保存，并在打开的阅读器通过 Riverpod 监听即时切换。
- 页面布局与翻页模式保持语义清晰：分页布局控制页内排版，翻页模式控制导航方向；不再用 `BookLayout` 代替两者。

### 6. 书架稳定性

修改 [book_shelf_view.dart](file:///c:/blog/media_library/lib/features/books/book_shelf_view.dart)：

- 使用 `MediaType.book` 枚举筛选，不使用字符串 `item.type.name == 'book'`。
- 返回阅读器后从数据库重新读取或监听 `mediaProvider`，不依赖已销毁页面内存对象。
- 使用阅读状态显示进度，封面/占位图加载失败不删除媒体记录。
- 当扫描失败时保留已有书架并显示非破坏性错误提示。

## Implementation Order

1. 先修复扫描完整性和 stale 删除保护，确保 PDF/EPUB 数据不再被误删；验证数据库同步单元测试。
2. 接入 PDF 页码/百分比保存恢复，再接入 EPUB 章节/百分比保存恢复；验证返回和重启流程。
3. 新增 `BookPageMode` 设置并完成 SharedPreferences 持久化。
4. 实现统一鼠标输入层，接入 PDF 和 EPUB 两条阅读路径。
5. 实现左右/上下模式切换、阅读器即时应用和书架进度展示。
6. 添加 EPUB/PDF 回归夹具与跨平台静态分析/构建验证。

## Testing Plan

### 数据不丢失

- 扫描目录包含 PDF，打开阅读器，翻页，返回书架；图书仍存在。
- 关闭并重新启动应用；图书仍存在。
- 返回后手动刷新；图书仍存在。
- 阅读期间模拟扫描返回空列表；数据库记录不删除，书架保持原内容。
- 模拟目录无权限/扫描异常；state 保持旧数据，显示错误而非空书架。
- 真正删除磁盘文件并完成成功扫描；对应媒体记录按策略删除，其他图书不受影响。
- 修改文件名、大小写或路径分隔符；不产生重复或误删。

### EPUB 回归

- EPUB 2、EPUB 3、漫画 EPUB、缺封面 EPUB 分别执行打开、翻页、返回、刷新、重启。
- 验证 EPUB 不会因为解析失败、封面失败或章节为空从 `MediaItems` 删除。
- 验证 PDF 与 EPUB 同时存在时互不覆盖阅读状态和书架记录。

### 输入与模式

- 触屏左右滑动和鼠标左右区域点击均可翻页。
- 鼠标滚轮在左右模式与上下模式分别执行预期动作。
- 上下模式点击上/下区域可切换屏幕，PDF 和 EPUB 均有效。
- 设置翻页模式后立即进入/留在阅读器，方向生效；关闭重启后仍保持。
- 在阅读中切换模式，不重置当前页码、章节和进度。
- 无鼠标设备的 Android/iOS 仍保持触摸操作和正常构建。

### Build and quality

- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- Android `flutter build apk --release --split-per-abi --android-skip-build-dependency-validation`
- Windows `flutter build windows --release`，保留 `CMAKE_POLICY_VERSION_MINIMUM=3.5`。
- 检查数据库迁移 version 6 和新增字段/表的旧数据库升级路径。

## Assumptions & Decisions

- PDF 和 EPUB 都支持左右/上下两种模式。
- PDF 保存页码和百分比；EPUB 保存章节索引和章节百分比，优先保存 CFI。
- 扫描异常或不完整结果保护已有数据库记录；只有确认文件不存在且扫描完整时才清理。
- 鼠标第一期支持左右区域点击和滚轮，不增加拖拽模拟。
- 不新增底部导航项，不改变现有扫描文件夹配置入口。
- 当前报告/计划阶段不修改业务代码，执行阶段再按本计划实施。
