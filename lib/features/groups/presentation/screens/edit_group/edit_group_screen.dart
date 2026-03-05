import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/groups/data/models/group_model.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';

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
    // Mover la carga del grupo despu�s del build para evitar setState durante build
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
    final l = Provider.of<LocaleNotifier>(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.t('edit_group')),
          backgroundColor: ColorTokens.primary30,
          foregroundColor: ColorTokens.neutral100,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.t('edit_group')),
          backgroundColor: ColorTokens.primary30,
          foregroundColor: ColorTokens.neutral100,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: ColorTokens.error50),
              SizedBox(height: 16),
              Text(l.t('group_not_found')),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l.t('back')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('edit_group')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              l.t('save'),
              style: TextStyle(
                color: ColorTokens.neutral100,
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
                      labelText: l.t('group_name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('group_name_required');
                      }
                      if (value.trim().length < 3) {
                        return l.t('name_min_chars');
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
                      labelText: l.t('description'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.t('description_required');
                      }
                      if (value.trim().length < 10) {
                        return l.t('description_min_chars');
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
                          backgroundColor: ColorTokens.primary30,
                          foregroundColor: ColorTokens.neutral100,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l.t('save_changes'),
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
                              provider.error!,
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

  Widget _buildCoverImageSection() {
    final l = Provider.of<LocaleNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('cover_image'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorTokens.neutral90,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorTokens.neutral90),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _coverFile != null
                ? Image.file(File(_coverFile!.path), fit: BoxFit.cover)
                : _group?.coverUrl != null
                ? OptimizedNetworkImage(
                    imageUrl: _group!.coverUrl!,
                    imageType: 'cover',
                    fit: BoxFit.cover,
                    errorWidget: _buildImagePlaceholder(),
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
              label: Text(l.t('camera')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary50,
                foregroundColor: ColorTokens.neutral100,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, true),
              icon: Icon(Icons.photo_library, size: 16),
              label: Text(l.t('gallery')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary50,
                foregroundColor: ColorTokens.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    final l = Provider.of<LocaleNotifier>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.t('group_logo'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ColorTokens.neutral90,
              shape: BoxShape.circle,
              border: Border.all(color: ColorTokens.neutral90),
            ),
            child: ClipOval(
              child: _logoFile != null
                  ? Image.file(File(_logoFile!.path), fit: BoxFit.cover)
                  : _group?.logoUrl != null
                  ? OptimizedNetworkImage(
                      imageUrl: _group!.logoUrl!,
                      width: 100,
                      height: 100,
                      imageType: 'avatar',
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        Icons.group,
                        size: 50,
                        color: ColorTokens.neutral60,
                      ),
                    )
                  : Icon(Icons.group, size: 50, color: ColorTokens.neutral60),
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
              label: Text(l.t('camera')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary50,
                foregroundColor: ColorTokens.neutral100,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery, false),
              icon: Icon(Icons.photo_library, size: 16),
              label: Text(l.t('gallery')),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.secondary50,
                foregroundColor: ColorTokens.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    final l = Provider.of<LocaleNotifier>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: ColorTokens.neutral60),
          SizedBox(height: 8),
          Text(
            l.t('tap_to_add_image'),
            style: TextStyle(color: ColorTokens.neutral60, fontSize: 14),
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

    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
          content: Text(l.t('group_updated_success')),
          backgroundColor: ColorTokens.success50,
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
