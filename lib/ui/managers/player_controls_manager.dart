import 'dart:async';

class PlayerControlsManager {
  PlayerControlsManager({
    required this.onControlsVisibilityChanged,
    required this.onLockChanged,
    required this.onFullscreenChanged,
    required this.setFullscreen,
    required this.getFullscreen,
    required this.isAlive,
  });

  final void Function(bool visible) onControlsVisibilityChanged;
  final void Function(bool locked) onLockChanged;
  final void Function(bool fullscreen) onFullscreenChanged;

  final Future<void> Function(bool fullscreen) setFullscreen;
  final Future<bool> Function() getFullscreen;
  final bool Function() isAlive;

  Timer? _hideTimer;

  bool _isLocked = false;
  bool _showControls = true;
  bool _isFullscreen = false;

  bool get isLocked => _isLocked;
  bool get showControls => _showControls;
  bool get isFullscreen => _isFullscreen;

  void startControlsHideTimer() {
    _hideTimer?.cancel();

    if (!_isLocked) return;

    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!isAlive() || !_isLocked) return;

      _showControls = false;
      onControlsVisibilityChanged(_showControls);
    });
  }

  Future<void> toggleFullscreen() async {
    final shouldEnterFullscreen = !_isFullscreen;

    await setFullscreen(shouldEnterFullscreen);
    final actualFullscreen = await getFullscreen();

    if (!isAlive()) return;

    _isFullscreen = actualFullscreen;
    onFullscreenChanged(_isFullscreen);
  }

  void toggleLock() {
    _isLocked = !_isLocked;
    _showControls = !_isLocked;

    onLockChanged(_isLocked);
    onControlsVisibilityChanged(_showControls);

    _hideTimer?.cancel();
  }

  void showControlsAndRestartTimer() {
    if (!_isLocked) return;

    if (!_showControls) {
      _showControls = true;
      onControlsVisibilityChanged(true);
    }

    startControlsHideTimer();
  }

  void dispose() {
    _hideTimer?.cancel();
  }
}
