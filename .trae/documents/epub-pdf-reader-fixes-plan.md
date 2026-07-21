# EPUB/PDF 阅读问题修复计划

## Summary

修复 EPUB 因 Windows 反斜杠 manifest 路径导致的打开失败，补齐 EPUB 与 PDF 的封面提取和书架展示，并修正上下翻页模式下左右区域点击不生效的问题。保持现有“浏览”页面、`BookShelfView`、`BookReaderScreen`、Riverpod 设置和 Drift 数据库结构不变，优先复用现有 `epub_pro`、`pdfx` 与 `MediaItem.thumbnailPath`。

## Current State Analysis

- [book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart) 使用 `EpubReader.readBook` 直接读取原始 EPUB 字节；异常路径 `Text\\Volume_0.xhtml` 表明包内 manifest 使用了反斜杠，而 EPUB 规范要求 ZIP/manifest 路径使用 `/`，`epub_pro` 未将其规范化。
- EPUB 当前只设置 `_epubBook`、章节和滚动状态，没有处理封面资源；[book_metadata_service.dart](file:///c:/blog/media_library/lib/services/book_metadata_service.dart) 返回 `coverPath` 字段但实际没有提取封面。
- PDF 阅读器创建了 `PdfController`，但没有渲染第一页为缓存图片，也没有把封面路径写入媒体记录。
- [book_shelf_view.dart](file:///c:/blog/media_library/lib/features/books/book_shelf_view.dart) 只显示占位图标和扩展名，不读取 `thumbnailPath`，因此即使存在缓存路径也不会显示封面。
- [book_reader_input.dart](file:///c:/blog/media_library/lib/features/books/book_reader_input.dart) 将 `GestureDetector` 直接包在阅读内容外层；PDF/滚动视图可能参与手势竞争。上下模式虽然计算了纵向区域，但点击事件不稳定，且区域高度使用包含 AppBar 的 `MediaQuery` 尺寸。
- [app_database.dart](file:///c:/blog/media_library/lib/services/database/app_database.dart) 已有 `thumbnailPath` 字段和同步逻辑；书籍封面写入应保留已有缓存，避免扫描时用空值覆盖。

## Proposed Changes

### 1. EPUB 路径兼容与解析

Files:

- [lib/services/book_metadata_service.dart](file:///c:/blog/media_library/lib/services/book_metadata_service.dart)
- [lib/features/books/book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart)

Changes:

- 在传给 `epub_pro` 前增加 EPUB 包路径修复层：读取 ZIP entry 名称、manifest/spine 相关 href 和资源引用时统一将 `\\` 转为 `/`，重新生成内存字节；不改变原始文件。
- 保留 `epub_pro` 作为 EPUB 解析器，不使用 `dependency_overrides`，并对无法修复的损坏包返回可理解的错误状态。
- 把同一套规范化读取逻辑用于元数据、封面和正文，避免书架能读而阅读页不能读的分裂行为。
- 增加真实异常样本测试，覆盖 `Text\\Volume_0.xhtml`、正常 `/Text/Volume_0.xhtml`、中文文件名和嵌套目录。

### 2. EPUB/PDF 封面提取、缓存与展示

Files:

- [lib/services/book_metadata_service.dart](file:///c:/blog/media_library/lib/services/book_metadata_service.dart)
- [lib/features/books/book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart)
- [lib/features/books/book_shelf_view.dart](file:///c:/blog/media_library/lib/features/books/book_shelf_view.dart)
- [lib/services/database/app_database.dart](file:///c:/blog/media_library/lib/services/database/app_database.dart)
- 如需独立职责，新增 `lib/services/book_cover_service.dart`

Changes:

- EPUB：使用 `epub_pro` 的 metadata/manifest/cover 资源定位能力读取封面，解码后写入应用支持目录中的稳定缓存路径；若无声明封面，按常见 cover image fallback 查找。
- PDF：打开文档后渲染第一页缩略图并写入同一缓存目录；对无效 PDF、渲染失败或权限错误使用占位图，不阻断阅读。
- 通过文件路径、大小和修改时间生成缓存键；文件变更时生成新缓存，旧缓存不影响书架。
- 仅在缓存文件存在且可读取时向书架提供路径；数据库同步时保留已有非空 `thumbnailPath`，避免异步封面任务完成前覆盖有效封面。
- 书架卡片优先使用 `Image.file` 显示封面，加载失败回退到现有图标占位；继续保留 EPUB/PDF 扩展名和书名信息。
- 封面提取采用后台/异步更新，首次扫描先显示占位，完成后通过 `mediaProvider` 从数据库重新加载，避免阻塞扫描和首屏。

### 3. 上下翻页点击与鼠标交互

Files:

- [lib/features/books/book_reader_input.dart](file:///c:/blog/media_library/lib/features/books/book_reader_input.dart)
- [lib/features/books/book_reader_screen.dart](file:///c:/blog/media_library/lib/features/books/book_reader_screen.dart)

Changes:

- 使用 `LayoutBuilder`/`Positioned.fill` 获取阅读区域实际尺寸，不再用包含 AppBar 的全局 `MediaQuery` 高度判断点击区域。
- 将透明点击层放在 PDF/EPUB 内容之上，确保上下模式的上半区/下半区点击稳定分发到上一屏/下一屏，同时保留内容自身的滚动和文本交互边界。
- 横向模式继续使用左半区/右半区；纵向模式使用上半区/下半区；点击中心区域不触发翻页时保留默认阅读交互。
- 鼠标滚轮统一根据滚动方向转换为上一屏/下一屏，触屏拖拽继续由 `PdfView` 或 EPUB `ScrollController` 处理；不改变已有设置持久化。
- EPUB 的 `_previous`/`_next` 根据当前 `BookLayout` 和 `BookPageMode` 计算屏幕步长；PDF 继续交给 `PdfController`，确保两种方向切换后点击、滚轮和已有翻页动作一致。

### 4. 数据流与状态安全

Files:

- [lib/providers/media_provider.dart](file:///c:/blog/media_library/lib/providers/media_provider.dart)
- [lib/services/database/app_database.dart](file:///c:/blog/media_library/lib/services/database/app_database.dart)

Changes:

- 封面更新使用按路径的数据库更新接口，不触发删除或全量替换；阅读页面退出只写 `BookReadingState`，不修改或删除 `MediaItems`。
- 扫描过程中封面提取失败只记录空封面/占位结果，不将图书从书架移除。
- 完成封面异步任务后只刷新数据库中的目标图书，避免把暂时不完整的扫描结果当作删除列表。

## Assumptions & Decisions

- 继续支持 Windows、Android、iOS；不引入依赖 `WebView` 的 EPUB 阅读器。
- `epub_pro` 继续作为 EPUB 解析器；路径兼容通过输入包修复解决，不修改第三方缓存目录。
- 书架封面统一使用 `MediaItem.thumbnailPath`，不新增第二套封面字段，除非当前 pdfx/epub_pro API 验证表明必须保留原始资源路径。
- PDF 封面定义为第一页缩略图；EPUB 封面优先使用 OPF 声明的 cover image，找不到时才使用命名 fallback。
- 不改变底部导航和既有页面结构；只更新书籍卡片、阅读输入层和已有图书服务。

## Verification

### Static and build checks

1. 执行 `dart format` 处理涉及文件。
2. 执行 `dart run build_runner build --delete-conflicting-outputs`，确认 Drift 生成代码一致。
3. 执行 `flutter analyze`，重点确认 `epub_pro`、`pdfx`、Pointer event 和数据库更新 API 无诊断。
4. 执行 `flutter test`；若项目没有现成 EPUB 测试资源，使用临时测试 fixture，不提交无关样本。
5. 执行 `flutter build windows --release` 和 Android release 构建，分别验证 CMake/PDFium 与 Dart 编译链。

### EPUB compatibility cases

- 正常 EPUB 2/3：打开、显示书名/章节/正文、返回书架后仍存在。
- manifest 使用反斜杠的 EPUB：自动修复并打开 `Text\\Volume_0.xhtml`。
- 缺失 manifest 目标、损坏 ZIP、无封面 EPUB：显示明确错误或占位封面，不删除书架记录。
- 中文文件名、嵌套目录、图片封面和无图片封面。
- 阅读 EPUB 后返回书架、刷新、重启应用，确认媒体记录、封面路径和阅读进度均保持。

### Cover cases

- PDF 第一页为普通页面、图片页、透明/异常页面。
- EPUB 有声明封面、只有命名封面、没有封面。
- 缓存命中、缓存失效、文件修改后重新生成。
- 封面加载失败时卡片回退占位，阅读和扫描不受影响。

### Interaction cases

- 左右模式：鼠标点击左右半区、滚轮、触屏手势均可翻页。
- 上下模式：鼠标点击上半区/下半区、滚轮、触屏滚动均可上一屏/下一屏。
- 切换模式后立即阅读，退出重进和重启后设置保持。
- EPUB 和 PDF 分别验证第一页/最后一页边界，不越界、不抛异常。
