# Ennuigo

A minimalist daily mood tracker built with Flutter. 

Ennuigo challenges the standard paradigms of habit trackers by removing text from the UI entirely. Instead, it relies on geometric layouts, custom freehand shapes, tactile haptic feedback, and vibrant color mapping to log and review your daily emotions.

## Key Features

- **Text-Free UI**: Communicate and review your emotions purely through colors, shapes, and spatial awareness.
- **Draw Your Moods**: A custom painting canvas lets you hand-draw geometric paths or abstract shapes to represent specific moods, which are translated to JSON coordinates and stored locally.
- **365-Day Year Matrix**: A dynamic, perfectly-squared responsive grid that effortlessly fits an entire year of data on a single screen without scrolling.
- **Snapping Month Rolodex**: A vertical `PageView` that snaps months into place with a subtle 3D scale and fade effect. Days are mapped identically to real-world calendar offsets.
- **Automatic Mood Chart**: Calculates your monthly mood proportions and automatically builds a sleek, absolute-positioned color bar chart when a month snaps into focus.
- **Tactile UX**: Integrated physics and haptic feedback responses across navigation, drawing, and logging.
- **Cross-Platform Storage**: Uses SQLite to privately store all mood entries offline, with desktop FFI adaptations for Windows/macOS/Linux.

## Navigation & Screens

1. **Year View**: A dense layout allowing you to visually scan color clusters across your entire year in an instant.
2. **Month View**: A spaced-out 7x5 constraint grid tracking past days (grey) and future days (dim white). Tap any eligible past or current day to log a mood.
3. **Floating Tab Bar**: An iOS-inspired floating navigation dock to smoothly switch between views and jump straight to logging today.
4. **Drawing Canvas**: Offers a palette of colors to draw new expressions via screen gestures. Includes refresh and save functionality.

## Built With
- **Framework:** Flutter / Dart
- **State & Layout:** Custom `LayoutBuilder` math to preserve strict 1:1 aspect ratios avoiding clipped items. 
- **Storage:** `sqflite`, `sqflite_common_ffi`, and `sqlite3_flutter_libs`.

## Getting Started

Ensure you have the Flutter SDK installed and environment variables configured.

```bash
# Clone the repository
git clone https://github.com/your-username/ennuigo.git
cd ennuigo

# Fetch dependencies
flutter pub get

# Run the app 
flutter run
```
