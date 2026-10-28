import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'viewmodels/visitor_viewmodel.dart';

void main() {
  runApp(const VisitorApp());
}

class VisitorApp extends StatelessWidget {
  const VisitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VisitorViewModel>(
      create: (_) => VisitorViewModel(),
      child: MaterialApp(
        title: 'Visitor Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
