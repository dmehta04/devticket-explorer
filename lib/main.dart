import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: DevTicketApp()));
}

class DevTicketApp extends StatelessWidget {
  const DevTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Ticket Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
