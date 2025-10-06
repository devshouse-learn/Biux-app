# Sistema de Experiencias - Biux

## Descripción General

El sistema de experiencias permite a los usuarios crear y compartir contenido multimedia (imágenes y videos) relacionado con sus actividades ciclísticas. Está diseñado con arquitectura Clean Architecture + Riverpod + Freezed para máxima escalabilidad y mantenibilidad.

## Arquitectura Implementada

### Capas del Sistema

```
lib/features/experiences/
├── domain/                    # Lógica de negocio
│   ├── entities/             # Entidades inmutables con Freezed
│   │   └── experience_entity.dart
│   └── repositories/         # Interfaces de repositorios
│       └── experience_repository.dart
├── data/                     # Capa de datos
│   ├── models/              # Modelos con serialización JSON
│   │   └── experience_model.dart
│   └── repositories/        # Implementaciones de repositorios
│       └── experience_repository_impl.dart
└── presentation/            # Capa de presentación
    ├── providers/          # Estado con Riverpod + Freezed
    │   ├── experience_provider.dart
    │   └── experience_creator_provider.dart
    ├── screens/           # Pantallas principales
    │   └── create_experience_screen.dart
    └── widgets/          # Widgets reutilizables
        ├── media_item_widget.dart
        ├── media_selector_widget.dart
        ├── compression_progress_widget.dart
        ├── compression_settings_widget.dart
        ├── video_preview_dialog.dart
        └── experience_stats_widget.dart
```

## Características Principales

### 🎯 Gestión de Estado con Riverpod

- **StateNotifier**: Para lógica compleja de creación de experiencias
- **Provider**: Para repositorios y servicios
- **Freezed**: Para inmutabilidad y copyWith automático

### 🖼️ Compresión Inteligente

- **Calidades configurables**: Baja (30%), Media (60%), Alta (80%), Original (100%)
- **Compresión automática**: Integración con `OptimizedStorageService`
- **Progreso en tiempo real**: Indicadores visuales durante el procesamiento

### 🎥 Soporte de Video

- **Duración máxima**: 30 segundos configurables
- **Generación de thumbnails**: Vista previa automática
- **Validación de archivos**: Tamaño y formato
- **Vista previa**: Modal con controles de reproducción

### 📱 UI/UX Optimizada

- **Drag & Drop**: Reordenamiento intuitivo de multimedia
- **Estadísticas en vivo**: Tamaño total, tiempo de subida estimado
- **Validaciones visuales**: Retroalimentación inmediata
- **Responsive design**: Adaptable a diferentes tamaños de pantalla

## Guía de Implementación

### 1. Uso Básico

```dart
// En una pantalla
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorState = ref.watch(experienceCreatorProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Selector de multimedia
          MediaSelectorWidget(
            allowVideo: true,
            onImageFromGallery: () => ref
                .read(experienceCreatorProvider.notifier)
                .addImageFromGallery(),
            onTakePhoto: () => ref
                .read(experienceCreatorProvider.notifier)
                .takePhoto(),
            onVideoFromGallery: () => ref
                .read(experienceCreatorProvider.notifier)
                .addVideoFromGallery(),
            onRecordVideo: () => ref
                .read(experienceCreatorProvider.notifier)
                .recordVideo(),
          ),
          
          // Lista de multimedia
          ...creatorState.mediaItems.map((item) => 
            MediaItemWidget(
              mediaItem: item,
              onRemove: () => ref
                  .read(experienceCreatorProvider.notifier)
                  .removeMediaItem(item.id),
            ),
          ),
          
          // Estadísticas
          ExperienceStatsWidget(
            mediaCount: creatorState.mediaItems.length,
            totalSizeMB: creatorState.totalSizeMB,
            isCompressing: creatorState.isProcessing,
          ),
        ],
      ),
    );
  }
}
```

### 2. Configuración de Compresión

```dart
CompressionSettingsWidget(
  selectedQuality: CompressionQuality.medium,
  onQualityChanged: (quality) {
    // Actualizar configuración
  },
  showVideoSettings: true,
  maxVideoSeconds: 30,
  onMaxVideoSecondsChanged: (seconds) {
    // Actualizar duración máxima
  },
)
```

### 3. Vista Previa de Videos

```dart
// Mostrar modal de vista previa
final accepted = await showVideoPreviewDialog(
  context: context,
  videoFile: File(videoPath),
  title: 'Vista previa del video',
);

if (accepted == true) {
  // Usuario aceptó el video
  await ref
      .read(experienceCreatorProvider.notifier)
      .addVideoFile(videoPath);
}
```

## Integración con Firebase

### Colecciones Firestore

