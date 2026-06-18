import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/social/presentation/widgets/notifications_list.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Pantalla de notificaciones
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Limpiar notificaciones antiguas de prueba con formato incorrecto
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<NotificationsProvider>().cleanOldTestNotifications();
      }
    });
    // Inyectar notificaciones de prueba
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _injectFollowRequestNotification('Valeria Vargas');
      }
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _injectFollowAcceptedNotification('Annie Sofía');
      }
    });
  }

  // Métodos de simulación para testing (opcional - se pueden eliminar después)
  Future<void> _injectFollowRequestNotification(String userName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testId = 'follow_request_${timestamp}';

      await FirebaseDatabase.instance
          .ref('notifications/${user.uid}/$testId')
          .set({
            'id': testId,
            'type': 'follow_request',
            'fromUserId': 'user_${timestamp % 10000}',
            'fromUserName': userName,
            'fromUserPhoto': '',
            'message': '$userName quiere seguirte',
            'isRead': false,
            'createdAt': timestamp,
            'timestamp': timestamp,
            'metadata': {
              'requiresAction': true,
              'actionUrl': '/profile/user_${timestamp % 10000}',
            },
          });
    } catch (e) {
      debugPrint('❌ Error inyectando solicitud de seguimiento: $e');
    }
  }

  Future<void> _injectFollowAcceptedNotification(String userName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testId = 'follow_accepted_${timestamp}';

      await FirebaseDatabase.instance
          .ref('notifications/${user.uid}/$testId')
          .set({
            'id': testId,
            'type': 'follow_accepted',
            'fromUserId': 'BIUX_SYSTEM',
            'fromUserName': 'BIUX',
            'fromUserPhoto': '',
            'message': '$userName aceptó tu solicitud de seguimiento',
            'isRead': false,
            'createdAt': timestamp,
            'timestamp': timestamp,
            'metadata': {'actionUrl': '/profile/user_${timestamp % 10000}'},
          });
    } catch (e) {
      debugPrint('❌ Error inyectando notificación de aceptación: $e');
    }
  }

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
