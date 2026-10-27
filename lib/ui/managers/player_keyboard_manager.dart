import 'package:flutter/services.dart';

class PlayerKeyboardManager {
  PlayerKeyboardManager({
    required this.onTogglePlayback,
    required this.onSeekTo,
    required this.onToggleFullscreen,
    required this.onToggleMute,
    required this.getPositionSeconds,
    required this.getDurationSeconds,
    required this.isFullscreen,
  });

  final Future<void> Function() onTogglePlayback;
  final Future<void> Function(double seconds) onSeekTo;
  final Future<void> Function() onToggleFullscreen;
  final Future<void> Function() onToggleMute;

  final double Function() getPositionSeconds;
  final double Function() getDurationSeconds;
  final bool Function() isFullscreen;

  void handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final position = getPositionSeconds();
    final duration = getDurationSeconds();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.keyK:
        onTogglePlayback();
        break;

      case LogicalKeyboardKey.arrowLeft:
        onSeekTo((position - 10).clamp(0.0, duration).toDouble());
        break;

      case LogicalKeyboardKey.arrowRight:
        onSeekTo((position + 10).clamp(0.0, duration).toDouble());
        break;

      case LogicalKeyboardKey.keyJ:
        onSeekTo((position - 5).clamp(0.0, duration).toDouble());
        break;

      case LogicalKeyboardKey.keyL:
        onSeekTo((position + 5).clamp(0.0, duration).toDouble());
        break;

      case LogicalKeyboardKey.keyF:
        onToggleFullscreen();
        break;

      case LogicalKeyboardKey.keyM:
        onToggleMute();
        break;

      case LogicalKeyboardKey.escape:
        if (isFullscreen()) {
          onToggleFullscreen();
        }
        break;

      default:
        return;
    }
  }
}
