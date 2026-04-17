import 'package:flutter/foundation.dart';

class PushNotificationService {
  static Future<void> initialize() async {
    debugPrint('🔔 PushNotificationService: stub');
  }

  static Future<void> saveTokenToFirestore([String? userId]) async {
    debugPrint('🔔 saveToken stub');
  }

  static Future<void> removeTokenOnLogout() async {
    debugPrint('🔔 removeToken stub');
  }
}
