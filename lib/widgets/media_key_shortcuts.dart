import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';

/// 在应用根层捕获 Space / mediaPlayPause 键并切换播放/暂停。
///
/// 装在 [MaterialApp.builder]（与 [EscBackScope] 同层），覆盖整棵焦点树。
/// 当任何持有主焦点的控件未消费 Space（TextField、Material 按钮等会先消费）
/// 时，事件冒泡至此处理 — 这与 [EscBackScope] 处理 ESC 的模式对称。
///
/// 行为：
///  - 仅桌面平台（Windows/macOS/Linux）启用，与原 `_PlayerKeyboardShortcuts`
///    的 `_isDesktop` 判定保持一致；移动 / Web 仍保持默认 Space 行为。
///  - 无当前曲目（`state.current == null`）时忽略，避免空播放器误触。
///  - 仅响应 `KeyDownEvent`，忽略 key repeat 与 key-up，避免长按连发。
///  - 同时支持物理媒体键 `mediaPlayPause`（部分键盘有此独立按键）。
///
/// 设计说明：
///  - `autofocus: false`：不抢焦点，TextField / 按钮等仍可正常获得焦点。
///  - `descendantsAreFocusable: true`（默认）：后代仍可聚焦，不影响子树。
///  - 不需要处理 `EscBackScope` 关系 — 后者对非 ESC 一律返回 `ignored`，
///    Space 事件会自然冒泡穿过它到本作用域。
class MediaKeyShortcuts extends ConsumerStatefulWidget {
  final Widget child;

  const MediaKeyShortcuts({super.key, required this.child});

  @override
  ConsumerState<MediaKeyShortcuts> createState() => _MediaKeyShortcutsState();
}

class _MediaKeyShortcutsState extends ConsumerState<MediaKeyShortcuts> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 与原 `_PlayerKeyboardShortcuts._isDesktop` 判定保持一致。
  static bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // 仅响应初始按下，忽略 repeat 与 key-up。
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // 仅处理 Space 与物理媒体键。
    if (event.logicalKey != LogicalKeyboardKey.space &&
        event.logicalKey != LogicalKeyboardKey.mediaPlayPause) {
      return KeyEventResult.ignored;
    }

    // 移动 / Web 平台不启用（保持默认 Space 行为，如滚动）。
    if (!_isDesktop) return KeyEventResult.ignored;

    // 无当前曲目时忽略 — 避免空播放器误触。
    final state = ref.read(playbackControllerProvider);
    if (state.current == null) return KeyEventResult.ignored;

    ref.read(playbackControllerProvider.notifier).playOrPause();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: false,
      // 后代仍可聚焦（默认 true）— TextField / 按钮 / 音乐播放器内的
      // CallbackShortcuts 都能正常工作。
      descendantsAreFocusable: true,
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }
}
