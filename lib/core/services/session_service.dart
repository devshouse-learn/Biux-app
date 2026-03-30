import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _lastActivityKey = 'last_activity';
  static const _sessionTimeoutMinutes = 30;
  static Timer? _timer;
  static void Function()? _onTimeout;

  static void startSessionTimer(void Function() onTimeout) {
    _onTimeout = onTimeout;
    _updateActivity();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkTimeout());
  }

  static void stopSessionTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> onUserActivity() async => _updateActivity();

  static Future<void> _checkTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActivity;
    if (elapsed > _sessionTimeoutMinutes * 60 * 1000) {
      stopSessionTimer();
      await FirebaseAuth.instance.signOut();
      _onTimeout?.call();
    }
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
    if (lastActivity == 0) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActivity;
    return elapsed > (_sessionTimeoutMinutes * 60 * 1000);
  }
}
