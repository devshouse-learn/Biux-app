import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/config/colors.dart';
import 'package:biux/features/cities/data/models/city_model.dart';
import 'package:biux/features/cities/presentation/providers/city_provider.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';

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
      _checkAdminStatus();
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

  void _checkAdminStatus() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    groupProvider.loadAdminGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Crear Grupo',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          // Verificar si el usuario ya es admin de un grupo
          if (groupProvider.isAdminOfAnyGroup) {
            return _buildAlreadyAdminView(groupProvider);
          }

          return _buildCreateGroupForm(groupProvider);
        },
      ),
    );
  }

  Widget _buildAlreadyAdminView(GroupProvider groupProvider) {
    final adminGroup = groupProvider.adminGroups.first;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.darkBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'Ya eres administrador de un grupo',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.blackPearl,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (adminGroup.logoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          adminGroup.logoUrl!,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.group,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      adminGroup.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${adminGroup.memberIds.length} miembros',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Solo puedes ser administrador de un grupo a la vez. Para crear un nuevo grupo, primero debes transferir la administración del grupo actual a otro miembro.',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/groups/${adminGroup.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Ver Mi Grupo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      side: const BorderSide(color: AppColors.darkBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Volver'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateGroupForm(GroupProvider groupProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo del grupo
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(isLogo: true),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppColors.darkBlue,
                      width: 2,
                    ),
                  ),
                  child: _logoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(58),
                          child: Image.file(
                            File(_logoFile!.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: AppColors.darkBlue,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Logo del grupo (opcional)',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre del grupo
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                labelStyle: TextStyle(color: AppColors.grey600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.darkBlue),
                ),
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
            const SizedBox(height: 16),

            // Selector de ciudad
            Consumer<CityProvider>(
              builder: (context, cityProvider, child) {
                if (cityProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<CityModel>(
                  initialValue: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    labelStyle: TextStyle(color: AppColors.grey600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.darkBlue),
                    ),
                  ),
                  items: cityProvider.cities.map((city) {
                    return DropdownMenuItem<CityModel>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (CityModel? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una ciudad';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: AppColors.grey600),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.darkBlue),
                ),
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
            const SizedBox(height: 24),

            // Imagen de portada
            const Text(
              'Imagen de portada (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickImage(isLogo: false),
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.grey600,
                    width: 1,
                  ),
                ),
                child: _coverFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          File(_coverFile!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: AppColors.grey600,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca para agregar imagen de portada',
                            style: TextStyle(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón crear
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: groupProvider.isLoading ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: groupProvider.isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.white,
                      )
                    : const Text(
                        'Crear Grupo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage({required bool isLogo}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar ${isLogo ? 'logo' : 'imagen de portada'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera, isLogo: isLogo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery, isLogo: isLogo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _getImage(ImageSource source, {required bool isLogo}) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final XFile? image = await groupProvider.pickImage(source);

    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = image;
        } else {
          _coverFile = image;
        }
      });
    }
  }

  void _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una ciudad'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Verificar una vez más que no sea admin de otro grupo
    if (groupProvider.isAdminOfAnyGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya eres administrador de otro grupo'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final success = await groupProvider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      cityId: _selectedCity!.id,
      logoFile: _logoFile,
      coverFile: _coverFile,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grupo creado exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(groupProvider.error ?? 'Error al crear el grupo'),
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
