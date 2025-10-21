import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/presentation/providers/edit_username_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

/// Pantalla para editar el nombre de usuario (@username)
class EditUsernameScreen extends StatefulWidget {
  const EditUsernameScreen({super.key});

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EditUsernameProvider>(
        context,
        listen: false,
      );
      provider.loadCurrentUsername();
      _usernameController.text = provider.currentUsername;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.neutral10,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        title: const Text('Editar Usuario'),
        elevation: 0,
      ),
      body: Consumer<EditUsernameProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información explicativa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorTokens.info90,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorTokens.info40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: ColorTokens.primary50,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nombre de usuario',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ColorTokens.primary30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu nombre de usuario (@username) es como te encontrarán otros usuarios. Debe ser único y solo puede contener letras, números y guiones bajos.',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorTokens.neutral70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campo de username
                  Text(
                    'Nombre de usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.neutral90,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _usernameController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'miusuario',
                      prefixText: '@',
                      prefixStyle: TextStyle(
                        color: ColorTokens.primary50,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: ColorTokens.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorTokens.neutral30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorTokens.neutral30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.primary50,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.error50,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.error50,
                          width: 2,
                        ),
                      ),
                      suffixIcon: provider.isCheckingAvailability
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : provider.usernameAvailable == true
                          ? Icon(
                              Icons.check_circle,
                              color: ColorTokens.success50,
                            )
                          : provider.usernameAvailable == false
                          ? Icon(Icons.error, color: ColorTokens.error50)
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre de usuario es obligatorio';
                      }

                      if (value.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }

                      if (value.trim().length > 30) {
                        return 'No puede tener más de 30 caracteres';
                      }

                      // Validar formato
                      final regex = RegExp(r'^[a-zA-Z0-9_]+$');
                      if (!regex.hasMatch(value.trim())) {
                        return 'Solo letras, números y guiones bajos';
                      }

                      // Validar disponibilidad
                      if (provider.usernameAvailable == false) {
                        return 'Este nombre de usuario no está disponible';
                      }

                      return null;
                    },
                    onChanged: (value) {
                      // Debounce de 500ms para verificar disponibilidad
                      provider.checkUsernameAvailability(value.trim());
                    },
                  ),

                  // Mensaje de estado
                  if (provider.availabilityMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      provider.availabilityMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: provider.usernameAvailable == true
                            ? ColorTokens.success60
                            : ColorTokens.error60,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: ColorTokens.neutral40),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorTokens.neutral70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              provider.isUpdating ||
                                  provider.isCheckingAvailability ||
                                  provider.usernameAvailable != true
                              ? null
                              : () => _saveUsername(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTokens.primary50,
                            foregroundColor: ColorTokens.neutral100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: provider.isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveUsername(EditUsernameProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.updateUsername(
      _usernameController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Refrescar el UserProvider para mostrar el nuevo username en el perfil
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nombre de usuario actualizado correctamente'),
            backgroundColor: ColorTokens.success50,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error ?? 'Error al actualizar el nombre de usuario',
            ),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }
}
