import 'package:flutter/material.dart';

class PlayerMenuBar extends StatelessWidget {
  final VoidCallback onOpenVideo;
  final VoidCallback onExit;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const PlayerMenuBar({
    super.key,
    required this.onOpenVideo,
    required this.onExit,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: MenuBar(
        style: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          elevation: WidgetStatePropertyAll(0),
        ),
        children: [
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: onOpenVideo,
                child: const Text('Open Video...'),
              ),
              const MenuItemButton(
                onPressed: null,
                child: Text('Recent Videos'),
              ),
              MenuItemButton(onPressed: onExit, child: const Text('Exit')),
            ],
            child: const Text('File'),
          ),
          SubmenuButton(
            menuChildren: const [
              MenuItemButton(onPressed: null, child: Text('Play / Pause')),
              MenuItemButton(onPressed: null, child: Text('Seek Forward')),
              MenuItemButton(onPressed: null, child: Text('Seek Backward')),
            ],
            child: const Text('Playback'),
          ),
          SubmenuButton(
            menuChildren: const [
              MenuItemButton(onPressed: null, child: Text('Volume')),
              MenuItemButton(onPressed: null, child: Text('Mute')),
            ],
            child: const Text('Audio'),
          ),
          SubmenuButton(
            menuChildren: const [
              MenuItemButton(onPressed: null, child: Text('Load Subtitle...')),
              MenuItemButton(onPressed: null, child: Text('Subtitle Settings')),
            ],
            child: const Text('Subtitles'),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: onToggleFullscreen,
                child: Text(isFullscreen ? 'Exit Fullscreen' : 'Fullscreen'),
              ),
              const MenuItemButton(
                onPressed: null,
                child: Text('Lock Controls'),
              ),
            ],
            child: const Text('View'),
          ),
          SubmenuButton(
            menuChildren: const [
              MenuItemButton(
                onPressed: null,
                child: Text('About Video Player'),
              ),
            ],
            child: const Text('Help'),
          ),
        ],
      ),
    );
  }
}
