# 🚀 Guía Rápida: Probar Sistema de Notificaciones

## ✅ ¿Qué se ha implementado?

1. **NotificationService**: Servicio completo de notificaciones push + locales
2. **BiuxNotificationListener**: Widget para manejar navegación desde notificaciones
3. **Configuración Android**: Permisos en AndroidManifest.xml
4. **Integración completa**: Todo conectado en main.dart

---

## 🧪 Cómo Probar (Paso a Paso)

### Opción 1: Prueba desde Firebase Console (Más Fácil)

#### Paso 1: Ejecuta la app
```bash
flutter run
```

#### Paso 2: Obtén el token FCM
En la consola de Flutter, busca esta línea:
```
🔔 FCM Token: [tu-token-aquí]
```
Copia ese token completo.

#### Paso 3: Envía notificación de prueba
1. Abre [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto "biux"
3. Ve a **Cloud Messaging** (menú lateral)
4. Click en **"Send test message"** o **"Nueva campaña"**
5. Completa:
   - **Título**: "¡Nuevo like!"
   - **Texto**: "A JuanPerez le gustó tu publicación"
   
6. En **"Send test message to token"**:
   - Pega el token FCM que copiaste
   
7. Click en **"Additional options"** (Opciones adicionales)
8. Agrega datos personalizados:
   ```json
   {
     "type": "like",
     "senderId": "user123",
     "relatedId": "experience456"
   }
   ```

9. Click en **"Test"** o **"Enviar"**

#### Paso 4: Verifica el resultado

**Si la app está abierta (foreground):**
- ✅ Deberías ver un snackbar en la parte inferior
- ✅ También una notificación local del sistema
- ✅ Click en "Ver" te lleva a la experiencia

**Si la app está minimizada (background):**
- ✅ Verás una notificación del sistema
- ✅ Tap en ella abre la app y navega a la experiencia

**Si la app está cerrada (terminated):**
- ✅ Verás una notificación del sistema
- ✅ Tap en ella abre la app y navega directamente

---

### Opción 2: Prueba con código de test

#### Crear archivo de test:
`lib/debug/test_notifications.dart`
```dart
import 'package:biux/shared/services/notification_service.dart';

Future<void> testNotifications() async {
  final service = NotificationService();
  
  // Simular notificación de like
  service.notificationStream.add({
    'title': 'Nuevo like',
    'body': 'A María le gustó tu publicación',
    'type': 'like',
    'senderId': 'user123',
    'relatedId': 'experience456',
  });
  
  // Esperar 3 segundos
  await Future.delayed(Duration(seconds: 3));
  
  // Simular notificación de comentario
  service.notificationStream.add({
    'title': 'Nuevo comentario',
    'body': 'Juan: ¡Qué buena ruta!',
    'type': 'comment',
    'senderId': 'user789',
    'relatedId': 'experience456',
  });
}
```

#### Llamar desde cualquier pantalla:
```dart
import 'package:biux/debug/test_notifications.dart';

// En un botón o FloatingActionButton
FloatingActionButton(
  onPressed: () => testNotifications(),
  child: Icon(Icons.notifications_active),
)
```

---

## 📱 Tipos de Notificación y Navegación

### 1. Like en publicación
```json
{
  "type": "like",
  "senderId": "user123",
  "relatedId": "experience456"
}
```
**Navegación**: `/experiences/experience456`

---

### 2. Comentario en publicación
```json
{
  "type": "comment",
  "senderId": "user456",
  "relatedId": "experience789"
}
```
**Navegación**: `/experiences/experience789`

---

### 3. Nuevo seguidor
```json
{
  "type": "follow",
  "senderId": "user999"
}
```
**Navegación**: `/users/user999`

---

### 4. Invitación a rodada
```json
{
  "type": "ride_invitation",
  "senderId": "user111",
  "relatedId": "ride222"
}
```
**Navegación**: `/rides/ride222`

---

### 5. Invitación a grupo
```json
{
  "type": "group_invitation",
  "senderId": "user333",
  "relatedId": "group444"
}
```
**Navegación**: `/groups/group444`

---

### 6. Nueva historia
```json
{
  "type": "story",
  "senderId": "user555"
}
```
**Navegación**: `/stories`

---

## 🔍 Verificación de Datos en Firestore

### 1. Token guardado:
```
users/{userId}
  ├─ fcmTokens: ["token1", "token2", ...]
```

### 2. Notificación guardada:
```
users/{userId}/notifications/{notificationId}
  ├─ title: "Nuevo like"
  ├─ body: "A Juan le gustó tu publicación"
  ├─ type: "like"
  ├─ senderId: "user123"
  ├─ relatedId: "experience456"
  ├─ timestamp: Timestamp
  ├─ read: false
```

---

## 🐛 Solución de Problemas

### ❌ No aparece el token en consola
**Solución**: 
- Verifica que internet está conectado
- Revisa que Firebase está inicializado
- Espera unos segundos después del inicio

### ❌ Notificación no llega
**Solución**:
- Verifica que el token es correcto (sin espacios extra)
- Asegúrate de que `google-services.json` está actualizado
- Comprueba que Firebase Cloud Messaging está activado en Console

### ❌ No navega al tocar notificación
**Solución**:
- Verifica que `BiuxNotificationListener` está envolviendo `MaterialApp`
- Comprueba que las rutas existen en `app_router.dart`
- Revisa que los datos tienen `type` y `relatedId` correctos

### ❌ Error de permisos en Android
**Solución**:
- Ve a Configuración del dispositivo → Apps → Biux → Notificaciones
- Activa todas las notificaciones
- En Android 13+, acepta el diálogo de permisos al abrir la app

---

## 📊 Logs para Debugging

### Habilitar logs detallados:
En `notification_service.dart`, agrega prints:

```dart
// En initialize()
print('🔔 Initializing NotificationService...');
print('🔔 FCM Token: $token');

// En _handleForegroundMessage()
print('📩 Foreground message received');
print('📦 Title: ${message.notification?.title}');
print('📦 Body: ${message.notification?.body}');
print('📦 Data: ${message.data}');

// En _showLocalNotification()
print('🔔 Showing local notification');
print('📱 Title: $title, Body: $body');
```

---

## ✅ Checklist de Funcionalidad

- [ ] Token FCM se imprime en consola al iniciar
- [ ] Token se guarda en Firestore `users/{userId}/fcmTokens`
- [ ] Notificación llega cuando app está abierta (foreground)
- [ ] Snackbar aparece con botón "Ver"
- [ ] Notificación local se muestra en sistema
- [ ] Notificación llega cuando app está minimizada (background)
- [ ] Notificación llega cuando app está cerrada (terminated)
- [ ] Tap en notificación navega correctamente
- [ ] Notificación se guarda en Firestore
- [ ] Navegación funciona para todos los tipos:
  - [ ] like → experiencia
  - [ ] comment → experiencia
  - [ ] follow → perfil de usuario
  - [ ] ride_invitation → rodada
  - [ ] group_invitation → grupo
  - [ ] story → historias

---

## 🎯 Próximo Paso

Una vez verificado que funciona:
1. Implementar Cloud Functions en backend (ver `SISTEMA_NOTIFICACIONES.md`)
2. Configurar iOS push notifications (si vas a publicar en App Store)
3. Agregar preferencias de usuario para tipos de notificaciones
4. Implementar badge count con notificaciones no leídas

---

**¿Necesitas ayuda?** Revisa `SISTEMA_NOTIFICACIONES.md` para documentación completa.
