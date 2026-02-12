import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/data/services/media_upload_service.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';

/// Pantalla de administración de productos (solo para admins)
class AdminShopScreen extends StatefulWidget {
  const AdminShopScreen({Key? key}) : super(key: key);

  @override
  State<AdminShopScreen> createState() => _AdminShopScreenState();
}

class _AdminShopScreenState extends State<AdminShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Widget que se muestra cuando el usuario no tiene permisos de admin
  Widget _buildAccessDenied(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 120,
              color: ColorTokens.primary30.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorTokens.primary30,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, {ProductEntity? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFormModal(product: product),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final shopProvider = context.read<ShopProvider>();
              final success = await shopProvider.deleteProduct(product.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto eliminado'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shopProvider.errorMessage ?? 'Error al eliminar',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
        backgroundColor: ColorTokens.primary30,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          final userProvider = context.watch<UserProvider>();
          final currentUser = userProvider.user;

          // ⚠️ VALIDACIÓN DE PERMISOS: Solo admins pueden acceder
          if (currentUser == null) {
            return _buildAccessDenied(
              context,
              'Sesión no iniciada',
              'Debes iniciar sesión para acceder a esta sección.',
              Icons.login,
            );
          }

          // Verificar si el usuario es admin
          final isAdmin = currentUser.isAdmin;
          if (!isAdmin) {
            return _buildAccessDenied(
              context,
              'Acceso Denegado',
              'Solo los administradores designados pueden subir productos a la tienda.',
              Icons.admin_panel_settings_outlined,
            );
          }

          // Filtrar productos del vendedor actual
          var myProducts = shopProvider.products
              .where((p) => p.sellerId == currentUser.uid)
              .toList();

          // Aplicar búsqueda
          if (_searchQuery.isNotEmpty) {
            myProducts = myProducts.where((p) {
              return p.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  p.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
            }).toList();
          }

          return Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Lista de productos
              Expanded(
                child: myProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.inventory_2_outlined
                                  : Icons.search_off,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No tienes productos'
                                  : 'No se encontraron productos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Crea tu primer producto',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: myProducts.length,
                        itemBuilder: (context, index) {
                          final product = myProducts[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: product.images.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.mainImage,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.shopping_bag,
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.shopping_bag),
                                    ),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('\$${product.price.toStringAsFixed(0)}'),
                                  Row(
                                    children: [
                                      Text(
                                        'Stock: ${product.stock}',
                                        style: TextStyle(
                                          color: product.isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      if (product.hasVideo) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.videocam,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showProductForm(
                                      context,
                                      product: product,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(
                                      context,
                                      product,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context),
        backgroundColor: ColorTokens.secondary50,
        icon: const Icon(Icons.add),
        label: const Text('Crear Producto'),
      ),
    );
  }
}

/// Modal para crear/editar productos con carga de medios
class ProductFormModal extends StatefulWidget {
  final ProductEntity? product;

  const ProductFormModal({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _mediaService = MediaUploadService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _longDescriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _cityController;

  String _selectedCategory = ProductCategories.all;
  List<String> _selectedSizes = [];
  List<String> _imageUrls = [];
  String? _videoUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _longDescriptionController = TextEditingController(
      text: widget.product?.longDescription ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _cityController = TextEditingController(
      text: widget.product?.sellerCity ?? '',
    );

    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _selectedSizes = List.from(widget.product!.sizes);
      _imageUrls = List.from(widget.product!.images);
      _videoUrl = widget.product?.videoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    print('📸 Intentando abrir cámara...');
    final image = await _mediaService.pickImageFromCamera();
    if (image != null) {
      print('✅ Imagen capturada, subiendo...');
      await _uploadImage(image);
    } else {
      print('⚠️ No se capturó imagen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo acceder a la cámara'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    print('🖼️ Abriendo selector de imágenes...');
    try {
      final image = await _mediaService.pickImageFromGallery();
      if (image != null) {
        print('✅ Imagen seleccionada: ${image.name}, subiendo...');
        await _uploadImage(image);
      } else {
        print('⚠️ No se seleccionó ninguna imagen');
      }
    } catch (e) {
      print('❌ Error en _pickImageFromGallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    print('🖼️ Abriendo selector múltiple...');
    try {
      final images = await _mediaService.pickMultipleImages();
      print('📸 ${images.length} imágenes seleccionadas');

      if (images.isEmpty) {
        print('⚠️ No se seleccionaron imágenes');
        return;
      }

      for (final image in images) {
        print('📤 Subiendo ${image.name}...');
        await _uploadImage(image);
      }
    } catch (e) {
      print('❌ Error en _pickMultipleImages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imágenes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final productId =
        widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final url = await _mediaService.uploadImage(
      image,
      productId,
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
    );

    if (url != null) {
      setState(() {
        _imageUrls.add(url);
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida exitosamente')),
      );
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideoFromCamera() async {
    final video = await _mediaService.pickVideoFromCamera();
    if (video != null) {
      await _uploadVideo(video);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final video = await _mediaService.pickVideoFromGallery();
    if (video != null) {
      await _uploadVideo(video);
    }
  }

  Future<void> _uploadVideo(XFile video) async {
    // Validar duración
    final isValid = await _mediaService.validateVideoDuration(video.path);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El video debe durar máximo 30 segundos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final productId =
        widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final url = await _mediaService.uploadVideo(
      video,
      productId,
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
    );

    if (url != null) {
      setState(() {
        _videoUrl = url;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video subido exitosamente')),
      );
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _videoUrl = null;
    });
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // 🌐 En WEB: Solo mostrar opciones de galería (cámara no funciona en web)
            if (!kIsWeb) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Seleccionar imagen'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text('Seleccionar múltiples imágenes'),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
            const Divider(),
            if (!kIsWeb) ...[
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: const Text('Grabar video (máx 30s)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.orange),
              title: const Text('Seleccionar video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una imagen')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no encontrado')),
      );
      return;
    }

    final product = ProductEntity(
      id: widget.product?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      longDescription: _longDescriptionController.text.isEmpty
          ? null
          : _longDescriptionController.text,
      price: double.parse(_priceController.text),
      images: _imageUrls,
      videoUrl: _videoUrl,
      category: _selectedCategory,
      sizes: _selectedSizes,
      stock: int.parse(_stockController.text),
      sellerId: currentUser.uid,
      sellerName: currentUser.username ?? currentUser.name ?? 'Vendedor',
      sellerCity: _cityController.text.isEmpty ? null : _cityController.text,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      isActive: true,
    );

    final shopProvider = context.read<ShopProvider>();
    bool success;

    if (widget.product == null) {
      success = await shopProvider.createProduct(
        product,
        canCreateProducts:
            currentUser.isAdmin ||
            (userProvider.user?.canCreateProducts ?? false),
      );
    } else {
      success = await shopProvider.updateProduct(product);
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? 'Producto creado exitosamente'
                : 'Producto actualizado',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shopProvider.errorMessage ?? 'Error al guardar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                widget.product == null ? 'Crear Producto' : 'Editar Producto',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción corta
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción corta *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción larga
              TextFormField(
                controller: _longDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada (opcional)',
                  border: OutlineInputBorder(),
                  hintText: 'Características, materiales, medidas, etc.',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Precio y Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio *',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stock inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ciudad
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Ej: Bogotá, Medellín, Cali...',
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  border: OutlineInputBorder(),
                ),
                items: ProductCategories.getAll().map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text('${category.icon} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Tallas
              const Text(
                'Tallas disponibles (opcional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((size) {
                  final isSelected = _selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSizes.add(size);
                        } else {
                          _selectedSizes.remove(size);
                        }
                      });
                    },
                    // Usar la misma paleta `secondary50` pero más clara visualmente
                    // y con mayor contraste: alpha más bajo
                    selectedColor: ColorTokens.secondary50.withValues(alpha: 0.12),
                    // Texto blanco al estar seleccionado para garantizar contraste
                    labelStyle: TextStyle(
                      color: isSelected ? ColorTokens.neutral100 : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Botón agregar multimedia
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _showMediaOptions,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Agregar Fotos/Video'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorTokens.secondary50,
                  side: BorderSide(color: ColorTokens.secondary50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Progress bar durante carga
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorTokens.secondary50,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subiendo... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 16),

              // Lista de imágenes
              if (_imageUrls.isNotEmpty) ...[
                const Text(
                  'Imágenes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(_imageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Video
              if (_videoUrl != null) ...[
                const Text(
                  'Video',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeVideo,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.secondary50,
                      ),
                      child: Text(
                        widget.product == null ? 'Crear' : 'Actualizar',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
