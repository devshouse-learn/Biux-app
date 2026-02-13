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
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _frameSerialController = TextEditingController();
  final _cityController = TextEditingController();

  BikeType? _selectedType;
  int? _selectedYear;

  // Método público para validar el formulario
  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

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
    _selectedYear = data['year'];
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
                if (value.trim().length < 2) {
                  return 'La marca debe tener al menos 2 caracteres';
                }
                if (!RegExp(
                  r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-]+$',
                ).hasMatch(value)) {
                  return 'Solo se permiten letras, números y guiones';
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
                if (value.trim().length < 2) {
                  return 'El modelo debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Año (Selector)
            _buildYearSelector(),

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
                if (value.trim().length < 3) {
                  return 'Ingresa un color válido (ej: Rojo, Azul, Negro)';
                }
                if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\/\-]+$').hasMatch(value)) {
                  return 'Solo se permiten letras (ej: Rojo/Negro)';
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
                // Acepta: S, M, L, XL, XXL o números (14, 16, 18, etc.) o medidas en pulgadas
                if (!RegExp(
                  r'^(XXS|XS|S|M|L|XL|XXL|XXXL|\d{1,2}(\.\d)?|\d{1,2}"?)$',
                  caseSensitive: false,
                ).hasMatch(value.trim())) {
                  return 'Ingresa una talla válida (ej: S, M, L, XL, 16, 18")';
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
                if (value.trim().length < 4) {
                  return 'El número de serie debe tener al menos 4 caracteres';
                }
                if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value.trim())) {
                  return 'Solo se permiten letras, números y guiones';
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
              keyboardType: TextInputType.text,
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'city',
                  value.trim(),
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                // Validar que tenga al menos 2 caracteres
                if (value.trim().length < 2) {
                  return 'Ingresa un nombre de ciudad válido';
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

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1899 + 1,
      (index) => currentYear + 1 - index,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.yearLabel} *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showYearPicker(years),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedYear == null
                    ? ColorTokens.neutral70
                    : ColorTokens.primary30,
                width: _selectedYear == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _selectedYear == null
                      ? ColorTokens.neutral70
                      : ColorTokens.primary30,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedYear?.toString() ??
                      'Seleccionar año de la bicicleta',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedYear != null
                        ? Colors.black87
                        : ColorTokens.neutral70,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: ColorTokens.neutral70),
              ],
            ),
          ),
        ),
        if (_selectedYear == null && _shouldShowValidation())
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

  void _showYearPicker(List<int> years) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const Text(
                    'Selecciona el Año',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_selectedYear != null) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Listo',
                      style: TextStyle(
                        color: _selectedYear != null
                            ? ColorTokens.primary30
                            : ColorTokens.neutral70,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected = year == _selectedYear;

                    return ListTile(
                      title: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? ColorTokens.primary30
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: ColorTokens.primary30,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedYear = year;
                        });
                        context.read<BikeProvider>().updateRegistrationData(
                          'year',
                          year,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
