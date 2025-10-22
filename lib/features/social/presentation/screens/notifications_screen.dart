import 'package:flutter/material.dart';
import '../widgets/notifications_list.dart';

/// Pantalla de notificaciones
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF16242D), // AppColors.blackPearl
      ),
      body: const NotificationsList(),
    );
  }
}
