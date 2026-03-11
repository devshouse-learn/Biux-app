import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/design_system/theme_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      backgroundColor: SettingsWidgets.scaffoldBackground(isDark),
      appBar: SettingsWidgets.buildAppBar(context, l.t('account_settings')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: ColorTokens.primary30),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Información de Cuenta ---
              SettingsWidgets.buildSectionTitle(l.t('account_info'), isDark),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.email_outlined,
                title: l.t('email_label'),
                subtitle: (user.email?.isNotEmpty ?? false)
                    ? user.email!
                    : l.t('not_linked'),
                isDark: isDark,
                iconColor: (user.email?.isNotEmpty ?? false)
                    ? Colors.green.shade400
                    : null,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.phone_android_outlined,
                title: l.t('phone_number'),
                subtitle: user.phoneNumber.isNotEmpty
                    ? _formatPhoneNumber(user.phoneNumber)
                    : l.t('not_linked'),
                isDark: isDark,
                iconColor: user.phoneNumber.isNotEmpty
                    ? Colors.green.shade400
                    : null,
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // --- Dispositivos ---
              SettingsWidgets.buildSectionTitle(l.t('linked_devices'), isDark),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.smartphone,
                title: l.t('this_device'),
                subtitle: l.t('currently_logged_in'),
                isDark: isDark,
                iconColor: Colors.green.shade400,
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // --- Privacidad y Seguridad ---
              SettingsWidgets.buildSectionTitle(
                l.t('privacy_security'),
                isDark,
              ),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.lock_outline,
                title: l.t('change_password'),
                subtitle: l.t('change_password_subtitle'),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('feature_in_development')),
                      backgroundColor: Colors.orange.shade600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.history,
                title: l.t('activity_history'),
                subtitle: l.t('see_where_logged_in'),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('feature_in_development')),
                      backgroundColor: Colors.orange.shade600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.verified_user,
                title: l.t('verify_account'),
                subtitle: l.t('confirm_identity'),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('feature_in_development')),
                      backgroundColor: Colors.orange.shade600,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Apariencia ---
              SettingsWidgets.buildSectionTitle(l.t('appearance'), isDark),
              const SizedBox(height: 12),
              Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, child) {
                  final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;
                  return SettingsWidgets.buildToggleCard(
                    context: context,
                    icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    title: l.t('dark_mode'),
                    subtitle: isDarkMode
                        ? l.t('activated')
                        : l.t('deactivated'),
                    isDark: isDark,
                    value: isDarkMode,
                    onChanged: (value) {
                      themeNotifier.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    iconColor: isDarkMode
                        ? const Color(0xFF1A237E)
                        : const Color(0xFFFF9800),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Opciones de Cuenta ---
              SettingsWidgets.buildSectionTitle(l.t('account_options'), isDark),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.logout,
                title: l.t('logout'),
                subtitle: l.t('close_current_session'),
                isDark: isDark,
                iconColor: Colors.orange.shade400,
                onTap: () => _showLogoutDialog(),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.delete_forever,
                title: l.t('delete_account'),
                subtitle: l.t('permanently_delete_account'),
                isDark: isDark,
                iconColor: Colors.red.shade400,
                onTap: () => _showDeleteAccountDialog(),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
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
