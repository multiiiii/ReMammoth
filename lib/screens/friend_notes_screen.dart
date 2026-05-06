import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../models/sort_order.dart';
import '../widgets/dialogs/add_edit_note_dialog.dart';
import '../widgets/note_card.dart';
import '../widgets/sort_menu.dart';

class FriendNotesScreen extends StatefulWidget {
  const FriendNotesScreen({super.key, required this.friend});

  final Friend friend;

  @override
  State<FriendNotesScreen> createState() => _FriendNotesScreenState();
}

class _FriendNotesScreenState extends State<FriendNotesScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  Future<void> _showAddNoteDialog() async {
    final db = context.read<AppDatabase>();
    final result = await showDialog<({String title, String? description})>(
      context: context,
      builder: (_) => const AddEditNoteDialog(),
    );
    if (result != null) {
      await db.notesDao.insertNote(
        title: result.title,
        description: result.description,
        friendId: widget.friend.id,
      );
    }
  }

  Future<void> _editNote(Note note) async {
    final db = context.read<AppDatabase>();
    await db.notesDao.updateNote(note);
  }

  Future<void> _deleteNote(int id) async {
    final db = context.read<AppDatabase>();
    await db.notesDao.deleteNote(id);
  }

  Future<void> _togglePin(Note note) async {
    final db = context.read<AppDatabase>();
    await db.notesDao.togglePin(note);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
        actions: [
          SortMenu(
            currentSort: _sortOrder,
            onSortChanged: (s) => setState(() => _sortOrder = s),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: db.notesDao.watchNotes(
          friendId: widget.friend.id,
          sort: _sortOrder,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return _EmptyState(
              icon: Icons.note_add_outlined,
              message:
                  'No notes about ${widget.friend.name} yet.\nTap + to add one.',
            );
          }
          return MasonryGridView.count(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            itemCount: notes.length,
            itemBuilder: (_, i) => NoteCard(
              note: notes[i],
              onEdit: _editNote,
              onDelete: _deleteNote,
              onTogglePin: _togglePin,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
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
