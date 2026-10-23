import 'dart:typed_data';

import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';

class ThumbnailService {
  Future<Uint8List?> generateThumbnail({
    required String videoPath,
    required Duration position,
  }) async {
    try {
      return await FlutterVideoThumbnailPlus.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.jpeg,
        maxWidth: 240,
        maxHeight: 135,
        timeMs: position.inMilliseconds,
        quality: 70,
      );
    } catch (error) {
      return null;
    }
  }
}