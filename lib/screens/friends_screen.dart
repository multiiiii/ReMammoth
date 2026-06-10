import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../models/sort_order.dart';
import '../widgets/dialogs/add_edit_friend_dialog.dart';
import '../widgets/friend_card.dart';
import '../widgets/sort_menu.dart';
import 'friend_notes_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  Future<void> _showAddFriendDialog() async {
    final db = context.read<AppDatabase>();
    final result = await showDialog<({String name, DateTime? birthday})>(
      context: context,
      builder: (_) => const AddEditFriendDialog(),
    );
    if (result != null) {
      final friendId = await db.friendsDao.insertFriend(
        name: result.name,
        birthday: result.birthday,
      );
      await db.notesDao.insertNote(
        title: 'Gift ideas',
        friendId: friendId,
        isPinned: true,
      );
      await db.notesDao.insertNote(
        title: 'Stuff to talk about',
        friendId: friendId,
        isPinned: true,
      );
    }
  }

  Future<void> _editFriend(Friend friend) async {
    final db = context.read<AppDatabase>();
    await db.friendsDao.updateFriend(friend);
  }

  Future<void> _deleteFriend(int id) async {
    final db = context.read<AppDatabase>();
    await db.friendsDao.deleteFriend(id);
  }

  Future<void> _togglePin(Friend friend) async {
    final db = context.read<AppDatabase>();
    await db.friendsDao.togglePin(friend);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          SortMenu(
            currentSort: _sortOrder,
            onSortChanged: (s) => setState(() => _sortOrder = s),
            showLastEdited: false,
          ),
        ],
      ),
      body: StreamBuilder<List<Friend>>(
        stream: db.friendsDao.watchFriends(sort: _sortOrder),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final friends = snapshot.data!;
          if (friends.isEmpty) {
            return const _EmptyState(
              icon: Icons.person_add_outlined,
              message: 'No friends added yet.\nTap + to add a friend.',
            );
          }
          return MasonryGridView.count(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            itemCount: friends.length,
            itemBuilder: (_, i) => FriendCard(
              friend: friends[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FriendNotesScreen(friend: friends[i]),
                ),
              ),
              onEdit: _editFriend,
              onDelete: _deleteFriend,
              onTogglePin: _togglePin,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}
