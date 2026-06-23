import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/presentation/widgets/notifications_list.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de notificaciones
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l.t('notifications'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: const NotificationsList(),
    );
  }
}
