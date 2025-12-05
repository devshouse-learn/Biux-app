import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/widgets/price_tag.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle de producto
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductEntity? _product;
  String? _selectedSize;
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    // Buscar el producto en la lista cargada
    final shopProvider = context.read<ShopProvider>();
    final product = shopProvider.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => shopProvider.products.first, // Fallback
    );
    
    setState(() {
      _product = product;
      if (product.sizes.isNotEmpty) {
        _selectedSize = product.sizes.first;
      }
    });
  }

  void _addToCart() {
    if (_product == null) return;

    if (_product!.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una talla')),
      );
      return;
    }

    final shopProvider = context.read<ShopProvider>();
    for (int i = 0; i < _quantity; i++) {
      shopProvider.addToCart(_product!, selectedSize: _selectedSize);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity ${_product!.name} agregado(s) al carrito'),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {
            context.push('/shop/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorTokens.primary30,
        ),
        body: Center(
          child: CircularProgressIndicator(color: ColorTokens.secondary50),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: ColorTokens.primary30,
            flexibleSpace: FlexibleSpaceBar(
              background: _product!.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: _product!.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: _product!.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.shopping_bag,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de imágenes
                  if (_product!.images.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _product!.images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? ColorTokens.secondary50
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  // Nombre del producto
                  Text(
                    _product!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Precio
                  LargePriceTag(price: _product!.price),
                  const SizedBox(height: 8),
                  
                  // Stock
                  Row(
                    children: [
                      Icon(
                        _product!.isAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _product!.isAvailable
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _product!.isAvailable
                            ? 'En stock (${_product!.stock} disponibles)'
                            : 'Agotado',
                        style: TextStyle(
                          color: _product!.isAvailable
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Tallas
                  if (_product!.sizes.isNotEmpty) ...[
                    const Text(
                      'Tallas disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _product!.sizes.map((size) {
                        final isSelected = size == _selectedSize;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          selectedColor: ColorTokens.secondary50,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100), // Espacio para el botón
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Barra inferior con cantidad y botón
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_quantity < _product!.stock) {
                          setState(() {
                            _quantity++;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Botón agregar al carrito
              Expanded(
                child: ElevatedButton(
                  onPressed: _product!.isAvailable ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.secondary50,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Agregar al carrito',
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
    );
  }
}
