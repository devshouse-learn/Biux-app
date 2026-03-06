import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: Text(
          l.t('account_settings'),
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
                  l.t('account_info'),
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
                  title: l.t('email_label'),
                  value: (user.email?.isNotEmpty ?? false)
                      ? user.email!
                      : l.t('not_linked'),
                  isLinked: user.email?.isNotEmpty ?? false,
                  context: context,
                ),
                SizedBox(height: 12),

                // Tarjeta de Teléfono
                _buildAccountInfoCard(
                  icon: Icons.phone_android_outlined,
                  title: l.t('phone_number'),
                  value: user.phoneNumber.isNotEmpty
                      ? _formatPhoneNumber(user.phoneNumber)
                      : l.t('not_linked'),
                  isLinked: user.phoneNumber.isNotEmpty,
                  context: context,
                ),
                SizedBox(height: 32),

                // Sección de Dispositivos
                Text(
                  l.t('linked_devices'),
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
                              l.t('this_device'),
                              style: TextStyle(
                                color: ColorTokens.neutral100,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              l.t('currently_logged_in'),
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
                          l.t('active_status'),
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
                  l.t('privacy_security'),
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
                  title: l.t('change_password'),
                  subtitle: l.t('change_password_subtitle'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('feature_in_development')),
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
                  title: l.t('activity_history'),
                  subtitle: l.t('see_where_logged_in'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('feature_in_development')),
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
                  title: l.t('verify_account'),
                  subtitle: l.t('confirm_identity'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('feature_in_development')),
                        backgroundColor: ColorTokens.warning50,
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                // Sección de Apariencia
                Text(
                  l.t('appearance'),
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
                                  l.t('dark_mode'),
                                  style: TextStyle(
                                    color: ColorTokens.neutral100,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isDark
                                      ? l.t('activated')
                                      : l.t('deactivated'),
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
                            activeThumbColor: ColorTokens.secondary50,
                            activeTrackColor: ColorTokens.secondary50
                                .withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 32),

                // Sección de Opciones de Cuenta
                Text(
                  l.t('account_options'),
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Botón Cerrar Sesión
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.logout,
                  title: l.t('logout'),
                  subtitle: l.t('close_current_session'),
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
                SizedBox(height: 12),

                // Botón Eliminar Cuenta
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.delete_forever,
                  title: l.t('delete_account'),
                  subtitle: l.t('permanently_delete_account'),
                  onTap: () {
                    _showDeleteAccountDialog();
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

  void _showLogoutDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l.t('logout')),
          content: Text(l.t('sign_out_confirm')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l.t('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final userProvider = context.read<UserProvider>();
                await userProvider.signOut();
                if (mounted) {
                  context.go('/login');
                }
              },
              child: Text(l.t('confirm'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l.t('delete_account')),
          content: Text(l.t('delete_account_confirm')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l.t('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final userProvider = context.read<UserProvider>();
                await userProvider.requestAccountDeletion();
                if (mounted) {
                  context.go('/login');
                }
              },
              child: Text(l.t('confirm'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
