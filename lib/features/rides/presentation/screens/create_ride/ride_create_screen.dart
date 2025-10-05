import 'package:biux/features/maps/data/models/meeting_point.dart';
import 'package:biux/features/maps/presentation/providers/meeting_point_provider.dart';
import 'package:biux/features/rides/data/models/ride_model.dart';
import 'package:biux/features/rides/presentation/providers/ride_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/config/colors.dart';

class RideCreateScreen extends StatefulWidget {
  final String groupId;

  const RideCreateScreen({Key? key, required this.groupId}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    // Cargar puntos de encuentro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingPointProvider>(context, listen: false)
          .startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Rodada'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
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
                      labelText: 'Nombre de la rodada',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.directions_bike),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Punto de encuentro
                  _buildMeetingPointSelector(meetingPointProvider),
                  SizedBox(height: 16),

                  // Fecha
                  _buildDateSelector(),
                  SizedBox(height: 16),

                  // Hora
                  _buildTimeSelector(),
                  SizedBox(height: 16),

                  // Kilómetros
                  TextFormField(
                    controller: _kilometersController,
                    decoration: InputDecoration(
                      labelText: 'Kilómetros',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.straighten),
                      suffixText: 'km',
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Los kilómetros son requeridos';
                      }
                      final km = double.tryParse(value);
                      if (km == null || km <= 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Nivel de dificultad
                  _buildDifficultySelector(),
                  SizedBox(height: 16),

                  // Instrucciones
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Instrucciones',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las instrucciones son requeridas';
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
                      labelText: 'Recomendaciones',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lightbulb_outline),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las recomendaciones son requeridas';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Botón de crear
                  if (rideProvider.isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blackPearl,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear Rodada',
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
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rideProvider.error!,
                              style: TextStyle(color: AppColors.red),
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

  Widget _buildMeetingPointSelector(MeetingPointProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Punto de encuentro',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMeetingPointPicker(provider),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.blackPearl),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedMeetingPoint?.name ??
                        'Selecciona un punto de encuentro',
                    style: TextStyle(
                      color: _selectedMeetingPoint != null
                          ? AppColors.black87
                          : AppColors.grey600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.grey600),
              ],
            ),
          ),
        ),
        if (_selectedMeetingPoint == null)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'El punto de encuentro es requerido',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey600),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.blackPearl),
            SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Selecciona la fecha',
              style: TextStyle(
                color: _selectedDate != null
                    ? AppColors.black87
                    : AppColors.grey600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey600),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.blackPearl),
            SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : 'Selecciona la hora',
              style: TextStyle(
                color: _selectedTime != null
                    ? AppColors.black87
                    : AppColors.grey600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de dificultad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey600),
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
                  color = AppColors.softGreen;
                  break;
                case DifficultyLevel.medium:
                  color = AppColors.vividOrange;
                  break;
                case DifficultyLevel.hard:
                  color = AppColors.red;
                  break;
                case DifficultyLevel.expert:
                  color = AppColors.purple;
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
                    Text(_getDifficultyName(difficulty)),
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

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Fácil';
      case DifficultyLevel.medium:
        return 'Intermedio';
      case DifficultyLevel.hard:
        return 'Difícil';
      case DifficultyLevel.expert:
        return 'Experto';
    }
  }

  void _showMeetingPointPicker(MeetingPointProvider provider) {
    if (provider.meetingPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cargando puntos de encuentro...'),
          backgroundColor: AppColors.vividOrange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Punto de Encuentro'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: provider.meetingPoints.length,
              itemBuilder: (context, index) {
                final meetingPoint = provider.meetingPoints[index];
                return ListTile(
                  leading: Icon(Icons.location_on, color: AppColors.strongCyan),
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
              child: Text('Cancelar'),
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

  void _createRide() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMeetingPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona un punto de encuentro'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona la fecha'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona la hora'),
          backgroundColor: AppColors.red,
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
          content: Text('La fecha y hora deben ser en el futuro'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<RideProvider>(context, listen: false);

    final success = await provider.createRide(
      name: _nameController.text.trim(),
      groupId: widget.groupId,
      meetingPointId: _selectedMeetingPoint!.id,
      dateTime: dateTime,
      difficulty: _selectedDifficulty,
      kilometers: double.parse(_kilometersController.text),
      instructions: _instructionsController.text.trim(),
      recommendations: _recommendationsController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rodada creada exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop();
    }
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
