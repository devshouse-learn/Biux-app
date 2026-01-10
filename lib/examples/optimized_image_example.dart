import 'package:flutter/material.dart';
import '../../shared/widgets/optimized_image_picker.dart';
import '../../core/design_system/color_tokens.dart';

/// Ejemplo de integración del sistema optimizado de imágenes
/// Este ejemplo muestra cómo reducir costos de Firebase significativamente
class OptimizedImageExampleScreen extends StatefulWidget {
  const OptimizedImageExampleScreen({super.key});

  @override
  State<OptimizedImageExampleScreen> createState() =>
      _OptimizedImageExampleScreenState();
}

class _OptimizedImageExampleScreenState
    extends State<OptimizedImageExampleScreen> {
  String? _userAvatarUrl;
  String? _groupCoverUrl;
  String? _rideImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema Optimizado de Imágenes'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información sobre ahorro de costos
            _buildCostSavingsInfo(),

            SizedBox(height: 24),

            // Avatar de usuario (400x400, optimizado para perfil)
            _buildSection(
              'Avatar de Usuario',
              'Compresión: 400x400px, calidad 80%\nReducción estimada: 70-80% del tamaño original',
              OptimizedImagePicker(
                currentImageUrl: _userAvatarUrl,
                onImageSelected: (url) => setState(() => _userAvatarUrl = url),
                imageType: 'avatar',
                entityId: 'user123', // En app real, usar ID del usuario actual
                width: 120,
                height: 120,
                borderRadius: BorderRadius.circular(60),
              ),
            ),

            SizedBox(height: 24),

            // Portada de grupo (1080x1080, optimizado para visualización)
            _buildSection(
              'Portada de Grupo',
              'Compresión: 1080x1080px, calidad 85%\nCrea automáticamente thumbnail 200x200px',
              OptimizedImagePicker(
                currentImageUrl: _groupCoverUrl,
                onImageSelected: (url) => setState(() => _groupCoverUrl = url),
                imageType: 'group',
                entityId: 'group456', // En app real, usar ID del grupo
                width: 300,
                height: 200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            SizedBox(height: 24),

            // Imagen de rodada (1080x1080, optimizada para compartir)
            _buildSection(
              'Imagen de Rodada',
              'Compresión: 1080x1080px, calidad 85%\nOptimizada para compartir en redes sociales',
              OptimizedImagePicker(
                currentImageUrl: _rideImageUrl,
                onImageSelected: (url) => setState(() => _rideImageUrl = url),
                imageType: 'ride',
                entityId: 'ride789', // En app real, usar ID de la rodada
                width: 300,
                height: 200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            SizedBox(height: 24),

            // Estadísticas de uso
            _buildUsageStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSavingsInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.success95,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.success40, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings, color: ColorTokens.success40, size: 24),
              SizedBox(width: 8),
              Text(
                'Ahorro de Costos Firebase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.success30,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSavingItem(
            '📉',
            'Almacenamiento',
            'Hasta 80% menos espacio con compresión inteligente',
          ),
          _buildSavingItem(
            '🚀',
            'Transferencia',
            '90% menos datos con thumbnails automáticos',
          ),
          _buildSavingItem(
            '💾',
            'Caché',
            'Reduce cargas repetidas con caché optimizado',
          ),
          _buildSavingItem(
            '⚡',
            'CDN',
            'Usa automáticamente CDN global de Firebase',
          ),
        ],
      ),
    );
  }

  Widget _buildSavingItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: ColorTokens.neutral20, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget child) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.neutral20.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTokens.primary95,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.primary30, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: ColorTokens.primary30, size: 24),
              SizedBox(width: 8),
              Text(
                'Optimizaciones Implementadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.primary30,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildStatItem('Compresión automática antes de subir'),
          _buildStatItem('Múltiples tamaños (original + thumbnail)'),
          _buildStatItem('Caché inteligente con expiración'),
          _buildStatItem('Metadatos optimizados para CDN'),
          _buildStatItem('Limpieza automática de archivos temporales'),
          _buildStatItem('URLs optimizadas para máximo rendimiento'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: ColorTokens.primary30, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: ColorTokens.neutral20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Integración en formularios existentes - Ejemplo para crear grupo
class CreateGroupWithOptimizedImageExample extends StatefulWidget {
  const CreateGroupWithOptimizedImageExample({super.key});

  @override
  State<CreateGroupWithOptimizedImageExample> createState() =>
      _CreateGroupWithOptimizedImageExampleState();
}

class _CreateGroupWithOptimizedImageExampleState
    extends State<CreateGroupWithOptimizedImageExample> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _groupImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Grupo - Con Optimización'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: ColorTokens.neutral100,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen del grupo con optimización automática
            OptimizedImagePicker(
              currentImageUrl: _groupImageUrl,
              onImageSelected: (url) => setState(() => _groupImageUrl = url),
              imageType: 'group',
              entityId:
                  'new_group', // Se actualizará con ID real después de crear
              width: 200,
              height: 200,
              borderRadius: BorderRadius.circular(12),
              placeholder: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: ColorTokens.neutral10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorTokens.neutral20, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 48, color: ColorTokens.neutral40),
                    SizedBox(height: 8),
                    Text(
                      'Foto del Grupo',
                      style: TextStyle(color: ColorTokens.neutral40),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Campos del formulario
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _createGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: ColorTokens.neutral100,
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Crear Grupo'),
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Por favor ingresa un nombre')));
      return;
    }

    // Aquí iría la lógica para crear el grupo
    // La imagen ya está optimizada y subida si _groupImageUrl no es null

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo creado con imagen optimizada'),
        backgroundColor: ColorTokens.success40,
      ),
    );
  }
}
