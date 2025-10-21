import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';

/// Tercer paso del registro: Propiedad y Compra (datos opcionales)
class BikeRegistrationStep3 extends StatefulWidget {
  const BikeRegistrationStep3({super.key});

  @override
  State<BikeRegistrationStep3> createState() => _BikeRegistrationStep3State();
}

class _BikeRegistrationStep3State extends State<BikeRegistrationStep3> {
  final _neighborhoodController = TextEditingController();
  final _purchasePlaceController = TextEditingController();
  final _featuredComponentsController = TextEditingController();
  DateTime? _selectedPurchaseDate;
  String? _invoicePhoto;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final bikeProvider = context.read<BikeProvider>();
    final data = bikeProvider.registrationData;

    _neighborhoodController.text = data['neighborhood'] ?? '';
    _purchasePlaceController.text = data['purchasePlace'] ?? '';
    _featuredComponentsController.text = data['featuredComponents'] ?? '';

    if (data['purchaseDate'] != null) {
      _selectedPurchaseDate = data['purchaseDate'] as DateTime?;
    }

    _invoicePhoto = data['invoice'];
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    _purchasePlaceController.dispose();
    _featuredComponentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // Información introductoria
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
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Información Opcional',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Estos datos son opcionales pero ayudan a tener un registro más completo de tu bicicleta.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Barrio
          _buildTextField(
            controller: _neighborhoodController,
            label: AppStrings.neighborhoodLabel,
            onChanged: (value) {
              context.read<BikeProvider>().updateRegistrationData(
                'neighborhood',
                value,
              );
            },
          ),

          const SizedBox(height: 16),

          // Fecha de compra
          _buildDateField(),

          const SizedBox(height: 16),

          // Lugar de compra
          _buildTextField(
            controller: _purchasePlaceController,
            label: AppStrings.purchasePlaceLabel,
            onChanged: (value) {
              context.read<BikeProvider>().updateRegistrationData(
                'purchasePlace',
                value,
              );
            },
          ),

          const SizedBox(height: 16),

          // Componentes destacados
          _buildTextField(
            controller: _featuredComponentsController,
            label: AppStrings.featuredComponentsLabel,
            maxLines: 3,
            onChanged: (value) {
              context.read<BikeProvider>().updateRegistrationData(
                'featuredComponents',
                value,
              );
            },
          ),

          const SizedBox(height: 24),

          // Factura o recibo
          _buildInvoiceSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ColorTokens.neutral70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColorTokens.primary30,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.purchaseDateLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorTokens.neutral70),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: ColorTokens.neutral70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedPurchaseDate != null
                      ? '${_selectedPurchaseDate!.day}/${_selectedPurchaseDate!.month}/${_selectedPurchaseDate!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedPurchaseDate != null
                        ? Colors.black87
                        : ColorTokens.neutral70,
                  ),
                ),
                const Spacer(),
                if (_selectedPurchaseDate != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPurchaseDate = null;
                      });
                      context.read<BikeProvider>().updateRegistrationData(
                        'purchaseDate',
                        null,
                      );
                    },
                    child: Icon(
                      Icons.close,
                      color: ColorTokens.neutral70,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.invoiceLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickInvoiceImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: _invoicePhoto != null
                    ? ColorTokens.primary30
                    : ColorTokens.neutral70,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _invoicePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      _invoicePhoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInvoicePlaceholder(true);
                      },
                    ),
                  )
                : _buildInvoicePlaceholder(false),
          ),
        ),
        if (_invoicePhoto != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _pickInvoiceImage,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cambiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: ColorTokens.primary30,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _invoicePhoto = null;
                    });
                    context.read<BikeProvider>().updateRegistrationData(
                      'invoice',
                      null,
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInvoicePlaceholder(bool hasError) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasError ? Icons.error_outline : Icons.receipt,
          size: 32,
          color: hasError ? Colors.red : ColorTokens.neutral70,
        ),
        const SizedBox(height: 8),
        Text(
          hasError ? 'Error al cargar imagen' : 'Toca para agregar factura',
          style: TextStyle(
            fontSize: 12,
            color: hasError ? Colors.red : ColorTokens.neutral70,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorTokens.primary30,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedPurchaseDate) {
      setState(() {
        _selectedPurchaseDate = picked;
      });
      context.read<BikeProvider>().updateRegistrationData(
        'purchaseDate',
        picked,
      );
    }
  }

  Future<void> _pickInvoiceImage() async {
    // En una implementación real, aquí usarías ImagePicker
    // Por ahora, simulamos la selección
    setState(() {
      _invoicePhoto = 'placeholder-invoice-path';
    });
    context.read<BikeProvider>().updateRegistrationData(
      'invoice',
      _invoicePhoto,
    );
  }
}
