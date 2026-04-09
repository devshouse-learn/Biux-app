import 'package:flutter/material.dart';

/// Servicio centralizado de SnackBars para toda la app.
/// Permite mostrar notificaciones sin necesidad de BuildContext.
///
/// Configuración en MaterialApp:
/// ```dart
/// MaterialApp(
///   scaffoldMessengerKey: SnackBarService.messengerKey,
/// )
/// ```
class SnackBarService {
  SnackBarService._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void _show({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: duration,
        action: action,
      ),
    );
  }

  static void showSuccess(String message, {SnackBarAction? action}) {
    _show(
      message: message,
      backgroundColor: const Color(0xFF2E7D32),
      icon: Icons.check_circle_outline,
      action: action,
    );
  }

  static void showError(String message, {SnackBarAction? action}) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFC62828),
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4),
      action: action,
    );
  }

  static void showWarning(String message, {SnackBarAction? action}) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFE65100),
      icon: Icons.warning_amber_rounded,
      action: action,
    );
  }

  static void showInfo(String message, {SnackBarAction? action}) {
    _show(
      message: message,
      backgroundColor: const Color(0xFF1565C0),
      icon: Icons.info_outline,
      action: action,
    );
  }

  static void showLoading(String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF424242),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  static void dismiss() {
    messengerKey.currentState?.hideCurrentSnackBar();
  }
}
