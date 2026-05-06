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
    final friends = _friends;

    Widget content;
    if (friends == null) {
      content = const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (friends.isEmpty) {
      content = const Text('No other friends to copy to.');
    } else {
      content = SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (_, i) {
            final friend = friends[i];
            final selected = _selected.contains(friend.id);
            return CheckboxListTile(
              title: Text(friend.name),
              value: selected,
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
      );
    }

    return AlertDialog(
      title: const Text('Copy to friend'),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              (friends != null && _selected.isNotEmpty) ? _confirm : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
