import 'dart:async';

import '../../files/video_file_picker.dart';
import '../../playback/media_controller.dart';

class PlayerStateManager {
  PlayerStateManager({
    required this._controller,
    required this._filePicker,
    required this.onChanged,
    required this.isAlive,
  });

  final MediaController _controller;
  final VideoFilePicker _filePicker;
  final void Function() onChanged;
  final bool Function() isAlive;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  bool isOpening = false;
  bool isPlaying = false;

  String? errorMessage;
  String? fileName;

  bool _isSeeking = false;

  void initialize() {
    _positionSubscription = _controller.positionStream.listen((value) {
      if (!isAlive()) return;

      if (!_isSeeking) {
        position = value;
        onChanged();
      }
    });

    _durationSubscription = _controller.durationStream.listen((value) {
      if (!isAlive()) return;

      duration = value;
      onChanged();
    });
  }

  void setSeeking(bool value) {
    _isSeeking = value;
  }

  void setPreviewPosition(Duration value) {
    position = value;
    onChanged();
  }

  Future<void> openVideo() async {
    try {
      final path = await _filePicker.pickVideo();

      if (path == null || !isAlive()) return;

      isOpening = true;
      errorMessage = null;
      fileName = path.split(RegExp(r'[/\\]')).last;
      position = Duration.zero;
      duration = Duration.zero;
      onChanged();

      await _controller.openFile(path);

      if (!isAlive()) return;

      isOpening = false;
      isPlaying = _controller.isPlaying;
      onChanged();
    } catch (error) {
      if (!isAlive()) return;

      isOpening = false;
      errorMessage = 'Could not open video: $error';
      onChanged();
    }
  }

  Future<void> togglePlayback() async {
    try {
      await _controller.togglePlayPause();

      if (!isAlive()) return;

      isPlaying = _controller.isPlaying;
      onChanged();
    } catch (error) {
      if (!isAlive()) return;

      errorMessage = 'Playback error: $error';
      onChanged();
    }
  }

  Future<void> seekTo(double seconds) async {
    final target = Duration(milliseconds: (seconds * 1000).round());

    try {
      await _controller.seek(target);
    } catch (error) {
      if (!isAlive()) return;

      errorMessage = 'Could not seek: $error';
      onChanged();
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
  }
}
