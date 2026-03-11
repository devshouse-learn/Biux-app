import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import '../widgets/notifications_list.dart';

/// Pantalla de notificaciones
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('notifications')),
        backgroundColor: const Color(0xFF16242D), // AppColors.blackPearl
      ),
      body: const NotificationsList(),
    );
  }
}
