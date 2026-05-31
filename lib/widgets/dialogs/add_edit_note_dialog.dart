import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/app_database.dart';
import '../../providers/settings_provider.dart';

class AddEditNoteDialog extends StatefulWidget {
  const AddEditNoteDialog({super.key, this.note});

  final Note? note;

  @override
  State<AddEditNoteDialog> createState() => _AddEditNoteDialogState();
}

class _AddEditNoteDialogState extends State<AddEditNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop((
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final colorScheme = Theme.of(context).colorScheme;
    final bg = colorScheme.primaryContainer;
    final onBg = colorScheme.onPrimaryContainer;
    final blue = colorScheme.primary;

    return AlertDialog(
      backgroundColor: bg,
      // Reduce horizontal inset so the dialog fills more of the screen width.
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit note' : 'Add note',
          style: TextStyle(color: onBg)),
      content: SizedBox(
        width: double.maxFinite,
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: onBg.withValues(alpha: 0.7)),
              floatingLabelStyle: TextStyle(color: onBg),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: onBg.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: onBg.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              errorStyle: TextStyle(color: colorScheme.error),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: onBg),
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: onBg,
                    fontSize: context
                        .watch<SettingsProvider>()
                        .noteFontSize,
                  ),
                  decoration:
                      const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ),
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
          ),
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
