import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:biux/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:biux/features/settings/domain/entities/notification_settings_entity.dart';

class _FakeNotifProvider extends ChangeNotifier implements NotificationSettingsProvider {
  NotificationSettingsEntity? _settings = NotificationSettingsEntity.defaults();
  bool _isLoading = false;
  String? _error;

  @override
  NotificationSettingsEntity? get settings => _settings;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get error => _error;

  @override
  Future<void> loadSettings() async {}

  // no-op implementations
  @override Future<void> toggleLikes(bool enabled) async {}
  @override Future<void> toggleComments(bool enabled) async {}
  @override Future<void> toggleFollows(bool enabled) async {}
  @override Future<void> toggleStories(bool enabled) async {}
  @override Future<void> togglePushNotifications(bool enabled) async {}
  @override Future<void> toggleRideInvitations(bool enabled) async {}
  @override Future<void> toggleGroupInvitations(bool enabled) async {}
  @override Future<void> toggleRideReminders(bool enabled) async {}
  @override Future<void> toggleGroupUpdates(bool enabled) async {}
  @override Future<void> toggleSystemNotifications(bool enabled) async {}
  @override Future<void> resetToDefaults() async {}
  @override bool isNotificationTypeEnabled(String type) => true;
}

void main() {
  testWidgets('NotificationSettings back icon exists and is tappable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<NotificationSettingsProvider>(
          create: (_) => _FakeNotifProvider(),
          child: const NotificationSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final back = find.byIcon(Icons.arrow_back);
    expect(back, findsWidgets);
    await tester.tap(back.first);
    await tester.pumpAndSettle();
  });
}
