import 'dart:typed_data';
import 'package:device_volume/device_volume.dart';

import '../playback/thumbnail_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../files/video_file_picker.dart';
import '../playback/media_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final MediaController _controller;
  final VideoFilePicker _filePicker = VideoFilePicker();
  Timer? _volumeSyncTimer;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isOpening = false;
  bool _isPlaying = false;
  bool _isSeeking = false;
  double _volume = 100.0;
double _previousVolume = 100.0;

  String? _errorMessage;
  String? _fileName;
  final ThumbnailService _thumbnailService = ThumbnailService();

final Map<int, Uint8List> _thumbnailCache = {};
final Set<int> _loadingThumbnailBuckets = {};

bool _isHoveringTimeline = false;
double _previewX = 0;
Duration _previewTime = Duration.zero;
Uint8List? _previewImage;
String _currentVideoPath = '';
StreamSubscription<VolumeState>? _systemVolumeSubscription;
int _systemVolume = 100;
Future<void> _initSystemVolume() async {
  try {
    final state = await DeviceVolume.getVolume();

    if (!mounted) return;

    // Initialize both volume controls to the Windows volume.
    setState(() {
      _systemVolume = state.value;
      _volume = state.value.toDouble();

      if (_volume > 0) {
        _previousVolume = _volume;
      }
    });

    await _controller.setVolume(state.value.toDouble());

    _systemVolumeSubscription = DeviceVolume.streamVolume().listen(
      (state) {
        debugPrint('Windows volume event: ${state.value}%');
        if (!mounted) return;

        setState(() {
          _systemVolume = state.value;
          _volume = state.value.toDouble();

          if (_volume > 0) {
            _previousVolume = _volume;
          }
        });

        // Apply the Windows volume-key change to video playback too.
        _controller.setVolume(state.value.toDouble()).catchError(
          (Object error) {
            debugPrint('Could not sync player volume: $error');
          },
        );
      },
      onError: (Object error, StackTrace stackTrace) {
  debugPrint('Volume listener error: $error');
  debugPrintStack(stackTrace: stackTrace);
},
    );
  } catch (error) {
    debugPrint('Could not initialize system volume: $error');
  }
}


void _startVolumeSync() {
  _volumeSyncTimer?.cancel();

  _volumeSyncTimer = Timer.periodic(
    const Duration(milliseconds: 500),
    (_) async {
      try {
        final state = await DeviceVolume.getVolume();

        if (!mounted) return;

        final windowsVolume = state.value.toDouble();
        final windowsMuted = state.isMuted;

        if (windowsVolume.round() != _systemVolume ||
            windowsMuted != (_volume == 0)) {
          setState(() {
            _systemVolume = windowsVolume.round();

            if (windowsMuted) {
              if (_volume > 0) {
                _previousVolume = _volume;
              }
              _volume = 0;
            } else {
              _volume = windowsVolume;

              if (_volume > 0) {
                _previousVolume = _volume;
              }
            }
          });

          await _controller.setVolume(
            windowsMuted ? 0 : windowsVolume,
          );
        }
      } catch (error) {
        debugPrint('Volume sync error: $error');
      }
    },
  );
}

  @override
  void initState() {
    super.initState();

    _controller = MediaController();
    _initSystemVolume();
    _startVolumeSync();


    _positionSubscription = _controller.positionStream.listen((position) {
      if (!mounted) return;

      if (!_isSeeking) {
        setState(() {
          _position = position;
        });
      }
    });

    _durationSubscription = _controller.durationStream.listen((duration) {
      if (!mounted) return;

      setState(() {
        _duration = duration;
      });
    });
  }

  Future<void> _openVideo() async {
    try {
      final path = await _filePicker.pickVideo();

      if (path == null || !mounted) return;

      setState(() {
        _isOpening = true;
        _errorMessage = null;
        _fileName = path.split(RegExp(r'[/\\]')).last;
        _position = Duration.zero;
        _duration = Duration.zero;
        _currentVideoPath = path;
_thumbnailCache.clear();
_loadingThumbnailBuckets.clear();
_previewImage = null;
      });

      await _controller.openFile(path);

      if (!mounted) return;

      setState(() {
        _isOpening = false;
        _isPlaying = _controller.isPlaying;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isOpening = false;
        _errorMessage = 'Could not open video: $error';
      });
    }
  }

  Future<void> _togglePlayback() async {
    try {
      await _controller.togglePlayPause();

      if (!mounted) return;

      setState(() {
        _isPlaying = _controller.isPlaying;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Playback error: $error';
      });
    }
  }
Future<void> _changeVolume(double value) async {
  final safeVolume = value.clamp(0.0, 100.0).toDouble();

  setState(() {
    _volume = safeVolume;

    if (safeVolume > 0) {
      _previousVolume = safeVolume;
    }
  });

  try {
    // Set the video player's volume.
    await _controller.setVolume(safeVolume);

    // Set Windows system volume to the same percentage.
    final applied = await DeviceVolume.setVolume(safeVolume.round());

    if (!mounted) return;

    // Use the actual volume Windows applied.
    setState(() {
      _systemVolume = applied.value;
      _volume = applied.value.toDouble();

      if (_volume > 0) {
        _previousVolume = _volume;
      }
    });

    await _controller.setVolume(applied.value.toDouble());
  } catch (error) {
    debugPrint('Could not synchronize volume: $error');
  }
}

