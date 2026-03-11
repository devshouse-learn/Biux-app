import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Pantalla para agregar un nuevo producto a la tienda
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _sizesController = TextEditingController();
  final _tagsController = TextEditingController();

  // Campos de bicicleta
  final _frameSerialController = TextEditingController();
  final _bikeBrandController = TextEditingController();
  final _bikeModelController = TextEditingController();
  final _bikeColorController = TextEditingController();
  final _bikeYearController = TextEditingController();

  String _selectedCategory = ProductCategories.accessories;
  bool _isBicycle = false;
  bool _isSubmitting = false;
  bool _isStolenCheckDone = false;
  bool _isStolenCheckPassed = false;
  bool _isCheckingStolen = false;
  final List<String> _imageUrls = [];
  final List<File> _selectedImages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _sizesController.dispose();
    _tagsController.dispose();
    _frameSerialController.dispose();
    _bikeBrandController.dispose();
    _bikeModelController.dispose();
    _bikeColorController.dispose();
    _bikeYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onBack(),
        ),
        title: Text(
          l.t('add_product'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // === INFORMACIÓN BÁSICA ===
            _buildSectionHeader(
              l.t('product_info_section'),
              Icons.info_outline,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: l.t('product_name_label'),
              hint: l.t('product_name_hint'),
              icon: Icons.label_outline,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.t('name_required') : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: l.t('short_description'),
              hint: l.t('short_description_hint'),
              icon: Icons.short_text,
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty
                  ? l.t('description_required')
                  : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _longDescriptionController,
              label: l.t('detailed_description'),
              hint: l.t('detailed_description_hint'),
              icon: Icons.description_outlined,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // === CATEGORÍA ===
            _buildSectionHeader(l.t('category_label'), Icons.category_outlined),
            const SizedBox(height: 12),
            _buildCategorySelector(),

            const SizedBox(height: 24),

            // === PRECIO Y STOCK ===
            _buildSectionHeader(l.t('price_and_stock'), Icons.attach_money),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: l.t('price_cop'),
                    hint: '150000',
                    icon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return l.t('required_label');
                      final price = double.tryParse(v);
                      if (price == null || price <= 0)
                        return l.t('invalid_price');
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stockController,
                    label: l.t('stock_field'),
                    hint: '1',
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return l.t('required_label');
                      final stock = int.tryParse(v);
                      if (stock == null || stock < 1) return l.t('min_one');
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // === TALLAS Y TAGS ===
            _buildSectionHeader(l.t('sizes_and_tags'), Icons.straighten),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _sizesController,
              label: l.t('sizes_hint'),
              hint: l.t('sizes_placeholder'),
              icon: Icons.straighten,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _tagsController,
              label: l.t('search_tags_hint'),
              hint: l.t('search_tags_placeholder'),
              icon: Icons.tag,
            ),

            const SizedBox(height: 24),

            // === IMÁGENES (OBLIGATORIO) ===
            _buildSectionHeader(l.t('images_required'), Icons.image_outlined),
            const SizedBox(height: 4),
            Text(
              l.t('min_one_photo'),
              style: TextStyle(
                fontSize: 12,
                color: _selectedImages.isEmpty
                    ? Colors.red.shade400
                    : ColorTokens.neutral60,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildImagePicker(l),

            const SizedBox(height: 24),

            // === SECCIÓN BICICLETA ===
            _buildBicycleSection(l),

            const SizedBox(height: 32),

            // === BOTONES ===
            _buildActionButtons(l),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===== WIDGETS DE FORMULARIO =====

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorTokens.primary30.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorTokens.primary30, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ColorTokens.neutral10,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: ColorTokens.neutral10),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: ColorTokens.neutral50)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.neutral90),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.neutral90),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.primary30, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.error50),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ProductCategories.getAll()
        .where((c) => c.id != ProductCategories.all)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral90),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: ColorTokens.neutral50),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ColorTokens.neutral10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
                _isBicycle = value == ProductCategories.bikes;
                // Reset stolen check when category changes
                _isStolenCheckDone = false;
                _isStolenCheckPassed = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker(LocaleNotifier l) {
    return Column(
      children: [
        // Preview de imágenes seleccionadas
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorTokens.neutral90),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedImages.removeAt(index));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
        // Botón para agregar imágenes
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _selectedImages.isEmpty
                  ? Colors.red.shade50
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImages.isEmpty
                    ? Colors.red.shade300
                    : ColorTokens.neutral90,
                style: BorderStyle.solid,
                width: _selectedImages.isEmpty ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedImages.isEmpty
                      ? Icons.add_a_photo_outlined
                      : Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: _selectedImages.isEmpty
                      ? Colors.red.shade300
                      : ColorTokens.primary30,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImages.isEmpty
                      ? '📷 ${l.t('tap_add_photos')}'
                      : '${l.t('add_more_images')} (${_selectedImages.length}/5)',
                  style: TextStyle(
                    color: _selectedImages.isEmpty
                        ? Colors.red.shade400
                        : ColorTokens.neutral50,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== SECCIÓN BICICLETA CON VERIFICACIÓN ANTIRROBO =====

  Widget _buildBicycleSection(LocaleNotifier l) {
    return Column(
      children: [
        // Toggle de bicicleta
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorTokens.neutral90),
          ),
          child: Row(
            children: [
              Icon(Icons.pedal_bike, color: ColorTokens.primary30, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.t('is_bicycle_question'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.neutral10,
                      ),
                    ),
                    Text(
                      l.t('anti_theft_verification_required'),
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorTokens.neutral50,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isBicycle,
                onChanged: (value) {
                  setState(() {
                    _isBicycle = value;
                    if (value) {
                      _selectedCategory = ProductCategories.bikes;
                    }
                    _isStolenCheckDone = false;
                    _isStolenCheckPassed = false;
                  });
                },
                activeThumbColor: ColorTokens.primary30,
              ),
            ],
          ),
        ),

        // Campos de bicicleta (solo si es bicicleta)
        if (_isBicycle) ...[
          const SizedBox(height: 16),

          // Warning de verificación
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorTokens.warning99,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorTokens.warning50.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: ColorTokens.warning50,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.t('stolen_bikes_warning'),
                    style: TextStyle(
                      fontSize: 13,
                      color: ColorTokens.neutral20,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildTextField(
            controller: _frameSerialController,
            label: l.t('frame_serial_label'),
            hint: l.t('frame_serial_hint'),
            icon: Icons.qr_code,
            validator: _isBicycle
                ? (v) => v == null || v.trim().isEmpty
                      ? l.t('serial_required_bikes')
                      : null
                : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bikeBrandController,
            label: '${l.t('brand_label')} *',
            hint: l.t('bike_brand_hint'),
            icon: Icons.branding_watermark,
            validator: _isBicycle
                ? (v) => v == null || v.trim().isEmpty
                      ? l.t('brand_required_msg')
                      : null
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _bikeModelController,
                  label: l.t('model_label'),
                  hint: l.t('bike_model_hint'),
                  icon: Icons.directions_bike,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _bikeYearController,
                  label: l.t('year_label'),
                  hint: '2024',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bikeColorController,
            label: l.t('color_label'),
            hint: l.t('bike_color_hint'),
            icon: Icons.palette_outlined,
          ),

          const SizedBox(height: 16),

          // Botón de verificación antirrobo
          _buildStolenCheckButton(l),
        ],
      ],
    );
  }

  Widget _buildStolenCheckButton(LocaleNotifier l) {
    if (_isStolenCheckDone && _isStolenCheckPassed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorTokens.success95,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorTokens.success40.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: ColorTokens.success40, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('verification_approved'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ColorTokens.success30,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.t('bike_not_reported_stolen'),
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorTokens.success40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_isStolenCheckDone && !_isStolenCheckPassed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorTokens.error95,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorTokens.error50.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.dangerous, color: ColorTokens.error50, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('bike_reported_stolen'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ColorTokens.error50,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.t('cannot_publish_contact_admin'),
                    style: TextStyle(fontSize: 12, color: ColorTokens.error50),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCheckingStolen ? null : _checkStolenStatus,
        icon: _isCheckingStolen
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.verified_user),
        label: Text(
          _isCheckingStolen ? l.t('verifying') : l.t('verify_not_stolen_btn'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.primary30,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ===== BOTONES DE ACCIÓN =====

  Widget _buildActionButtons(LocaleNotifier l) {
    return Column(
      children: [
        // Botón Agregar
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitProduct,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.publish),
            label: Text(
              _isSubmitting ? l.t('publishing') : l.t('publish_product'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.success40,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botón Cancelar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _onBack,
            icon: const Icon(Icons.close),
            label: Text(
              l.t('cancel'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorTokens.neutral40,
              side: BorderSide(color: ColorTokens.neutral80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== ACCIONES =====

  void _onBack() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _priceController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l.t('discard_changes')),
          content: Text(l.t('discard_changes_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.t('keep_editing')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _goBack();
              },
              child: Text(
                l.t('discard'),
                style: TextStyle(color: ColorTokens.error50),
              ),
            ),
          ],
        ),
      );
    } else {
      _goBack();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/shop');
    }
  }

  Future<void> _pickImages() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('max_5_images'))));
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        final remaining = 5 - _selectedImages.length;
        final toAdd = images
            .take(remaining)
            .map((xFile) => File(xFile.path))
            .toList();
        _selectedImages.addAll(toAdd);
      });
    }
  }

  Future<void> _checkStolenStatus() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final serial = _frameSerialController.text.trim();
    if (serial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('enter_serial_to_verify')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCheckingStolen = true);

    // Simular verificación (en producción consultar base de datos de robadas)
    await Future.delayed(const Duration(seconds: 2));

    // Verificar contra la lista de bicicletas robadas
    final shopProvider = context.read<ShopProvider>();
    final stolenBikes = shopProvider.products.where(
      (p) =>
          p.isBicycle &&
          p.bikeFrameSerial != null &&
          p.bikeFrameSerial!.toLowerCase() == serial.toLowerCase() &&
          p.metadata?['reportedStolen'] == true,
    );

    if (!mounted) return;

    setState(() {
      _isCheckingStolen = false;
      _isStolenCheckDone = true;
      _isStolenCheckPassed = stolenBikes.isEmpty;
    });

    if (!_isStolenCheckPassed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${l.t('bike_stolen_cannot_publish')}'),
          backgroundColor: ColorTokens.error50,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _submitProduct() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    // Validar bicicleta
    if (_isBicycle && !_isStolenCheckDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('must_verify_bike_first')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isBicycle && !_isStolenCheckPassed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('cannot_publish_stolen_bike')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    // Validar al menos una imagen
    if (_selectedImages.isEmpty && _imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('add_product_image')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userProvider = context.read<UserProvider>();
      final shopProvider = context.read<ShopProvider>();
      final currentUser = userProvider.user;

      if (currentUser == null) {
        throw Exception(l.t('user_not_authenticated'));
      }

      // Parsear tallas y tags
      final sizes = _sizesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Subir imágenes a Firebase Storage y obtener URLs
      // Si no hay imágenes reales, no permitir publicar
      if (_selectedImages.isEmpty && _imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('must_add_product_photo')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      List<String> imageUrls;
      if (_imageUrls.isNotEmpty) {
        imageUrls = _imageUrls;
      } else {
        // IMPLEMENTADO (STUB): Implementar subida real a Firebase Storage
        // Por ahora, los productos sin URLs reales no se publican
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('image_processing_error')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final product = ProductEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        longDescription: _longDescriptionController.text.trim().isNotEmpty
            ? _longDescriptionController.text.trim()
            : null,
        price: double.parse(_priceController.text.trim()),
        images: imageUrls,
        category: _selectedCategory,
        sizes: sizes.isNotEmpty ? sizes : [l.t('unique_size')],
        stock: int.parse(_stockController.text.trim()),
        sellerId: currentUser.uid,
        sellerName: currentUser.name ?? l.t('default_seller'),
        sellerCity: null,
        createdAt: DateTime.now(),
        tags: tags,
        isBicycle: _isBicycle,
        bikeFrameSerial: _isBicycle ? _frameSerialController.text.trim() : null,
        bikeBrand: _isBicycle ? _bikeBrandController.text.trim() : null,
        bikeModel: _isBicycle && _bikeModelController.text.trim().isNotEmpty
            ? _bikeModelController.text.trim()
            : null,
        bikeColor: _isBicycle && _bikeColorController.text.trim().isNotEmpty
            ? _bikeColorController.text.trim()
            : null,
        bikeYear: _isBicycle && _bikeYearController.text.trim().isNotEmpty
            ? int.tryParse(_bikeYearController.text.trim())
            : null,
        isVerifiedNotStolen: _isBicycle ? _isStolenCheckPassed : false,
        stolenVerificationDate: _isBicycle ? DateTime.now() : null,
      );

      final success = await shopProvider.createProduct(
        product,
        canCreateProducts: currentUser.canCreateProducts,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l.t('product_published_success')}'),
            backgroundColor: ColorTokens.success40,
          ),
        );
        _goBack();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shopProvider.errorMessage ?? l.t('error_publishing')),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: ColorTokens.error50,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
