import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final String? fileName;
  final bool isOpening;
  final bool isPlaying;
  final bool isLocked;
  final bool isFullscreen;
  final double volume;

  final VoidCallback onPlayPause;
  final VoidCallback onMute;
  final VoidCallback onFullscreen;
  final VoidCallback onLock;
  final ValueChanged<double> onChangeVolume;

  const PlayerControls({
    super.key,
    required this.fileName,
    required this.isOpening,
    required this.isPlaying,
    required this.isLocked,
    required this.isFullscreen,
    required this.volume,
    required this.onPlayPause,
    required this.onMute,
    required this.onFullscreen,
    required this.onLock,
    required this.onChangeVolume,
  });

  ButtonStyle _playerIconButtonStyle() {
    return IconButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isLocked) ...[
          IconButton(
            onPressed: fileName == null || isOpening ? null : onPlayPause,
            tooltip: isPlaying ? 'Pause' : 'Play',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 30,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName ?? 'No video selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),

          // Mute / unmute
          IconButton(
            onPressed: onMute,
            tooltip: volume == 0 ? 'Unmute (M)' : 'Mute (M)',
            style: _playerIconButtonStyle(),
            icon: Icon(
              volume == 0
                  ? Icons.volume_off_rounded
                  : volume < 50
                  ? Icons.volume_down_rounded
                  : Icons.volume_up_rounded,
            ),
          ),

          // Volume slider
          SizedBox(
            width: 140,
            child: Slider(
              min: 0,
              max: 100,
              divisions: 20,
              value: volume.clamp(0.0, 100.0).toDouble(),
              label: '${volume.round()}%',
              onChanged: onChangeVolume,
            ),
          ),

          SizedBox(
            width: 42,
            child: Text(
              '${volume.round()}%',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),

          // Fullscreen
          IconButton(
            onPressed: onFullscreen,
            tooltip: isFullscreen ? 'Exit Fullscreen (F)' : 'Fullscreen (F)',
            style: _playerIconButtonStyle(),
            icon: Icon(
              isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
            ),
          ),
        ] else
          const Spacer(),

        // Lock / unlock
        IconButton(
          onPressed: onLock,
          tooltip: isLocked ? 'Unlock Controls' : 'Lock Controls',
          style: IconButton.styleFrom(
            foregroundColor: isLocked ? Colors.amber : Colors.white,
            backgroundColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          icon: Icon(
            isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            size: 22,
          ),
        ),
      ],
    );
  }
}
