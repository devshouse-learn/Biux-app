# 🐛 DEBUG: Notificaciones No Llegan

## ❌ Problema Encontrado

La Cloud Function estaba buscando los **tokens FCM** y **preferencias** en los lugares equivocados:

### Antes (INCORRECTO):
```javascript
// ❌ Buscaba tokens en: users/{userId}/fcmTokens (campo array)
const userData = userDoc.data();
const fcmTokens = userData.fcmTokens || [];

// ❌ Buscaba preferencias en: users/{userId}/notificationSettings (campo)
const settings = userData.notificationSettings || {};
```

### Ahora (CORREGIDO):
```javascript
// ✅ Lee tokens de: users/{userId}/fcmTokens/{tokenId} (subcolección)
const tokensSnapshot = await admin.firestore()
  .collection('users')
  .doc(userId)
  .collection('fcmTokens')
  .get();

// ✅ Lee preferencias de: users/{userId}/notificationSettings/preferences
const preferencesDoc = await admin.firestore()
  .collection('users')
  .doc(userId)
  .collection('notificationSettings')
  .doc('preferences')
  .get();
```

## ✅ Solución Aplicada

1. ✅ **Cloud Function Corregida** - Desplegada exitosamente
2. ✅ **Widget de Debug Creado** - Para pruebas fáciles
3. ✅ **Script de Prueba Creado** - Para verificación manual

---

## 🧪 CÓMO PROBAR AHORA

### Opción 1: Widget Visual (Recomendado)

1. **Agregar el widget de debug** a cualquier pantalla temporalmente:

```dart
// En cualquier archivo de tu app, por ejemplo main.dart o una pantalla de debug
import 'package:biux/debug/notification_debug_widget.dart';

// Agregar un botón para abrir el debug
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDebugWidget(),
      ),
    );
  },
  child: Icon(Icons.bug_report),
)
```

2. **Ejecutar la app** y abrir el widget de debug

3. **Seguir estos pasos en orden**:
   - Paso 1: Click en "**Verificar Configuración**"
   - Paso 2: Click en "**Reinicializar Servicio**"
   - Paso 3: Click en cualquier botón de tipo de notificación (like, comment, etc.)

4. **Observar los logs** en tiempo real en el widget

---

### Opción 2: Consola de Firebase (Manual)

1. **Abre la consola de Firestore**: https://console.firebase.google.com/project/biux-1576614678644/firestore

2. **Navega a**: `users/{tu_userId}/fcmTokens`
   - ✅ Deberías ver al menos 1 documento con tu token FCM
   - ❌ Si no hay nada: Ejecuta `await NotificationService().reinitializeAfterLogin()` en tu app

3. **Navega a**: `users/{tu_userId}/notificationSettings/preferences`
   - ✅ Deberías ver preferencias con todos los tipos en `true`
   - ❌ Si no existe: Se creará automáticamente al reinicializar

4. **Crear notificación manualmente**:
   - Ve a: `users/{tu_userId}/notifications`
   - Click en "Agregar documento"
   - ID: (auto)
   - Campos:
     ```
     type: "like"
     title: "Test Manual"
     body: "Prueba desde Firestore"
     senderId: "test123"
     relatedId: "test456"
     timestamp: (usar timestamp actual)
     read: false
     ```
   - Click "Guardar"

5. **Verificar logs de Cloud Function**:
   ```powershell
   cd biux-cloud
   firebase functions:log --only onNotificationCreated
   ```

   **Deberías ver**:
   ```
   New notification created for user abc123, type: like
   User abc123 preferences: { likes: true, ... }
   Found 1 FCM token(s) for user abc123
   Push notification sent to user abc123: 1 success, 0 failures
   ```

---

## 🔍 Verificar que Todo Funciona

### ✅ Checklist de Verificación

- [ ] **Tokens FCM guardados**
  ```dart
  // En DevTools o debug console:
  final tokens = await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .collection('fcmTokens')
    .get();
  print('Tokens: ${tokens.docs.length}');
  ```

- [ ] **Preferencias creadas**
  ```dart
  final prefs = await FirebaseFirestore.instance
    .doc('users/${FirebaseAuth.instance.currentUser!.uid}/notificationSettings/preferences')
    .get();
  print('Preferencias: ${prefs.data()}');
  ```

- [ ] **Cloud Function se ejecuta**
  - Crear notificación en Firestore
  - Ver logs: `firebase functions:log --only onNotificationCreated`
  - Debe aparecer: "New notification created for user..."

- [ ] **Push notification llega**
  - Minimizar la app (no cerrarla)
  - Crear notificación
  - Debe aparecer notificación del sistema en 2-3 segundos

---

## 🚨 Troubleshooting

### Problema: "No FCM tokens found"

**Causa**: El token no se guardó después del login

**Solución**:
```dart
await NotificationService().reinitializeAfterLogin();
```

---

### Problema: "No preferences found"

**Causa**: Las preferencias no se crearon

**Solución**: Las preferencias se crean automáticamente. Si no existen, la Cloud Function permite todas las notificaciones por defecto.

---

### Problema: Cloud Function no se ejecuta

**Causa 1**: El documento no se está creando en la ruta correcta
- Verificar que la ruta sea: `users/{userId}/notifications/{notificationId}`

**Causa 2**: Permisos de Eventarc no están listos
- Esperar 5-10 minutos después del deploy
- Verificar en: https://console.cloud.google.com/eventarc

**Solución**: Revisar logs de deployment:
```powershell
firebase functions:log
```

---

### Problema: Cloud Function se ejecuta pero no llega push

**Causa 1**: Token FCM inválido o expirado
- La Cloud Function lo elimina automáticamente
- Solución: Reinicializar servicio

**Causa 2**: Notificación deshabilitada en preferencias
- Verificar que el tipo esté en `true` en preferences

**Causa 3**: App en foreground
- En foreground se muestra notificación local, no push del sistema
- Solución: Minimizar la app para probar

---

## 📱 Estados de la App

| Estado | Qué sucede |
|--------|------------|
| **Foreground** | Notificación local + snackbar (NO push del sistema) |
| **Background** | Push del sistema → tap navega |
| **Closed** | Push del sistema → tap abre app y navega |

---

## 🎯 Próximos Pasos

1. **Hot Restart** tu app para cargar los cambios
2. **Abrir el NotificationDebugWidget**
3. **Seguir los 3 pasos** en el widget
4. **Observar los logs** en el widget
5. **Minimizar la app** y esperar la notificación

---

## 📞 Si Aún No Funciona

Comparte:
1. Screenshot del NotificationDebugWidget mostrando los logs
2. Resultado de: `firebase functions:log --only onNotificationCreated`
3. Screenshot de Firestore mostrando:
   - `users/{tuUserId}/fcmTokens`
   - `users/{tuUserId}/notificationSettings/preferences`
   - `users/{tuUserId}/notifications` (última notificación)

---

**Estado**: ✅ Cloud Function corregida y desplegada
**Última actualización**: 22 oct 2025, 16:45
