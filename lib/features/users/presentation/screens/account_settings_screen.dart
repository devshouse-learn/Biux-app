import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Cuenta'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar tu cuenta? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
