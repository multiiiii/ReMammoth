import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../models/app_color_scheme.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import 'friends_screen.dart';
import 'personal_notes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showSettingsSheet(BuildContext context) {
    final scheme = context.read<SettingsProvider>().colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: scheme.midPrimaryColor,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            final settings = sheetContext.read<SettingsProvider>();
            final scheme = settings.colorScheme;
            final onBg = AppColorScheme.onColor(scheme.midPrimaryColor);
            final currentSize = settings.noteFontSize;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color theme',
                      style: TextStyle(
                        color: onBg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.8,
                      children: AppColorScheme.values.map((s) {
                        final isSelected = s == scheme;
                        final onCard = AppColorScheme.onColor(s.primaryColor);
                        return GestureDetector(
                          onTap: () {
                            settings.setColorScheme(s);
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: s.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white, width: 2.5)
                                  : Border.all(
                                      color: Colors.white24, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.displayName,
                                    style: TextStyle(
                                      color: onCard,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: s.primaryColor,
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.white38),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: s.accentColor,
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.white38),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.check_circle,
                                      size: 14, color: onCard),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: onBg.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text(
                      'Note font size',
                      style: TextStyle(
                        color: onBg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<double>(
                      segments: const [
                        ButtonSegment(value: 12.0, label: Text('Small')),
                        ButtonSegment(value: 14.0, label: Text('Medium')),
                        ButtonSegment(value: 16.0, label: Text('Large')),
                      ],
                      selected: {currentSize},
                      onSelectionChanged: (value) {
                        settings.setNoteFontSize(value.first);
                        setState(() {});
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: scheme.primaryColor,
                        foregroundColor:
                            AppColorScheme.onColor(scheme.primaryColor),
                        selectedBackgroundColor: scheme.accentColor,
                        selectedForegroundColor:
                            AppColorScheme.onColor(scheme.accentColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBackupSheet(BuildContext context) {
    final db = context.read<AppDatabase>();
    final scheme = context.read<SettingsProvider>().colorScheme;
    final onBg = AppColorScheme.onColor(scheme.midPrimaryColor);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: scheme.midPrimaryColor,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.upload_file, color: onBg),
              title: Text('Export backup',
                  style: TextStyle(color: onBg)),
              subtitle: Text('Share your data as a file',
                  style: TextStyle(
                      color: onBg.withValues(alpha: 0.7))),
              onTap: () {
                Navigator.of(sheetContext).pop();
                BackupService.exportBackup(db, context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download_for_offline_outlined, color: onBg),
              title: Text('Import backup',
                  style: TextStyle(color: onBg)),
              subtitle: Text('Restore from a backup file',
                  style: TextStyle(
                      color: onBg.withValues(alpha: 0.7))),
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
    final scheme = context.watch<SettingsProvider>().colorScheme;
    final onPrimary = AppColorScheme.onColor(scheme.primaryColor);
    return Scaffold(
      backgroundColor: scheme.primaryColor,
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
                        scheme.logoAsset,
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
                            color: scheme.accentColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remember what matters',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: onPrimary.withValues(alpha: 0.75),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: onPrimary),
                    tooltip: 'Settings',
                    onPressed: () => _showSettingsSheet(context),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_backup_restore,
                      color: onPrimary,
                    ),
                    tooltip: 'Backup & Restore',
                    onPressed: () => _showBackupSheet(context),
                  ),
                ],
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
    final scheme = context.watch<SettingsProvider>().colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.accentColor,
          foregroundColor: AppColorScheme.onColor(scheme.accentColor),
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
