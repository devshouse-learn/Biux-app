# Feature Social - Sistema de Interacciones Sociales

Sistema completo de interacciones sociales para la app Biux usando Firebase Realtime Database.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Arquitectura](#arquitectura)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Uso](#uso)
- [Ejemplos de Integración](#ejemplos-de-integración)

## ✨ Características

### 1. **Notificaciones** 
- 9 tipos de notificaciones en tiempo real
- Contador de notificaciones no leídas
- Marcado individual y masivo como leídas
- Navegación directa al contenido relacionado

### 2. **Likes**
- Likes en posts, comentarios e historias
- Contador de likes en tiempo real
- Animación visual al dar/quitar like
- Expiración automática para historias (24h)

### 3. **Comentarios**
- Comentarios en posts y rodadas
- Respuestas anidadas (replies)
- Detección automática de menciones (@usuario)
- Edición y eliminación (solo autor)
- Límite de 500 caracteres
- Contador de likes por comentario

### 4. **Asistentes**
- Registro de asistencia a rodadas
- 3 estados: confirmado, tal vez, cancelado
- Información de nivel y tipo de bici
- Navegación a perfiles de asistentes

## 🏗️ Arquitectura

```
lib/features/social/
├── domain/
│   ├── entities/              # Entidades de negocio
│   │   ├── notification_entity.dart
│   │   ├── like_entity.dart
│   │   ├── comment_entity.dart
│   │   └── attendee_entity.dart
│   └── repositories/          # Interfaces de repositorios
│       ├── notifications_repository.dart
│       ├── likes_repository.dart
│       ├── comments_repository.dart
│       └── attendees_repository.dart
├── data/
│   ├── models/               # Modelos de datos (JSON)
│   │   ├── notification_model.dart
│   │   ├── like_model.dart
│   │   ├── comment_model.dart
│   │   └── attendee_model.dart
│   ├── datasources/          # Conexión con Firebase Realtime DB
│   │   ├── notifications_realtime_datasource.dart
│   │   ├── likes_realtime_datasource.dart
│   │   ├── comments_realtime_datasource.dart
│   │   └── attendees_realtime_datasource.dart
│   └── repositories/         # Implementaciones de repositorios
│       ├── notifications_repository_impl.dart
│       ├── likes_repository_impl.dart
│       ├── comments_repository_impl.dart
│       └── attendees_repository_impl.dart
└── presentation/
    ├── providers/            # State management (Provider pattern)
    │   ├── notifications_provider.dart
    │   ├── likes_provider.dart
    │   ├── comments_provider.dart
    │   └── attendees_provider.dart
    ├── screens/              # Pantallas completas
    │   ├── notifications_screen.dart
    │   ├── comments_screen.dart
    │   └── attendees_screen.dart
    └── widgets/              # Componentes reutilizables
        ├── like_button.dart
        ├── comments_list.dart
        ├── comment_item.dart
        ├── attendees_list.dart
        └── notifications_list.dart
```

## 📦 Instalación

### 1. Dependencias

Ya están agregadas en `pubspec.yaml`:

```yaml
dependencies:
  firebase_database: ^12.0.2  # Firebase Realtime Database
  timeago: ^3.7.0             # Formateo de fechas relativas
  provider: ^6.1.5+1          # State management
```

### 2. Firebase Realtime Database

1. **Habilitar en Firebase Console:**
   - Ve a tu proyecto en [Firebase Console](https://console.firebase.google.com)
   - Menú lateral → Build → Realtime Database
   - Clic en "Create Database"
   - Selecciona ubicación (recomendado: us-central1)
   - Modo de inicio: "Locked mode" (configuraremos reglas después)

2. **Desplegar reglas de seguridad:**

```bash
firebase deploy --only database
```

Este comando usa el archivo `database.rules.json` que ya está creado.

## ⚙️ Configuración

### 1. Agregar Providers al Main

En `lib/main.dart`, agrega los providers del feature social:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'features/social/social_providers_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ... tus providers existentes ...
        
        // Providers del feature social (solo si hay usuario autenticado)
        ...SocialProvidersConfig.getProviders(),
      ],
      child: MaterialApp(
        // ... tu configuración ...
      ),
    );
  }
}
```

### 2. Configurar Rutas (Go Router)

En `lib/core/config/router/app_router.dart`:

```dart
import 'package:biux/features/social/presentation/screens/notifications_screen.dart';
import 'package:biux/features/social/presentation/screens/comments_screen.dart';
import 'package:biux/features/social/presentation/screens/attendees_screen.dart';

