import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';

/// Wraps the app in a [Focus] node that intercepts the ESC key and turns it
/// into a "go back" action, mirroring the behaviour of the on-screen back
/// button / chevron.
///
/// Behaviour:
/// - When a route can be popped (sub-page, dialog, bottom sheet, player
///   screen, …), ESC pops exactly one level — identical to tapping the back
///   button, so any [PopScope] / `onPopInvokedWithResult` callbacks (e.g. the
///   video player's pause-on-exit) run as expected and state stays in sync.
/// - When already at the root route, a short "already at the top level" hint
///   is shown (debounced so it never spams).
///
/// Priority / conflict handling:
/// The [Focus] sits at the very top of the focus tree (installed via
/// `MaterialApp.builder`). Key events bubble from the primary focus node *up*
/// to this ancestor only when no descendant handled them. Therefore any
/// widget that wants to override ESC for a local action (e.g. closing the
/// search bar, dismissing a lyrics overlay) can wrap itself in its own
/// [Focus] whose `onKeyEvent` returns [KeyEventResult.handled] — the event
/// never reaches this scope. Returning [KeyEventResult.ignored] lets ESC fall
/// through to this global handler, which is the desired default.
///
/// Only the physical ESC key is intercepted; all other keys are passed
/// through untouched, so existing shortcuts (Space / ← / → in the music
/// player, text editing, etc.) are unaffected.
class EscBackScope extends StatefulWidget {
  final Widget child;

  const EscBackScope({super.key, required this.child});

  @override
  State<EscBackScope> createState() => _EscBackScopeState();
}

class _EscBackScopeState extends State<EscBackScope> {
  final FocusNode _focusNode = FocusNode();

  /// Timestamp of the last "already at top level" hint, used to debounce the
  /// SnackBar so a user leaning on the ESC key does not get a flood of
  /// toasts.
  DateTime? _lastHintAt;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // Only react to the initial key-down (ignore repeats and key-up) so a
    // single ESC press equals a single back action.
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }

    // FocusNode.context is nullable (the node may have been detached between
    // the key press landing and us reading it here).
    final ctx = node.context;
    if (ctx == null) return KeyEventResult.ignored;

    final navigator = Navigator.of(ctx, rootNavigator: true);
    if (!navigator.canPop()) {
      _maybeShowTopLevelHint(ctx);
      return KeyEventResult.handled;
    }
    // maybePop respects PopScope / WillPopScope and route-level guards, so
    // the back behaviour is identical to clicking the back button — state
    // saving and data sync hooks (e.g. the video player's pause-on-exit)
    // fire exactly once per ESC press.
    navigator.maybePop();
    return KeyEventResult.handled;
  }

  void _maybeShowTopLevelHint(BuildContext context) {
    final now = DateTime.now();
    if (_lastHintAt != null &&
        now.difference(_lastHintAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastHintAt = now;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_hintText(context)),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _hintText(BuildContext context) {
    // Look up the localized string via the generated AppLocalizations, which
    // is mounted above this widget by MaterialApp. Fall back gracefully if
    // (e.g. during very early startup) localizations are not yet available.
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return l10n?.alreadyAtTopLevel ?? '已是最顶层';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      // `descendantsAreFocusable` stays true so text fields, buttons and the
      // music player's own shortcut Focus all keep working. We only intercept
      // ESC; every other key returns `ignored` and propagates normally.
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }
}
