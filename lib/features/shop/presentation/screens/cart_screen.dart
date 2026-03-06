import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/shop/presentation/widgets/price_tag.dart';
import 'package:biux/features/shop/presentation/widgets/payment_method_selector.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:go_router/go_router.dart';

/// Pantalla del carrito de compras
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  void _showCheckoutDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    PaymentMethod? selectedPaymentMethod;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.t('checkout')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de método de pago
                CompactPaymentMethodSelector(
                  selectedMethod: selectedPaymentMethod,
                  onChanged: (method) {
                    setState(() {
                      selectedPaymentMethod = method;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: l.t('delivery_address'),
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: l.t('contact_phone'),
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: l.t('additional_notes'),
                    prefixIcon: Icon(Icons.note),
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
              child: Text(l.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPaymentMethod == null ||
                    addressController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.t('fill_required_fields')),
                      backgroundColor: Colors.orange,
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
                    SnackBar(
                      content: Text(l.t('user_not_found')),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final orderId = await shopProvider.createOrderFromCart(
                  userId: currentUser.uid,
                  userName:
                      currentUser.username ??
                      currentUser.name ??
                      l.t('default_user'),
                  deliveryAddress: addressController.text,
                  phoneNumber: phoneController.text,
                  notes: notesController.text.isEmpty
                      ? '${l.t('payment_method_prefix')}: ${l.t(selectedPaymentMethod!.labelKey)}'
                      : '${l.t('payment_method_prefix')}: ${l.t(selectedPaymentMethod!.labelKey)}\n${notesController.text}',
                );

                if (orderId != null) {
                  // Éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l.t('order_success')}\n${l.t('payment_method_label')}: ${l.t(selectedPaymentMethod!.labelKey)}',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  context.go('/shop');
                } else {
                  // Error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        shopProvider.errorMessage ?? l.t('order_error'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary50,
              ),
              child: Text(l.t('confirm_order')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/shop');
            }
          },
        ),
        title: Text(l.t('shopping_cart')),
        backgroundColor: ColorTokens.primary30,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          final isEmpty = shopProvider.cartItems.isEmpty;

          return Column(
            children: [
              // Lista de items o mensaje vacío
              Expanded(
                child: isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorTokens.primary30.withValues(
                                  alpha: 0.1,
                                ),
                                border: Border.all(
                                  color: ColorTokens.primary30.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 60,
                                color: ColorTokens.primary30,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l.t('cart_empty'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l.t('cart_empty_subtitle'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.go('/shop');
                              },
                              icon: const Icon(Icons.pedal_bike, size: 22),
                              label: Text(l.t('explore_products')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTokens.primary30,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: shopProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = shopProvider.cartItems[index];
                          final product = item.product;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                // Navegar al detalle del producto
                                context.go('/shop/${product.id}');
                              },
                              borderRadius: BorderRadius.circular(12),
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
                                        placeholder: (context, url) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.shopping_bag,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.shopping_bag,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Info del producto
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              '${l.t('size_label')}: ${item.selectedSize}',
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
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  if (item.quantity > 1) {
                                                    shopProvider
                                                        .updateCartItemQuantity(
                                                          product.id,
                                                          item.quantity - 1,
                                                          selectedSize:
                                                              item.selectedSize,
                                                        );
                                                  }
                                                },
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  if (item.quantity <
                                                      product.stock) {
                                                    shopProvider
                                                        .updateCartItemQuantity(
                                                          product.id,
                                                          item.quantity + 1,
                                                          selectedSize:
                                                              item.selectedSize,
                                                        );
                                                  }
                                                },
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                constraints:
                                                    const BoxConstraints(),
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
                            ),
                          );
                        },
                      ),
              ),

              // Resumen y checkout - Solo visible cuando hay productos
              if (!isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Información de métodos de pago
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l.t('payment_methods_info'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de cupón
                        const _CouponField(),
                        const SizedBox(height: 16),

                        // Total de items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.t('total_items')}:',
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

                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.t('subtotal')}:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '\$${(shopProvider.cartTotal * 1).toStringAsFixed(0)} COP',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Descuento por cupón (si aplica)
                        Consumer<ShopProvider>(
                          builder: (context, shopProvider, _) {
                            if (shopProvider.appliedCoupon != null) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${l.t('discount_label')} (${shopProvider.appliedCoupon}):',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '- \$${shopProvider.couponDiscount.toStringAsFixed(0)} COP',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Envío
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.t('shipping_label')}:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              shopProvider.cartTotal >= 100000
                                  ? l.t('free_label')
                                  : '\$${(15000).toStringAsFixed(0)} COP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: shopProvider.cartTotal >= 100000
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Total a pagar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l.t('total_to_pay')}:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${((shopProvider.cartTotalWithDiscount) + (shopProvider.cartTotal >= 100000 ? 0 : 15000)).toStringAsFixed(0)} COP',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorTokens.primary30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botón de checkout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCheckoutDialog(context),
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: Text(l.t('checkout')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.primary30,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
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

/// Widget para aplicar cupones de descuento
class _CouponField extends StatefulWidget {
  const _CouponField();

  @override
  State<_CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<_CouponField> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        // Si ya hay un cupón aplicado, mostrar badge con opción de remover
        if (shopProvider.appliedCoupon != null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopProvider.appliedCoupon!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.t('savings')}: \$${shopProvider.couponDiscount.toStringAsFixed(0)} COP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    shopProvider.removeCoupon();
                    _couponController.clear();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: l.t('remove_coupon'),
                ),
              ],
            ),
          );
        }

        // Campo para ingresar cupón
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: l.t('coupon_question'),
                      hintText: l.t('coupon_hint_example'),
                      prefixIcon: Icon(
                        Icons.confirmation_number,
                        color: ColorTokens.primary30,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.primary30,
                          width: 2,
                        ),
                      ),
                      errorText: shopProvider.couponErrorMessage,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _applyCoupon(shopProvider, context),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _applyCoupon(shopProvider, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    l.t('apply'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botón para ver cupones disponibles
            InkWell(
              onTap: () => _showAvailableCoupons(context, shopProvider),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.t('view_available_coupons'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[700],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyCoupon(ShopProvider shopProvider, BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final coupon = _couponController.text.trim();
    if (coupon.isNotEmpty) {
      final success = shopProvider.applyCoupon(coupon);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 ${l.t('coupon_applied')} ${l.t('savings')}: \$${shopProvider.couponDiscount.toStringAsFixed(0)} COP',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _couponController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('enter_coupon_code')),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAvailableCoupons(BuildContext context, ShopProvider shopProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final coupons = shopProvider.getAvailableCoupons();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorTokens.primary30,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.t('available_coupons'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Información de compra mínima
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.t('min_purchase')}: \$50.000 COP',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de cupones
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final category = coupons[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          category['category'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorTokens.primary30,
                          ),
                        ),
                      ),
                      ...List.generate(category['coupons'].length, (
                        couponIndex,
                      ) {
                        final coupon = category['coupons'][couponIndex];
                        return _CouponCard(
                          code: coupon['code'],
                          discount: coupon['discount'],
                          description: coupon['description'],
                          onTap: () {
                            Navigator.pop(context);
                            _couponController.text = coupon['code'];
                            _applyCoupon(shopProvider, context);
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una tarjeta de cupón
class _CouponCard extends StatelessWidget {
  final String code;
  final String discount;
  final String description;
  final VoidCallback onTap;

  const _CouponCard({
    required this.code,
    required this.discount,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorTokens.primary30.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.primary30.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Badge de descuento
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.primary30,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del cupón
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Botón de aplicar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