// ... en tus rutas:

GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationsScreen(),
),
GoRoute(
  path: '/posts/:postId/comments',
  builder: (context, state) {
    final postId = state.pathParameters['postId']!;
    final postOwnerId = state.uri.queryParameters['ownerId']!;
    return PostCommentsScreen(
      postId: postId,
      postOwnerId: postOwnerId,
    );
  },
),
GoRoute(
  path: '/rides/:rideId/comments',
  builder: (context, state) {
    final rideId = state.pathParameters['rideId']!;
    final rideOwnerId = state.uri.queryParameters['ownerId']!;
    return RideCommentsScreen(
      rideId: rideId,
      rideOwnerId: rideOwnerId,
    );
  },
),
GoRoute(
  path: '/rides/:rideId/attendees',
  builder: (context, state) {
    final rideId = state.pathParameters['rideId']!;
    final rideOwnerId = state.uri.queryParameters['ownerId']!;
    return RideAttendeesScreen(
      rideId: rideId,
      rideOwnerId: rideOwnerId,
    );
  },
),
```

## 🚀 Uso

### 1. Botón de Like

```dart
import 'package:biux/features/social/presentation/widgets/like_button.dart';
import 'package:biux/features/social/domain/repositories/likes_repository.dart';

// En un post:
LikeButton(
  type: LikeableType.post,
  targetId: post.id,
  targetOwnerId: post.userId,
  targetPreview: post.content,
  showCount: true,
  activeColor: Colors.red,
)

// En un comentario:
LikeButton(
  type: LikeableType.comment,
  targetId: comment.id,
  targetOwnerId: comment.userId,
  showCount: true,
  size: 18.0,
)

// En una historia:
LikeButton(
  type: LikeableType.story,
  targetId: story.id,
  targetOwnerId: story.userId,
  showCount: false,
  activeColor: Colors.pink,
)
```

### 2. Lista de Comentarios

```dart
import 'package:biux/features/social/presentation/widgets/comments_list.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';

// En un post:
CommentsList(
  type: CommentableType.post,
  targetId: postId,
  targetOwnerId: postOwnerId,
  showTextField: true,
  placeholder: 'Escribe un comentario...',
)

// En una rodada:
CommentsList(
  type: CommentableType.ride,
  targetId: rideId,
  targetOwnerId: rideOwnerId,
  showTextField: true,
  placeholder: 'Comenta sobre esta rodada...',
)
```

### 3. Lista de Asistentes

```dart
import 'package:biux/features/social/presentation/widgets/attendees_list.dart';

AttendeesList(
  rideId: rideId,
  showJoinButton: true,
  rideOwnerId: rideOwnerId,
)
```

### 4. Badge de Notificaciones

```dart
import 'package:provider/provider.dart';
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';

