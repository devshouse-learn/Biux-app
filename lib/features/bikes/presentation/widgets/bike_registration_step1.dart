import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
              text: l.t('brand_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'brand',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                if (value.trim().length < 2) {
                  return l.t('brand_min_chars');
                }
                if (value.trim().length > 100) {
                  return l.t('brand_max_chars');
                }
                if (!RegExp(
                  r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-]+$',
                ).hasMatch(value.trim())) {
                  return l.t('only_letters_numbers_spaces_hyphens');
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Modelo
            TextFormFieldBiuxWidget(
              controller: _modelController,
              text: l.t('model_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'model',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                if (value.trim().length < 2) {
                  return l.t('model_min_chars');
                }
                if (value.trim().length > 100) {
                  return l.t('model_max_chars');
                }
                if (!RegExp(
                  r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-/]+$',
                ).hasMatch(value.trim())) {
                  return l.t('only_letters_numbers_spaces_hyphens_slashes');
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
              text: l.t('color_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'color',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                if (value.trim().length < 2) {
                  return l.t('color_min_chars');
                }
                if (value.trim().length > 100) {
                  return l.t('color_max_chars');
                }
                if (!RegExp(
                  r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s\-/]+$',
                ).hasMatch(value.trim())) {
                  return l.t('only_letters_numbers_spaces_hyphens_slashes');
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Talla
            TextFormFieldBiuxWidget(
              controller: _sizeController,
              text: l.t('size_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'size',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                final trimmed = value.trim();
                if (trimmed.length > 10) {
                  return l.t('size_max_chars');
                }
                // Acepta: XS, S, M, L, XL, XXL, XXXL o números (14, 16, 18, etc.) o medidas en pulgadas
                if (!RegExp(
                  r'^(XXS|XS|S|M|L|XL|XXL|XXXL|\d{1,2}(\.\d)?|\d{1,2}")$',
                  caseSensitive: false,
                ).hasMatch(trimmed)) {
                  return l.t('valid_size_hint');
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
              text: l.t('frame_serial_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'frameSerial',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                if (value.trim().length < 4) {
                  return l.t('serial_min_chars');
                }
                if (value.trim().length > 100) {
                  return l.t('serial_max_chars');
                }
                if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value.trim())) {
                  return l.t('only_letters_numbers_hyphens');
                }
                return null;
              },
            ),

            // Texto de ayuda para el número de serie
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                l.t('frame_serial_help'),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 16),

            // Ciudad * - Campo de texto libre con validación
            TextFormFieldBiuxWidget(
              controller: _cityController,
              text: l.t('city_department_label'),
              onChanged: (value) {
                context.read<BikeProvider>().updateRegistrationData(
                  'city',
                  value,
                );
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l.t('field_required');
                }
                // Validar formato: debe contener al menos una coma separando ciudad de departamento/estado
                final parts = value.split(',').map((e) => e.trim()).toList();
                if (parts.length < 2) {
                  return l.t('city_format_hint');
                }
                if (parts[0].isEmpty || parts[1].isEmpty) {
                  return l.t('city_and_department_required');
                }
                if (parts[0].length < 2) {
                  return l.t('city_min_chars');
                }
                if (parts[1].length < 2) {
                  return l.t('department_min_chars');
                }
                if (value.trim().length > 150) {
                  return l.t('text_max_150_chars');
                }
                // Validar que solo contenga letras, espacios, comas, acentos y guiones
                if (!RegExp(
                  r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s,\-\.]+$',
                ).hasMatch(value.trim())) {
                  return l.t('only_letters_spaces_commas_hyphens');
                }
                return null;
              },
            ),

            // Texto de ayuda para ciudad
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                l.t('city_example_hint'),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeTypeSelector() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('bike_type_label'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorTokens.primary30,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showBikeTypePicker(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedType == null
                    ? ColorTokens.neutral70
                    : ColorTokens.primary30,
                width: _selectedType == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.pedal_bike,
                  color: _selectedType == null
                      ? ColorTokens.neutral70
                      : ColorTokens.primary30,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedType?.displayName != null
                      ? l.t(_selectedType!.displayName)
                      : l.t('select_bike_type'),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedType != null
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
        if (_selectedType == null && _shouldShowValidation())
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              l.t('field_required'),
              style: TextStyle(fontSize: 12, color: ColorTokens.error40),
            ),
          ),
      ],
    );
  }

  void _showBikeTypePicker() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorTokens.primary30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: ColorTokens.primary30,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.t('select_bike_type_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.neutral100,
                ),
              ),
              const Divider(color: ColorTokens.neutral80),
              ...BikeType.values.map((type) {
                final isSelected = type == _selectedType;
                return ListTile(
                  title: Text(
                    l.t(type.displayName),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: ColorTokens.neutral100,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: ColorTokens.secondary50,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                    context.read<BikeProvider>().updateRegistrationData(
                      'type',
                      type,
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  bool _shouldShowValidation() {
    // Solo mostrar validación si se ha intentado avanzar
    return context.read<BikeProvider>().currentStep > 0;
  }

  Widget _buildYearSelector() {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1899 + 1,
      (index) => currentYear + 1 - index,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l.t('year_label')} *',
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
                  _selectedYear?.toString() ?? l.t('select_bike_year'),
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
              l.t('field_required'),
              style: TextStyle(fontSize: 12, color: ColorTokens.error40),
            ),
          ),
      ],
    );
  }

  void _showYearPicker(List<int> years) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorTokens.primary30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: ColorTokens.primary30,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l.t('cancel'),
                      style: const TextStyle(color: ColorTokens.neutral100),
                    ),
                  ),
                  Text(
                    l.t('select_year_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral100,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_selectedYear != null) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      l.t('done'),
                      style: TextStyle(
                        color: _selectedYear != null
                            ? ColorTokens.secondary50
                            : ColorTokens.neutral70,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: ColorTokens.neutral80),
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
                          color: ColorTokens.neutral100,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: ColorTokens.secondary50,
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
