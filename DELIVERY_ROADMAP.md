# LumiLuna 可交付 / 上线路线图

> 目标：把当前可用的 Demo（Windows 桌面媒体库）推进为**可分发、可上线**的产品。
> 现状（已具备）：媒体浏览（网格/列表）、集合播放（图片/视频/音乐）、按文件夹/搜索管理、Material 3 + 深浅主题、`flutter build windows` 的 GitHub Actions 流水线、思源黑体打包。
> 本文档按里程碑拆分，每项标注**改动文件**与**验收标准**，供评审后逐条实现。

---

## 0. 先拍板的三个决策

| 决策 | 选项 A（推荐） | 选项 B | 影响 |
|---|---|---|---|
| **`windows/` 目录是否入库** | 提交 `windows/` 并定制图标/版本 | CI 里 `flutter create` 后用脚本注入 | 决定图标、版本信息、RC 资源的落点 |
| **代码签名证书** | 正规 CA 证书（如 DigiCert/免费型） | 自签名（仍会被 SmartScreen 拦截） | 决定用户双击是否报"未知发布者" |
| **分发渠道** | GitHub Releases（开源友好） | Microsoft Store(MSIX) / 官网直链 | 决定打包格式（Inno Setup vs MSIX） |

> 建议：提交 `windows/` + 正规 CA 签名 + GitHub Releases（Inno Setup 安装包）。

---

## M0 — 上线硬门槛（P0，阻塞发布）

### M0.1 应用图标
- **改动文件**：`windows/runner/resources/app_icon.ico`（1024×1024 转多尺寸 ico）；如提交 `windows/`，同步 `windows/runner/Runner.rc` 里的图标与版本资源。
- **验收**：任务栏、资源管理器、安装包、关于框均显示 LumiLuna 图标；无 Flutter 默认蓝标。

### M0.2 安装包 + 代码签名
- **改动文件**：
  - `packaging/windows/installer.iss`（Inno Setup 脚本：输出 `LumiLuna-Setup-x.y.z.exe`、写开始菜单/卸载项）。
  - `.github/workflows/build-windows.yml` 增加步骤：构建 Release → `signtool sign`（`secrets` 注入 pfx + 密码）→ 跑 Inno 生成安装包 → 上传 artifact。
- **验收**：产出一个**已签名**的安装包；在干净 Win10/11 虚拟机双击安装，无 SmartScreen 拦截（需正规证书）。

### M0.3 LICENSE
- **改动文件**：仓库根 `LICENSE`（MIT 或你选定的协议）。
- **验收**：`README` 顶部标注协议；仓库可见许可证文件。

### M0.4 全局错误兜底
- **改动文件**：
  - `lib/main.dart`：用 `runZonedGuarded` 包裹 `runApp`，并设置 `ErrorWidget.builder` 全局兜底页。
  - `lib/widgets/async_view.dart`：补 `onError` 文案与"重试"按钮（当前仅有 loading/empty）。
  - `lib/features/player/*`：播放失败（解码/文件缺失）显示错误态而非黑屏。
  - `lib/services/media_scanner_service.dart`：捕获权限/坏文件异常，返回带错误信息的状态而非抛崩溃。
- **验收**：扫描一个含损坏文件的文件夹不崩溃；断网/缺权限时给出可读提示并可重试。

---

## M1 — 产品完善（P1，用户会直接对比的功能）

### M1.1 音频元数据（封面/标题/艺术家/专辑）
- **新增依赖**：`metadata_god`（Windows 支持，可读取封面与标签）。
- **改动文件**：`lib/models/media_item.dart`（加 `title/artist/album/coverPath` 字段）、`media_scanner_service.dart`（扫描时解析）、`lib/features/player/music_player_screen.dart`（展示封面与信息）、`lib/widgets/media_thumbnail.dart`（音频用封面图替代占位）。
- **验收**：音乐网格显示封面；播放页显示歌名/歌手/专辑；无元数据时回退占位。

