import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/config/router/app_routes.dart';

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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),

                // ========== DATOS PERSONALES ==========
                Text(
                  'Datos Personales',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Nombre Completo
                _buildPersonalDataCard(
                  icon: Icons.person_outline,
                  title: 'Nombre Completo',
                  value: (user.name?.isNotEmpty ?? false)
                      ? user.name!
                      : 'No registrado',
                  hasValue: user.name?.isNotEmpty ?? false,
                  onEdit: () => _showEditNameDialog(user.name ?? ''),
                ),
                SizedBox(height: 12),

                // Fecha de Nacimiento + Edad
                _buildPersonalDataCard(
                  icon: Icons.cake_outlined,
                  title: 'Fecha de Nacimiento',
                  value: user.birthDate != null
                      ? _formatBirthDate(user.birthDate!)
                      : 'No registrada',
                  hasValue: user.birthDate != null,
                  onEdit: () => _showEditBirthDateDialog(user.birthDate),
                  trailing: user.birthDate != null
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorTokens.secondary50.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_calculateAge(user.birthDate!)} años',
                            style: TextStyle(
                              color: ColorTokens.secondary50,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(height: 12),

                // Número de Teléfono Vinculado
                _buildPersonalDataCard(
                  icon: Icons.phone_android_outlined,
                  title: 'Número de Teléfono Vinculado',
                  value: user.phoneNumber.isNotEmpty
                      ? _formatPhoneNumber(user.phoneNumber)
                      : 'No vinculado',
                  hasValue: user.phoneNumber.isNotEmpty,
                ),
                SizedBox(height: 12),

                // Correo Electrónico Vinculado
                _buildPersonalDataCard(
                  icon: Icons.email_outlined,
                  title: 'Correo Electrónico Vinculado',
                  value: (user.email?.isNotEmpty ?? false)
                      ? user.email!
                      : 'No vinculado',
                  hasValue: user.email?.isNotEmpty ?? false,
                  onEdit: () => _showEditEmailDialog(user.email ?? ''),
                ),
                SizedBox(height: 32),

                // ========== SEGURIDAD Y VERIFICACIÓN ==========
                Text(
                  'Seguridad y Verificación',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.verified_user_outlined,
                  title: 'Verificar Cuenta',
                  subtitle: 'Estado de verificación por teléfono y email',
                  onTap: () => _showVerifyAccountDialog(),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.lock_outline,
                  title: 'Cambiar Contraseña',
                  subtitle: 'Actualiza tu contraseña de acceso',
                  onTap: () => _showChangePasswordDialog(),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.history,
                  title: 'Historial de Actividad',
                  subtitle: 'Sesiones y proveedores de autenticación',
                  onTap: () => _showActivityHistoryDialog(),
                ),
                SizedBox(height: 32),

                // ========== TU ACTIVIDAD ==========
                Text(
                  'Tu Actividad',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.favorite_outline,
                  title: 'Me gusta',
                  subtitle: 'Contenido al que le diste like',
                  onTap: () => context.push('/activity/likes'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Comentarios',
                  subtitle: 'Comentarios que has realizado',
                  onTap: () => context.push('/activity/comments'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.grid_on,
                  title: 'Publicaciones',
                  subtitle: 'Publicaciones que has subido',
                  onTap: () => context.push('/activity/posts'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.auto_stories_outlined,
                  title: 'Historias',
                  subtitle: 'Historias que has compartido',
                  onTap: () => context.push('/activity/stories'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.timer_outlined,
                  title: 'Tiempo en la App',
                  subtitle: 'Promedio diario y estadísticas de uso',
                  onTap: () => context.push('/activity/screen-time'),
                ),
                SizedBox(height: 32),

                // ========== CONFIGURACIÓN ==========
                Text(
                  'Configuración',
                  style: TextStyle(
                    color: ColorTokens.neutral100,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.shield_outlined,
                  title: 'Privacidad',
                  subtitle: 'Visibilidad del perfil y permisos',
                  onTap: () => context.push('/settings/privacy'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Configura tus alertas y notificaciones',
                  onTap: () => context.push(AppRoutes.notificationSettings),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.palette_outlined,
                  title: 'Apariencia',
                  subtitle: 'Tema e idioma de la aplicación',
                  onTap: () => context.push('/settings/appearance'),
                ),
                SizedBox(height: 12),

                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'Información',
                  subtitle: 'Versión, términos y soporte técnico',
                  onTap: () => context.push('/settings/information'),
                ),
                SizedBox(height: 32),

                // Sección de Opciones de Cuenta
                Text(
                  'Opciones de Cuenta',
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
                  title: 'Cerrar Sesión',
                  subtitle: 'Cierra tu sesión actual',
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
                SizedBox(height: 12),

                // Botón Eliminar Cuenta
                _buildSettingOptionButton(
                  context: context,
                  icon: Icons.delete_forever,
                  title: 'Eliminar Cuenta',
                  subtitle: 'Elimina permanentemente tu cuenta',
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

  /// Construye una tarjeta de datos personales
  Widget _buildPersonalDataCard({
    required IconData icon,
    required String title,
    required String value,
    required bool hasValue,
    Widget? trailing,
    VoidCallback? onEdit,
  }) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorTokens.primary40,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? ColorTokens.secondary50.withValues(alpha: 0.3)
                : ColorTokens.neutral60.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasValue
                    ? ColorTokens.secondary50.withValues(alpha: 0.2)
                    : ColorTokens.neutral60.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: hasValue
                    ? ColorTokens.secondary50
                    : ColorTokens.neutral80,
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
                      color: hasValue
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
            if (trailing != null) ...[SizedBox(width: 8), trailing],
            if (onEdit != null) ...[
              SizedBox(width: 8),
              Icon(Icons.edit_outlined, color: ColorTokens.neutral80, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  /// Diálogo para editar el nombre
  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ColorTokens.primary40,
          title: Text(
            'Editar Nombre',
            style: TextStyle(color: ColorTokens.neutral100),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: ColorTokens.neutral100),
            decoration: InputDecoration(
              hintText: 'Tu nombre completo',
              hintStyle: TextStyle(color: ColorTokens.neutral80),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTokens.neutral60),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTokens.secondary50),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: ColorTokens.neutral80),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  final userProvider = context.read<UserProvider>();
                  await userProvider.updateProfile(name: newName);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nombre actualizado'),
                        backgroundColor: ColorTokens.success50,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: ColorTokens.secondary50),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diálogo para editar la fecha de nacimiento
  void _showEditBirthDateDialog(DateTime? currentDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: ColorTokens.secondary50,
              onPrimary: ColorTokens.neutral100,
              surface: ColorTokens.primary40,
              onSurface: ColorTokens.neutral100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final userProvider = context.read<UserProvider>();
      await userProvider.updateProfile(birthDate: picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fecha de nacimiento actualizada'),
            backgroundColor: ColorTokens.success50,
          ),
        );
      }
    }
  }

  /// Diálogo para editar el correo electrónico
  void _showEditEmailDialog(String currentEmail) {
    final controller = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ColorTokens.primary40,
          title: Text(
            'Editar Correo Electrónico',
            style: TextStyle(color: ColorTokens.neutral100),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: ColorTokens.neutral100),
            decoration: InputDecoration(
              hintText: 'correo@ejemplo.com',
              hintStyle: TextStyle(color: ColorTokens.neutral80),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTokens.neutral60),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTokens.secondary50),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: ColorTokens.neutral80),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newEmail = controller.text.trim();
                if (newEmail.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  final userProvider = context.read<UserProvider>();
                  await userProvider.updateProfile(email: newEmail);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Correo electrónico actualizado'),
                        backgroundColor: ColorTokens.success50,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: ColorTokens.secondary50),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Formatea la fecha de nacimiento
  String _formatBirthDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Calcula la edad a partir de la fecha de nacimiento
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
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

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
