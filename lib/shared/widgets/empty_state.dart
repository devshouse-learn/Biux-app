import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final String? emoji;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.emoji,
  }) : super(key: key);

  // Factorías para empty states comunes
  factory EmptyState.noRides(BuildContext context, {VoidCallback? onAction}) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.directions_bike_rounded,
      emoji: '🚴',
      title: l.t('empty_no_rides_title'),
      description: l.t('empty_no_rides_desc'),
      actionText: l.t('empty_create_ride'),
      onAction: onAction,
    );
  }

  factory EmptyState.noGroups(BuildContext context, {VoidCallback? onAction}) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.group_rounded,
      emoji: '👥',
      title: l.t('empty_no_groups_title'),
      description: l.t('empty_no_groups_desc'),
      actionText: l.t('empty_explore_groups'),
      onAction: onAction,
    );
  }

  factory EmptyState.noPosts(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.photo_camera_rounded,
      emoji: '📸',
      title: l.t('empty_no_posts_title'),
      description: l.t('empty_no_posts_desc'),
    );
  }

  factory EmptyState.noMessages(
    BuildContext context, {
    VoidCallback? onAction,
  }) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      emoji: '💬',
      title: l.t('empty_no_messages_title'),
      description: l.t('empty_no_messages_desc'),
      actionText: l.t('empty_new_message'),
      onAction: onAction,
    );
  }

  factory EmptyState.noNotifications(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.notifications_none_rounded,
      emoji: '🔔',
      title: l.t('empty_no_notifications_title'),
      description: l.t('empty_no_notifications_desc'),
    );
  }

  factory EmptyState.noResults(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.search_off_rounded,
      emoji: '🔍',
      title: l.t('empty_no_results_title'),
      description: l.t('empty_no_results_desc'),
    );
  }

  factory EmptyState.noBikes(BuildContext context, {VoidCallback? onAction}) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return EmptyState(
      icon: Icons.pedal_bike_rounded,
      emoji: '🚲',
      title: l.t('empty_no_bikes_title'),
      description: l.t('empty_no_bikes_desc'),
      actionText: l.t('empty_register_bike'),
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorTokens.primary30.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: ColorTokens.primary30.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
