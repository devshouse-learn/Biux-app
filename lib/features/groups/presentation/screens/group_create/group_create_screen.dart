import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/cities/data/models/city_model.dart';
import 'package:biux/features/cities/presentation/providers/city_provider.dart';
import 'package:biux/features/groups/presentation/providers/group_provider.dart';
import 'package:biux/shared/widgets/optimized_image_picker.dart';

class GroupCreateScreen extends StatefulWidget {
  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _logoUrl;
  String? _coverUrl;
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
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('create_group'),
          style: TextStyle(color: ColorTokens.neutral100),
        ),
        backgroundColor: ColorTokens.primary30,
        iconTheme: const IconThemeData(color: ColorTokens.neutral100),
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
    final l = Provider.of<LocaleNotifier>(context);
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
              color: ColorTokens.primary30,
            ),
            const SizedBox(height: 24),
            Text(
              l.t('already_admin_of_group'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorTokens.neutral0,
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
                        child: OptimizedNetworkImage(
                          imageUrl: adminGroup.logoUrl!,
                          height: 60,
                          width: 60,
                          imageType: 'avatar',
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: ColorTokens.primary30,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: ColorTokens.neutral100,
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
                      '${adminGroup.memberIds.length} ${l.t('members')}',
                      style: TextStyle(
                        color: ColorTokens.neutral60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.t('only_one_admin_explanation'),
              style: TextStyle(color: ColorTokens.neutral60, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/groups/${adminGroup.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTokens.primary30,
                      foregroundColor: ColorTokens.neutral100,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l.t('view_my_group')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorTokens.primary30,
                      side: const BorderSide(color: ColorTokens.primary30),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l.t('back')),
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
    final l = Provider.of<LocaleNotifier>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo del grupo con optimización automática
            Center(
              child: OptimizedImagePicker(
                currentImageUrl: _logoUrl,
                onImageSelected: (url) => setState(() => _logoUrl = url),
                imageType: 'avatar',
                entityId: 'temp_group_${DateTime.now().millisecondsSinceEpoch}',
                width: 120,
                height: 120,
                borderRadius: BorderRadius.circular(60),
                placeholder: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ColorTokens.neutral90,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: ColorTokens.primary30, width: 2),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate,
                    size: 50,
                    color: ColorTokens.primary30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l.t('group_logo_optional'),
                style: TextStyle(color: ColorTokens.neutral60, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Nombre del grupo
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l.t('group_name'),
                labelStyle: TextStyle(color: ColorTokens.neutral60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorTokens.primary30),
                ),
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
                    labelText: l.t('city'),
                    labelStyle: TextStyle(color: ColorTokens.neutral60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: ColorTokens.primary30,
                      ),
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
                      return l.t('select_city');
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
                labelText: l.t('description'),
                labelStyle: TextStyle(color: ColorTokens.neutral60),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ColorTokens.primary30),
                ),
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
            const SizedBox(height: 24),

            // Imagen de portada
            Text(
              l.t('cover_image_optional'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Imagen de portada con optimización automática
            OptimizedImagePicker(
              currentImageUrl: _coverUrl,
              onImageSelected: (url) => setState(() => _coverUrl = url),
              imageType: 'group',
              entityId: 'temp_group_${DateTime.now().millisecondsSinceEpoch}',
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.circular(8),
              placeholder: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral90,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorTokens.neutral60, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: ColorTokens.neutral60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.t('tap_to_add_cover'),
                      style: const TextStyle(color: ColorTokens.neutral60),
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
                  backgroundColor: ColorTokens.primary30,
                  foregroundColor: ColorTokens.neutral100,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: groupProvider.isLoading
                    ? const CircularProgressIndicator(
                        color: ColorTokens.neutral100,
                      )
                    : Text(
                        l.t('create_group'),
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

  void _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l = Provider.of<LocaleNotifier>(context, listen: false);

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('select_city')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    // Verificar una vez más que no sea admin de otro grupo
    if (groupProvider.isAdminOfAnyGroup) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('already_admin')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    // IMPLEMENTADO (STUB): En el futuro, el GroupProvider debería aceptar URLs directamente
    // Por ahora, las imágenes ya están optimizadas y subidas a Firebase
    final success = await groupProvider.createGroup(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      cityId: _selectedCity!.id,
      logoFile: null, // Las URLs ya están optimizadas
      coverFile: null, // Las URLs ya están optimizadas
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('group_created_success')),
          backgroundColor: ColorTokens.success50,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(groupProvider.error ?? l.t('error_creating_group')),
          backgroundColor: ColorTokens.error50,
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
