import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, InsertMode;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class BackupService {
  static Future<void> exportBackup(AppDatabase db, BuildContext context) async {
    try {
      final friends = await db.select(db.friends).get();
      final notes = await db.select(db.notes).get();

      final data = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'friends': friends
            .map((f) => {
                  'id': f.id,
                  'name': f.name,
                  'birthday': f.birthday?.toIso8601String(),
                  'createdAt': f.createdAt.toIso8601String(),
                  'isPinned': f.isPinned,
                })
            .toList(),
        'notes': notes
            .map((n) => {
                  'id': n.id,
                  'title': n.title,
                  'description': n.description,
                  'createdAt': n.createdAt.toIso8601String(),
                  'updatedAt': n.updatedAt.toIso8601String(),
                  'friendId': n.friendId,
                  'isPinned': n.isPinned,
                })
            .toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${dir.path}/remammoth_backup_$dateStr.json');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'ReMammoth Backup',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  static Future<void> importBackup(AppDatabase db, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import backup'),
        content: const Text(
          'This will replace all current notes and friends with the backup. '
          'This cannot be undone.',
        ),
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
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final jsonStr = await File(result.files.single.path!).readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      if ((data['version'] as int?) != 1) {
        throw const FormatException('Unsupported backup version');
      }

      final friendsList = data['friends'] as List<dynamic>;
      final notesList = data['notes'] as List<dynamic>;

      await db.transaction(() async {
        await db.delete(db.notes).go();
        await db.delete(db.friends).go();

        for (final f in friendsList) {
          final m = f as Map<String, dynamic>;
          await db.into(db.friends).insert(
            FriendsCompanion(
              id: Value(m['id'] as int),
              name: Value(m['name'] as String),
              birthday: Value(m['birthday'] != null
                  ? DateTime.parse(m['birthday'] as String)
                  : null),
              createdAt: Value(DateTime.parse(m['createdAt'] as String)),
              isPinned: Value(m['isPinned'] as bool),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }

        for (final n in notesList) {
          final m = n as Map<String, dynamic>;
          await db.into(db.notes).insert(
            NotesCompanion(
              id: Value(m['id'] as int),
              title: Value(m['title'] as String),
              description: Value(m['description'] as String?),
              createdAt: Value(DateTime.parse(m['createdAt'] as String)),
              updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
              friendId: Value(m['friendId'] as int?),
              isPinned: Value(m['isPinned'] as bool),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restored ${friendsList.length} friends and '
              '${notesList.length} notes.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}
