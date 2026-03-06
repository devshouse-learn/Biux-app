import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/store/domain/entities/product_entity.dart';
import 'package:biux/features/store/presentation/providers/cart_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla de detalle completo de un producto
class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cantidad = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.nombre),
        actions: [
          // Botón del carrito
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de imágenes
            _buildImageGallery(),

            // Información del producto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    widget.product.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Categoría
                  Chip(
                    label: Text(l.t(widget.product.categoria.displayName)),
                    backgroundColor: Colors.blue[100],
                  ),

                  const SizedBox(height: 16),

                  // Precio
                  _buildPriceSection(),

                  const SizedBox(height: 16),

                  // Vendedor
                  if (widget.product.vendedorNombre != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.store, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${l.t('sold_by')} ${widget.product.vendedorNombre}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stock
                  Row(
                    children: [
                      Icon(
                        widget.product.disponible
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: widget.product.disponible
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.disponible
                            ? '${l.t('stock_label')}: ${widget.product.stock}'
                            : l.t('out_of_stock'),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.product.disponible
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Descripción
                  Text(
                    l.t('description'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.descripcion,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),

                  // Especificaciones
                  if (widget.product.especificaciones != null &&
                      widget.product.especificaciones!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    Text(
                      l.t('specifications'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.especificaciones!.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(flex: 3, child: Text('${entry.value}')),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Tags
                  if (widget.product.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    Text(
                      l.t('tags_label'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey[200],
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ],
        ),
      ),

      // Barra inferior con selector de cantidad y botón agregar
      bottomNavigationBar: widget.product.disponible ? _buildBottomBar() : null,
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.imagenes;

    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 100, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Imagen principal
        Container(
          height: 300,
          color: Colors.grey[200],
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 100),
                  );
                },
              );
            },
          ),
        ),

        // Indicadores de página
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),

        // Miniaturas
        if (images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentImageIndex == index
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    if (widget.product.tieneDescuento) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Precio original tachado
          Text(
            '\$${widget.product.precio.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Precio con descuento
              Text(
                '\$${widget.product.precioFinal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              // Badge de descuento
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '-${widget.product.descuento!.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Text(
        '\$${widget.product.precio.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      );
    }
  }

  Widget _buildBottomBar() {
    final l = Provider.of<LocaleNotifier>(context);
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
        child: Row(
          children: [
            // Selector de cantidad
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _cantidad > 1
                        ? () => setState(() => _cantidad--)
                        : null,
                  ),
                  Text(
                    '$_cantidad',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _cantidad < widget.product.stock
                        ? () => setState(() => _cantidad++)
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Botón agregar al carrito
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  try {
                    context.read<CartProvider>().addItem(
                      widget.product,
                      cantidad: _cantidad,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_cantidad ${_cantidad == 1 ? l.t('product_added_to_cart') : l.t('products_added_to_cart')}',
                        ),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: l.t('view_cart'),
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(l.t('add_to_cart')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
