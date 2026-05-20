import 'package:flutter/material.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

/// Tipos de error predefinidos
enum ErrorType { network, notFound, permission, server, generic, empty }

/// Widget reutilizable para mostrar estados de error.
///
/// Uso:
/// ```dart
/// ErrorView(
///   type: ErrorType.network,
///   onRetry: () => provider.reload(),
/// )
/// ```
class ErrorView extends StatelessWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? icon;

  const ErrorView({
    super.key,
    this.type = ErrorType.generic,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    final theme = Theme.of(context);
    final config = _getConfig(l);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  config.icon,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            const SizedBox(height: 16),
            Text(
              title ?? config.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? config.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 18),
                label: Text(retryLabel ?? l.t('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorConfig _getConfig(LocaleNotifier l) {
    switch (type) {
      case ErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: l.t('no_connection'),
          message: l.t('check_connection'),
        );
      case ErrorType.notFound:
        return _ErrorConfig(
          icon: Icons.search_off_rounded,
          title: l.t('not_found'),
          message: l.t('content_not_available'),
        );
      case ErrorType.permission:
        return _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          title: l.t('no_permissions'),
          message: l.t('no_permissions_msg'),
        );
      case ErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          title: l.t('server_error'),
          message: l.t('server_error_msg'),
        );
      case ErrorType.empty:
        return _ErrorConfig(
          icon: Icons.inbox_rounded,
          title: l.t('no_content'),
          message: l.t('nothing_to_show'),
        );
      case ErrorType.generic:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          title: l.t('something_went_wrong'),
          message: l.t('unexpected_error'),
        );
    }
  }
}

class _ErrorConfig {
  final IconData icon;
  final String title;
  final String message;

  _ErrorConfig({
    required this.icon,
    required this.title,
    required this.message,
  });
}
