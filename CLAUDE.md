# CLAUDE.md — ReMammoth

## What this app is

ReMammoth is an offline-first personal memory app for Android. It lets users keep personal notes and notes about friends (with optional birthdays). All data is stored locally in SQLite — no accounts, no cloud sync.

---

## Tech stack

| Concern | Library |
|---|---|
| UI | Flutter / Material 3 (`useMaterial3: true`) |
| Database | Drift (SQLite ORM) — `drift: ^2.26.0` |
| Platform DB driver | `drift_flutter` |
| State / DI | `provider` — `AppDatabase` provided at root |
| Grid layout | `flutter_staggered_grid_view` (masonry) |
| Date formatting | `intl` |
| Backup export | `share_plus` + `path_provider` |
| Backup import | `file_picker` |

---

## Project layout

```
lib/
  app.dart                    # MaterialApp, applies theme
  main.dart                   # entry point, provides AppDatabase
  database/
    app_database.dart         # schema, migrations, AppDatabase class
    app_database.g.dart       # Drift-generated — DO NOT edit
    daos/
      friends_dao.dart        # FriendsDao
      notes_dao.dart          # NotesDao
  models/
    sort_order.dart           # SortOrder enum (newest/oldest/alpha)
  screens/
    home_screen.dart          # landing screen with backup button
    personal_notes_screen.dart
    friends_screen.dart
    friend_notes_screen.dart
  services/
    backup_service.dart       # JSON export / import logic
  theme/
    app_theme.dart            # appTheme + appDarkTheme, exports appBlue/appOrange
  widgets/
    note_card.dart            # NoteCard + _NoteExpandedSheet (bottom sheet)
    friend_card.dart          # FriendCard
    sort_menu.dart            # PopupMenuButton for sort order
    dialogs/
      add_edit_note_dialog.dart
      add_edit_friend_dialog.dart
```

---

## Database schema

**`friends`** (schema v2)
| column | type | notes |
|---|---|---|
| id | INTEGER PK | autoIncrement |
| name | TEXT | required |
| birthday | DATETIME | nullable |
| createdAt | DATETIME | required |
| isPinned | BOOLEAN | default false |

**`notes`** (schema v2)
| column | type | notes |
|---|---|---|
| id | INTEGER PK | autoIncrement |
| title | TEXT | required |
| description | TEXT | nullable |
| createdAt | DATETIME | required |
| updatedAt | DATETIME | required |
| friendId | INTEGER FK | nullable → friends.id CASCADE DELETE |
| isPinned | BOOLEAN | default false |

Schema version: **2**. Migration v1→v2 adds `is_pinned` to both tables.
Foreign keys are enabled via `PRAGMA foreign_keys = ON` in `beforeOpen`.

---

## Color scheme & theme

Brand colors (exported from `lib/theme/app_theme.dart`):
- `appBlue = Color(0xFF023B67)` — scaffold backgrounds, app bars, home screen
- `appOrange = Color(0xFFDC771F)` — `primaryContainer` (card backgrounds, FABs)

Key color roles:
- `colorScheme.primaryContainer` → orange — used for card backgrounds and FABs
- `colorScheme.onPrimaryContainer` → dark brown `0xFF1A0900` — text on orange cards
- `colorScheme.secondary` → `0xFFE67E22` — friend avatar circles, pin icons
- `colorScheme.scaffoldBackgroundColor` → `appBlue`
- App bars → `appBlue` background, white icons/text

Cards must be created with `surfaceTintColor: Colors.transparent` to prevent Material 3's blue surface tint from muddying the orange. The global `cardTheme` alone is not reliably picked up in all Flutter versions.

The home screen uses hardcoded `_blue` / `_orange` constants (not theme) to guarantee exact color matching with the logo image.

---

## Key patterns

### Accessing the database
```dart
final db = context.read<AppDatabase>();
```
`AppDatabase` is a singleton provided at root via `Provider<AppDatabase>`.

### Note editing (bottom sheet)
`NoteCard` is a `StatelessWidget`. Tapping opens `showModalBottomSheet` with `_NoteExpandedSheet` — a `StatefulWidget` that owns the `TextEditingController`s and auto-saves on any dismissal via `PopScope(onPopInvokedWithResult:)`.

The sheet background is set by passing `backgroundColor: colorScheme.secondaryContainer` directly to `showModalBottomSheet`.

### Auto-created "Gift ideas" note
When a new friend is created in `FriendsScreen`, a pinned "Gift ideas" note is automatically inserted for that friend using the returned `friendId`.

### Backup / restore
`BackupService` in `lib/services/backup_service.dart`:
- **Export**: queries all rows, serialises to JSON, writes to temp dir, shares via Android share sheet.
- **Import**: picks a `.json` file, confirms with the user, clears all data in a transaction, re-inserts with original IDs (`InsertMode.insertOrReplace`) to preserve `friendId` FK references.
- Backup format: `{ version: 1, exportedAt, friends: [...], notes: [...] }`

### Code generation
Drift requires code generation after any schema change:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Never edit `*.g.dart` files manually.

---

## Running & building

```bash
flutter pub get                                        # install deps
dart run build_runner build --delete-conflicting-outputs  # regen Drift code (after schema changes)
flutter run                                            # debug on connected device
flutter build apk --release                            # release APK → build/app/outputs/flutter-apk/
```

---

## What NOT to commit

- `*.g.dart` files are generated — they ARE committed (Drift convention)
- `linux/flutter/generated_plugin_registrant.*`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/generated_plugin_registrant.*` — gitignored, regenerated by `flutter pub get`
- `.claude/` — AI assistant memory, gitignored
- `.metadata` — Flutter IDE file, gitignored
- `/build/` — gitignored
