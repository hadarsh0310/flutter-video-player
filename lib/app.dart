import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/player_screen.dart';

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const PlayerScreen(),
    );
  }
}