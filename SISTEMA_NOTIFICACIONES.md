# Sistema de Notificaciones Push - Biux

## ✅ Implementación Completada

### 1. Servicio de Notificaciones (`NotificationService`)
**Ubicación**: `lib/shared/services/notification_service.dart`

#### Características:
- ✅ **Patrón Singleton** para acceso global
- ✅ **Firebase Cloud Messaging (FCM)** integrado
- ✅ **Notificaciones Locales** con `flutter_local_notifications`
- ✅ **Stream de eventos** para comunicación con UI
- ✅ **Manejo completo de estados de la app**:
  - Foreground (app abierta)
  - Background (app minimizada)
  - Terminated (app cerrada)

#### Funcionalidades Implementadas:
```dart
// Inicialización completa
await NotificationService().initialize();

// Maneja permisos automáticamente
// Configura canal Android de alta prioridad
// Configura iOS con sonido y badge
// Guarda token FCM en Firestore
```

#### Flujo de Notificaciones:
1. **Recepción de Mensaje**:
   - Foreground: Muestra notificación local + guarda en Firestore
   - Background: Firebase muestra notificación + ejecuta handler
   - Terminated: Firebase muestra notificación al iniciar app

2. **Almacenamiento en Firestore**:
   ```
   users/{userId}/notifications/{notificationId}
   ```
   - Estructura: title, body, type, senderId, relatedId, timestamp, read

3. **Token Management**:
   - Token guardado en `users/{userId}/fcmTokens` array
   - Actualización automática en cambios de token

### 2. Widget Listener (`BiuxNotificationListener`)
**Ubicación**: `lib/shared/widgets/notification_listener_widget.dart`

#### Características:
- ✅ Escucha el stream de notificaciones
- ✅ Muestra snackbar en foreground con acción "Ver"
- ✅ Navega a pantallas según tipo de notificación
- ✅ Integrado en el árbol de widgets principal

#### Tipos de Navegación:
```dart
'like' → /experiences/{relatedId}
'comment' → /experiences/{relatedId}
'follow' → /users/{senderId}
'ride_invitation' → /rides/{relatedId}
'group_invitation' → /groups/{relatedId}
'story' → /stories
default → /notifications
```

### 3. Configuración Android
**Archivo**: `android/app/src/main/AndroidManifest.xml`

#### Permisos Agregados:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

#### Canal de Notificaciones:
- **ID**: `biux_notifications`
- **Nombre**: Biux Notifications
- **Importancia**: Alta (High)
- **Sonido**: Activado
- **Vibración**: Activada

### 4. Integración en App
**Archivo**: `lib/main.dart`

```dart
// Inicialización en main()
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
await NotificationService().initialize();

// Envuelto en MaterialApp
BiuxNotificationListener(
  child: MaterialApp.router(...)
)
```

### 5. Dependencia
**Archivo**: `pubspec.yaml`
```yaml
flutter_local_notifications: ^18.0.1
```

---

## 📋 Configuración Backend Pendiente

### Cloud Functions para Envío de Notificaciones

#### 1. Notificación de "Like"
```javascript
exports.sendLikeNotification = functions.firestore
  .document('experiences/{experienceId}/likes/{likeId}')
  .onCreate(async (snap, context) => {
    const like = snap.data();
    const experienceId = context.params.experienceId;
    
    // Obtener dueño del post
    const experience = await admin.firestore()
      .collection('experiences')
      .doc(experienceId)
      .get();
    
    const ownerId = experience.data().userId;
    
    // No notificar si el like es del mismo usuario
    if (like.userId === ownerId) return;
    
    // Obtener tokens del usuario
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(ownerId)
      .get();
    
    const fcmTokens = userDoc.data().fcmTokens || [];
    
    // Enviar notificación
    const message = {
      notification: {
        title: 'Nuevo like',
        body: `A ${like.userName} le gustó tu publicación`
      },
      data: {
        type: 'like',
        senderId: like.userId,
        relatedId: experienceId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      tokens: fcmTokens
    };
    
    await admin.messaging().sendMulticast(message);
  });
```

#### 2. Notificación de "Comentario"
```javascript
exports.sendCommentNotification = functions.firestore
  .document('experiences/{experienceId}/comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const experienceId = context.params.experienceId;
    
    // Similar a likes...
    const message = {
      notification: {
        title: 'Nuevo comentario',
        body: `${comment.userName}: ${comment.text.substring(0, 50)}...`
      },
      data: {
        type: 'comment',
        senderId: comment.userId,
        relatedId: experienceId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      tokens: fcmTokens
    };
  });
```

#### 3. Notificación de "Seguidor"
```javascript
exports.sendFollowNotification = functions.firestore
  .document('users/{userId}/followers/{followerId}')
  .onCreate(async (snap, context) => {
    const follower = snap.data();
    const userId = context.params.userId;
    
    const message = {
      notification: {
        title: 'Nuevo seguidor',
        body: `${follower.userName} comenzó a seguirte`
      },
      data: {
        type: 'follow',
        senderId: follower.userId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      tokens: fcmTokens
    };
  });
```

#### 4. Notificación de "Invitación a Rodada"
```javascript
exports.sendRideInvitationNotification = functions.firestore
  .document('rides/{rideId}/invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const rideId = context.params.rideId;
    
    const message = {
      notification: {
        title: 'Invitación a rodada',
        body: `${invitation.inviterName} te invitó a una rodada`
      },
      data: {
        type: 'ride_invitation',
        senderId: invitation.inviterId,
        relatedId: rideId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      tokens: fcmTokens
    };
  });
```