// En un AppBar o NavigationBar:
Consumer<NotificationsProvider>(
  builder: (context, notifProvider, child) {
    return Badge(
      label: Text('${notifProvider.unreadCount}'),
      isLabelVisible: notifProvider.hasUnread,
      child: IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () => context.push('/notifications'),
      ),
    );
  },
)
```

## 📖 Ejemplos de Integración

### Ejemplo 1: Post Card con Likes y Comentarios

```dart
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Contenido del post
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post.content),
          ),

          // Acciones: like y comentarios
          Row(
            children: [
              LikeButton(
                type: LikeableType.post,
                targetId: post.id,
                targetOwnerId: post.userId,
                targetPreview: post.content,
              ),
              const SizedBox(width: 16),
              StreamBuilder<int>(
                stream: context
                    .read<CommentsProvider>()
                    .watchCommentsCount(CommentableType.post, post.id),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return TextButton.icon(
                    icon: const Icon(Icons.comment),
                    label: Text('$count'),
                    onPressed: () {
                      context.push(
                        '/posts/${post.id}/comments?ownerId=${post.userId}',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Ejemplo 2: Rodada Card con Asistentes

```dart
class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final attendeesProvider = context.watch<AttendeesProvider>();

    return Card(
      child: Column(
        children: [
          // Info de la rodada
          ListTile(
            title: Text(ride.title),
            subtitle: Text(ride.description),
          ),

          // Asistentes confirmados
          StreamBuilder<int>(
            stream: attendeesProvider.watchConfirmedCount(ride.id),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return ListTile(
                leading: const Icon(Icons.people),
                title: Text('$count asistentes'),
                trailing: StreamBuilder<bool>(
                  stream: attendeesProvider.watchUserIsAttending(ride.id),
                  builder: (context, attending) {
                    final isAttending = attending.data ?? false;
                    return ElevatedButton(
                      onPressed: isAttending
                          ? null
                          : () async {
                              await attendeesProvider.joinRide(
                                rideId: ride.id,
                                rideOwnerId: ride.userId,
                              );
                            },
                      child: Text(isAttending ? 'Confirmado' : 'Unirme'),
                    );
                  },
                ),
                onTap: () {
                  context.push(
                    '/rides/${ride.id}/attendees?ownerId=${ride.userId}',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 🔧 API Reference

Ver documentación completa en:
- `SISTEMA_INTERACCIONES_SOCIALES.md` - Diseño completo del sistema
- `database.rules.json` - Reglas de seguridad de Firebase

## 🎯 Próximos Pasos

1. **Desplegar reglas de seguridad:**
   ```bash
   firebase deploy --only database
   ```

2. **Integrar widgets en pantallas existentes:**
   - Agregar `LikeButton` en posts y comentarios
   - Agregar `CommentsList` en detalles de posts y rodadas
   - Agregar `AttendeesList` en detalles de rodadas
   - Agregar badge de notificaciones en NavigationBar

3. **Sincronización con Firestore:**
   - Los contadores (likes, comentarios, asistentes) deben actualizarse en Firestore
   - Esto se puede hacer con Cloud Functions (opcional)

4. **Push Notifications (Opcional):**
   - Configurar Firebase Cloud Messaging
   - Crear Cloud Functions para enviar notificaciones push
   - Ver `SISTEMA_INTERACCIONES_SOCIALES.md` sección 6.1

## 📝 Notas

- **Rendimiento:** Realtime Database está optimizado para datos en tiempo real
- **Costos:** Plan Spark (gratuito) incluye 1GB almacenamiento + 10GB descarga/mes
- **Escalabilidad:** Para > 100k usuarios concurrentes considerar particiones
- **Seguridad:** Las reglas están configuradas para validar tipos y permisos

## 🐛 Troubleshooting

**Error: "Permission denied"**
- Verificar que las reglas estén desplegadas: `firebase deploy --only database`
- Verificar que el usuario esté autenticado

**Error: "Target of URI doesn't exist"**
- Los errores de compilación se resolverán una vez que todos los archivos estén creados
- Ejecutar `flutter pub get` para actualizar dependencias

**Notificaciones no aparecen:**
- Verificar que el usuario esté autenticado
- Verificar que los providers estén configurados en main.dart
- Revisar logs de Firebase Console

---

**Creado con ❤️ para Biux - La comunidad ciclista**
