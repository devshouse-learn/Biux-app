import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

/// Banner que muestra el porcentaje de completitud del perfil
class ProfileCompletionBanner extends StatelessWidget {
  const ProfileCompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final percent = provider.profileCompletionPercent;
        final missing = provider.missingProfileFields;
        if (percent >= 100 || missing.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorTokens.primary95,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTokens.primary40.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perfil completado al \$percent%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/edit-user'),
                    child: const Text('Completar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 80 ? Colors.green : ColorTokens.primary40,
                  ),
                ),
              ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Faltan: \${missing.join(", ")}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
