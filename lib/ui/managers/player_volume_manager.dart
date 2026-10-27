import 'dart:async';

import 'package:device_volume/device_volume.dart';
import 'package:flutter/services.dart';

class PlayerVolumeManager {
  PlayerVolumeManager({
    required this.onVolumeChanged,
    required this.setPlayerVolume,
    required this.isAlive,
  });

  final void Function(double volume) onVolumeChanged;
  final Future<void> Function(double volume) setPlayerVolume;
  final bool Function() isAlive;

  static const MethodChannel _systemMuteChannel = MethodChannel(
    'video_player/system_mute',
  );

  Timer? _volumeSyncTimer;
  StreamSubscription<VolumeState>? _systemVolumeSubscription;

  double _volume = 100;
  double _previousVolume = 100;
  DateTime _lastUserVolumeChange = DateTime.fromMillisecondsSinceEpoch(0);

  double get volume => _volume;

  Future<void> initialize() async {
    try {
      final state = await DeviceVolume.getVolume();
      if (!isAlive()) return;

      _volume = state.isMuted ? 0 : state.value.toDouble();
      if (_volume > 0) _previousVolume = _volume;

      onVolumeChanged(_volume);
      await setPlayerVolume(_volume);

      _systemVolumeSubscription = DeviceVolume.streamVolume().listen(
        (state) {
          if (!isAlive()) return;

          if (state.isMuted) {
            if (_volume > 0) _previousVolume = _volume;
            _volume = 0;
          } else {
            _volume = state.value.toDouble();
            if (_volume > 0) _previousVolume = _volume;
          }

          onVolumeChanged(_volume);
          setPlayerVolume(_volume).catchError((Object error) {
            // A sync failure should not stop playback.
          });
        },
        onError: (Object error, StackTrace stackTrace) {
          // Polling below remains available if the stream fails.
        },
      );

      startSync();
    } catch (error) {
      // Keep playback available if volume initialization fails.
    }
  }

  void startSync() {
    _volumeSyncTimer?.cancel();

    _volumeSyncTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      if (!isAlive()) return;
      if (DateTime.now().difference(_lastUserVolumeChange) <
          const Duration(seconds: 1)) {
        return;
      }

      try {
        final state = await DeviceVolume.getVolume();
        if (!isAlive()) return;

        final newVolume = state.isMuted ? 0.0 : state.value.toDouble();
        if (newVolume == _volume) return;

        if (state.isMuted && _volume > 0) {
          _previousVolume = _volume;
        }

        _volume = newVolume;
        if (_volume > 0) _previousVolume = _volume;

        onVolumeChanged(_volume);
        await setPlayerVolume(_volume);
      } catch (error) {
        // Retry on the next tick.
      }
    });
  }

  Future<void> changeVolume(double value) async {
    _lastUserVolumeChange = DateTime.now();
    final safeVolume = value.clamp(0.0, 100.0).toDouble();

    _volume = safeVolume;
    if (_volume > 0) _previousVolume = _volume;
    onVolumeChanged(_volume);

    try {
      await setPlayerVolume(safeVolume);
      if (!isAlive()) return;

      final applied = await DeviceVolume.setVolume(safeVolume.round());
      if (!isAlive()) return;

      _volume = applied.value.toDouble();
      if (_volume > 0) _previousVolume = _volume;

      onVolumeChanged(_volume);
      await setPlayerVolume(_volume);
    } catch (error) {
      // Keep the current UI state if system volume cannot be changed.
    }
  }

  Future<void> toggleMute() async {
    _lastUserVolumeChange = DateTime.now();

    try {
      if (_volume > 0) {
        _previousVolume = _volume;

        await _systemMuteChannel.invokeMethod<void>('setMute', {'muted': true});

        await setPlayerVolume(0);
        if (!isAlive()) return;

        _volume = 0;
        onVolumeChanged(_volume);
      } else {
        final restoreVolume = _previousVolume > 0 ? _previousVolume : 100.0;

        await _systemMuteChannel.invokeMethod<void>('setMute', {
          'muted': false,
        });
        if (!isAlive()) return;

        await changeVolume(restoreVolume);
      }
    } catch (error) {
      // Leave the app running if the native mute call fails.
    }
  }

  void dispose() {
    _volumeSyncTimer?.cancel();
    _systemVolumeSubscription?.cancel();
  }
}
