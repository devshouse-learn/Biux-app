import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/users/data/models/user_model.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla para que los administradores gestionen permisos de vendedores
class ManageSellersScreen extends StatefulWidget {
  const ManageSellersScreen({Key? key}) : super(key: key);

  @override
  State<ManageSellersScreen> createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends State<ManageSellersScreen> {
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final users = await userProvider.getAllUsers();

    setState(() {
      _allUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleSellerPermission(UserModel user) async {
    final userProvider = context.read<UserProvider>();

    final bool success;
    if (user.canSellProducts) {
      success = await userProvider.revokeSellerPermission(user.uid);
    } else {
      success = await userProvider.authorizeSeller(user.uid);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.canSellProducts
                ? 'Permiso revocado exitosamente'
                : 'Vendedor autorizado exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers(); // Recargar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Error al actualizar permisos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.user;

    // Verificar que el usuario actual sea administrador
    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso Denegado'),
          backgroundColor: ColorTokens.primary30,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Solo los administradores\npueden acceder a esta sección',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop'),
          tooltip: 'Volver a la tienda',
        ),
        title: const Text('Gestionar Vendedores'),
        backgroundColor: ColorTokens.primary30,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allUsers.isEmpty
          ? const Center(child: Text('No hay usuarios registrados'))
          : ListView.builder(
              itemCount: _allUsers.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final user = _allUsers[index];

                // No mostrar al usuario actual ni otros administradores
                if (user.uid == currentUser.uid || user.isAdmin) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: user.canSellProducts
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Icon(
                              Icons.person,
                              color: user.canSellProducts
                                  ? Colors.green
                                  : Colors.grey,
                              size: 32,
                            )
                          : null,
                    ),
                    title: Text(
                      user.name ?? user.username ?? 'Usuario sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user.email != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.email!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.phoneNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.canSellProducts
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: user.canSellProducts
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.canSellProducts
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 14,
                                color: user.canSellProducts
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.canSellProducts
                                    ? 'Vendedor Autorizado'
                                    : 'Sin permiso para vender',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: user.canSellProducts
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: user.canSellProducts,
                      onChanged: (value) => _toggleSellerPermission(user),
                      thumbColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.green;
                        }
                        return Colors.grey;
                      }),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