Future<void> _toggleMute() async {
  if (_volume > 0) {
    _previousVolume = _volume;
    await _changeVolume(0);
  } else {
    await _changeVolume(
      _previousVolume > 0 ? _previousVolume : 100,
    );
  }
}
  Future<void> _seekTo(double seconds) async {
    final target = Duration(milliseconds: (seconds * 1000).round());

    try {
      await _controller.seek(target);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not seek: $error';
      });
    }
  }
void _updateTimelinePreview(double dx, double width) {
  if (_duration.inMilliseconds <= 0 || width <= 0) return;

  final fraction = (dx / width).clamp(0.0, 1.0);
  final targetMs = (_duration.inMilliseconds * fraction).round();
  final target = Duration(milliseconds: targetMs);

  // Generate at most one preview per 3-second interval.
  final bucket = (target.inSeconds ~/ 3) * 3;

  setState(() {
    _isHoveringTimeline = true;
    _previewX = dx.clamp(0.0, width).toDouble();
    _previewTime = target;
    _previewImage = _thumbnailCache[bucket];
  });

  if (_thumbnailCache.containsKey(bucket) ||
      _loadingThumbnailBuckets.contains(bucket) ||
      _fileName == null) {
    return;
  }

  _loadingThumbnailBuckets.add(bucket);
  _loadThumbnail(bucket);
}

Future<void> _loadThumbnail(int seconds) async {
  try {
    final bytes = await _thumbnailService.generateThumbnail(
      videoPath: _currentVideoPath,
      position: Duration(seconds: seconds),
    );

    if (bytes == null) return;

    _thumbnailCache[seconds] = bytes;

    if (!mounted) return;

    final currentBucket = (_previewTime.inSeconds ~/ 3) * 3;

    if (_isHoveringTimeline && currentBucket == seconds) {
      setState(() {
        _previewImage = bytes;
      });
    }
  } finally {
    _loadingThumbnailBuckets.remove(seconds);
  }
}
  String _formatTime(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _controller.dispose();
    _systemVolumeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxSeconds = _duration.inMilliseconds / 1000.0;
   
    final canSeek = _fileName != null && maxSeconds > 0 && !_isOpening;

    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050505),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_fileName != null)
                        Video(
                          controller: _controller.videoController,
                          controls: NoVideoControls,
                          fit: BoxFit.contain,
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.movie_outlined,
                              size: 64,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nothing playing',
                              style: TextStyle(fontSize: 21),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Open a video file to get started',
                              style: TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      if (_isOpening)
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    final maxMs = _duration.inMilliseconds;
    final progress = maxMs > 0
        ? (_position.inMilliseconds / maxMs).clamp(0.0, 1.0)
        : 0.0;

    final previewLeft = (_previewX - 65.0)
    .clamp(0.0, (width - 130.0).clamp(0.0, double.infinity))
    .toDouble();

    return MouseRegion(
      onHover: (event) {
        _updateTimelinePreview(event.localPosition.dx, width);
      },
      onExit: (_) {
        setState(() {
          _isHoveringTimeline = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          if (canSeek) {
            final fraction =
                (details.localPosition.dx / width).clamp(0.0, 1.0);
            _seekTo(maxMs * fraction / 1000.0);
          }
        },
        onHorizontalDragStart: (details) {
          if (canSeek) {
            setState(() => _isSeeking = true);
          }
        },
        onHorizontalDragUpdate: (details) {
          if (!canSeek) return;

          final fraction =
              (details.localPosition.dx / width).clamp(0.0, 1.0);

          setState(() {
            _position = Duration(
              milliseconds: (maxMs * fraction).round(),
            );
          });

          _updateTimelinePreview(details.localPosition.dx, width);
        },
        onHorizontalDragEnd: (_) async {
          if (!canSeek) return;

          await _seekTo(_position.inMilliseconds / 1000.0);

          if (!mounted) return;
          setState(() => _isSeeking = false);
        },
        child: SizedBox(
          height: 90,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 39,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isHoveringTimeline && canSeek)
                Positioned(
                  left: previewLeft,
                  top: -48,
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 130,
                          height: 73,
                          decoration: BoxDecoration(
                            color: const Color(0xFF292929),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _previewImage != null
                              ? Image.memory(
                                  _previewImage!,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                )
                              : const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(_previewTime),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  },
),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            _formatTime(_position),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(_duration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  Row(
  children: [
    IconButton(
      onPressed: _fileName == null || _isOpening
          ? null
          : _togglePlayback,
      tooltip: _isPlaying ? 'Pause' : 'Play',
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        size: 30,
      ),
    ),
    const SizedBox(width: 8),

    Expanded(
      child: Text(
        _fileName ?? 'No video selected',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70),
      ),
    ),

    const SizedBox(width: 12),

    // Mute / unmute button
    IconButton(
      onPressed: _toggleMute,
      tooltip: _volume == 0 ? 'Unmute' : 'Mute',
      icon: Icon(
        _volume == 0
            ? Icons.volume_off
            : _volume < 50
                ? Icons.volume_down
                : Icons.volume_up,
      ),
    ),

    // Volume slider: 0% to 100%
    SizedBox(
      width: 140,
      child: Slider(
        min: 0,
        max: 100,
        divisions: 20,
        value: _volume,
        label: '${_volume.round()}%',
        onChanged: _changeVolume,
      ),
    ),

    SizedBox(
      width: 42,
      child: Text(
        '${_volume.round()}%',
        textAlign: TextAlign.end,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    ),
    

    const SizedBox(width: 12),

    FilledButton.icon(
      onPressed: _isOpening ? null : _openVideo,
      icon: const Icon(Icons.folder_open),
      label: const Text('Open Video'),
    ),
  ],
),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}