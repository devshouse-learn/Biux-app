# 🚀 Guía de Implementación Final - Sistema Social

## ✅ Estado Actual

Se ha implementado completamente:

1. ✅ **Entidades** (4): NotificationEntity, LikeEntity, CommentEntity, AttendeeEntity
2. ✅ **Repositorios Domain** (4 interfaces)
3. ✅ **Modelos** (4): Conversión JSON ↔ Entities
4. ✅ **Datasources** (4): Conexión con Firebase Realtime Database
5. ✅ **Repositorios Impl** (4): Implementaciones con lógica de negocio
6. ✅ **Providers** (4): State management con ChangeNotifier
7. ✅ **Widgets** (5): LikeButton, CommentsList, CommentItem, AttendeesList, NotificationsList
8. ✅ **Screens** (3): NotificationsScreen, CommentsScreen, AttendeesScreen
9. ✅ **Dependencias**: firebase_database, timeago agregadas
10. ✅ **Documentación**: README.md y SISTEMA_INTERACCIONES_SOCIALES.md
11. ✅ **Reglas de seguridad**: database.rules.json

## 📋 Pasos para Completar la Implementación

### Paso 1: Configurar Firebase Realtime Database

```bash
# 1. Inicializar Firebase en el proyecto (si no está hecho)
firebase init database

# 2. Desplegar las reglas de seguridad
firebase deploy --only database
```

**Verificación:**
- Ve a Firebase Console → Realtime Database
- Deberías ver la estructura de reglas desplegada

### Paso 2: Actualizar main.dart

Agrega los providers sociales en `lib/main.dart`:

```dart
import 'features/social/social_providers_config.dart';

// Dentro de MultiProvider:
providers: [
  // ... providers existentes (AuthProvider, ThemeNotifier, etc.)
  
  // Providers del feature social
  ...SocialProvidersConfig.getProviders(),
],
```

### Paso 3: Configurar Rutas

En `lib/core/config/router/app_router.dart`, agrega:

```dart
// Importaciones
import 'package:biux/features/social/presentation/screens/notifications_screen.dart';
import 'package:biux/features/social/presentation/screens/comments_screen.dart';
import 'package:biux/features/social/presentation/screens/attendees_screen.dart';

// Rutas
GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationsScreen(),
),
GoRoute(
  path: '/posts/:postId/comments',
  builder: (context, state) {
    final postId = state.pathParameters['postId']!;
    final postOwnerId = state.uri.queryParameters['ownerId']!;
    return PostCommentsScreen(postId: postId, postOwnerId: postOwnerId);
  },
),
GoRoute(
  path: '/rides/:rideId/comments',
  builder: (context, state) {
    final rideId = state.pathParameters['rideId']!;
    final rideOwnerId = state.uri.queryParameters['ownerId']!;
    return RideCommentsScreen(rideId: rideId, rideOwnerId: rideOwnerId);
  },
),
GoRoute(
  path: '/rides/:rideId/attendees',
  builder: (context, state) {
    final rideId = state.pathParameters['rideId']!;
    final rideOwnerId = state.uri.queryParameters['ownerId']!;
    return RideAttendeesScreen(rideId: rideId, rideOwnerId: rideOwnerId);
  },
),
```

### Paso 4: Integrar en Posts

En tu widget de post existente, agrega:

```dart
import 'package:biux/features/social/presentation/widgets/like_button.dart';
import 'package:biux/features/social/domain/repositories/likes_repository.dart';
import 'package:biux/features/social/domain/repositories/comments_repository.dart';
import 'package:biux/features/social/presentation/providers/comments_provider.dart';

// Ejemplo de integración en un PostCard:
Row(
  children: [
    // Botón de like
    LikeButton(
      type: LikeableType.post,
      targetId: post.id,
      targetOwnerId: post.authorId,
      targetPreview: post.content,
      showCount: true,
    ),
    
    const SizedBox(width: 16),
    
    // Botón de comentarios con contador
    Consumer<CommentsProvider>(
      builder: (context, provider, _) {
        return StreamBuilder<int>(
          stream: provider.watchCommentsCount(
            CommentableType.post,
            post.id,
          ),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return TextButton.icon(
              icon: const Icon(Icons.comment_outlined),
              label: Text('$count'),
              onPressed: () {
                context.push('/posts/${post.id}/comments?ownerId=${post.authorId}');
              },
            );
          },
        );
      },
    ),
  ],
)
```

### Paso 5: Integrar en Rodadas

En tu widget de rodada existente, agrega:

```dart
import 'package:biux/features/social/presentation/widgets/attendees_list.dart';
import 'package:biux/features/social/presentation/providers/attendees_provider.dart';

// En el detalle de la rodada:
Consumer<AttendeesProvider>(
  builder: (context, provider, _) {
    return StreamBuilder<int>(
      stream: provider.watchConfirmedCount(ride.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return ListTile(
          leading: const Icon(Icons.people),
          title: Text('$count asistentes confirmados'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/rides/${ride.id}/attendees?ownerId=${ride.authorId}');
          },
        );
      },
    );
  },
)
```

### Paso 6: Badge de Notificaciones

En tu `MainShell` o `NavigationBar`, agrega:

