import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class ReMammothApp extends StatelessWidget {
  const ReMammothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReMammoth',
      theme: appTheme,
      darkTheme: appDarkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
