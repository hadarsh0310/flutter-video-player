import 'package:file_picker/file_picker.dart';

class VideoFilePicker {
  Future<String?> pickVideo() async {
    final file = await FilePicker.pickFile(
      type: FileType.video,
    );

    return file?.path;
  }
}