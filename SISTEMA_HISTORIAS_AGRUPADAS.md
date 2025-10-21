# Sistema de Historias Agrupadas por Usuario (Estilo Instagram)

## 📋 Resumen

Se ha implementado un sistema completo para agrupar las experiencias (historias) por usuario, similar a Instagram Stories. El sistema incluye almacenamiento local de vistas para evitar consumo innecesario de recursos de red.

## 🎯 Características Principales

### 1. Agrupación por Usuario
- Las historias del mismo usuario se agrupan en un solo círculo
- Si un usuario publicó 10 historias en diferentes horas del día, aparecen juntas
- Los grupos se ordenan: **no vistas primero**, luego por fecha más reciente

### 2. Estado de Visualización Local
- ✅ **Sin consumo de red**: Las vistas se almacenan en `SharedPreferences`
- ✅ **Persistencia**: Las vistas se mantienen entre sesiones
- ✅ **Expiración automática**: Las vistas expiran después de 24 horas
- ✅ **Limpieza automática**: Cada 6 horas se eliminan vistas expiradas

### 3. Indicadores Visuales
- **Borde de gradiente**: Historias no vistas (rojo-naranja-amarillo)
- **Borde gris**: Historias ya vistas completamente
- **Contador**: Número de historias no vistas por grupo

## 🏗️ Arquitectura

### Entidades (Domain Layer)

#### `UserStoryGroupEntity`
```dart
lib/features/experiences/domain/entities/user_story_group_entity.dart
```
- Agrupa experiencias de un usuario específico
- Propiedades:
  - `user`: Datos del usuario
  - `stories`: Lista de experiencias del usuario
  - `latestStoryTime`: Fecha de la historia más reciente
  - `hasUnseenStories`: Indica si hay historias sin ver
  - `unseenCount`: Cantidad de historias no vistas

### Data Sources

#### `StoryViewsLocalService`
```dart
lib/features/experiences/data/datasources/story_views_local_service.dart
```
- Gestiona el almacenamiento local de vistas
- Métodos principales:
  - `markStoryAsViewed(storyId)`: Marca una historia como vista
  - `isStoryViewed(storyId)`: Verifica si fue vista
  - `areStoriesViewed(storyIds)`: Verifica múltiples historias
  - `cleanupExpiredViews()`: Limpia vistas antiguas (>24h)
  - `clearAllViews()`: Limpia todas las vistas (logout)

### Use Cases

#### `GroupStoriesByUserUseCase`
```dart
lib/features/experiences/domain/usecases/group_stories_by_user_usecase.dart
```
- Agrupa experiencias por usuario
- Calcula estado de visualización
- Ordena grupos (no vistas primero)
- Métodos:
  - `call(experiences)`: Agrupación básica
  - `callForStoriesOnly(experiences)`: Solo formato story
  - `callForRecentStories(experiences)`: Últimas 24 horas

### Presentation Layer

#### `StoryGroupsProvider`
```dart
lib/features/experiences/presentation/providers/story_groups_provider.dart
```
- Gestiona el estado de grupos de historias
- Métodos principales:
  - `loadStoryGroups(userId)`: Carga grupos desde red
  - `markStoryAsViewed(storyId)`: Marca vista localmente
  - `markUserStoriesAsViewed(userId)`: Marca todo el grupo
  - `addNewExperience(experience)`: Agrega historia nueva
  - `removeExperience(experienceId)`: Elimina historia

#### `StoryGroupsList` Widget
```dart
lib/features/experiences/presentation/widgets/story_groups_list.dart
```
- Lista horizontal de grupos de historias
- Componentes:
  - `_AddStoryItem`: Botón "Tu historia"
  - `_StoryGroupItem`: Grupo individual de usuario
  - `_LoadingStoryGroups`: Estado de carga
  - `StoryViewerScreen`: Placeholder para visor (por implementar)

## 🔧 Uso

### 1. Configurar Provider en main.dart

