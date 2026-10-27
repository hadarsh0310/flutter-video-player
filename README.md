# Flutter Video Player

A minimalist video player built with **Flutter and Dart**, using `media_kit` for video playback. The project is currently focused on Windows, with cross-platform support being developed progressively.

## Features

- **Video playback:** Open and play local video files.
- **Playback controls:** Play and pause videos.
- **Timeline seeking:** Navigate through videos using the playback timeline.
- **Playback timestamps:** Display the current playback position and total duration.
- **Volume control:** Adjust player volume with a slider.
- **Windows volume synchronization:** Synchronize the player volume with the Windows system volume.
- **Mute integration:** Synchronize mute functionality with Windows using native Windows integration.
- **Keyboard shortcuts:** Control playback and access player functions using the keyboard.
- **Fullscreen mode:** Watch videos in fullscreen.
- **Control visibility:** Automatically hide playback controls and support locking and unlocking controls.
- **Minimalist interface:** A clean, dark user interface.

## Tech Stack

- **Flutter** — UI framework
- **Dart** — Programming language
- **media_kit** — Media playback
- **media_kit_video** — Video rendering
- **media_kit_libs_video** — Native video playback libraries
- **file_picker** — Local video file selection
- **device_volume** — System-volume integration

### Native Windows Integration

The Windows version includes native C++ integration for system mute functionality through Flutter platform channels.

## Project Structure

```text
lib/
├── files/
│   └── video_file_picker.dart
├── playback/
│   └── media_controller.dart
├── ui/
│   ├── managers/
│   │   ├── player_controls_manager.dart
│   │   ├── player_keyboard_manager.dart
│   │   ├── player_state_manager.dart
│   │   └── player_volume_manager.dart
│   ├── widgets/
│   │   ├── player_controls.dart
│   │   ├── player_menu_bar.dart
│   │   └── player_timeline.dart
│   └── player_screen.dart
└── main.dart
```

The code is organized into separate managers for playback state, volume synchronization, keyboard shortcuts, and player controls, helping keep the UI code more maintainable.

## Getting Started

### Prerequisites

- Windows 10 or later
- Flutter SDK
- Dart SDK (included with Flutter)
- Visual Studio with the required C++ desktop development tools
- Git

### Run on Windows

1. Clone the repository:

   ```bash
   git clone https://github.com/hadarsh0310/flutter-video-player.git
   ```

2. Navigate to the project directory:

   ```bash
   cd flutter-video-player
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Check the development environment:

   ```bash
   flutter doctor
   ```

5. Run the application:

   ```bash
   flutter run -d windows
   ```

### Build for Windows

```bash
flutter build windows
```

The generated Windows application can be found under:

```text
build/windows/x64/runner/Release/
```

## Project Status

**Status: In active development**

Windows is the primary development platform. Other platform targets are present in the Flutter project, but compatibility and functionality must be verified separately on each platform.

## Roadmap

- Improve error handling and playback-state management.
- Add unit and widget tests.
- Test supported functionality across target platforms.
- Improve documentation and setup instructions.
- Add screenshots and a demonstration video.
- Prepare a tested release build for distribution.

## Author

**Adarsh H**

- GitHub: [@hadarsh0310](https://github.com/hadarsh0310)
- Project Repository: [flutter-video-player](https://github.com/hadarsh0310/flutter-video-player)
