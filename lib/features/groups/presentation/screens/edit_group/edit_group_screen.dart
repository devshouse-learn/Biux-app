import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/config/colors.dart';
import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';

class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _logoFile;
  XFile? _coverFile;
  GroupModel? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Mover la carga del grupo después del build para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroup();
    });
  }

  void _loadGroup() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.selectGroup(widget.groupId);

    if (mounted) {
      setState(() {
        _group = groupProvider.selectedGroup;
        if (_group != null) {
          _nameController.text = _group!.name;
          _descriptionController.text = _group!.description;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Editar Grupo'),
          backgroundColor: AppColors.blackPearl,
          foregroundColor: AppColors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Editar Grupo'),
          backgroundColor: AppColors.blackPearl,
          foregroundColor: AppColors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: AppColors.red),
              SizedBox(height: 16),
              Text('Grupo no encontrado'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Grupo'),
        backgroundColor: AppColors.blackPearl,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                  _buildCoverImageSection(),
                  SizedBox(height: 24),

                  // Logo del grupo
                  _buildLogoSection(),
                  SizedBox(height: 24),

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

                  // Botón de guardar
                  if (provider.isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blackPearl,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (provider.error != null) ...[
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
                              provider.error!,
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

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de portada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _coverFile != null
                ? Image.file(
                    File(_coverFile!.path),
                    fit: BoxFit.cover,
                  )
                : _group?.coverUrl != null
                    ? Image.network(
                        _group!.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, true),
              icon: Icon(Icons.camera_alt, size: 16),
              label: Text('Cámara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, true),
              icon: Icon(Icons.photo_library, size: 16),
              label: Text('Galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo del grupo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey200),
            ),
            child: ClipOval(
              child: _logoFile != null
                  ? Image.file(
                      File(_logoFile!.path),
                      fit: BoxFit.cover,
                    )
                  : _group?.logoUrl != null
                      ? Image.network(
                          _group!.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.group,
                              size: 50,
                              color: AppColors.grey600,
                            );
                          },
                        )
                      : Icon(
                          Icons.group,
                          size: 50,
                          color: AppColors.grey600,
                        ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera, false),
              icon: Icon(Icons.camera_alt, size: 16),
              label: Text('Cámara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, false),
              icon: Icon(Icons.photo_library, size: 16),
              label: Text('Galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strongCyan,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 50,
            color: AppColors.grey600,
          ),
          SizedBox(height: 8),
          Text(
            'Toca para agregar imagen',
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(ImageSource source, bool isCover) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final image = await groupProvider.pickImage(source);

    if (image != null) {
      setState(() {
        if (isCover) {
          _coverFile = image;
        } else {
          _logoFile = image;
        }
      });
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final success = await groupProvider.editGroup(
      groupId: widget.groupId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      logoFile: _logoFile,
      coverFile: _coverFile,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Grupo actualizado exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop(); // Volver a la pantalla anterior
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
