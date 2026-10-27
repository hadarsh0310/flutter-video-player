import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import 'managers/player_controls_manager.dart';
import 'managers/player_keyboard_manager.dart';
import 'managers/player_state_manager.dart';
import 'managers/player_volume_manager.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_menu_bar.dart';
import 'widgets/player_timeline.dart';

import '../files/video_file_picker.dart';
import '../playback/media_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();

  late final MediaController _controller;
  late final PlayerVolumeManager _volumeManager;
  late final PlayerKeyboardManager _keyboardManager;
  late final PlayerControlsManager _controlsManager;
  late final PlayerStateManager _stateManager;

  final VideoFilePicker _filePicker = VideoFilePicker();

  bool _isFullscreen = false;
  bool _isLocked = false;
  bool _showControls = true;

  double _volume = 100.0;

  @override
  void initState() {
    super.initState();

    _controller = MediaController();

    _stateManager = PlayerStateManager(
      controller: _controller,
      filePicker: _filePicker,
      onChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      isAlive: () => mounted,
    );

    _stateManager.initialize();

    _keyboardManager = PlayerKeyboardManager(
      onTogglePlayback: _togglePlayback,
      onSeekTo: _seekTo,
      onToggleFullscreen: _toggleFullscreen,
      onToggleMute: _toggleMute,
      getPositionSeconds: () => _stateManager.position.inSeconds.toDouble(),
      getDurationSeconds: () => _stateManager.duration.inSeconds.toDouble(),
      isFullscreen: () => _isFullscreen,
    );

    _controlsManager = PlayerControlsManager(
      onControlsVisibilityChanged: (visible) {
        if (!mounted) return;
        setState(() => _showControls = visible);
      },
      onLockChanged: (locked) {
        if (!mounted) return;
        setState(() => _isLocked = locked);
      },
      onFullscreenChanged: (fullscreen) {
        if (!mounted) return;
        setState(() => _isFullscreen = fullscreen);
      },
      setFullscreen: windowManager.setFullScreen,
      getFullscreen: windowManager.isFullScreen,
      isAlive: () => mounted,
    );

    _volumeManager = PlayerVolumeManager(
      onVolumeChanged: (volume) {
        if (!mounted) return;
        setState(() => _volume = volume);
      },
      setPlayerVolume: _controller.setVolume,
      isAlive: () => mounted,
    );

    _volumeManager.initialize();
  }

  @override
  void dispose() {
    _volumeManager.dispose();
    _controlsManager.dispose();
    _stateManager.dispose();
    _keyboardFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Volume
  // ---------------------------------------------------------------------------

  Future<void> _changeVolume(double value) =>
      _volumeManager.changeVolume(value);

  Future<void> _toggleMute() => _volumeManager.toggleMute();

  // ---------------------------------------------------------------------------
  // Controls and fullscreen
  // ---------------------------------------------------------------------------

  Future<void> _toggleFullscreen() async {
    await _controlsManager.toggleFullscreen();
  }

  void _toggleLock() {
    _controlsManager.toggleLock();
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> _openVideo() => _stateManager.openVideo();

  Future<void> _togglePlayback() => _stateManager.togglePlayback();

  Future<void> _seekTo(double seconds) => _stateManager.seekTo(seconds);

  // ---------------------------------------------------------------------------
  // Time formatting
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // UI pieces
  // ---------------------------------------------------------------------------

  Widget _buildTimeline(bool canSeek) {
    return PlayerTimeline(
      position: _stateManager.position,
      duration: _stateManager.duration,
      canSeek: canSeek,
      isLocked: _isLocked,
      onSeek: _seekTo,
      onDragStart: () {
        _stateManager.setSeeking(true);
      },
      onDragUpdate: (value) {
        if (value < 0) return;

        _stateManager.setPreviewPosition(Duration(milliseconds: value.round()));
      },
      onDragEnd: () async {
        await _seekTo(_stateManager.position.inMilliseconds / 1000.0);

        if (!mounted) return;

        setState(() {
          _stateManager.setSeeking(false);
        });
      },
      onDragCancel: () {
        if (!mounted) return;

        setState(() {
          _stateManager.setSeeking(false);
        });
      },
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            _formatTime(_stateManager.position),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            _formatTime(_stateManager.duration),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return PlayerControls(
      fileName: _stateManager.fileName,
      isOpening: _stateManager.isOpening,
      isPlaying: _stateManager.isPlaying,
      isLocked: _isLocked,
      isFullscreen: _isFullscreen,
      volume: _volume,
      onPlayPause: _togglePlayback,
      onMute: _toggleMute,
      onFullscreen: _toggleFullscreen,
      onLock: _toggleLock,
      onChangeVolume: _changeVolume,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final maxSeconds = _stateManager.duration.inMilliseconds / 1000.0;

    final canSeek =
        _stateManager.fileName != null &&
        maxSeconds > 0 &&
        !_stateManager.isOpening;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _keyboardManager.handleKeyEvent,
      child: Scaffold(
        body: MouseRegion(
          onHover: (_) {
            _controlsManager.showControlsAndRestartTimer();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _controlsManager.showControlsAndRestartTimer();
            },
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.zero,
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
                            if (_stateManager.fileName != null)
                              Positioned.fill(
                                child: Video(
                                  controller: _controller.videoController,
                                  controls: NoVideoControls,
                                  fit: BoxFit.contain,
                                ),
                              )
                            else
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.movie_outlined,
                                    size: 64,
                                    color: Colors.white38,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nothing playing',
                                    style: TextStyle(fontSize: 21),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Open a video file to get started',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                ],
                              ),
                            if (_stateManager.isOpening)
                              const CircularProgressIndicator(),
                            if (_showControls)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildTimeline(canSeek),
                                      _buildTimeLabels(),
                                      const SizedBox(height: 8),
                                      _buildButtonRow(),
                                    ],
                                  ),
                                ),
                              ),
                            if (!_isLocked)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: PlayerMenuBar(
                                  onOpenVideo: _openVideo,
                                  onExit: () => windowManager.close(),
                                  isFullscreen: _isFullscreen,
                                  onToggleFullscreen: _toggleFullscreen,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_stateManager.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _stateManager.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
