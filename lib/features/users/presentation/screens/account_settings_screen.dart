import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          'Configuración de Cuenta',
          style: TextStyle(
            color: ColorTokens.neutral100,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTokens.neutral100),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          if (user == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorTokens.secondary50,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Sección de Información de Cuenta
                Text(
                  'Información de Cuenta',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Tarjeta de Correo Electrónico
                _buildAccountInfoCard(
                  icon: Icons.email_outlined,
                  title: 'Correo Electrónico',
                  value: (user.email?.isNotEmpty ?? false)
                      ? user.email!
                      : 'No vinculado',
                  isLinked: user.email?.isNotEmpty ?? false,
                  context: context,
                ),
                SizedBox(height: 12),

                // Tarjeta de Teléfono
                _buildAccountInfoCard(
                  icon: Icons.phone_android_outlined,
                  title: 'Número de Teléfono',
                  value: user.phoneNumber.isNotEmpty
                      ? _formatPhoneNumber(user.phoneNumber)
                      : 'No vinculado',
                  isLinked: user.phoneNumber.isNotEmpty,
                  context: context,
                ),
                SizedBox(height: 32),

                // Sección de Dispositivos
                Text(
                  'Dispositivos Vinculados',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Tarjeta de Dispositivo Actual
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary40,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorTokens.secondary50.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorTokens.secondary50.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.smartphone,
                          color: ColorTokens.secondary50,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Este Dispositivo',
                              style: TextStyle(
                                color: ColorTokens.neutral100,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Actualmente sesión iniciada',
                              style: TextStyle(
                                color: ColorTokens.neutral80,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTokens.success50.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Activo',
                          style: TextStyle(
                            color: ColorTokens.success50,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Sección de Privacidad
                Text(
                  'Privacidad y Seguridad',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Botón para cambiar contraseña
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.lock_outline,
                  title: 'Cambiar Contraseña',
                  subtitle: 'Actualiza tu contraseña regularmente',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Función en desarrollo'),
                        backgroundColor: ColorTokens.warning50,
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),

                // Botón para ver actividad
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.history,
                  title: 'Historial de Actividad',
                  subtitle: 'Ve dónde iniciaste sesión',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Función en desarrollo'),
                        backgroundColor: ColorTokens.warning50,
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),

                // Botón para verificación de cuenta
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.verified_user,
                  title: 'Verificar Cuenta',
                  subtitle: 'Confirma tu identidad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Función en desarrollo'),
                        backgroundColor: ColorTokens.warning50,
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                // Sección de Apariencia
                Text(
                  'Apariencia',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, child) {
                    final isDark = themeNotifier.themeMode == ThemeMode.dark;
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorTokens.primary40,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorTokens.neutral60.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColorTokens.primary50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: ColorTokens.neutral100,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Modo Oscuro',
                                  style: TextStyle(
                                    color: ColorTokens.neutral100,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isDark ? 'Activado' : 'Desactivado',
                                  style: TextStyle(
                                    color: ColorTokens.neutral80,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (value) {
                              themeNotifier.setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                            activeColor: ColorTokens.secondary50,
                            activeTrackColor: ColorTokens.secondary50
                                .withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye una tarjeta con información de cuenta
  Widget _buildAccountInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isLinked,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.primary40,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLinked
              ? ColorTokens.success50.withValues(alpha: 0.3)
              : ColorTokens.neutral60.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLinked
                  ? ColorTokens.success50.withValues(alpha: 0.2)
                  : ColorTokens.neutral60.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLinked ? ColorTokens.success50 : ColorTokens.neutral80,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: isLinked
                        ? ColorTokens.neutral100
                        : ColorTokens.neutral80,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          if (isLinked)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorTokens.success50.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: ColorTokens.success50,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  /// Construye un botón de opción de configuración
  Widget _buildSettingOptionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorTokens.primary40,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTokens.neutral60.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorTokens.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ColorTokens.neutral100, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ColorTokens.neutral100,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ColorTokens.neutral80,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: ColorTokens.neutral80,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea el número de teléfono
  String _formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Si comienza con 57 (código de Colombia), remover
    if (cleaned.startsWith('57')) {
      cleaned = cleaned.substring(2);
    }

    // Formatear como XXX XXX XXXX
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }

    return phoneNumber;
  }
}
