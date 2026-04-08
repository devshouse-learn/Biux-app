import 'package:flutter/material.dart';

/// Tipos de error predefinidos
enum ErrorType {
  network,
  notFound,
  permission,
  server,
  generic,
  empty,
}

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
    final theme = Theme.of(context);
    final config = _getConfig();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? Icon(
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
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel ?? 'Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorConfig _getConfig() {
    switch (type) {
      case ErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: 'Sin conexión',
          message: 'Verifica tu conexión a internet e intenta nuevamente.',
        );
      case ErrorType.notFound:
        return _ErrorConfig(
          icon: Icons.search_off_rounded,
          title: 'No encontrado',
          message: 'El contenido que buscas no está disponible.',
        );
      case ErrorType.permission:
        return _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          title: 'Sin permisos',
          message: 'No tienes permisos para acceder a este contenido.',
        );
      case ErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          title: 'Error del servidor',
          message: 'Hubo un problema con el servidor. Intenta más tarde.',
        );
      case ErrorType.empty:
        return _ErrorConfig(
          icon: Icons.inbox_rounded,
          title: 'Sin contenido',
          message: 'No hay nada que mostrar aquí por ahora.',
        );
      case ErrorType.generic:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          title: 'Algo salió mal',
          message: 'Ocurrió un error inesperado. Intenta nuevamente.',
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