```dart
import 'package:biux/features/social/presentation/providers/notifications_provider.dart';

// En el ítem de navegación:
Consumer<NotificationsProvider>(
  builder: (context, provider, child) {
    return Badge(
      label: Text('${provider.unreadCount}'),
      isLabelVisible: provider.hasUnread,
      backgroundColor: Colors.red,
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => context.push('/notifications'),
      ),
    );
  },
)
```

### Paso 7: Integrar en Historias (Stories)

En tu widget de historias, agrega likes:

```dart
import 'package:biux/features/social/presentation/widgets/like_button.dart';

// En el visualizador de historias:
Positioned(
  bottom: 100,
  left: 20,
  child: LikeButton(
    type: LikeableType.story,
    targetId: story.id,
    targetOwnerId: story.authorId,
    showCount: true,
    activeColor: Colors.pink,
    inactiveColor: Colors.white,
  ),
)
```

## 🧪 Testing

### 1. Probar Likes

```dart
// En cualquier pantalla:
void _testLikes() async {
  final provider = context.read<LikesProvider>();
  
  // Dar like a un post
  await provider.likePost(
    postId: 'test-post-123',
    postOwnerId: 'user-456',
    postPreview: 'Este es un post de prueba',
  );
  
  print('Like agregado!');
}
```

### 2. Probar Comentarios

```dart
// En cualquier pantalla:
void _testComments() async {
  final provider = context.read<CommentsProvider>();
  
  // Comentar en un post
  final commentId = await provider.commentOnPost(
    postId: 'test-post-123',
    postOwnerId: 'user-456',
    text: 'Este es un comentario de prueba',
  );
  
  print('Comentario creado: $commentId');
}
```

### 3. Probar Asistentes

```dart
// En cualquier pantalla:
void _testAttendees() async {
  final provider = context.read<AttendeesProvider>();
  
  // Unirse a una rodada
  await provider.joinRide(
    rideId: 'test-ride-789',
    rideOwnerId: 'user-101',
    level: CyclingLevel.intermediate,
    bikeType: 'MTB',
  );
  
  print('Asistencia registrada!');
}
```

## 📊 Verificación en Firebase Console

1. Ve a Firebase Console → Realtime Database
2. Deberías ver la estructura:
   ```
   - notifications
     - {userId}
       - {notificationId}
     - unread
       - {userId}: number
   - likes
     - posts
       - {postId}
         - {userId}
     - comments
     - stories
   - comments
     - posts
       - {postId}
         - {commentId}
     - rides
   - rides
     - attendees
       - {rideId}
         - {userId}
   ```

## 🔍 Debugging

Si hay problemas:

1. **Verificar autenticación:**
   ```dart
   print('Usuario actual: ${FirebaseAuth.instance.currentUser?.uid}');
   ```

2. **Verificar providers:**
   ```dart
   print('NotificationsProvider: ${context.read<NotificationsProvider>()}');
   ```

3. **Verificar Firebase Console:**
   - Logs en Firebase Console → Realtime Database → Usage
   - Revisar denied reads/writes

## 🎨 Personalización

### Cambiar colores del LikeButton

```dart
LikeButton(
  // ... otros parámetros
  activeColor: AppColors.primary, // Tu color
  inactiveColor: Colors.grey,
  size: 28.0,
)
```

### Cambiar límite de caracteres en comentarios

En `comments_provider.dart`, línea 84:
```dart
if (text.length > 500) { // Cambiar a tu límite
```

### Cambiar expiración de likes en stories

En `likes_provider.dart`, línea 64:
```dart
final expiresAt = DateTime.now().add(const Duration(hours: 24)); // Cambiar duración
```

## ✨ Siguiente Nivel (Opcional)

### Cloud Functions para sincronizar contadores

Crear `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Sincronizar contador de likes en Firestore
exports.syncLikesCount = functions.database
  .ref('/likes/posts/{postId}/{userId}')
  .onWrite(async (change, context) => {
    const postId = context.params.postId;
    const snapshot = await change.after.ref.parent.once('value');
    const count = snapshot.numChildren();
    
    return admin.firestore()
      .collection('posts')
      .doc(postId)
      .update({ likesCount: count });
  });

// Sincronizar contador de comentarios
exports.syncCommentsCount = functions.database
  .ref('/comments/posts/{postId}/{commentId}')
  .onWrite(async (change, context) => {
    const postId = context.params.postId;
    const snapshot = await change.after.ref.parent.once('value');
    const count = snapshot.numChildren();
    
    return admin.firestore()
      .collection('posts')
      .doc(postId)
      .update({ commentsCount: count });
  });
```

Desplegar:
```bash
firebase deploy --only functions
```

## 📚 Recursos Adicionales

- [Firebase Realtime Database Docs](https://firebase.google.com/docs/database)
- [Provider State Management](https://pub.dev/packages/provider)
- [Timeago Package](https://pub.dev/packages/timeago)

---

## ✅ Checklist Final

- [ ] Firebase Realtime Database habilitado
- [ ] Reglas de seguridad desplegadas (`firebase deploy --only database`)
- [ ] Providers agregados en main.dart
- [ ] Rutas configuradas en app_router.dart
- [ ] LikeButton integrado en posts
- [ ] CommentsList integrado en posts
- [ ] AttendeesList integrado en rodadas
- [ ] Badge de notificaciones en navegación
- [ ] LikeButton integrado en historias
- [ ] Probado en dispositivo real
- [ ] Verificado en Firebase Console

**¡El sistema está completo y listo para usar! 🎉**
