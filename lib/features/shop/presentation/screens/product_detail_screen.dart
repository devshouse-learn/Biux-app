import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/presentation/widgets/price_tag.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de detalle de producto mejorada
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductEntity? _product;
  String? _selectedSize;
  int _quantity = 1;
  int _currentImageIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // No llamar _loadProduct aquí para evitar usar context antes de que el widget esté montado
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      print('🔍 Buscando producto con ID: ${widget.productId}');
      final shopProvider = context.read<ShopProvider>();

      // Asegurarse de que los productos estén cargados
      if (shopProvider.products.isEmpty) {
        print('📦 Cargando productos desde Firebase...');
        await shopProvider.loadProducts();
        print('✅ Productos cargados: ${shopProvider.products.length}');
      } else {
        print('📦 Ya hay ${shopProvider.products.length} productos cargados');
      }

      // Buscar el producto específico
      ProductEntity? product;
      try {
        product = shopProvider.products.firstWhere(
          (p) => p.id == widget.productId,
        );
        print('✅ Producto encontrado: ${product.name}');
      } catch (e) {
        print('❌ Producto con ID ${widget.productId} no encontrado');
        print(
          '📋 IDs disponibles: ${shopProvider.products.map((p) => p.id).join(", ")}',
        );

        if (!mounted) return;

        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        // Mostrar snackbar solo si el widget está montado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto no encontrado'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );

            // Regresar a la tienda después de mostrar el error
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                print('⬅️ Regresando a la tienda...');
                context.go('/shop');
              }
            });
          }
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _product = product;
        _isLoading = false;
        if (product!.sizes.isNotEmpty) {
          _selectedSize = product.sizes.first;
        }
      });

      // Inicializar video si existe
      if (product.hasVideo &&
          product.videoUrl != null &&
          product.videoUrl!.isNotEmpty) {
        print('🎥 Inicializando video: ${product.videoUrl}');
        _initializeVideo(product.videoUrl!);
      }
    } catch (e) {
      print('❌ Error cargando producto: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar el producto'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print('Error inicializando video: $e');
      // Si falla el video, simplemente no lo mostramos
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _addToCart() {
    if (_product == null) {
      print('⚠️ ERROR: Producto es null');
      return;
    }

    print('🛒 Intentando agregar al carrito: ${_product!.name}');
    print('  - ID: ${_product!.id}');
    print('  - Precio: \$${_product!.price}');
    print('  - Cantidad: $_quantity');
    print('  - Talla seleccionada: $_selectedSize');
    print('  - Disponible: ${_product!.isAvailable}');
    print('  - Stock: ${_product!.stock}');
    print('  - Activo: ${_product!.isActive}');
    print('  - Vendido: ${_product!.isSold}');

    if (_product!.sizes.isNotEmpty && _selectedSize == null) {
      print('⚠️ ERROR: Debe seleccionar una talla');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una talla')),
      );
      return;
    }

    final shopProvider = context.read<ShopProvider>();
    print('📦 Carrito antes: ${shopProvider.cartItems.length} items');

    for (int i = 0; i < _quantity; i++) {
      shopProvider.addToCart(_product!, selectedSize: _selectedSize);
    }

    print('📦 Carrito después: ${shopProvider.cartItems.length} items');
    print('✅ Producto agregado exitosamente');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_quantity ${_product!.name} agregado(s) al carrito'),
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () => context.push('/shop/cart'),
          ),
        ),
      );
    }
  }

  void _buyNow() {
    if (_product == null) return;

    if (_product!.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una talla')),
      );
      return;
    }

    _showBuyNowDialog();
  }

  void _showBuyNowDialog() {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Comprar Ahora'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_product!.name} x$_quantity',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LargePriceTag(price: _product!.price * _quantity),
              const SizedBox(height: 16),
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
                maxLines: 2,
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
                  const SnackBar(content: Text('Error: usuario no encontrado')),
                );
                return;
              }

              final orderId = await shopProvider.buyNow(
                userId: currentUser.uid,
                userName: currentUser.username ?? currentUser.name ?? 'Usuario',
                product: _product!,
                quantity: _quantity,
                selectedSize: _selectedSize,
                deliveryAddress: addressController.text,
                phoneNumber: phoneController.text,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );

              if (orderId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Compra realizada con éxito!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/shop');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shopProvider.errorMessage ?? 'Error al realizar compra',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.secondary50,
            ),
            child: const Text('Confirmar Compra'),
          ),
        ],
      ),
    );
  }

  void _showMarkAsSoldDialog(String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar como vendido'),
        content: const Text(
          '¿Estás seguro de que quieres marcar este producto como vendido? '
          'Ya no estará disponible para compra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final shopProvider = context.read<ShopProvider>();
              final success = await shopProvider.markProductAsSold(
                _product!.id,
                userId,
              );

              if (success) {
                setState(() {
                  _product = _product!.copyWith(isSold: true, stock: 0);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto marcado como vendido'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shopProvider.errorMessage ??
                          'Error al marcar como vendido',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Marcar vendido'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta publicación? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final shopProvider = context.read<ShopProvider>();
              final success = await shopProvider.deleteProduct(_product!.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Publicación eliminada'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/shop');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shopProvider.errorMessage ??
                          'Error al eliminar publicación',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 78, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar el producto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/shop'),
                  child: const Text('Volver a la tienda'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: ColorTokens.primary30),
        body: Center(
          child: CircularProgressIndicator(color: ColorTokens.secondary50),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen o video
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: ColorTokens.primary30,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildMediaSection()),
            actions: [
              // Botón de opciones para el vendedor
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final currentUser = userProvider.user;
                  if (currentUser == null ||
                      _product!.sellerId != currentUser.uid) {
                    return const SizedBox.shrink();
                  }

                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'mark_sold') {
                        _showMarkAsSoldDialog(currentUser.uid);
                      } else if (value == 'delete') {
                        _showDeleteProductDialog(currentUser.uid);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!_product!.isSold)
                        const PopupMenuItem(
                          value: 'mark_sold',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marcar como vendido'),
                            ],
                          ),
                        ),
                      if (_product!.isSold)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar publicación'),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de imágenes/video
                  if (_product!.images.length > 1 || _product!.hasVideo)
                    _buildMediaIndicator(),
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

                  // Badge VENDIDO
                  if (_product!.isSold)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🔴 PRODUCTO VENDIDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_product!.isSold) const SizedBox(height: 8),

                  // Stock
                  _buildStockIndicator(),
                  const SizedBox(height: 16),

                  // Ciudad del vendedor
                  if (_product!.sellerCity != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ubicación: ${_product!.sellerCity}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Vendedor
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Vendedor: ${_product!.sellerName}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                          // Usar un token de la misma paleta pero mucho más claro
                          // para que sea claramente visible en el simulador
                          selectedColor: ColorTokens.secondary95,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? ColorTokens.primary30
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Descripción detallada
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.displayDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 120), // Espacio para botones
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra inferior con botones
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMediaSection() {
    final totalItems = _product!.images.length + (_product!.hasVideo ? 1 : 0);

    return PageView.builder(
      itemCount: totalItems,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });

        // Control de video
        if (_product!.hasVideo) {
          if (index == _product!.images.length && _videoController != null) {
            _videoController!.play();
          } else {
            _videoController?.pause();
          }
        }
      },
      itemBuilder: (context, index) {
        // Mostrar video en el último índice si existe
        if (_product!.hasVideo && index == _product!.images.length) {
          return _buildVideoPlayer();
        }

        // Mostrar imágenes
        return CachedNetworkImage(
          imageUrl: _product!.images[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
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
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        Center(
          child: IconButton(
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              size: 64,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            onPressed: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Video',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaIndicator() {
    final totalItems = _product!.images.length + (_product!.hasVideo ? 1 : 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalItems, (index) {
        final isVideo = _product!.hasVideo && index == _product!.images.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index
                ? ColorTokens.secondary50
                : Colors.grey[300],
            border: isVideo ? Border.all(color: Colors.red, width: 1) : null,
          ),
        );
      }),
    );
  }

  Widget _buildStockIndicator() {
    return Row(
      children: [
        Icon(
          _product!.isAvailable ? Icons.check_circle : Icons.cancel,
          color: _product!.isAvailable ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          _product!.isAvailable
              ? 'En stock (${_product!.stock} disponibles)'
              : 'Agotado',
          style: TextStyle(
            color: _product!.isAvailable ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
            // Selector de cantidad
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                // Botón Agregar al carrito
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _product!.isAvailable ? _addToCart : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Agregar al carrito'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.secondary50,
                      side: BorderSide(color: ColorTokens.secondary50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Comprar ahora
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _product!.isAvailable ? _buyNow : null,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Comprar ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.secondary50,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
