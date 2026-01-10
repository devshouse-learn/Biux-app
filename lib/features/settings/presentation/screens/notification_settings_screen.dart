import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/color_tokens.dart';
import '../providers/notification_settings_provider.dart';
import '../../../../debug/notification_debug_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar configuración al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ColorTokens.primary30 : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Botón de debug (temporal para pruebas)
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationDebugWidget(),
                ),
              );
            },
          ),
          Consumer<NotificationSettingsProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: provider.isLoading ? null : provider.loadSettings,
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          if (provider.error != null && provider.settings == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar configuración',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: provider.loadSettings,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final settings = provider.settings!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Switch principal
              _buildMainToggleCard(
                context,
                isDark,
                settings.enablePushNotifications,
                provider,
              ),

              const SizedBox(height: 24),

              // Sección: Interacciones Sociales
              _buildSectionTitle('Interacciones Sociales', isDark),
              const SizedBox(height: 12),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.favorite,
                iconColor: Colors.red.shade400,
                title: 'Likes',
                description: 'Cuando alguien le da like a tus publicaciones',
                value: settings.enableLikes,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleLikes,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.comment,
                iconColor: Colors.blue.shade400,
                title: 'Comentarios',
                description: 'Cuando alguien comenta en tus publicaciones',
                value: settings.enableComments,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleComments,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.person_add,
                iconColor: Colors.green.shade400,
                title: 'Nuevos Seguidores',
                description: 'Cuando alguien comienza a seguirte',
                value: settings.enableFollows,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleFollows,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.auto_stories,
                iconColor: Colors.purple.shade400,
                title: 'Historias',
                description: 'Cuando tus amigos publican nuevas historias',
                value: settings.enableStories,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleStories,
              ),

              const SizedBox(height: 24),

              // Sección: Rodadas y Grupos
              _buildSectionTitle('Rodadas y Grupos', isDark),
              const SizedBox(height: 12),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.pedal_bike,
                iconColor: Colors.orange.shade400,
                title: 'Invitaciones a Rodadas',
                description: 'Cuando te invitan a participar en una rodada',
                value: settings.enableRideInvitations,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleRideInvitations,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.group,
                iconColor: Colors.teal.shade400,
                title: 'Invitaciones a Grupos',
                description: 'Cuando te invitan a unirte a un grupo',
                value: settings.enableGroupInvitations,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleGroupInvitations,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.notifications_active,
                iconColor: Colors.amber.shade600,
                title: 'Recordatorios de Rodadas',
                description: 'Recordatorios de rodadas próximas',
                value: settings.enableRideReminders,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleRideReminders,
              ),
              const SizedBox(height: 8),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.update,
                iconColor: Colors.cyan.shade400,
                title: 'Actualizaciones de Grupos',
                description: 'Nuevas publicaciones y eventos en tus grupos',
                value: settings.enableGroupUpdates,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleGroupUpdates,
              ),

              const SizedBox(height: 24),

              // Sección: Sistema
              _buildSectionTitle('Sistema', isDark),
              const SizedBox(height: 12),
              _buildNotificationCard(
                context,
                isDark,
                icon: Icons.info_outline,
                iconColor: Colors.indigo.shade400,
                title: 'Notificaciones del Sistema',
                description: 'Avisos importantes de Biux',
                value: settings.enableSystemNotifications,
                enabled: settings.enablePushNotifications,
                onChanged: provider.toggleSystemNotifications,
              ),

              const SizedBox(height: 32),

              // Botón para resetear a valores por defecto
              OutlinedButton.icon(
                onPressed: () => _showResetDialog(context, provider),
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar Valores por Defecto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  side: BorderSide(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? ColorTokens.primary30.withValues(alpha: 0.1)
                      : ColorTokens.primary30.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorTokens.primary30.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: ColorTokens.primary30,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Puedes cambiar estas preferencias en cualquier momento',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainToggleCard(
    BuildContext context,
    bool isDark,
    bool enabled,
    NotificationSettingsProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enabled
              ? [
                  ColorTokens.primary30,
                  ColorTokens.primary30.withValues(alpha: 0.7),
                ]
              : [Colors.grey.shade600, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: enabled
                ? ColorTokens.primary30.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              enabled ? Icons.notifications_active : Icons.notifications_off,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones Push',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled ? 'Activadas' : 'Desactivadas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: provider.togglePushNotifications,
            thumbColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.white70;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white.withValues(alpha: 0.5);
              }
              return Colors.white.withValues(alpha: 0.3);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required bool enabled,
    required Function(bool) onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ColorTokens.primary20 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              thumbColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return ColorTokens.primary30;
                }
                return Colors.grey;
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    NotificationSettingsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Valores por Defecto'),
        content: const Text(
          '¿Estás seguro de que deseas restaurar todas las configuraciones de notificaciones a sus valores por defecto? Esto activará todas las notificaciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restaurada correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
