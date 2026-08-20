// lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/role_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TelemedicinaApp());
}

class TelemedicinaApp extends StatelessWidget {
  const TelemedicinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telemedicina Ecuador',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: NotificationService.messengerKey,
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
