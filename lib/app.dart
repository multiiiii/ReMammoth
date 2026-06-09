import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class ReMammothApp extends StatelessWidget {
  const ReMammothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final theme = buildThemeForScheme(settings.colorScheme);
        return MaterialApp(
          title: 'ReMammoth',
          theme: theme,
          themeMode: ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
