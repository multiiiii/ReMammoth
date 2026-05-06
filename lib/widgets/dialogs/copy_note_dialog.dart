import 'package:flutter/material.dart';

import '../../database/app_database.dart';

class CopyNoteDialog extends StatefulWidget {
  const CopyNoteDialog({super.key, required this.db, required this.note});

  final AppDatabase db;
  final Note note;

  @override
  State<CopyNoteDialog> createState() => _CopyNoteDialogState();
}

class _CopyNoteDialogState extends State<CopyNoteDialog> {
  List<Friend>? _friends;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await widget.db.friendsDao.watchFriends().first;
    // Exclude the friend the note already belongs to.
    final filtered =
        all.where((f) => f.id != widget.note.friendId).toList();
    setState(() => _friends = filtered);
  }

  Future<void> _confirm() async {
    for (final id in _selected) {
      await widget.db.notesDao.insertNote(
        title: widget.note.title,
        description: widget.note.description,
        friendId: id,
        isPinned: widget.note.isPinned,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final friends = _friends;
    // Blue background matching scaffold/app bars.
    final bg = colorScheme.primary;
    // Orange accent matching cards and FABs.
    final accent = colorScheme.primaryContainer;
    final onAccent = colorScheme.onPrimaryContainer;

    Widget content;
    if (friends == null) {
      content = SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: accent)),
      );
    } else if (friends.isEmpty) {
      content = Text(
        'No other friends to copy to.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
      );
    } else {
      content = SizedBox(
        width: double.maxFinite,
        child: Theme(
          // Override checkbox colors so they are visible on the blue background.
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? accent
                      : Colors.transparent),
              checkColor: WidgetStatePropertyAll(onAccent),
              side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (_, i) {
              final friend = friends[i];
              return CheckboxListTile(
                title: Text(friend.name,
                    style: const TextStyle(color: Colors.white)),
                value: _selected.contains(friend.id),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _selected.add(friend.id);
                  } else {
                    _selected.remove(friend.id);
                  }
                }),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: bg,
      title: const Text('Copy to friend',
          style: TextStyle(color: Colors.white)),
      content: content,
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: onAccent,
            disabledBackgroundColor: accent.withValues(alpha: 0.35),
            disabledForegroundColor: onAccent.withValues(alpha: 0.35),
          ),
          onPressed:
              (friends != null && _selected.isNotEmpty) ? _confirm : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
