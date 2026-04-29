import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/store/presentation/providers/cart_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla del carrito de compras con checkout
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  String? _selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l.t('shopping_cart'))),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.getCartItems()[index];
                    return _buildCartItem(context, item, cart);
                  },
                ),
              ),

              // Resumen y botón de compra
              _buildCheckoutSection(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l.t('cart_empty'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[200]!, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: Colors.orange[700],
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.t('put_products_here'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.t('explore_store_message'),
                    style: TextStyle(fontSize: 14, color: Colors.orange[800]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.t('find_amazing_products'),
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/store');
              },
              icon: const Icon(Icons.shopping_bag, size: 24),
              label: Text(
                l.t('explore_store'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cart,
  ) {
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
              child: product.imagenPrincipal != null
                  ? Image.network(
                      product.imagenPrincipal!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
            ),

            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.precioFinal.toStringAsFixed(0)} COP c/u',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Selector de cantidad
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                cart.decrementQuantity(product.id);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.remove, size: 20),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.cantidad}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                try {
                                  cart.incrementQuantity(product.id);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.add, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Subtotal
                      Text(
                        '\$${item.subtotal.toStringAsFixed(0)} COP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón eliminar
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(
                  context,
                  cart,
                  product.id,
                  product.nombre,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cart) {
    // Validar stock
    final stockIssues = cart.getStockIssues();
    final hasStockIssues = stockIssues.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Advertencias de stock
            if (hasStockIssues) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Problemas de stock',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...stockIssues.map(
                      (issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $issue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resumen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${cart.totalQuantity} ${cart.totalQuantity == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '\$${cart.subtotal.toStringAsFixed(0)} COP',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            // Cupón de descuento
            const SizedBox(height: 16),
            _buildCouponSection(context, cart),

            // Descuento aplicado (si existe)
            if (cart.appliedCoupon != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descuento (${cart.appliedCoupon!.code}):',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '-\$${cart.couponDiscount.toStringAsFixed(0)} COP',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.total.toStringAsFixed(0)} COP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Métodos de pago disponibles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Métodos de pago disponibles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaymentMethod(Icons.credit_card, 'Tarjeta'),
                      _buildPaymentMethod(Icons.account_balance, 'PSE'),
                      _buildPaymentMethod(Icons.phone_android, 'Nequi'),
                      _buildPaymentMethod(Icons.wallet, 'Daviplata'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de envío disponibles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Envíos disponibles a:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildShippingChip('Bogotá', Icons.location_city),
                      _buildShippingChip('Medellín', Icons.location_city),
                      _buildShippingChip('Cali', Icons.location_city),
                      _buildShippingChip('Barranquilla', Icons.location_city),
                      _buildShippingChip('Cartagena', Icons.location_city),
                      _buildShippingChip('Todo Colombia', Icons.public),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Envío gratis en compras mayores a \$150,000 COP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón de compra mejorado
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasStockIssues
                    ? null
                    : () => _processCheckout(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Comprar Ahora',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${cart.total.toStringAsFixed(0)} COP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Botón continuar comprando
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continuar comprando'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CartProvider cart,
    String productId,
    String productName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar producto'),
        content: Text('¿Deseas eliminar "$productName" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cart.removeItem(productId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado del carrito'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Barra superior
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFF059669),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirmar Compra',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Revisa tu pedido',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen del pedido
                    const Text(
                      'Resumen del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Productos:'),
                              Text(
                                '${cart.totalQuantity} ${cart.totalQuantity == 1 ? 'item' : 'items'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text('\$${cart.subtotal.toStringAsFixed(0)} COP'),
                            ],
                          ),
                          if (cart.appliedCoupon != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Descuento (${cart.appliedCoupon!.code}):',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '-\$${cart.couponDiscount.toStringAsFixed(0)} COP',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Envío:'),
                              Text(
                                cart.total >= 150000
                                    ? 'GRATIS'
                                    : '\$15,000 COP',
                                style: TextStyle(
                                  color: cart.total >= 150000
                                      ? const Color(0xFF059669)
                                      : Colors.black,
                                  fontWeight: cart.total >= 150000
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${(cart.total + (cart.total >= 150000 ? 0 : 15000)).toStringAsFixed(0)} COP',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Método de pago
                    const Text(
                      'Selecciona método de pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      context,
                      'Tarjeta de Crédito/Débito',
                      Icons.credit_card,
                      selected: _selectedPayment == 'Tarjeta de Crédito/Débito',
                      onTap: () {
                        setState(
                          () => _selectedPayment = 'Tarjeta de Crédito/Débito',
                        );
                        context.read<CartProvider>().setSelectedPayment(
                          'Tarjeta de Crédito/Débito',
                        );
                      },
                    ),
                    _buildPaymentOption(
                      context,
                      'PSE - Transferencia Bancaria',
                      Icons.account_balance,
                      selected:
                          _selectedPayment == 'PSE - Transferencia Bancaria',
                      onTap: () {
                        setState(
                          () =>
                              _selectedPayment = 'PSE - Transferencia Bancaria',
                        );
                        context.read<CartProvider>().setSelectedPayment(
                          'PSE - Transferencia Bancaria',
                        );
                      },
                    ),
                    _buildPaymentOption(
                      context,
                      'Nequi',
                      Icons.phone_android,
                      selected: _selectedPayment == 'Nequi',
                      onTap: () {
                        setState(() => _selectedPayment = 'Nequi');
                        context.read<CartProvider>().setSelectedPayment(
                          'Nequi',
                        );
                      },
                    ),
                    _buildPaymentOption(
                      context,
                      'Daviplata',
                      Icons.wallet,
                      selected: _selectedPayment == 'Daviplata',
                      onTap: () {
                        setState(() => _selectedPayment = 'Daviplata');
                        context.read<CartProvider>().setSelectedPayment(
                          'Daviplata',
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCityOption('Bogotá'),
                        _buildCityOption('Medellín'),
                        _buildCityOption('Cali'),
                        _buildCityOption('Barranquilla'),
                        _buildCityOption('Cartagena'),
                        _buildCityOption('Otra ciudad'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Nota informativa
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Esta es una versión demo. En producción se integraría una pasarela de pago real.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botón de confirmación
            Container(
              padding: const EdgeInsets.all(24),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Simular compra exitosa
                      cart.clearCart();
                      Navigator.pop(context); // Cerrar modal
                      Navigator.pop(context); // Volver a tienda

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  '¡Compra realizada con éxito!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF059669),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Confirmar y Pagar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    IconData icon, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3B82F6) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: selected ? Colors.white : Colors.grey[600]),
        ),
        title: Text(title),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? const Color(0xFF3B82F6) : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCityOption(String city) {
    return ChoiceChip(
      label: Text(city),
      selected: false,
      onSelected: (selected) {},
      selectedColor: const Color(0xFF059669),
      backgroundColor: Colors.grey[100],
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(icon, size: 24, color: Colors.blue[600]),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildShippingChip(String city, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green[700]),
          const SizedBox(width: 6),
          Text(
            city,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, CartProvider cart) {
    final TextEditingController couponController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cart.appliedCoupon != null
            ? Colors.green[50]
            : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cart.appliedCoupon != null
              ? Colors.green[300]!
              : Colors.orange[300]!,
        ),
      ),
      child: cart.appliedCoupon != null
          ? _buildAppliedCoupon(cart)
          : _buildCouponInput(context, cart, couponController),
    );
  }

  Widget _buildAppliedCoupon(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.confirmation_number, color: Colors.green[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cupón aplicado: ${cart.appliedCoupon!.code}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    cart.appliedCoupon!.description,
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: Colors.red[700],
              onPressed: () => cart.removeCoupon(),
              tooltip: 'Quitar cupón',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponInput(
    BuildContext context,
    CartProvider cart,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              '¿Tienes un cupón de descuento?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu código',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF059669)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  errorText: cart.couponErrorMessage,
                ),
                onChanged: (_) => cart.clearCouponError(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final code = controller.text.trim();
                final success = cart.applyCoupon(code);
                if (success) {
                  controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cupón "${cart.appliedCoupon!.code}" aplicado',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Aplicar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
