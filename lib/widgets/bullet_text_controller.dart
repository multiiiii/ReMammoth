import 'package:flutter/material.dart';

TextEditingController makeBulletController(String? initial) {
  final initialText = (initial == null || initial.isEmpty) ? '• ' : initial;
  final ctrl = TextEditingController(text: initialText);
  String prev = ctrl.text;

  ctrl.addListener(() {
    final cur = ctrl.text;
    final offset = ctrl.selection.baseOffset;
    if (offset < 0) {
      prev = cur;
      return;
    }

    if (cur.length > prev.length) {
      // Insertion: if the character just before the cursor is '\n', add a bullet.
      if (offset > 0 && cur[offset - 1] == '\n') {
        final newText = '${cur.substring(0, offset)}• ${cur.substring(offset)}';
        ctrl.value = ctrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: offset + 2),
        );
        prev = ctrl.text;
        return;
      }
    } else if (cur.length < prev.length) {
      // Deletion: if the current line now contains only '• ', remove it.
      final lineStart = cur.lastIndexOf('\n', offset - 1) + 1;
      if (offset >= lineStart) {
        final lineContent = cur.substring(lineStart, offset);
        if (lineContent == '• ') {
          final newText =
              cur.substring(0, lineStart) + cur.substring(offset);
          ctrl.value = ctrl.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: lineStart),
          );
          prev = ctrl.text;
          return;
        }
      }
    }

    prev = cur;
  });

  return ctrl;
}

// Strips a trailing lone bullet so an empty last line isn't persisted.
String cleanBulletDesc(String s) {
  final t = s.trimRight();
  if (t == '• ') return '';
  if (t.endsWith('\n• ')) return t.substring(0, t.length - 3).trimRight();
  return t;
}
