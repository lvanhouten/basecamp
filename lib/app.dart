import 'package:flutter/material.dart';

import 'core/home_shell.dart';
import 'core/theme.dart';

class BasecampApp extends StatelessWidget {
  const BasecampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basecamp',
      debugShowCheckedModeBanner: false,
      theme: basecampTheme(Brightness.light),
      darkTheme: basecampTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