### M1.2 文件管理操作（删除 + 收藏）
- **新增文件**：`lib/services/media_manager_service.dart`（删除、移动、收藏）。
- **改动文件**：`media_item.dart` 加 `isFavorite`；`settings_service.dart` 或独立 JSON 存收藏集；`media_grid_view.dart`/`media_list_view.dart` 加长按选择/多选模式与操作菜单；`media_type_screen.dart` 接入。
- **验收**：可多选删除（带二次确认）、可收藏并在"收藏"筛选中查看；删除后列表实时刷新。

### M1.3 国际化（i18n）
- **新增文件**：`l10n.yaml`、`lib/l10n/*.arb`（先中/英）。
- **改动文件**：`pubspec.yaml` 加 `flutter_localizations` + `intl`；全量替换硬编码中文字符串为 `AppLocalizations.of(context)`；`MaterialApp` 配 `localizationsDelegates`/`supportedLocales`。
- **验收**：跟随系统语言切换；英文环境下无残留中文（除用户媒体文件名）。

### M1.4 设置实用项
- **改动文件**：`lib/features/settings/settings_screen.dart` 增加：缩略图缓存清理（删 `lumiluna_thumbs/`）、关于页入口。
- **新增文件**：`lib/features/settings/about_screen.dart`（版本号来自 `package_info_plus`、第三方许可证清单、LICENSE 链接）。
- **验收**：点"清理缓存"后缩略图目录清空且下次进入重新生成；关于页显示版本与许可证。

### M1.5 规模化性能
- **改动文件**：
  - `lib/main.dart`：设 `PaintingBinding.instance.imageCache.maximumSizeBytes`（按内存档位，如 200MB）。
  - `media_scanner_service.dart`：扫描结果持久化到应用支持目录的索引文件（JSON/简易 DB），启动时增量更新而非全量重扫。
  - `media_thumbnail.dart`：缩略图磁盘缓存加上限/过期清理策略。
- **验收**：10000+ 文件库冷启动 < 数秒（命中缓存）；长时间使用内存不持续增长。

### M1.6 桌面体验
- **改动文件**：`lib/features/home/home_screen.dart` 加键盘快捷键（Ctrl+1~4 切 tab、Space 播放/暂停、Delete 删除）；各可交互控件补 `semanticsLabel`。
- **验收**：纯键盘可完成主要操作；屏幕阅读器可朗读控件用途。

---

## M2 — 工程化与可持续（P2）

### M2.1 单元测试
- **新增文件**：`test/media_scanner_service_test.dart`、`test/providers_test.dart`、`test/format_utils_test.dart`、`test/media_item_test.dart`。
- **验收**：`flutter test` 全绿；核心扫描/过滤/格式化逻辑有覆盖。

### M2.2 CI 增强
- **改动文件**：`.github/workflows/build-windows.yml` 增加：`flutter test` 步骤 → Release 构建 → 签名 → Inno 打包 → **仅当 push tag（`v*`）时**创建 GitHub Release 并上传安装包。
- **验收**：推 `v1.0.0` tag 自动产出带签名的 Release 安装包；普通 push 跑测试+构建不发布。

### M2.3 文档
- **新增文件**：`CHANGELOG.md`、`CONTRIBUTING.md`；`README.md` 补架构图、截图、构建/运行说明、本路线图链接。
- **验收**：新贡献者按 README 可本地跑起来；CHANGELOG 记录版本变更。

---

## M3 — 增强（可选，按需求再定）

- 自动更新（如 `sparkle`/自研更新检查）。
- 系统托盘 + 最小化到托盘、单实例启动。
- 相册自动聚类（按拍摄时间/地点，需 EXIF 解析）。
- 视频播放记忆进度、音乐均衡器。

---

## 实施建议顺序
1. 先定 **第 0 节三个决策**（尤其签名证书来源，决定 M0.2 能否真消除 SmartScreen 警告）。
2. 顺序：`M0（硬门槛）` → `M1.1~M1.4（核心功能）` → `M2（工程化）` → `M1.5/M1.6/M3（打磨）`。
3. 每完成一个里程碑跑一次 `flutter analyze` + `flutter test`，并手动在干净 Windows 虚拟机验收。
