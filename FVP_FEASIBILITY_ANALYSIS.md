# FVP 在 LumiLuna 项目的可行性分析

> 评估对象：[`fvp`](https://pub.dev/packages/fvp) 包（基于 libmdk，为官方 `video_player` 提供全平台桌面/移动后端）
> 评估日期：2026-07-18
> 当前引擎：`media_kit` ^1.1.11 / `media_kit_video` ^1.2.5（基于 libmpv）

---

## 一、结论速览

| 维度 | 结论 |
|---|---|
| 纯技术可行性（能跑起来） | ✅ 可行 — FVP 支持 Windows + Android，兼容 Flutter 3.19+ |
| 本项目实际迁移可行性 | ⚠️ **低** — 架构冲突大，改造成本高 |
| 推荐度 | ❌ **不建议整体替换**；可考虑"仅视频侧试点"作为实验 |
| 建议路径 | 维持 media_kit；除非出现明确的性能瓶颈或新需求（如杜比视界、录屏、快进快退优化） |

---

## 二、FVP 是什么

`fvp` 是为官方 `video_player` 包提供全平台后端的插件，底层是 **libmdk**（非 libmpv）。核心特性：

- 全平台：Windows x64/arm64（含 Win7）、Linux、macOS、iOS、Android
- 硬件解码默认开启（Windows 用 D3D11，Apple 用 Metal，Linux/Android 用 OpenGL/Impeller）
- 官方宣称 CPU/GPU/内存负载低于 libmpv 方案
- 每架构仅增加约 10MB
- 支持字幕（libass）、杜比视界、HEVC/VP8/VP9 透明视频
- 两种 API：
  1. **官方 video_player 兼容层** — `fvp.registerWith()` 后即可用 `VideoPlayerController`
  2. **mdk 后端 API**（`package:fvp/mdk.dart`）— 更底层，功能更丰富（snapshot / record / fastSeekTo / setExternalSubtitle），但需自行封装

> 注意：自 Flutter 3.27 起，`fvp` 必须作为直接依赖。本项目要求 Flutter ≥ 3.19，若升到 3.27+ 需注意此约束。

---

## 三、与现有架构的冲突（核心问题）

LumiLuna 的播放器架构有一个关键设计：**音视频共享同一个 `media_kit.Player` 实例**，这是 `CLAUDE.md` 明确写下的架构目标（"音视频共享同一个 media_kit 播放器，可无缝切换"）。

`PlaybackController`（`lib/providers/player_provider.dart`）深度依赖 media_kit 的 API：

| media_kit API（当前使用） | 用途 | FVP 是否有对应 |
|---|---|---|
| `player.stream.playing/position/duration/volume/completed` | 状态流订阅 | ⚠️ video_player 用 `controller.addListener` 轮询，非干净 Stream；mdk 后端有事件但 API 不同 |
| `player.stream.playlist` | 播放列表变化监听 | ❌ video_player 无播放列表概念 |
| `Playlist` + `player.open(Playlist(...))` | 整列表加载 + 起始索引 | ❌ 需自行维护列表 + 单文件 `setMedia` |
| `PlaylistMode.loop/none` + `setPlaylistMode` | 循环/顺序模式 | ❌ 需在 `completed` 事件里手动实现 |
| `player.next()` / `player.previous()` / `player.jump(i)` | 列表导航 | ❌ 需自行实现索引管理 |
| `VideoController(player)` + `Video` 组件 + `AdaptiveVideoControls` | 视频渲染 + 内置控件 | ❌ video_player **无控件组件**，需引入 `chewie` 或自建 |
| `player.setVolume` / `setRate` | 音量/倍速 | ✅ 支持 |

**shuffle 逻辑**（`player_provider.dart` 第 138-144 行）尤其依赖 media_kit 的语义：强制 `PlaylistMode.none` 让 `completed` 事件触发，再随机 `jump`。FVP 没有等价机制，必须完整重写。

---

## 四、迁移方案对比

### 方案 A：FVP 仅替换视频，media_kit 保留做音频

| 项 | 评估 |
|---|---|
| 可行性 | ⚠️ 技术可行，但代价大 |
| 二进制体积 | libmpv + libmdk 双后端并存，Windows 包体增加约 10MB+ |
| 架构破坏 | ❌ 失去"单一共享播放器"——视频走 FVP，音频走 media_kit，两者状态无法统一 |
| `PlaybackController` | 需拆成两个控制器，播放列表/续播逻辑分叉 |
| `flutter_lyric` 集成 | `music_player_screen.dart:1106` 直接订阅 `pc.player.stream.position`，音频侧不受影响，但若未来视频也想挂歌词则要适配 |
| 控件 | 视频侧需自建或引入 `chewie`，丢失 `AdaptiveVideoControls` |
| 收益 | 仅视频侧获得 D3D11 直渲、杜比视界、更低负载 |

**结论**：得不偿失。双后端的复杂度 > 单点性能收益。

### 方案 B：FVP 完全替换 media_kit（用 mdk 后端 API）

| 项 | 评估 |
|---|---|
| 可行性 | ⚠️ 技术可行，工作量大 |
| 改造范围 | 重写 `PlaybackController` 全部（~290 行）、`VideoPlayerScreen`、`MusicPlayerScreen` 的播放器交互、歌词位置订阅 |
| 播放列表 | ❌ 无内置 PlaylistMode → 需手动实现顺序/循环/随机 + `completed` 监听 + `setMedia` 切换 |
| 控件 | ❌ 无内置 → 自建视频控件（播放/暂停/进度/全屏/音量） |
| 音频播放 | ⚠️ FVP 声称"支持纯音频"，但 video_player API 视频向；mdk 后端可用但需验证音频流稳定性 |
| 收益 | 单一后端、体积更小（~10MB vs libmpv）、D3D11 直渲、mdk 高级 API（snapshot/record/fastSeekTo） |

**结论**：技术上能做，但相当于"重写播放器层"。除非有强需求驱动，否则 ROI 偏低。

### 方案 C（推荐）：维持 media_kit，仅在出现明确痛点时局部引入 FVP

维持现状。仅当以下场景出现时再评估 FVP：
- media_kit 在某些视频编码（如杜比视界、特定 HEVC 10bit）上解码异常
- Windows 上 CPU/内存占用成为用户投诉主因
- 需要 mdk 独有的能力（视频截图、录制、精确快进）

---

## 五、FVP 相对 media_kit 的真实优劣

| 维度 | media_kit（现状） | FVP | 对本项目影响 |
|---|---|---|---|
| Windows 视频渲染 | OpenGL（经 ANGLE） | D3D11 直渲 | FVP 略优，但 media_kit 实测足够流畅 |
| 硬件解码 | ✅ | ✅（默认开启，宣称更优） | 差异不大 |
| 包体积 | libmpv 较大 | ~10MB/架构 | FVP 更小，但本项目已含 libmpv |
| 播放列表 API | ✅ 一流支持 | ❌ 无 | media_kit 完胜，本项目重度依赖 |
| 内置视频控件 | ✅ `Video` + `AdaptiveVideoControls` | ❌ 无 | media_kit 完胜 |
| 纯音频 | ✅ 一流 | ⚠️ 可用但非主战场 | media_kit 更稳 |
| 字幕 | ✅ libass | ✅ libass | 持平 |
| 高级 API（截图/录制） | ⚠️ 需走底层 | ✅ mdk 暴露 | FVP 优，但本项目当前不需要 |
| 生态成熟度 | 高（pub 评分高，社区活跃） | 高（持续更新至 2025.12） | 持平 |
| Win7 兼容 | 一般 | ✅ 明确支持 | 本项目目标 Win10+，不构成优势 |

---

## 六、若坚持迁移，需改动的文件清单

```
lib/main.dart                         # MediaKit.ensureInitialized() → fvp.registerWith()
lib/providers/player_provider.dart    # 整体重写 PlaybackController（最大改动）
lib/features/player/video_player_screen.dart  # 替换 Video 组件 + 自建控件
lib/features/player/music_player_screen.dart  # 位置流订阅方式重写（第 1106 行）
pubspec.yaml                          # 增 fvp，可能移除 media_kit*
windows/CMakeLists.txt                # 插件注册由 generated_plugins.cmake 自动处理，基本无需手改
```

预估工作量：`PlaybackController` 重写 + 控件自建 + 音频验证，**约 2-4 个完整工作日**，且需充分回归测试（播放列表续播、shuffle、歌词同步、Android 端兼容）。

---

## 七、最终建议

1. **维持 media_kit**。它在本项目的集成度高、API 契合度好，是当前架构的合理选择。
2. 若你引入 FVP 的动机是某个**具体痛点**（例如某类视频解码失败、内存高、想要截图功能），请把痛点告诉我，我可以针对性评估是否有比"换引擎"更轻量的解法（如 media_kit 的 `PlayerConfiguration` 调参、`fc_native_video_thumbnail` 替换等）。
3. 若确实想试水 FVP，建议**新建一个分支**做方案 B 的最小可用原型（仅视频、固定单文件、无播放列表），先验证 D3D11 渲染和目标视频格式的兼容性，再决定是否推进。

---

## 八、补充：halo_videoplayer 与 VLC-based 方案评估

### 8.1 halo_videoplayer

**基本信息**
- 当前版本：`0.0.3`（仅 3 个版本，集中在 4 个月前发布后停滞）
- 发布者：**未验证**（unverified uploader）
- 周下载量：38；likes：2；pub points：145
- 平台：Android / iOS / macOS / Windows / Linux / Web

**架构**
- Android/iOS/macOS/Web → 直接复用官方 `video_player`
- Windows → Windows Media Foundation（WMF）原生实现
- Linux → GStreamer

**对本项目的问题**
| 问题 | 严重程度 | 说明 |
|---|---|---|
| 极不成熟 | ❌ 致命 | 0.0.x 版本、未验证发布者、38 周下载、4 个月无更新——生产风险极高 |
| Windows 用 WMF | ❌ 严重 | WMF 原生不支持 MKV 容器、FLAC-in-video、HEVC 需装扩展、AV1 需 Win11+——比 libmpv/ffmpeg 是明显降级 |
| 无播放列表 API | ❌ 严重 | 同 FVP，单文件 `HaloVideoPlayerController`，需自建播放列表逻辑 |
| 无内置控件 | ❌ 严重 | 示例代码全靠手搓 Slider/IconButton |
| 仅视频 | ⚠️ 中等 | 文档未提音频播放，无法替代 media_kit 的音频职责 |
| 架构冲突 | ❌ 同 FVP | 与"单一共享播放器"设计冲突 |

**结论**：✗ 不推荐。即使忽略成熟度问题，WMF 的格式覆盖对媒体库应用是硬伤——用户 MKV/HEVC 视频会大量播放失败。

### 8.2 flutter_vlc_player（VLC-based）

**基本信息**
- 当前版本：`7.4.4`（2025-09）
- 发布者：solid.software（已验证，知名）
- 周下载量：5.6k；likes：547；2019 年起维护
- 许可证：BSD-3-Clause
- 平台：**仅 Android + iOS**

**优点**
- VLC 引擎，格式覆盖最全（几乎能放任何东西）
- 支持多播放器同屏、录制、Chromecast、音轨/字幕轨切换
- 成熟、社区大、发布者可靠

**致命问题**
| 问题 | 严重程度 | 说明 |
|---|---|---|
| ❌ **不支持 Windows 桌面** | 致命 | 仅 Android + iOS。LumiLuna 的**主力平台是 Windows**（见 CLAUDE.md / README），直接出局 |
| 无播放列表 API | 严重 | 同样需要自建 |
| 控件基础 | 中等 | 有 `VlcPlayer` 组件但控件简陋，不如 media_kit 的 `AdaptiveVideoControls` |
| 366 个 open issues | 中等 | 维护跟得上但历史包袱重 |
| 录制功能在 iOS/Android 有已知 bug | 轻微 | 本项目不需要录制 |

**关于 Windows VLC 的补充**：历史上曾有 `dart_vlc` 提供 Windows 桌面的 VLC 支持，但该项目**已归档/停止维护**，不推荐使用。`flutter_vlc_player` 本身没有 Windows 后端计划。

**结论**：✗ 对本项目不可行。Windows 是主力平台，VLC 方案覆盖不到。

### 8.3 四款方案综合排序（针对 LumiLuna）

| 排名 | 方案 | 适配度 | 一句话 |
|---|---|---|---|
| 1 | **media_kit**（现状） | ★★★★★ | 唯一同时满足 Windows+Android+音频+播放列表+控件 |
| 2 | fvp | ★★☆☆☆ | 技术可行但需重写播放器层，ROI 偏低 |
| 3 | halo_videoplayer | ★☆☆☆☆ | 不成熟 + WMF 格式受限 |
| 4 | flutter_vlc_player | ✗ | 不支持 Windows，直接出局 |

**最终建议**：维持 media_kit。如果未来确实要换引擎，**fvp 是四款中唯一值得做技术验证的选项**（方案 B），其余两款不应纳入考虑。