```dart
import 'package:biux/features/experiences/presentation/providers/story_groups_provider.dart';
import 'package:biux/features/experiences/domain/usecases/group_stories_by_user_usecase.dart';
import 'package:biux/features/experiences/data/datasources/story_views_local_service.dart';
import 'package:biux/features/experiences/data/repositories/experience_repository_impl.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ... otros providers
        ChangeNotifierProvider(
          create: (_) => StoryGroupsProvider(
            ExperienceRepositoryImpl(),
            GroupStoriesByUserUseCase(StoryViewsLocalService()),
            StoryViewsLocalService(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Usar en pantalla principal

```dart
import 'package:biux/features/experiences/presentation/widgets/story_groups_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storyProvider = Provider.of<StoryGroupsProvider>(context);
    
    // Cargar historias al iniciar
    useEffect(() {
      storyProvider.loadStoryGroups(authProvider.currentUser!.id);
      return null;
    }, []);
    
    return Scaffold(
      body: Column(
        children: [
          // Lista de historias en la parte superior
          StoryGroupsList(
            currentUserId: authProvider.currentUser!.id,
            onAddStory: () {
              // Navegar a crear historia
              context.push('/experiences/create');
            },
          ),
          
          // Resto del contenido (feed, etc.)
          Expanded(
            child: YourFeedWidget(),
          ),
        ],
      ),
    );
  }
}
```

### 3. Marcar historia como vista

```dart
// Al visualizar una historia individual
await storyProvider.markStoryAsViewed(story.id);

// Al completar todas las historias de un usuario
await storyProvider.markUserStoriesAsViewed(user.id);
```

## 📊 Flujo de Datos

```
1. Usuario abre app
   ↓
2. StoryGroupsProvider.loadStoryGroups(userId)
   ↓
3. ExperienceRepository.getFollowingExperiences()
   ↓
4. GroupStoriesByUserUseCase.callForRecentStories()
   ├─ Agrupa por usuario
   ├─ StoryViewsLocalService.areStoriesViewed()
   ├─ Calcula unseenCount
   └─ Ordena (no vistas primero)
   ↓
5. StoryGroupsList muestra círculos
   ↓
6. Usuario toca grupo
   ↓
7. StoryViewer muestra historias
   ↓
8. Al ver cada historia:
   └─ StoryGroupsProvider.markStoryAsViewed(id)
       └─ StoryViewsLocalService.markStoryAsViewed(id)
           └─ SharedPreferences guarda vista
```

## ✅ Ventajas del Almacenamiento Local

1. **Sin consumo de red**: Las vistas se guardan solo en el dispositivo
2. **Instantáneo**: No hay delay al marcar como vista
3. **Offline-first**: Funciona sin conexión
4. **Económico**: Ahorra ancho de banda y llamadas a Firebase
5. **Privacidad**: Las vistas son privadas del usuario

## 🔄 Sincronización con Red (Opcional)

Si en el futuro se desea sincronizar las vistas con el servidor:

```dart
// Agregar método en StoryViewsLocalService
Future<void> syncViewsToServer(String userId) async {
  final viewedStories = await getViewedStories();
  
  // Enviar a Firebase solo las vistas no sincronizadas
  for (final entry in viewedStories.entries) {
    await _repository.markStoryAsViewedOnServer(
      userId,
      entry.key,
      entry.value,
    );
  }
}
```

## 🎨 Personalización de UI

### Cambiar colores del borde de historias no vistas

```dart
// En _StoryGroupItem
gradient: LinearGradient(
  colors: [
    Color(0xFFFF6B6B), // Rojo
    Color(0xFFFFB84D), // Naranja
    Color(0xFFFFD93D), // Amarillo
  ],
  // Cambia estos colores según tu diseño
)
```

### Ajustar tiempo de expiración

```dart
// En StoryViewsLocalService
static const Duration _viewExpirationDuration = Duration(hours: 24);
// Cambia a Duration(hours: 48) para 48 horas, etc.
```

## 📝 Pendientes

- [ ] Implementar `StoryViewerScreen` completo con:
  - Gestos de navegación (tap izq/der)
  - Indicador de progreso por historia
  - Autoplay con timer
  - Marca automática de vistas
  - Transiciones entre grupos
  
- [ ] Agregar animaciones al borde de gradiente

- [ ] Implementar "Ver quién vio mi historia" (requiere sync con servidor)

- [ ] Agregar reacciones rápidas en el visor

## 🐛 Debugging

### Limpiar todas las vistas (útil para testing)

```dart
final storyProvider = Provider.of<StoryGroupsProvider>(context);
await storyProvider.clearAllViews();
```

### Ver vistas almacenadas

```dart
final viewsService = StoryViewsLocalService();
final viewedStories = await viewsService.getViewedStories();
print('Historias vistas: $viewedStories');
```

## 📚 Referencias

- [Instagram Stories UX Pattern](https://www.instagram.com)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- Clean Architecture en Flutter