```
experiences/
├── {experienceId}/
│   ├── id: string
│   ├── userId: string
│   ├── type: 'general' | 'ride'
│   ├── title: string
│   ├── description: string
│   ├── mediaItems: ExperienceMediaEntity[]
│   ├── location?: Location
│   ├── rideId?: string
│   ├── createdAt: Timestamp
│   ├── updatedAt: Timestamp
│   ├── reactions: ExperienceReactionEntity[]
│   ├── isPublic: boolean
│   └── tags: string[]
```

### Firebase Storage

```
experiences/
├── {userId}/
│   ├── images/
│   │   ├── exp_img_{timestamp}.jpg
│   │   └── thumbnails/
│   │       └── thumb_{imageId}.jpg
│   └── videos/
│       ├── {timestamp}_{filename}
│       └── thumbnails/
│           └── thumb_{videoId}.jpg
```

## Estados del Sistema

### ExperienceCreatorState

```dart
@freezed
class ExperienceCreatorState with _$ExperienceCreatorState {
  const factory ExperienceCreatorState({
    @Default([]) List<MediaItem> mediaItems,
    @Default('') String title,
    @Default('') String description,
    @Default(false) bool isLoading,
    @Default(false) bool isProcessing,
    String? error,
    ExperienceType? type,
    String? rideId,
  }) = _ExperienceCreatorState;
}
```

### MediaItem

```dart
@freezed
class MediaItem with _$MediaItem {
  const factory MediaItem({
    required String id,
    required MediaType type,
    required String filePath,
    String? url,
    String? thumbnailPath,
    @Default(false) bool isProcessing,
    @Default(0.0) double processingProgress,
    @Default(1.0) double aspectRatio,
    @Default(0.0) double sizeMB,
    int? durationSeconds,
  }) = _MediaItem;
}
```

## Configuración de Calidad

### Opciones Predefinidas

- **Baja (30%)**: Menor tamaño, menor calidad - Ideal para conexiones lentas
- **Media (60%)**: Balance entre tamaño y calidad - Recomendado por defecto
- **Alta (80%)**: Mayor calidad, mayor tamaño - Para contenido de alta calidad
- **Original (100%)**: Sin compresión - Solo para casos especiales

### Configuración de Video

- **Duración máxima**: 10-60 segundos (por defecto 30s)
- **Resolución**: Se mantiene la original con compresión inteligente
- **Formatos soportados**: MP4, MOV, AVI

## Próximas Funcionalidades

### En Desarrollo 🔧

- [ ] Integración completa de video con `VideoExperienceService`
- [ ] Filtros y efectos para imágenes
- [ ] Geolocalización automática
- [ ] Sincronización offline

### Planificadas 📋

- [ ] Edición de video básica (cortar, rotar)
- [ ] Reconocimiento de objetos en imágenes
- [ ] Integración con redes sociales
- [ ] Analytics de engagement

## Optimizaciones de Rendimiento

### Compresión Inteligente

- **Detección automática**: El sistema determina la mejor configuración según el tipo de contenido
- **Procesamiento en background**: No bloquea la UI durante la compresión
- **Cache local**: Los archivos procesados se almacenan temporalmente

### Gestión de Memoria

- **Lazy loading**: Las imágenes se cargan solo cuando son visibles
- **Limpieza automática**: Los archivos temporales se eliminan automáticamente
- **Reducción de memoria**: Thumbnails optimizados para listas

### Network Optimization

- **Upload en paralelo**: Múltiples archivos se suben simultáneamente
- **Retry automático**: Reintentos inteligentes en caso de fallos de red
- **Compresión antes de upload**: Reduce el tiempo y costo de transferencia

## Troubleshooting

### Errores Comunes

1. **"Error procesando video"**
   - Verificar que el archivo no esté corrupto
   - Comprobar que el formato sea compatible
   - Revisar permisos de almacenamiento

2. **"Funcionalidad de video en desarrollo"**
   - Estado temporal mientras se completa la integración
   - Las imágenes funcionan completamente

3. **Problemas de compresión**
   - Verificar espacio disponible en dispositivo
   - Comprobar que la imagen original sea válida

### Debug

```dart
// Habilitar logs detallados
const bool kDebugMode = true;

if (kDebugMode) {
  print('🎯 Estado actual: ${ref.read(experienceCreatorProvider)}');
}
```

## Contribución

Para contribuir al sistema de experiencias:

1. Seguir la arquitectura Clean Architecture establecida
2. Usar Freezed para todas las clases de datos
3. Implementar tests para nuevas funcionalidades
4. Documentar cambios en la API

---

*Última actualización: Enero 2025*
*Versión: 1.0.0*