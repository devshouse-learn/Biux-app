import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class RideCreateScreen extends StatefulWidget {
  final String groupId;
  final RideModel? rideToEdit; // Rodada a editar (null = modo creación)

  const RideCreateScreen({Key? key, required this.groupId, this.rideToEdit})
    : super(key: key);

  @override
  _RideCreateScreenState createState() => _RideCreateScreenState();
}

class _RideCreateScreenState extends State<RideCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kilometersController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _recommendationsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;
  MeetingPoint? _selectedMeetingPoint;
  String? _customMeetingPointName;
  double? _customMeetingPointLat;
  double? _customMeetingPointLng;
  String? _rideImageUrl;

  @override
  void initState() {
    super.initState();

    // Cargar puntos de encuentro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meetingPointProvider = Provider.of<MeetingPointProvider>(
        context,
        listen: false,
      );
      meetingPointProvider.startListening();

      // Si es modo edición, pre-cargar los datos
      if (widget.rideToEdit != null) {
        _loadRideData(meetingPointProvider);
      }
    });
  }

  void _loadRideData(MeetingPointProvider meetingPointProvider) {
    final ride = widget.rideToEdit!;

    // Cargar campos de texto
    _nameController.text = ride.name;
    _kilometersController.text = ride.kilometers.toString();
    _instructionsController.text = ride.instructions;
    _recommendationsController.text = ride.recommendations;

    // Cargar fecha y hora
    _selectedDate = ride.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(ride.dateTime);

    // Cargar dificultad
    _selectedDifficulty = ride.difficulty;

    // Cargar punto de encuentro
    _selectedMeetingPoint = meetingPointProvider.meetingPoints
        .where((mp) => mp.id == ride.meetingPointId)
        .firstOrNull;

    // Cargar imagen URL
    _rideImageUrl = ride.imageUrl;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rideToEdit != null ? l.t('edit_ride') : l.t('create_ride'),
        ),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
      ),
      body: Consumer2<RideProvider, MeetingPointProvider>(
        builder: (context, rideProvider, meetingPointProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la rodada
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l.t('ride_name_label'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.directions_bike),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('name_required');
                      }
                      if (value.trim().length < 3) {
                        return l.t('name_min_chars');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Punto de encuentro
                  _buildMeetingPointSelector(meetingPointProvider, l),
                  SizedBox(height: 16),

                  // Fecha
                  _buildDateSelector(l),
                  SizedBox(height: 16),

                  // Hora
                  _buildTimeSelector(l),
                  SizedBox(height: 16),

                  // Kilómetros
                  TextFormField(
                    controller: _kilometersController,
                    decoration: InputDecoration(
                      labelText: l.t('kilometers'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.straighten),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('km_required');
                      }
                      final km = double.tryParse(value);
                      if (km == null || km <= 0) {
                        return l.t('enter_valid_value');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Nivel de dificultad
                  _buildDifficultySelector(l),
                  SizedBox(height: 16),

                  // Instrucciones
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l.t('instructions'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('instructions_required');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Recomendaciones
                  TextFormField(
                    controller: _recommendationsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l.t('recommendations'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lightbulb_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('recommendations_required');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Imagen de la rodada
                  Text(
                    l.t('ride_image_optional'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  OptimizedImagePicker(
                    width: double.infinity,
                    height: 200,
                    borderRadius: BorderRadius.circular(12),
                    imageType: 'ride',
                    currentImageUrl:
                        _rideImageUrl, // Pre-cargar imagen en modo edición
                    onImageSelected: (String? imageUrl) {
                      setState(() {
                        _rideImageUrl = imageUrl;
                      });
                    },
                    placeholder: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorTokens.neutral60,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: ColorTokens.neutral10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: ColorTokens.neutral40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            l.t('add_image'),
                            style: TextStyle(
                              color: ColorTokens.neutral40,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Botón de crear/actualizar
                  if (rideProvider.isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.primary30,
                          foregroundColor: ColorTokens.neutral100,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.rideToEdit != null
                              ? l.t('update_ride')
                              : l.t('create_ride'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (rideProvider.error != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorTokens.error50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ColorTokens.error50.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: ColorTokens.error50),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rideProvider.error!,
                              style: TextStyle(color: ColorTokens.error50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingPointSelector(
    MeetingPointProvider provider,
    LocaleNotifier l,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('meeting_point'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),

        // ✅ CAMPO DE TEXTO PARA NOMBRE MANUAL
        if (_customMeetingPointName != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorTokens.primary30, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: ColorTokens.primary30.withValues(alpha: 0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punto personalizado',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorTokens.neutral60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _customMeetingPointName!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTokens.neutral20,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_customMeetingPointLat != null &&
                              _customMeetingPointLng != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '${_customMeetingPointLat!.toStringAsFixed(4)}, ${_customMeetingPointLng!.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorTokens.neutral60,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openMapWithCoordinates(
                        _customMeetingPointLat ?? 4.6097,
                        _customMeetingPointLng ?? -74.0817,
                        _customMeetingPointName ?? 'Punto de Encuentro',
                      ),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorTokens.primary30,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // Selector de puntos predefinidos
          GestureDetector(
            onTap: () => _showMeetingPointPicker(provider),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: ColorTokens.neutral60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: ColorTokens.primary30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedMeetingPoint?.name ??
                          l.t('select_a_meeting_point'),
                      style: TextStyle(
                        color: _selectedMeetingPoint != null
                            ? ColorTokens.neutral20
                            : ColorTokens.neutral60,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: ColorTokens.neutral60),
                ],
              ),
            ),
          ),

        SizedBox(height: 12),

        // ✅ BOTÓN PARA AGREGAR PUNTO MANUAL
        ElevatedButton.icon(
          onPressed: () => _showCustomMeetingPointDialog(),
          icon: Icon(Icons.add_location),
          label: Text(
            _customMeetingPointName != null
                ? l.t('change_custom_point')
                : l.t('add_custom_point'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTokens.secondary50,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 48),
          ),
        ),

        // Si hay error
        if (_selectedMeetingPoint == null && _customMeetingPointName == null)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              l.t('meeting_point_required'),
              style: TextStyle(color: ColorTokens.error50, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector(LocaleNotifier l) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorTokens.neutral60),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: ColorTokens.primary30),
            SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : l.t('select_date'),
              style: TextStyle(
                color: _selectedDate != null
                    ? ColorTokens.neutral20
                    : ColorTokens.neutral60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(LocaleNotifier l) {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorTokens.neutral60),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: ColorTokens.primary30),
            SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : l.t('select_time'),
              style: TextStyle(
                color: _selectedTime != null
                    ? ColorTokens.neutral20
                    : ColorTokens.neutral60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(LocaleNotifier l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('difficulty_level'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: ColorTokens.neutral60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<DifficultyLevel>(
            value: _selectedDifficulty,
            isExpanded: true,
            underline: SizedBox.shrink(),
            items: DifficultyLevel.values.map((difficulty) {
              Color color;
              switch (difficulty) {
                case DifficultyLevel.easy:
                  color = ColorTokens.success40;
                  break;
                case DifficultyLevel.medium:
                  color = ColorTokens.warning60;
                  break;
                case DifficultyLevel.hard:
                  color = ColorTokens.error50;
                  break;
                case DifficultyLevel.expert:
                  color = ColorTokens.secondary60;
                  break;
              }

              return DropdownMenuItem(
                value: difficulty,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(_getDifficultyName(difficulty, l)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDifficulty = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  String _getDifficultyName(DifficultyLevel difficulty, [LocaleNotifier? l]) {
    l ??= Provider.of<LocaleNotifier>(context, listen: false);
    switch (difficulty) {
      case DifficultyLevel.easy:
        return l.t('difficulty_easy');
      case DifficultyLevel.medium:
        return l.t('difficulty_medium');
      case DifficultyLevel.hard:
        return l.t('difficulty_hard');
      case DifficultyLevel.expert:
        return l.t('difficulty_expert');
    }
  }

  void _showMeetingPointPicker(MeetingPointProvider provider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (provider.meetingPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('loading_meeting_points')),
          backgroundColor: ColorTokens.warning60,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.t('select_meeting_point')),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: provider.meetingPoints.length,
              itemBuilder: (context, index) {
                final meetingPoint = provider.meetingPoints[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: ColorTokens.secondary50,
                  ),
                  title: Text(meetingPoint.name),
                  subtitle: meetingPoint.description.isNotEmpty
                      ? Text(meetingPoint.description)
                      : null,
                  selected: _selectedMeetingPoint?.id == meetingPoint.id,
                  onTap: () {
                    setState(() {
                      _selectedMeetingPoint = meetingPoint;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.t('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveRide() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    // Validar que hay al menos un punto de encuentro (predefinido o personalizado)
    if (_selectedMeetingPoint == null && _customMeetingPointName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('please_select_meeting_point')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    // Si hay punto personalizado pero sin coordenadas
    if (_customMeetingPointName != null &&
        (_customMeetingPointLat == null || _customMeetingPointLng == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('custom_point_needs_location')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('please_select_date')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('please_select_time')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('date_must_be_future')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    final provider = Provider.of<RideProvider>(context, listen: false);

    // Determinar el meetingPointId a usar
    late String meetingPointId;

    if (_customMeetingPointName != null) {
      // Si hay punto personalizado, crear uno temporal con ID único
      final customPointId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      meetingPointId = customPointId;
    } else {
      // Usar el punto seleccionado
      meetingPointId = _selectedMeetingPoint!.id;
    }

    final bool success;
    if (widget.rideToEdit != null) {
      // Modo edición
      success = await provider.updateRide(
        rideId: widget.rideToEdit!.id,
        name: _nameController.text.trim(),
        meetingPointId: meetingPointId,
        dateTime: dateTime,
        difficulty: _selectedDifficulty,
        kilometers: double.parse(_kilometersController.text),
        instructions: _instructionsController.text.trim(),
        recommendations: _recommendationsController.text.trim(),
        imageUrl: _rideImageUrl,
      );
    } else {
      // Modo creación
      success = await provider.createRide(
        name: _nameController.text.trim(),
        groupId: widget.groupId,
        meetingPointId: meetingPointId,
        dateTime: dateTime,
        difficulty: _selectedDifficulty,
        kilometers: double.parse(_kilometersController.text),
        instructions: _instructionsController.text.trim(),
        recommendations: _recommendationsController.text.trim(),
        imageUrl: _rideImageUrl,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.rideToEdit != null
                ? l.t('ride_updated_success')
                : l.t('ride_created_success'),
          ),
          backgroundColor: ColorTokens.success50,
        ),
      );
      context.pop();
    }
  }

  Future<void> _openMapWithCoordinates(
    double lat,
    double lng,
    String name,
  ) async {
    try {
      final googleMapsUrl = 'https://www.google.com/maps?q=$lat,$lng&z=16';
      final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng';

      final googleMapsUri = Uri.parse(googleMapsUrl);
      final appleMapsUri = Uri.parse(appleMapsUrl);

      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.t('maps_app_not_found'))));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.t('error_opening_maps')}: $e')),
        );
      }
    }
  }

  Future<void> _showCustomMeetingPointDialog() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _customMeetingPointName != null
                ? l.t('change_custom_point')
                : l.t('add_custom_point'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l.t('point_name'),
                    hintText: l.t('point_name_hint'),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final locationService = loc.Location();
                      final hasPermission = await locationService
                          .requestPermission();

                      if (hasPermission == loc.PermissionStatus.granted) {
                        final currentLocation = await locationService
                            .getLocation();
                        if (mounted) {
                          setState(() {
                            _customMeetingPointLat = currentLocation.latitude;
                            _customMeetingPointLng = currentLocation.longitude;
                            _customMeetingPointName = nameController.text
                                .trim();
                          });
                          Navigator.pop(context);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('location_permission_denied')),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${l.t('error_getting_location')}: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.location_on),
                  label: Text(l.t('use_current_location')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: ColorTokens.neutral100,
                  ),
                ),
                if (_customMeetingPointLat != null &&
                    _customMeetingPointLng != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTokens.primary10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l.t('saved_coordinates'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lat: ${_customMeetingPointLat?.toStringAsFixed(4)}\n'
                            'Lng: ${_customMeetingPointLng?.toStringAsFixed(4)}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.t('enter_point_name'))),
                  );
                  return;
                }
                if (_customMeetingPointLat == null ||
                    _customMeetingPointLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.t('select_a_location'))),
                  );
                  return;
                }
                setState(() {
                  _customMeetingPointName = nameController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
              ),
              child: Text(l.t('save')),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kilometersController.dispose();
    _instructionsController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }
}
