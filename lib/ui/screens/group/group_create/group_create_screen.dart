import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../config/colors.dart';
import '../../../../data/models/city_model.dart';
import '../../../../providers/city_provider.dart';
import '../../../../providers/group_provider.dart';

class GroupCreateScreen extends StatefulWidget {
  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _logoFile;
  XFile? _coverFile;
  CityModel? _selectedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCities();
    });
  }

  void _initializeCities() async {
    final cityProvider = Provider.of<CityProvider>(context, listen: false);

    // Inicializar ciudades si no están cargadas
    if (cityProvider.cities.isEmpty) {
      await cityProvider.initializeCities();
    }

    // Seleccionar Ibagué por defecto
    if (cityProvider.cities.isNotEmpty) {
      final ibague = cityProvider.cities.firstWhere(
        (city) => city.name == 'Ibagué',
        orElse: () => cityProvider.cities.first,
      );
      setState(() {
        _selectedCity = ibague;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Grupo'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
      ),
      body: Consumer2<GroupProvider, CityProvider>(
        builder: (context, groupProvider, cityProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de portada
                  _buildCoverImageSection(groupProvider),
                  SizedBox(height: 24),

                  // Logo del grupo
                  _buildLogoSection(groupProvider),
                  SizedBox(height: 24),

                  // Selector de ciudad
                  _buildCitySelector(cityProvider),
                  SizedBox(height: 16),

                  // Nombre del grupo
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del grupo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre del grupo es requerido';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es requerida';
                      }
                      if (value.trim().length < 10) {
                        return 'La descripción debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  // Botón de crear
                  if (groupProvider.isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blackPearl,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Crear Grupo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (groupProvider.error != null) ...[
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
                              groupProvider.error!,
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

  Widget _buildCitySelector(CityProvider cityProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCityPicker(cityProvider),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city, color: AppColors.blackPearl),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCity != null
                        ? (_selectedCity!.department.isNotEmpty
                            ? '${_selectedCity!.name}, ${_selectedCity!.department}'
                            : _selectedCity!.name)
                        : 'Selecciona una ciudad',
                    style: TextStyle(
                      color: _selectedCity != null
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
        if (_selectedCity == null)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'La ciudad es requerida',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _showCityPicker(CityProvider cityProvider) {
    if (cityProvider.cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cargando ciudades...'),
          backgroundColor: AppColors.vividOrange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Ciudad'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: cityProvider.cities.length,
              itemBuilder: (context, index) {
                final city = cityProvider.cities[index];
                return ListTile(
                  leading: city.name == 'Ibagué'
                      ? Icon(Icons.star, color: AppColors.vividOrange)
                      : Icon(Icons.location_city),
                  title: Text(city.name),
                  subtitle:
                      city.department.isNotEmpty ? Text(city.department) : null,
                  selected: _selectedCity?.id == city.id,
                  onTap: () {
                    setState(() {
                      _selectedCity = city;
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

  Widget _buildCoverImageSection(GroupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de portada (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectCoverImage(provider),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey200, width: 1),
            ),
            child: _coverFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_coverFile!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: AppColors.grey600,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toca para agregar portada',
                        style: TextStyle(color: AppColors.grey600),
                      ),
                    ],
                  ),
          ),
        ),
        if (_coverFile != null) ...[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _coverFile = null;
                  });
                },
                icon: Icon(Icons.delete, color: AppColors.red),
                label: Text('Quitar', style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLogoSection(GroupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo del grupo (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => _selectLogoImage(provider),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey200, width: 1),
                ),
                child: _logoFile != null
                    ? ClipOval(
                        child: Image.file(
                          File(_logoFile!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: AppColors.grey600,
                      ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _logoFile != null ? 'Logo seleccionado' : 'Sin logo',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca el círculo para agregar un logo',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                  if (_logoFile != null) ...[
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _logoFile = null;
                        });
                      },
                      icon: Icon(Icons.delete, color: AppColors.red, size: 16),
                      label: Text('Quitar',
                          style: TextStyle(color: AppColors.red)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectCoverImage(GroupProvider provider) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final file = await provider.pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _coverFile = file;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final file = await provider.pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _coverFile = file;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectLogoImage(GroupProvider provider) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final file = await provider.pickImage(ImageSource.camera);
                if (file != null) {
                  setState(() {
                    _logoFile = file;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final file = await provider.pickImage(ImageSource.gallery);
                if (file != null) {
                  setState(() {
                    _logoFile = file;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una ciudad'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final provider = context.read<GroupProvider>();

    final success = await provider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      cityId: _selectedCity!.id, // AGREGAR EL PARÁMETRO CITYID REQUERIDO
      logoFile: _logoFile,
      coverFile: _coverFile,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo creado exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop(); // Volver a la lista de grupos
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al crear el grupo'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
