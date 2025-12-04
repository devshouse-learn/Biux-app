import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/presentation/widgets/price_tag.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:go_router/go_router.dart';

/// Pantalla del carrito de compras
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  void _showCheckoutDialog(BuildContext context) {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Compra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección de entrega',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono de contacto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addressController.text.isEmpty ||
                  phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos'),
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop();

              final shopProvider = context.read<ShopProvider>();
              final userProvider = context.read<UserProvider>();
              
              final currentUser = userProvider.user;
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: usuario no encontrado'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final orderId = await shopProvider.createOrderFromCart(
                userId: currentUser.uid,
                userName: currentUser.username ?? currentUser.name ?? 'Usuario',
                deliveryAddress: addressController.text,
                phoneNumber: phoneController.text,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );

              if (orderId != null) {
                // Éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Pedido realizado con éxito!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/shop');
              } else {
                // Error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        shopProvider.errorMessage ?? 'Error al crear pedido'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.secondary50,
            ),
            child: const Text('Confirmar Pedido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: ColorTokens.primary30,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          if (shopProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/shop');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.secondary50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Ir a la tienda'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Lista de items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shopProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = shopProvider.cartItems[index];
                    final product = item.product;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Imagen del producto
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: product.mainImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.shopping_bag),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.shopping_bag),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Info del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.selectedSize != null)
                                    Text(
                                      'Talla: ${item.selectedSize}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  SmallPriceTag(price: product.price),
                                ],
                              ),
                            ),

                            // Controles de cantidad
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            shopProvider.updateCartItemQuantity(
                                              product.id,
                                              item.quantity - 1,
                                              selectedSize: item.selectedSize,
                                            );
                                          }
                                        },
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () {
                                          if (item.quantity < product.stock) {
                                            shopProvider.updateCartItemQuantity(
                                              product.id,
                                              item.quantity + 1,
                                              selectedSize: item.selectedSize,
                                            );
                                          }
                                        },
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Botón eliminar
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    shopProvider.removeFromCart(
                                      product.id,
                                      selectedSize: item.selectedSize,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Resumen y checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Total de items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total de items:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${shopProvider.cartItemCount}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Total a pagar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a pagar:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LargePriceTag(price: shopProvider.cartTotal),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botón de checkout
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showCheckoutDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTokens.secondary50,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Finalizar Compra',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
