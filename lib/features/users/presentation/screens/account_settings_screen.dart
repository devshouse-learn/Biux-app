import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
                onTap: () => context.push(AppRoutes.activeSessions),
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

              // --- Tu Actividad ---
              SettingsWidgets.buildSectionTitle(l.t('your_activity'), isDark),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.favorite_outline,
                title: l.t('activity_likes'),
                subtitle: l.t('activity_likes_subtitle'),
                isDark: isDark,
                onTap: () => context.push('/activity/likes'),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.chat_bubble_outline,
                title: l.t('activity_comments'),
                subtitle: l.t('activity_comments_subtitle'),
                isDark: isDark,
                onTap: () => context.push('/activity/comments'),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.grid_on_outlined,
                title: l.t('activity_posts'),
                subtitle: l.t('activity_posts_subtitle'),
                isDark: isDark,
                onTap: () => context.push('/activity/posts'),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.auto_stories_outlined,
                title: l.t('activity_stories'),
                subtitle: l.t('activity_stories_subtitle'),
                isDark: isDark,
                onTap: () => context.push('/activity/stories'),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.access_time_outlined,
                title: l.t('activity_screen_time'),
                subtitle: l.t('activity_screen_time_subtitle'),
                isDark: isDark,
                onTap: () => context.push('/activity/screen-time'),
              ),

              const SizedBox(height: 24),

              // --- Apariencia (redirige a la pantalla completa de apariencia) ---
              SettingsWidgets.buildSectionTitle(l.t('appearance'), isDark),
              const SizedBox(height: 12),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: l.t('appearance'),
                subtitle: l.t('appearance_subtitle'),
                isDark: isDark,
                onTap: () => context.push(AppRoutes.notificationSettings),
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
                onTap: () => _showLogoutDialog(),
              ),
              const SizedBox(height: 8),
              SettingsWidgets.buildOptionCard(
                context: context,
                icon: Icons.delete_forever,
                title: l.t('delete_account'),
                subtitle: l.t('permanently_delete_account'),
                isDark: isDark,
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

  // ===== CAMBIAR CONTRASEÑA =====
  // ignore: unused_element
  void _showChangePasswordDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userEmail = firebaseUser?.email;

    if (userEmail != null && userEmail.isNotEmpty) {
      // Tiene email vinculado → enviar reset
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.t('change_password')),
          content: Text('${l.t('enter_email_for_reset')}\n\n$userEmail'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: userEmail,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('password_reset_sent')),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('error_sending_email')),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
              ),
              child: Text(l.t('send_reset_link')),
            ),
          ],
        ),
      );
    } else {
      // No tiene email → pedir que vincule uno
      final emailController = TextEditingController();
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.t('change_password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.t('no_email_linked')),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l.t('email_label'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) return;
                Navigator.of(dialogContext).pop();
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('password_reset_sent')),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.t('error_sending_email')),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
              ),
              child: Text(l.t('send_reset_link')),
            ),
          ],
        ),
      );
    }
  }

  // ===== HISTORIAL DE ACTIVIDAD =====
  // ignore: unused_element
  void _showActivityHistoryDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Obtener info de la sesión
    final creationTime = firebaseUser?.metadata.creationTime;
    final lastSignIn = firebaseUser?.metadata.lastSignInTime;
    final providers = firebaseUser?.providerData ?? [];

    String providerLabel(String providerId) {
      switch (providerId) {
        case 'phone':
          return l.t('phone_auth');
        case 'password':
          return l.t('email_auth');
        case 'google.com':
          return l.t('google_auth');
        default:
          return providerId;
      }
    }

    IconData providerIcon(String providerId) {
      switch (providerId) {
        case 'phone':
          return Icons.phone_android;
        case 'password':
          return Icons.email_outlined;
        case 'google.com':
          return Icons.g_mobiledata;
        default:
          return Icons.login;
      }
    }

    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? ColorTokens.primary40 : Colors.white,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.t('activity_history'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Fecha de creación
            _buildActivityRow(
              icon: Icons.calendar_today,
              label: l.t('account_created_date'),
              value: creationTime != null
                  ? dateFormat.format(creationTime.toLocal())
                  : '—',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Último inicio de sesión
            _buildActivityRow(
              icon: Icons.access_time,
              label: l.t('last_login_date'),
              value: lastSignIn != null
                  ? dateFormat.format(lastSignIn.toLocal())
                  : '—',
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Proveedores de login
            Text(
              l.t('login_provider'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            ...providers.map(
              (info) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTokens.primary30.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        providerIcon(info.providerId),
                        color: ColorTokens.primary30,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerLabel(info.providerId),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (info.email != null && info.email!.isNotEmpty)
                            Text(
                              info.email!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          if (info.phoneNumber != null &&
                              info.phoneNumber!.isNotEmpty)
                            Text(
                              info.phoneNumber!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ColorTokens.primary30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== VERIFICAR CUENTA =====
  // ignore: unused_element
  bool _isAccountVerified() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;
    // Si tiene teléfono verificado, está verificado
    if (firebaseUser.phoneNumber != null &&
        firebaseUser.phoneNumber!.isNotEmpty) {
      return true;
    }
    // Si tiene email verificado
    return firebaseUser.emailVerified;
  }

  // ignore: unused_element
  void _showVerifyAccountDialog() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPhoneVerified =
        firebaseUser?.phoneNumber != null &&
        firebaseUser!.phoneNumber!.isNotEmpty;
    final isEmailVerified = firebaseUser?.emailVerified ?? false;
    final hasEmail =
        firebaseUser?.email != null && firebaseUser!.email!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? ColorTokens.primary40 : Colors.white,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icono principal
            Icon(
              isPhoneVerified || isEmailVerified
                  ? Icons.verified
                  : Icons.shield_outlined,
              size: 64,
              color: isPhoneVerified || isEmailVerified
                  ? Colors.green.shade400
                  : Colors.orange.shade400,
            ),
            const SizedBox(height: 16),

            Text(
              isPhoneVerified || isEmailVerified
                  ? l.t('account_verified')
                  : l.t('verify_account'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Estado de verificación por teléfono
            if (isPhoneVerified)
              _buildVerificationRow(
                icon: Icons.phone_android,
                label: l.t('verified_by_phone'),
                value: firebaseUser.phoneNumber!,
                isVerified: true,
                isDark: isDark,
              ),

            // Estado de verificación por email
            if (hasEmail) ...[
              const SizedBox(height: 12),
              _buildVerificationRow(
                icon: Icons.email_outlined,
                label: l.t('email_auth'),
                value: firebaseUser.email!,
                isVerified: isEmailVerified,
                isDark: isDark,
              ),
            ],

            // Botón para enviar verificación de email si no está verificado
            if (hasEmail && !isEmailVerified) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await firebaseUser.sendEmailVerification();
                      Navigator.of(sheetContext).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.t('email_verification_sent')),
                            backgroundColor: Colors.green.shade600,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.t('error_sending_email')),
                            backgroundColor: Colors.red.shade600,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: Text(l.t('send_verification_email')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isVerified,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorTokens.primary30, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            color: isVerified ? Colors.green.shade400 : Colors.orange.shade400,
            size: 22,
          ),
        ],
      ),
    );
  }
}
