import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';
import 'package:biux/shared/widgets/text_form_field_biux_widget.dart';

/// Primer paso del registro: Datos básicos obligatorios
class BikeRegistrationStep1 extends StatefulWidget {
  const BikeRegistrationStep1({super.key});

  @override
  State<BikeRegistrationStep1> createState() => _BikeRegistrationStep1State();
}

class _BikeRegistrationStep1State extends State<BikeRegistrationStep1> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _frameSerialController = TextEditingController();
  final _cityController = TextEditingController();

  BikeType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final bikeProvider = context.read<BikeProvider>();
    final data = bikeProvider.registrationData;

    _brandController.text = data['brand'] ?? '';
    _modelController.text = data['model'] ?? '';
    _yearController.text = data['year']?.toString() ?? '';
    _colorController.text = data['color'] ?? '';
    _sizeController.text = data['size'] ?? '';
    _frameSerialController.text = data['frameSerial'] ?? '';
    _cityController.text = data['city'] ?? '';
    _selectedType = data['type'];
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _frameSerialController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 8),

            // Marca
            TextFormFieldBiuxWidget(
              controller: _brandController,
              text: AppStrings.brandLabel,
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'brand',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Modelo
            TextFormFieldBiuxWidget(
              controller: _modelController,
              text: AppStrings.modelLabel,

              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'model',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Año
            TextFormFieldBiuxWidget(
              controller: _yearController,
              text: AppStrings.yearLabel,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final year = int.tryParse(value);
                context.read<BikeProvider>().updateRegistrationData(
                  'year',
                  year,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                final year = int.tryParse(value);
                if (year == null ||
                    year < 1900 ||
                    year > DateTime.now().year + 1) {
                  return AppStrings.invalidYear;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Color
            TextFormFieldBiuxWidget(
              controller: _colorController,
              text: AppStrings.colorLabel,
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'color',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Talla
            TextFormFieldBiuxWidget(
              controller: _sizeController,
              text: AppStrings.sizeLabel,

              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'size',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Tipo de bicicleta
            _buildBikeTypeSelector(),

            const SizedBox(height: 16),

            // Número de serie del marco
            TextFormFieldBiuxWidget(
              controller: _frameSerialController,
              text: AppStrings.frameSerialLabel,

              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'frameSerial',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            // Texto de ayuda para el número de serie
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                AppStrings.frameSerialHelp,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 16),

            // Ciudad
            TextFormFieldBiuxWidget(
              controller: _cityController,
              text: AppStrings.cityLabel,
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'city',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.fieldRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.bikeTypeLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: ColorTokens.neutral70),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BikeType>(
              value: _selectedType,
              isExpanded: true,
              hint: const Text('Selecciona el tipo de bicicleta'),
              items: BikeType.values.map((type) {
                return DropdownMenuItem<BikeType>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (BikeType? value) {
                setState(() {
                  _selectedType = value;
                });
                context.read<BikeProvider>().updateRegistrationData(
                  'type',
                  value,
                );
              },
            ),
          ),
        ),
        if (_selectedType == null && _shouldShowValidation())
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              AppStrings.fieldRequired,
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
            ),
          ),
      ],
    );
  }

  bool _shouldShowValidation() {
    // Solo mostrar validación si se ha intentado avanzar
    return context.read<BikeProvider>().currentStep > 0;
  }
}
