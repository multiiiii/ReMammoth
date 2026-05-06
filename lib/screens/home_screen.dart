import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../services/backup_service.dart';
import 'friends_screen.dart';
import 'personal_notes_screen.dart';

const _blue = Color(0xFF023B67);
const _blueMid = Color(0xFF034F8C);
const _orange = Color(0xFFDE781C);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showBackupSheet(BuildContext context) {
    final db = context.read<AppDatabase>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _blueMid,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.white),
              title: const Text('Export backup',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Share your data as a file',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              onTap: () {
                Navigator.of(sheetContext).pop();
                BackupService.exportBackup(db, context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_outlined,
                  color: Colors.white),
              title: const Text('Import backup',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Restore from a backup file',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              onTap: () {
                Navigator.of(sheetContext).pop();
                BackupService.importBackup(db, context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blue,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ReMammoth',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _orange,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remember what matters',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                    ),
                    const Spacer(flex: 2),
                    _HomeButton(
                      label: 'Remember personal stuff',
                      icon: Icons.person_outline,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PersonalNotesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _HomeButton(
                      label: 'Remember stuff about friends',
                      icon: Icons.people_outline,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FriendsScreen(),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.settings_backup_restore,
                  color: Colors.white,
                ),
                tooltip: 'Backup & Restore',
                onPressed: () => _showBackupSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
