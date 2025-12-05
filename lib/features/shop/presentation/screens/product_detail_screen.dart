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
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final shopProvider = context.read<ShopProvider>();
    final product = shopProvider.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => shopProvider.products.first,
    );
    
    setState(() {
      _product = product;
      if (product.sizes.isNotEmpty) {
        _selectedSize = product.sizes.first;
      }
    });

    // Inicializar video si existe
    if (product.hasVideo) {
      _initializeVideo(product.videoUrl!);
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    _videoController = VideoPlayerController.network(videoUrl);
    await _videoController!.initialize();
    setState(() {
      _isVideoInitialized = true;
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
          onPressed: () => context.push('/shop/cart'),
        ),
      ),
    );
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
              if (addressController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor completa todos los campos')),
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
                notes: notesController.text.isEmpty ? null : notesController.text,
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
                    content: Text(shopProvider.errorMessage ?? 'Error al realizar compra'),
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

  @override
  Widget build(BuildContext context) {
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
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMediaSection(),
            ),
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
                  
                  // Stock
                  _buildStockIndicator(),
                  const SizedBox(height: 16),
                  
                  // Ciudad del vendedor
                  if (_product!.sellerCity != null) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
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
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
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
                  
                  // Descripción detallada
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            child: const Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
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
              color: Colors.white.withOpacity(0.8),
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
              color: Colors.black.withOpacity(0.6),
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
      children: List.generate(
        totalItems,
        (index) {
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
        },
      ),
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
            color: Colors.black.withOpacity(0.1),
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
