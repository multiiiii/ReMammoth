# ReMammoth

> How much does a mammoth weigh? Enough to break the ice. It also remembers your birthday and the gift idea it had months ago.

ReMammoth is a simple, offline-first personal memory app for Android. Keep notes about yourself and the people in your life — without cloud accounts, subscriptions, or ads.

---

## Features

- **Personal notes** — capture anything you want to remember, with titles and free-form text
- **Friends list** — add friends with an optional birthday, and keep dedicated notes for each one
- **Gift ideas** — every new friend automatically gets a pinned "Gift ideas" note ready to fill in
- **Pin notes** — pin important notes to the top of any list
- **Inline editing** — tap any note to open it full-screen and edit directly; changes save automatically when you close
- **Sort** — sort notes by newest, oldest, alphabetically, or last edited; friends can be sorted by newest, oldest, or alphabetically
- **Color schemes** — choose from four themes (Classic Blue, Fire & Ice, Dark Mode, Jungle) in the Settings sheet; the Android launcher icon updates to match
- **Fully offline** — all data is stored locally on your device, nothing leaves it

---

## Installation

Download the latest APK from the [Releases](../../releases) page and install it on your Android device.

> You may need to allow installation from unknown sources in your Android settings.

---

## Building from source

**Requirements**

- Flutter SDK (see `pubspec.yaml` for the minimum Dart SDK version)
- Android SDK / Android Studio (for Android builds)

**Steps**

```bash
# Clone the repository
git clone https://github.com/multiiiii/ReMammoth.git
cd ReMammoth

# Install dependencies
flutter pub get

# Generate database code
dart run build_runner build --delete-conflicting-outputs

# Run in debug mode
# Note: if you previously selected a non-default color scheme on the device,
# switch back to Classic Blue before running — flutter run launches the app
# via MainActivity, which Android disables when a non-default scheme is active.
flutter run

# Build a release APK
flutter build apk --release
```

The release APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Tech stack

| Layer | Library |
|---|---|
| UI framework | [Flutter](https://flutter.dev) / Material 3 |
| Local database | [Drift](https://drift.simonbinder.eu) (SQLite) |
| State / DI | [Provider](https://pub.dev/packages/provider) |
| Grid layout | [flutter\_staggered\_grid\_view](https://pub.dev/packages/flutter_staggered_grid_view) |

---

## License

MIT
