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
    // Orange background matching note cards.
    final bg = colorScheme.primaryContainer;
    final onBg = colorScheme.onPrimaryContainer;
    // Blue for action buttons on the orange surface.
    final blue = colorScheme.primary;

    Widget content;
    if (friends == null) {
      content = SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: blue)),
      );
    } else if (friends.isEmpty) {
      content = Text(
        'No other friends to copy to.',
        style: TextStyle(color: onBg.withValues(alpha: 0.75)),
      );
    } else {
      content = SizedBox(
        width: double.maxFinite,
        child: Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? blue
                      : Colors.transparent),
              checkColor: const WidgetStatePropertyAll(Colors.white),
              side: BorderSide(
                  color: onBg.withValues(alpha: 0.4), width: 1.5),
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (_, i) {
              final friend = friends[i];
              return CheckboxListTile(
                title: Text(friend.name, style: TextStyle(color: onBg)),
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
      title: Text('Copy to friend', style: TextStyle(color: onBg)),
      content: content,
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: onBg),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: blue.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.35),
          ),
          onPressed:
              (friends != null && _selected.isNotEmpty) ? _confirm : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
