import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';

enum _NoteAction { pin, delete }

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  final Note note;
  final Future<void> Function(Note) onEdit;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(Note) onTogglePin;

  void _showExpanded(BuildContext context) {
    final bg = Theme.of(context).colorScheme.secondaryContainer;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NoteExpandedSheet(
        note: note,
        onEdit: onEdit,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final desc = note.description;

    final onCard = colorScheme.onPrimaryContainer;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: colorScheme.secondaryContainer,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: () => _showExpanded(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (note.isPinned) ...[
                          Icon(Icons.push_pin,
                              size: 12, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            note.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: onCard,
                                ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_NoteAction>(
                    icon: Icon(Icons.more_vert,
                        size: 18, color: onCard),
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      if (action == _NoteAction.pin) {
                        onTogglePin(note);
                      } else {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (_) => _buildMenuItems(colorScheme),
                  ),
                ],
              ),
              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: onCard.withValues(alpha: 0.75),
                      ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('d MMM yyyy').format(note.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: onCard.withValues(alpha: 0.55),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete note'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete(note.id);
  }

  List<PopupMenuEntry<_NoteAction>> _buildMenuItems(ColorScheme colorScheme) {
    return [
      PopupMenuItem(
        value: _NoteAction.pin,
        child: ListTile(
          leading: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          title: Text(note.isPinned ? 'Unpin' : 'Pin'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: _NoteAction.delete,
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: colorScheme.error),
          title:
              Text('Delete', style: TextStyle(color: colorScheme.error)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Expanded sheet — StatefulWidget so controllers are tied to widget lifecycle.
// ---------------------------------------------------------------------------

class _NoteExpandedSheet extends StatefulWidget {
  const _NoteExpandedSheet({
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  final Note note;
  final Future<void> Function(Note) onEdit;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(Note) onTogglePin;

  @override
  State<_NoteExpandedSheet> createState() => _NoteExpandedSheetState();
}

class _NoteExpandedSheetState extends State<_NoteExpandedSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  // Guards against double-save (e.g. pin action calls _save() then pop
  // triggers onPopInvoked which also calls _save()).
  bool _saved = false;
  // Skip save when the note was deleted from this sheet.
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descController =
        TextEditingController(text: widget.note.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_deleted || _saved) return;
    _saved = true;
    final newTitle = _titleController.text.trim();
    final newDesc = _descController.text.trim();
    final note = widget.note;
    if (newTitle.isNotEmpty &&
        (newTitle != note.title || newDesc != (note.description ?? ''))) {
      await widget.onEdit(note.copyWith(
        title: newTitle,
        description: Value(newDesc.isEmpty ? null : newDesc),
      ));
    }
  }

  Future<bool> _confirmDelete() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete note'),
        content: Text('Delete "${widget.note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final note = widget.note;
    final onCard = colorScheme.onSecondaryContainer;

    return PopScope(
      // Auto-save whenever the sheet is dismissed (drag, back button, etc.).
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: SizedBox(
        // Tight height so Expanded inside Column has a finite bound.
        height: MediaQuery.sizeOf(context).height * 0.92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: onCard.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (note.isPinned) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.push_pin,
                              size: 16, color: colorScheme.secondary),
                        ),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, color: onCard),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: TextStyle(
                                color: onCard.withValues(alpha: 0.5)),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      PopupMenuButton<_NoteAction>(
                        icon: Icon(Icons.more_vert, color: onCard),
                        padding: EdgeInsets.zero,
                        onSelected: (action) async {
                          if (action == _NoteAction.pin) {
                            await _save();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            await widget.onTogglePin(note);
                          } else {
                            final confirmed = await _confirmDelete();
                            if (!confirmed || !context.mounted) return;
                            _deleted = true;
                            Navigator.of(context).pop();
                            await widget.onDelete(note.id);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _NoteAction.pin,
                            child: ListTile(
                              leading: Icon(note.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined),
                              title: Text(
                                  note.isPinned ? 'Unpin' : 'Pin'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: _NoteAction.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline,
                                  color: colorScheme.error),
                              title: Text('Delete',
                                  style: TextStyle(
                                      color: colorScheme.error)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 16, color: onCard.withValues(alpha: 0.2)),
                ],
              ),
            ),
            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _descController,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: onCard),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Note',
                        hintStyle: TextStyle(
                            color: onCard.withValues(alpha: 0.5)),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormat('d MMM yyyy').format(note.createdAt),
                      style: textTheme.labelSmall
                          ?.copyWith(color: onCard.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
