# Flutter Video Player

A cross-platform video player built with **Flutter** and **Dart**, using `media_kit` for media playback.

## Features

- Video playback with play and pause controls
- Seek through a video using the timeline
- Video thumbnail previews when hovering over the timeline
- Volume slider with Windows system-volume synchronization
- Mute and unmute controls synchronized with Windows
- Video file selection from the local device
- Dark, minimalist user interface

## Tech Stack

- **Flutter** — cross-platform UI framework
- **Dart** — application programming language
- **media_kit** — media playback
- **file_picker** — video file selection
- **flutter_video_thumbnail_plus** — thumbnail generation
- **device_volume** — Windows system-volume integration

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)
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

4. Run the application:

   ```bash
   flutter run -d windows
   ```

## Project Status

The Windows version is under active development. Cross-platform compatibility and testing on other target platforms are still in progress.

## Roadmap

- [ ] Fullscreen playback
- [ ] Keyboard shortcuts
- [ ] Improved error handling
- [ ] Unit and widget tests
- [ ] Platform-specific testing
- [ ] Screenshots and demonstration video

## Author

**Adarsh**

GitHub: [@hadarsh0310](https://github.com/hadarsh0310)
