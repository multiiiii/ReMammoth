import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import 'dialogs/add_edit_friend_dialog.dart';

enum _FriendAction { pin, edit, delete }

class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  final Friend friend;
  final VoidCallback onTap;
  final Future<void> Function(Friend) onEdit;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(Friend) onTogglePin;

  Future<void> _editFriend(BuildContext context) async {
    final result = await showDialog<({String name, DateTime? birthday})>(
      context: context,
      builder: (_) => AddEditFriendDialog(friend: friend),
    );
    if (result != null) {
      await onEdit(friend.copyWith(
        name: result.name,
        birthday: Value(result.birthday),
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove friend'),
        content: Text(
            'Remove "${friend.name}"? All their notes will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete(friend.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onCard = colorScheme.onPrimaryContainer;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.secondaryContainer,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.secondary,
                        child: Text(
                          friend.name.isNotEmpty
                              ? friend.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (friend.isPinned)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Icon(Icons.push_pin,
                              size: 12, color: colorScheme.secondary),
                        ),
                    ],
                  ),
                  const Spacer(),
                  PopupMenuButton<_FriendAction>(
                    icon: Icon(Icons.more_vert,
                        size: 18, color: onCard),
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      if (action == _FriendAction.pin) {
                        onTogglePin(friend);
                      } else if (action == _FriendAction.edit) {
                        _editFriend(context);
                      } else {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _FriendAction.pin,
                        child: ListTile(
                          leading: Icon(friend.isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined),
                          title: Text(friend.isPinned ? 'Unpin' : 'Pin'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: _FriendAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: _FriendAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: colorScheme.error),
                          title: Text('Remove',
                              style: TextStyle(color: colorScheme.error)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                friend.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (friend.birthday != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.cake_outlined,
                        size: 12, color: onCard.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM').format(friend.birthday!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: onCard.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
