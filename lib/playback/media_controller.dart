import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaController {
  late final Player _player;
  late final VideoController videoController;

  MediaController() {
    _player = Player();
    videoController = VideoController(_player);
  }

  Future<void> openFile(String path) async {
    await _player.open(Media(path));
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> togglePlayPause() async {
    if (_player.state.playing) {
      await pause();
    } else {
      await play();
    }
  }
  Future<void> setVolume(double volume) async {
  final safeVolume = volume.clamp(0.0, 100.0).toDouble();
  await _player.setVolume(safeVolume);
}

Future<void> mute() async {
  await _player.setVolume(0.0);
}

double get volume => _player.state.volume;

  bool get isPlaying => _player.state.playing;

  Stream<Duration> get positionStream => _player.stream.position;

  Stream<Duration> get durationStream => _player.stream.duration;

  Future<void> dispose() async {
    await _player.dispose();
  }
}