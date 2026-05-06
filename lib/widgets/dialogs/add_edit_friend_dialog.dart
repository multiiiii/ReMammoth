import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';

class AddEditFriendDialog extends StatefulWidget {
  const AddEditFriendDialog({super.key, this.friend});

  final Friend? friend;

  @override
  State<AddEditFriendDialog> createState() => _AddEditFriendDialogState();
}

class _AddEditFriendDialogState extends State<AddEditFriendDialog> {
  late final TextEditingController _nameController;
  DateTime? _birthday;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.friend?.name ?? '');
    _birthday = widget.friend?.birthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop((
        name: _nameController.text.trim(),
        birthday: _birthday,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.friend != null;
    final colorScheme = Theme.of(context).colorScheme;
    final bg = colorScheme.primaryContainer;
    final onBg = colorScheme.onPrimaryContainer;
    final blue = colorScheme.primary;

    final birthdayText = _birthday != null
        ? DateFormat('d MMM yyyy').format(_birthday!)
        : 'Not set';

    return AlertDialog(
      backgroundColor: bg,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit friend' : 'Add friend',
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
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: onBg),
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickBirthday,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Birthday (optional)',
                      labelStyle:
                          TextStyle(color: onBg.withValues(alpha: 0.7)),
                      floatingLabelStyle: TextStyle(color: onBg),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: onBg.withValues(alpha: 0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: onBg.withValues(alpha: 0.4)),
                      ),
                      suffixIcon:
                          Icon(Icons.cake_outlined, color: onBg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(birthdayText, style: TextStyle(color: onBg)),
                        if (_birthday != null)
                          GestureDetector(
                            onTap: () => setState(() => _birthday = null),
                            child: Icon(Icons.clear, size: 16, color: onBg),
                          ),
                      ],
                    ),
                  ),
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
