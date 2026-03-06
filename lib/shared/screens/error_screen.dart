
import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class ErrorScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String title;

  const ErrorScreen({
    Key? key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Algo salió mal',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]), textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!, style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.5), textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoConnectionScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoConnectionScreen({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      icon: Icons.wifi_off_rounded,
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e intenta de nuevo.',
      onRetry: onRetry,
    );
  }
}