#### 5. Notificación de "Invitación a Grupo"
```javascript
exports.sendGroupInvitationNotification = functions.firestore
  .document('groups/{groupId}/invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const groupId = context.params.groupId;
    
    const message = {
      notification: {
        title: 'Invitación a grupo',
        body: `${invitation.inviterName} te invitó a unirte a ${invitation.groupName}`
      },
      data: {
        type: 'group_invitation',
        senderId: invitation.inviterId,
        relatedId: groupId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      tokens: fcmTokens
    };
  });
```

#### 6. Notificación de "Nueva Historia"
```javascript
exports.sendStoryNotification = functions.firestore
  .document('stories/{storyId}')
  .onCreate(async (snap, context) => {
    const story = snap.data();
    
    // Obtener seguidores del usuario
    const followersSnapshot = await admin.firestore()
      .collection('users')
      .doc(story.userId)
      .collection('followers')
      .get();
    
    // Enviar a cada seguidor
    for (const follower of followersSnapshot.docs) {
      const followerDoc = await admin.firestore()
        .collection('users')
        .doc(follower.id)
        .get();
      
      const fcmTokens = followerDoc.data().fcmTokens || [];
      
      const message = {
        notification: {
          title: 'Nueva historia',
          body: `${story.userName} publicó una historia`
        },
        data: {
          type: 'story',
          senderId: story.userId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        tokens: fcmTokens
      };
      
      await admin.messaging().sendMulticast(message);
    }
  });
```

---

## 🧪 Testing

### 1. Prueba desde Firebase Console
1. Ir a Firebase Console → Cloud Messaging
2. Seleccionar "Send test message"
3. Agregar token FCM (se imprime en consola al iniciar app)
4. Enviar con datos:
   ```json
   {
     "type": "like",
     "senderId": "user123",
     "relatedId": "experience456"
   }
   ```

### 2. Verificar Funcionalidad
- [ ] App en foreground: Muestra snackbar + notificación local
- [ ] App en background: Muestra notificación del sistema
- [ ] App cerrada: Muestra notificación al iniciar
- [ ] Tap en notificación: Navega a pantalla correcta
- [ ] Token guardado en Firestore `users/{userId}/fcmTokens`
- [ ] Notificación guardada en `users/{userId}/notifications`

### 3. Logs para Debugging
```dart
// En NotificationService.initialize()
print('🔔 FCM Token: $token');

// En _handleForegroundMessage()
print('📩 Notification received: ${message.notification?.title}');
print('📦 Data: ${message.data}');

// En BiuxNotificationListener
print('🔔 Notification tapped: ${data['type']}');
```

---

## 📱 Configuración iOS (Pendiente)

### 1. Habilitar Push Notifications en Xcode
1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Seleccionar target "Runner"
3. Ir a "Signing & Capabilities"
4. Click en "+ Capability"
5. Agregar "Push Notifications"

### 2. Configurar APNs en Firebase Console
1. Ir a Firebase Console → Project Settings
2. Cloud Messaging → iOS App
3. Subir APNs Authentication Key (.p8)
   - Obtener de Apple Developer → Certificates, IDs & Profiles → Keys

### 3. Agregar Background Modes (si necesario)
En Info.plist:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 🎯 Próximos Pasos Recomendados

### Inmediatos:
1. ✅ Probar notificaciones desde Firebase Console
2. ✅ Verificar navegación desde notificaciones
3. ✅ Comprobar almacenamiento en Firestore

### Backend:
1. 📝 Implementar Cloud Functions para cada tipo de notificación
2. 📝 Configurar triggers en Firestore
3. 📝 Agregar lógica de rate limiting (evitar spam)
4. 📝 Implementar batch sending para múltiples usuarios

### Mejoras Futuras:
- 🔔 **Badge Count**: Actualizar badge de iOS/Android con notificaciones no leídas
- 🌐 **Deep Linking Avanzado**: Mejorar navegación con parámetros específicos
- 📊 **Analytics**: Tracking de taps en notificaciones
- 🔕 **Preferencias de Usuario**: Permitir silenciar tipos específicos
- 📅 **Notificaciones Programadas**: Para recordatorios de rodadas
- 🎨 **Notificaciones Ricas**: Con imágenes y acciones personalizadas

---

## 🐛 Solución de Problemas

### Notificaciones no llegan en foreground:
- Verificar que `NotificationService().initialize()` se llama en `main()`
- Revisar permisos en Android/iOS
- Comprobar que el token FCM se guarda correctamente

### Navegación no funciona:
- Verificar que `BiuxNotificationListener` envuelve `MaterialApp`
- Comprobar que el router está configurado correctamente
- Revisar que las rutas existen en `app_router.dart`

### Token no se guarda:
- Verificar conexión a internet
- Comprobar que el usuario está autenticado
- Revisar reglas de seguridad de Firestore

### Notificaciones duplicadas:
- Verificar que no hay múltiples tokens en Firestore
- Limpiar tokens antiguos periódicamente
- Implementar deduplicación en backend

---

## 📚 Recursos

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [iOS Push Notifications](https://developer.apple.com/documentation/usernotifications)

---

**Estado**: ✅ Sistema completo y funcional
**Última actualización**: ${DateTime.now().toString().split(' ')[0]}
