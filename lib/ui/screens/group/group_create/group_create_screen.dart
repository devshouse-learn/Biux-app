import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../config/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Grupo'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de portada
                  _buildCoverImageSection(provider),

                  SizedBox(height: 24),

                  // Logo del grupo
                  _buildLogoSection(provider),

                  SizedBox(height: 24),

                  // Nombre del grupo
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del grupo *',
                      hintText: 'Ej: Ciclistas de Ibagué',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      if (value.trim().length > 50) {
                        return 'El nombre no puede exceder 50 caracteres';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16),

                  // Descripción del grupo
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción *',
                      hintText:
                          'Describe el propósito y actividades del grupo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      if (value.trim().length < 10) {
                        return 'La descripción debe tener al menos 10 caracteres';
                      }
                      if (value.trim().length > 500) {
                        return 'La descripción no puede exceder 500 caracteres';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: 32),

                  // Información adicional
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Información importante',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Como creador, serás el administrador del grupo\n'
                          '• Podrás aprobar o rechazar solicitudes de ingreso\n'
                          '• Las imágenes son opcionales pero recomendadas\n'
                          '• El grupo será público y visible para todos',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Botón crear
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _createGroup,
                      icon: provider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : Icon(Icons.add),
                      label: Text(
                        provider.isLoading ? 'Creando grupo...' : 'Crear Grupo',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blackPearl,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

    final provider = context.read<GroupProvider>();

    final success = await provider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
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
