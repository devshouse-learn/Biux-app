import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/shop/domain/entities/product_entity.dart';
import 'package:biux/features/shop/domain/entities/category_entity.dart';
import 'package:biux/features/shop/presentation/providers/shop_provider.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class ProductFormModal extends StatefulWidget {
  final ProductEntity? product;
  const ProductFormModal({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _cityController;
  late final TextEditingController _bikeFrameSerialController;

  String _selectedCategory = ProductCategories.all;
  bool _isBicycle = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '0',
    );
    _stockController = TextEditingController(
      text: widget.product != null ? widget.product!.stock.toString() : '1',
    );
    _cityController = TextEditingController(
      text: widget.product?.sellerCity ?? '',
    );
    _bikeFrameSerialController = TextEditingController(
      text: widget.product?.bikeFrameSerial ?? '',
    );
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      _isBicycle = widget.product!.isBicycle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _cityController.dispose();
    _bikeFrameSerialController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) return;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final product = ProductEntity(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: widget.product?.description ?? '',
      price: double.tryParse(_priceController.text) ?? 0,
      images: [],
      videoUrl: null,
      category: _selectedCategory,
      sizes: [],
      stock: int.tryParse(_stockController.text) ?? 0,
      sellerId: user.uid,
      sellerName: user.username ?? user.name ?? l.t('seller'),
      sellerCity: _cityController.text.isEmpty ? null : _cityController.text,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      isActive: true,
      isBicycle: _isBicycle,
      bikeFrameSerial: _isBicycle
          ? _bikeFrameSerialController.text.trim()
          : null,
      bikeBrand: null,
      bikeModel: null,
      bikeColor: null,
      bikeYear: null,
      isVerifiedNotStolen: widget.product?.isVerifiedNotStolen ?? false,
    );

    final shop = context.read<ShopProvider>();
    final ok = widget.product == null
        ? await shop.createProduct(product, canCreateProducts: true)
        : await shop.updateProduct(product);

    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? l.t('product_created')
                : l.t('product_updated'),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(shop.errorMessage ?? l.t('error_saving'))),
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
          color: ColorTokens.neutral99,
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
              Text(
                widget.product == null
                    ? l.t('create_product')
                    : l.t('edit_product'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.neutral20,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l.t('product_name_required'),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l.t('enter_name') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: l.t('price_required'),
                        filled: true,
                        fillColor: ColorTokens.neutral100,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l.t('enter_price') : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: l.t('stock_required'),
                        filled: true,
                        fillColor: ColorTokens.neutral100,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l.t('enter_stock') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: ProductCategories.getAll()
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.icon} ${c.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(
                  () => _selectedCategory = v ?? ProductCategories.all,
                ),
                decoration: InputDecoration(
                  labelText: l.t('category_label'),
                  filled: true,
                  fillColor: ColorTokens.neutral100,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _isBicycle,
                onChanged: (v) => setState(() => _isBicycle = v ?? false),
                title: Text(l.t('is_complete_bike')),
              ),
              if (_isBicycle) ...[
                TextFormField(
                  controller: _bikeFrameSerialController,
                  decoration: InputDecoration(
                    labelText: l.t('serial_number_chassis'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l.t('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(
                        widget.product == null
                            ? l.t('create_product')
                            : l.t('update'),
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
