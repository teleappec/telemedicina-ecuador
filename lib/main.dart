import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(const TelemedApp());
}

class TelemedApp extends StatelessWidget {
  const TelemedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleMedicina Ecuador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
