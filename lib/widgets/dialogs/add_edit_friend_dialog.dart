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
    final birthdayText = _birthday != null
        ? DateFormat('d MMM yyyy').format(_birthday!)
        : 'Not set';

    return AlertDialog(
      title: Text(isEditing ? 'Edit friend' : 'Add friend'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickBirthday,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birthday (optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.cake_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(birthdayText),
                    if (_birthday != null)
                      GestureDetector(
                        onTap: () => setState(() => _birthday = null),
                        child: const Icon(Icons.clear, size: 16),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
