import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/shop/data/datasources/media_upload_service.dart';
// import 'package:biux/features/shop/presentation/widgets/product_form_modal.dart'; // import gestionado: se usa dinámicamente desde helpers
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/data/datasources/stolen_bike_verification_service.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';

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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
              label: Text(l.t('admin_go_back')),
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

  void _showCleanupDialog(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cleaning_services, color: ColorTokens.warning50),
            const SizedBox(width: 12),
            Text(l.t('admin_clean_database')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.t('admin_clean_database_warning'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(l.t('admin_clean_includes')),
            const SizedBox(height: 8),
            Text('• ${l.t('admin_clean_empty_images')}'),
            Text('• ${l.t('admin_clean_blank_images')}'),
            const SizedBox(height: 12),
            Text(
              l.t('admin_action_irreversible'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // Mostrar SnackBar de inicio (no bloquea la UI)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(l.t('admin_cleaning_products')),
                    ],
                  ),
                  duration: const Duration(seconds: 30),
                  backgroundColor: ColorTokens.secondary50,
                ),
              );

              // Ejecutar limpieza en segundo plano
              final shopProvider = context.read<ShopProvider>();
              final deletedCount = await shopProvider
                  .deleteProductsWithoutImages();

              // Ocultar SnackBar de progreso
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }

              // Mostrar resultado
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          deletedCount > 0 ? Icons.check_circle : Icons.info,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            deletedCount > 0
                                ? '✅ $deletedCount ${l.t('admin_products_deleted')}'
                                : '✨ ${l.t('admin_no_products_without_images')}',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: deletedCount > 0
                        ? Colors.green
                        : Colors.blue,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: Text(l.t('admin_clean_now')),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProductEntity product) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('admin_delete_product')),
        content: Text('${l.t('admin_confirm_delete')} "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final shopProvider = context.read<ShopProvider>();
              final success = await shopProvider.deleteProduct(product.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('admin_product_deleted')),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shopProvider.errorMessage ?? l.t('admin_error_deleting'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.t('admin_delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/shop');
            }
          },
        ),
        title: Text(
          l.t('admin_manage_products'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorTokens.primary30,
        actions: [
          // Botón para limpiar productos sin imágenes
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            tooltip: l.t('admin_clean_products_tooltip'),
            onPressed: () => _showCleanupDialog(context),
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          final userProvider = context.watch<UserProvider>();
          final currentUser = userProvider.user;

          // ⚠️ VALIDACIÓN DE PERMISOS: Solo admins pueden acceder
          if (currentUser == null) {
            return _buildAccessDenied(
              context,
              l.t('admin_session_not_started'),
              l.t('admin_session_required'),
              Icons.login,
            );
          }

          // Verificar si el usuario es admin
          final isAdmin = currentUser.isAdmin;
          if (!isAdmin) {
            return _buildAccessDenied(
              context,
              l.t('admin_access_denied'),
              l.t('admin_only_admins'),
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
                    hintText: l.t('admin_search_products'),
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
                                  ? l.t('admin_no_products')
                                  : l.t('admin_no_products_found'),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                l.t('admin_create_first'),
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
        label: Text(l.t('admin_create_product')),
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
  late TextEditingController _bikeFrameSerialController;
  late TextEditingController _bikeBrandController;
  late TextEditingController _bikeModelController;
  late TextEditingController _bikeColorController;
  late TextEditingController _bikeYearController;

  String _selectedCategory = ProductCategories.all;
  List<String> _selectedSizes = [];
  List<String> _imageUrls = [];
  String? _videoUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Campos anti-robo
  bool _isBicycle = false;
  bool _isVerifying = false;
  bool?
  _verificationResult; // null = no verificado, true = aprobado, false = robada

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

    // Controladores para bicicletas
    _bikeFrameSerialController = TextEditingController(
      text: widget.product?.bikeFrameSerial ?? '',
    );
    _bikeBrandController = TextEditingController(
      text: widget.product?.bikeBrand ?? '',
    );
    _bikeModelController = TextEditingController(
      text: widget.product?.bikeModel ?? '',
    );
    _bikeColorController = TextEditingController(
      text: widget.product?.bikeColor ?? '',
    );
    _bikeYearController = TextEditingController(
      text: widget.product?.bikeYear?.toString() ?? '',
    );

    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _selectedSizes = List.from(widget.product!.sizes);
      _imageUrls = List.from(widget.product!.images);
      _videoUrl = widget.product?.videoUrl;
      _isBicycle = widget.product!.isBicycle;
      if (widget.product!.isVerifiedNotStolen) {
        _verificationResult = true;
      }
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
    _bikeFrameSerialController.dispose();
    _bikeBrandController.dispose();
    _bikeModelController.dispose();
    _bikeColorController.dispose();
    _bikeYearController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    debugPrint('📸 Intentando abrir cámara...');
    final image = await _mediaService.pickImageFromCamera();
    if (image != null) {
      debugPrint('✅ Imagen capturada, subiendo...');
      await _uploadImage(image);
    } else {
      debugPrint('⚠️ No se capturó imagen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocaleNotifier>(
                context,
                listen: false,
              ).t('admin_camera_error'),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    debugPrint('🖼️ Abriendo selector de imágenes...');
    try {
      final image = await _mediaService.pickImageFromGallery();
      if (image != null) {
        debugPrint('✅ Imagen seleccionada: ${image.name}, subiendo...');
        await _uploadImage(image);
      } else {
        debugPrint('⚠️ No se seleccionó ninguna imagen');
      }
    } catch (e) {
      debugPrint('❌ Error en _pickImageFromGallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Provider.of<LocaleNotifier>(context, listen: false).t('admin_image_select_error')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    debugPrint('🖼️ Abriendo selector múltiple...');
    try {
      final images = await _mediaService.pickMultipleImages();
      debugPrint('📸 ${images.length} imágenes seleccionadas');

      if (images.isEmpty) {
        debugPrint('⚠️ No se seleccionaron imágenes');
        return;
      }

      for (final image in images) {
        debugPrint('📤 Subiendo ${image.name}...');
        await _uploadImage(image);
      }
    } catch (e) {
      debugPrint('❌ Error en _pickMultipleImages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Provider.of<LocaleNotifier>(context, listen: false).t('admin_images_select_error')}: $e',
            ),
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
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('admin_image_uploaded'),
          ),
        ),
      );
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('admin_image_upload_error'),
          ),
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
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('admin_video_max_30s'),
          ),
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
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('admin_video_uploaded'),
          ),
        ),
      );
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocaleNotifier>(
              context,
              listen: false,
            ).t('admin_video_upload_error'),
          ),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            // 🌐 En WEB: Solo mostrar opciones de galería (cámara no funciona en web)
            if (!kIsWeb) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: Text(l.t('admin_take_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(l.t('admin_select_image')),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: Text(l.t('admin_select_multiple_images')),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
            const Divider(),
            if (!kIsWeb) ...[
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.red),
                title: Text(l.t('admin_record_video')),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideoFromCamera();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.orange),
              title: Text(l.t('admin_select_video')),
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

  Future<void> _verifyBikeNotStolen() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    // Validar que se haya ingresado el número de serie
    if (_bikeFrameSerialController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.t('admin_serial_required_verify'),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      // Crear instancia del servicio de verificación
      final bikeRepo = BikeRepositoryImpl();
      final verificationService = StolenBikeVerificationService(
        bikeRepository: bikeRepo,
      );

      // Obtener información del usuario actual (vendedor)
      final currentUser = context.read<UserProvider>().user;
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;

      // Verificar contra la base de datos
      final result = await verificationService.verifyBikeNotStolen(
        frameSerial: _bikeFrameSerialController.text.trim(),
        brand: _bikeBrandController.text.trim().isEmpty
            ? null
            : _bikeBrandController.text.trim(),
        model: _bikeModelController.text.trim().isEmpty
            ? null
            : _bikeModelController.text.trim(),
        color: _bikeColorController.text.trim().isEmpty
            ? null
            : _bikeColorController.text.trim(),
        // 🚨 NUEVO: Pasar información del vendedor para notificaciones
        sellerUid: currentFirebaseUser?.uid,
        sellerName:
            currentUser?.name ??
            currentFirebaseUser?.phoneNumber ??
            l.t('seller_unknown'),
      );

      setState(() {
        _isVerifying = false;
        _verificationResult = !result.isStolen;
      });

      if (result.isStolen) {
        // ⚠️ BICICLETA ROBADA DETECTADA
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: ColorTokens.error50, width: 3),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: ColorTokens.error50, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.t('admin_theft_alert'),
                    style: TextStyle(
                      color: ColorTokens.error50,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTokens.error50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorTokens.error50),
                    ),
                    child: Text(
                      result.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.error50,
                      ),
                    ),
                  ),
                  if (result.details != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l.t('admin_details'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(result.details!, style: TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.t('admin_cannot_publish_bike'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l.t('understood'),
                  style: TextStyle(
                    color: ColorTokens.error50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // ✅ Bicicleta verificada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.verified, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.message,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationResult = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.t('admin_verify_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    // Validación obligatoria de imágenes
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.t('admin_photo_required'),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
          backgroundColor: ColorTokens.error50,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Validación para bicicletas: deben estar verificadas
    if (_isBicycle) {
      if (_bikeFrameSerialController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.t('admin_serial_required_bike'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: ColorTokens.error50,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      if (_verificationResult != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.t('admin_verify_not_stolen'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('admin_user_not_found'))));
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
      sellerName:
          currentUser.username ?? currentUser.name ?? l.t('seller_default'),
      sellerCity: _cityController.text.isEmpty ? null : _cityController.text,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      isActive: true,
      // Campos anti-robo para bicicletas
      isBicycle: _isBicycle,
      bikeFrameSerial:
          _isBicycle && _bikeFrameSerialController.text.trim().isNotEmpty
          ? _bikeFrameSerialController.text.trim()
          : null,
      bikeBrand: _isBicycle && _bikeBrandController.text.trim().isNotEmpty
          ? _bikeBrandController.text.trim()
          : null,
      bikeModel: _isBicycle && _bikeModelController.text.trim().isNotEmpty
          ? _bikeModelController.text.trim()
          : null,
      bikeColor: _isBicycle && _bikeColorController.text.trim().isNotEmpty
          ? _bikeColorController.text.trim()
          : null,
      bikeYear: _isBicycle && _bikeYearController.text.trim().isNotEmpty
          ? int.tryParse(_bikeYearController.text.trim())
          : null,
      isVerifiedNotStolen: _isBicycle && _verificationResult == true,
      stolenVerificationDate: _isBicycle && _verificationResult == true
          ? DateTime.now()
          : null,
      stolenVerificationBy: _isBicycle && _verificationResult == true
          ? currentUser.uid
          : null,
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
                ? l.t('admin_product_created')
                : l.t('admin_product_updated'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shopProvider.errorMessage ?? l.t('admin_error_saving')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: ColorTokens.neutral99, // Fondo claro
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: ColorTokens.neutral90,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                widget.product == null
                    ? l.t('admin_create_product')
                    : l.t('admin_edit_product'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.neutral20,
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: ColorTokens.neutral20),
                decoration: InputDecoration(
                  labelText: l.t('admin_product_name'),
                  labelStyle: TextStyle(color: ColorTokens.neutral60),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary30,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l.t('admin_enter_name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción corta
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: ColorTokens.neutral20),
                decoration: InputDecoration(
                  labelText: l.t('admin_short_description'),
                  labelStyle: TextStyle(color: ColorTokens.neutral60),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary30,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l.t('admin_enter_description');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción larga
              TextFormField(
                controller: _longDescriptionController,
                style: TextStyle(color: ColorTokens.neutral20),
                decoration: InputDecoration(
                  labelText: l.t('admin_detailed_description'),
                  labelStyle: TextStyle(color: ColorTokens.neutral60),
                  hintText: l.t('admin_features_hint'),
                  hintStyle: TextStyle(color: ColorTokens.neutral70),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary30,
                      width: 2,
                    ),
                  ),
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
                      style: TextStyle(color: ColorTokens.neutral20),
                      decoration: InputDecoration(
                        labelText: l.t('admin_price'),
                        labelStyle: TextStyle(color: ColorTokens.neutral60),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: ColorTokens.neutral40),
                        filled: true,
                        fillColor: ColorTokens.neutral100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorTokens.neutral95),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorTokens.neutral95),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorTokens.primary30,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('admin_enter_price');
                        }
                        if (double.tryParse(value) == null) {
                          return l.t('admin_invalid_price');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      style: TextStyle(color: ColorTokens.neutral20),
                      decoration: InputDecoration(
                        labelText: l.t('admin_stock'),
                        labelStyle: TextStyle(color: ColorTokens.neutral60),
                        filled: true,
                        fillColor: ColorTokens.neutral100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorTokens.neutral95),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: ColorTokens.neutral95),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorTokens.primary30,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('admin_enter_stock');
                        }
                        if (int.tryParse(value) == null) {
                          return l.t('admin_invalid_stock');
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
                style: TextStyle(color: ColorTokens.neutral20),
                decoration: InputDecoration(
                  labelText: l.t('admin_city_optional'),
                  labelStyle: TextStyle(color: ColorTokens.neutral60),
                  hintText: l.t('admin_city_hint'),
                  hintStyle: TextStyle(color: ColorTokens.neutral70),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: ColorTokens.neutral60,
                  ),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary30,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                style: TextStyle(color: ColorTokens.neutral20),
                decoration: InputDecoration(
                  labelText: l.t('admin_category'),
                  labelStyle: TextStyle(color: ColorTokens.neutral60),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorTokens.neutral95),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary30,
                      width: 2,
                    ),
                  ),
                ),
                dropdownColor: ColorTokens.neutral100,
                items: ProductCategories.getAll().map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(
                      '${category.icon} ${category.name}',
                      style: TextStyle(color: ColorTokens.neutral20),
                    ),
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

              // ============ SECCIÓN DE VERIFICACIÓN ANTI-ROBO ============
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTokens.primary99,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isBicycle
                        ? ColorTokens.primary30
                        : ColorTokens.neutral90,
                    width: _isBicycle ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pedal_bike,
                          color: ColorTokens.primary30,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.t('admin_anti_theft_system'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.neutral20,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.shield,
                          color: ColorTokens.primary30,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Checkbox: ¿Es una bicicleta completa?
                    CheckboxListTile(
                      value: _isBicycle,
                      onChanged: (value) {
                        setState(() {
                          _isBicycle = value ?? false;
                          if (!_isBicycle) {
                            _verificationResult = null;
                          }
                        });
                      },
                      title: Text(
                        l.t('admin_is_bicycle'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorTokens.neutral30,
                        ),
                      ),
                      subtitle: Text(
                        l.t('admin_bicycle_verify_note'),
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorTokens.neutral60,
                        ),
                      ),
                      activeColor: ColorTokens.primary30,
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Campos adicionales si es bicicleta
                    if (_isBicycle) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l.t('admin_verify_before_publish'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Número de Serie (OBLIGATORIO)
                      TextFormField(
                        controller: _bikeFrameSerialController,
                        style: TextStyle(color: ColorTokens.neutral20),
                        decoration: InputDecoration(
                          labelText: l.t('admin_serial_number'),
                          labelStyle: TextStyle(color: ColorTokens.neutral60),
                          hintText: 'Ej: AB123456789',
                          hintStyle: TextStyle(color: ColorTokens.neutral70),
                          filled: true,
                          fillColor: ColorTokens.neutral100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.tag,
                            color: ColorTokens.primary30,
                          ),
                        ),
                        validator: _isBicycle
                            ? (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l.t('admin_serial_required_bikes');
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Marca
                      TextFormField(
                        controller: _bikeBrandController,
                        style: TextStyle(color: ColorTokens.neutral20),
                        decoration: InputDecoration(
                          labelText: l.t('admin_brand'),
                          labelStyle: TextStyle(color: ColorTokens.neutral60),
                          hintText: 'Ej: Trek, Giant, Specialized...',
                          filled: true,
                          fillColor: ColorTokens.neutral100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Modelo y Color
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bikeModelController,
                              style: TextStyle(color: ColorTokens.neutral20),
                              decoration: InputDecoration(
                                labelText: l.t('admin_model'),
                                labelStyle: TextStyle(
                                  color: ColorTokens.neutral60,
                                ),
                                filled: true,
                                fillColor: ColorTokens.neutral100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _bikeColorController,
                              style: TextStyle(color: ColorTokens.neutral20),
                              decoration: InputDecoration(
                                labelText: l.t('admin_color'),
                                labelStyle: TextStyle(
                                  color: ColorTokens.neutral60,
                                ),
                                filled: true,
                                fillColor: ColorTokens.neutral100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Año
                      TextFormField(
                        controller: _bikeYearController,
                        style: TextStyle(color: ColorTokens.neutral20),
                        decoration: InputDecoration(
                          labelText: l.t('admin_year_optional'),
                          labelStyle: TextStyle(color: ColorTokens.neutral60),
                          hintText: '2024',
                          filled: true,
                          fillColor: ColorTokens.neutral100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Botón de Verificación
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isVerifying ? null : _verifyBikeNotStolen,
                          icon: _isVerifying
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  _verificationResult == true
                                      ? Icons.verified
                                      : _verificationResult == false
                                      ? Icons.dangerous
                                      : Icons.search,
                                ),
                          label: Text(
                            _isVerifying
                                ? l.t('admin_verifying_theft_db')
                                : _verificationResult == true
                                ? l.t('admin_verified_not_stolen')
                                : _verificationResult == false
                                ? l.t('admin_stolen_cannot_publish')
                                : l.t('admin_verify_theft_db'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verificationResult == true
                                ? Colors.green
                                : _verificationResult == false
                                ? ColorTokens.error50
                                : ColorTokens.primary30,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      // Mensaje de estado
                      if (_verificationResult != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _verificationResult == true
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _verificationResult == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _verificationResult == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _verificationResult == true
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _verificationResult == true
                                      ? l.t('admin_bike_verified_publish')
                                      : l.t('admin_bike_stolen_no_publish'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _verificationResult == true
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tallas
              Text(
                l.t('admin_sizes_optional'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.neutral30,
                ),
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
                    backgroundColor: ColorTokens.neutral100,
                    selectedColor: ColorTokens.primary99,
                    checkmarkColor: ColorTokens.primary30,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? ColorTokens.primary30
                          : ColorTokens.neutral50,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? ColorTokens.primary30
                          : ColorTokens.neutral90,
                      width: isSelected ? 2 : 1,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Título de sección de multimedia (obligatorio)
              Row(
                children: [
                  Text(
                    l.t('admin_product_photos'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorTokens.neutral30,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: ColorTokens.error50,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.t('admin_required_label'),
                    style: TextStyle(
                      color: ColorTokens.error50,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Botón agregar multimedia
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _showMediaOptions,
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: _imageUrls.isEmpty
                      ? ColorTokens.error50
                      : ColorTokens.primary30,
                ),
                label: Text(
                  _imageUrls.isEmpty
                      ? l.t('admin_add_photos_required')
                      : l.t('admin_add_more_media'),
                  style: TextStyle(
                    color: _imageUrls.isEmpty
                        ? ColorTokens.error50
                        : ColorTokens.primary30,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: ColorTokens.neutral100,
                  side: BorderSide(
                    color: _imageUrls.isEmpty
                        ? ColorTokens.error50
                        : ColorTokens.primary90,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Progress bar durante carga
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: ColorTokens.neutral95,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorTokens.primary30,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l.t('admin_uploading')} ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorTokens.neutral60, fontSize: 13),
                ),
              ],

              const SizedBox(height: 16),

              // Lista de imágenes
              if (_imageUrls.isNotEmpty) ...[
                Text(
                  l.t('admin_images_label'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.neutral30,
                  ),
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ColorTokens.neutral95),
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
                                decoration: BoxDecoration(
                                  color: ColorTokens.error50,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: ColorTokens.neutral100,
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
                Text(
                  l.t('admin_video_label'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.neutral30,
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: ColorTokens.neutral20,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorTokens.neutral95),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 48,
                          color: ColorTokens.neutral100,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeVideo,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorTokens.error50,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: ColorTokens.neutral100,
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorTokens.neutral50,
                        side: BorderSide(color: ColorTokens.neutral90),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l.t('cancel'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ColorTokens.neutral50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTokens.primary30,
                        foregroundColor: ColorTokens.neutral100,
                        disabledBackgroundColor: ColorTokens.neutral90,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.product == null
                            ? l.t('admin_create_product')
                            : l.t('admin_update'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
