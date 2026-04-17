import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoLogoutService {
  static const _timeoutKey = 'session_timeout_minutes';
  static const _defaultTimeout = 30;
  static Timer? _timer;
  static DateTime? _lastActivity;

  // ── Registrar actividad ───────────────────────────────────────
  static void registerActivity() {
    _lastActivity = DateTime.now();
  }

  // ── Iniciar monitoreo ─────────────────────────────────────────
  static Future<void> startMonitoring({
    required BuildContext context,
    VoidCallback? onLogout,
  }) async {
    final minutes = await getTimeoutMinutes();
    if (minutes == 0) return; // 0 = desactivado
    _timer?.cancel();
    _lastActivity = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_lastActivity == null) return;
      final elapsed = DateTime.now().difference(_lastActivity!).inMinutes;
      if (elapsed >= minutes) {
        await stopMonitoring();
        await FirebaseAuth.instance.signOut();
        onLogout?.call();
      }
    });
  }

  // ── Detener monitoreo ─────────────────────────────────────────
  static Future<void> stopMonitoring() async {
    _timer?.cancel();
    _timer = null;
  }

  // ── Configuración ─────────────────────────────────────────────
  static Future<int> getTimeoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timeoutKey) ?? _defaultTimeout;
  }

  static Future<void> setTimeoutMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, minutes);
  }
}
