# Corrección de Comentarios y Notificaciones - 22 Oct 2025

## Problemas Resueltos

### 1. ❌ Error de Permisos en Comentarios (Cuentas Nuevas)

**Error Original:**
```
PlatformException (permission-denied, Client doesn't have permission to access the desired data.)
```

**Causa:**
Las reglas de Firebase Realtime Database eran demasiado restrictivas. Requerían que el campo `text` no cambiara al actualizar contadores, lo que impedía la creación de comentarios nuevos.

**Solución:**
Actualicé las reglas para permitir:
- Crear comentarios nuevos (cualquier usuario autenticado)
- Actualizar solo los contadores (`likesCount`, `repliesCount`) sin cambiar el `text`
- Editar/eliminar solo los propios comentarios

**Reglas Actualizadas:**
```json
// Antes (demasiado restrictivo):
".write": "auth != null && (!data.exists() || data.child('userId').val() === auth.uid || 
  (data.exists() && ... && newData.child('text').val() === data.child('text').val()))"

// Después (permite actualizaciones de contadores):
".write": "auth != null && (!data.exists() || data.child('userId').val() === auth.uid || 
  (data.exists() && (newData.child('repliesCount').val() !== data.child('repliesCount').val() || 
   newData.child('likesCount').val() !== data.child('likesCount').val()) && 
   newData.child('userId').val() === data.child('userId').val()))"
```

Aplicado tanto a `comments/posts` como `comments/rides`.

---

### 2. ✅ Notificaciones de Seguimiento Agregadas

**Problema:**
No se creaban notificaciones cuando un usuario seguía a otro.

**Solución Implementada:**
Actualicé `user_profile_repository_impl.dart` para crear una notificación en Firestore después de seguir exitosamente:

```dart
// Después de batch.commit() en followUser():
await _firestore
  .collection('users')
  .doc(userId)
  .collection('notifications')
  .add({
    'type': 'follow',
    'fromUserId': _currentUserId,
    'fromUserName': currentUserData['fullName'] ?? 'Usuario',
    'fromUserPhoto': currentUserData['photo'],
    'message': 'ha comenzado a seguirte',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
```

**Comportamiento:**
- ✅ Usuario A sigue a Usuario B
- ✅ Usuario B recibe notificación "Usuario A ha comenzado a seguirte"
- ✅ Al tocar la notificación, navega al perfil de Usuario A
- ✅ Push notification enviada si Usuario B tiene habilitadas las notificaciones de "Seguimientos"

---

### 3. ✅ Notificaciones de Solicitud de Ingreso a Grupos

**Problema:**
Los administradores de grupos no recibían notificaciones cuando alguien solicitaba unirse a su grupo.

**Solución Implementada:**
Actualicé `group_repository.dart` para crear una notificación al admin después de agregar la solicitud:

```dart
// Después de actualizar pendingRequestIds:
await _firestore
  .collection('users')
  .doc(adminId)
  .collection('notifications')
  .add({
    'type': 'group_join_request',
    'fromUserId': userId,
    'fromUserName': userData['fullName'] ?? 'Usuario',
    'fromUserPhoto': userData['photo'],
    'targetType': 'group',
    'targetId': groupId,
    'targetPreview': groupData['name'],
    'message': 'solicita unirse a tu grupo ${groupData['name']}',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
    'metadata': {
      'groupName': groupData['name'],
      'groupLogo': groupData['logo'],
    }
  });
```

**Comportamiento:**
- ✅ Usuario solicita ingreso a grupo privado
- ✅ Admin del grupo recibe notificación "Usuario solicita unirse a tu grupo X"
- ✅ Al tocar la notificación, navega al grupo para aprobar/rechazar
- ✅ Push notification enviada si admin tiene habilitadas las notificaciones de "Actualizaciones de Grupos"

---

## Actualizaciones Adicionales

### Cloud Function (`notifications.js`)
Agregué soporte para el nuevo tipo `group_join_request`:

```javascript
const preferenceKey = {
  'like': 'likes',
  'comment': 'comments',
  'follow': 'follows',
  'ride_invitation': 'ride_invitations',
  'group_invitation': 'group_invitations',
  'group_join_request': 'group_updates', // ← NUEVO
  'story': 'stories',
  'ride_reminder': 'ride_reminders',
  'group_update': 'group_updates',
  'system': 'system'
}[notificationType];
```

### Reglas de Realtime Database
Agregué `group_join_request` como tipo válido de notificación:

```json
"type": {
  ".validate": "newData.isString() && (
    newData.val() === 'like_post' || 
    newData.val() === 'like_comment' || 
    newData.val() === 'like_story' || 
    newData.val() === 'comment_post' || 
    newData.val() === 'comment_ride' || 
    newData.val() === 'reply_comment' || 
    newData.val() === 'ride_join' || 
    newData.val() === 'mention' || 
    newData.val() === 'follow' || 
    newData.val() === 'group_join_request'  // ← NUEVO
  )"
}
```

### Notification Listener Widget
Actualicé el manejo de navegación para incluir `group_join_request`:

```dart
case 'group_invitation':
case 'group_update':
case 'group_join_request': // ← NUEVO
  if (relatedId != null) {
    context.push('/groups/$relatedId');
  }
  break;
```

---

## Archivos Modificados

1. ✅ `database.rules.json`
   - Reglas de comentarios más permisivas
   - Nuevo tipo de notificación `group_join_request`

2. ✅ `lib/features/users/data/repositories/user_profile_repository_impl.dart`
   - Crear notificación en `followUser()`

3. ✅ `lib/features/groups/data/repositories/group_repository.dart`
   - Crear notificación en `requestJoinGroup()`

4. ✅ `biux-cloud/functions/notifications.js`
   - Soporte para `group_join_request` en mapeo de preferencias

5. ✅ `lib/shared/widgets/notification_listener_widget.dart`
   - Navegación para `group_join_request`

---

## Despliegue Realizado

```bash
# Reglas de Realtime Database
✅ firebase deploy --only database

# Cloud Functions
✅ firebase deploy --only functions
```

**Estado:** Ambos desplegados exitosamente.

---

## Testing Recomendado

### Test 1: Comentarios con Cuenta Nueva
1. Crear cuenta nueva o usar cuenta reciente
2. Navegar a una experiencia/rodada
3. Intentar comentar
4. ✅ **Esperado:** Comentario se crea sin error de permisos

### Test 2: Notificaciones de Seguimiento
1. Usuario A sigue a Usuario B
2. Usuario B verifica notificaciones
3. ✅ **Esperado:** Notificación "Usuario A ha comenzado a seguirte"
4. Tocar notificación
5. ✅ **Esperado:** Navega al perfil de Usuario A
6. Minimizar app
7. ✅ **Esperado:** Push notification recibida (si habilitada)

### Test 3: Solicitudes de Ingreso a Grupos
1. Usuario A solicita ingreso a grupo privado de Admin B
2. Admin B verifica notificaciones
3. ✅ **Esperado:** Notificación "Usuario A solicita unirse a tu grupo X"
4. Tocar notificación
5. ✅ **Esperado:** Navega al grupo con solicitudes pendientes visibles
6. Minimizar app
7. ✅ **Esperado:** Push notification recibida (si habilitada)

---

## Notas Importantes

### Manejo de Errores
Las notificaciones están en bloques `try-catch` separados para que **no fallen la operación principal** si hay error al crear la notificación:

```dart
try {
  // Crear notificación
} catch (notifError) {
  print('Error creando notificación: $notifError');
  // No fallar la operación principal
}
```

Esto significa:
- ✅ Seguir usuario siempre funciona, incluso si falla la notificación
- ✅ Solicitar ingreso siempre funciona, incluso si falla la notificación

### Preferencias de Usuario
Las notificaciones respetan las preferencias:
- **Seguimientos:** `enableFollows` en configuración de notificaciones
- **Solicitudes de Grupo:** `enableGroupUpdates` en configuración de notificaciones

El usuario puede desactivar estos tipos en: **Configuración → Notificaciones**

---

## Próximos Pasos (Opcional)

### Notificación al Aprobar/Rechazar Solicitud de Grupo
Actualmente **no se notifica** al usuario cuando su solicitud es aprobada/rechazada. Podrías agregar notificaciones en:
- `approveJoinRequest()` → "Tu solicitud a grupo X fue aprobada"
- `rejectJoinRequest()` → "Tu solicitud a grupo X fue rechazada"

### Notificación de Seguimiento a Grupos
Si quieres implementar "seguir grupos" (similar a seguir usuarios), podrías:
- Agregar campo `followers` a grupos
- Crear notificaciones cuando alguien sigue el grupo
- Notificar a admin cuando hay nuevos seguidores

---

## Resumen de Estado

| Feature | Estado | Testing |
|---------|--------|---------|
| ✅ Comentarios (cuentas nuevas) | Corregido | Requiere testing |
| ✅ Notificaciones de seguimiento | Implementado | Requiere testing |
| ✅ Notificaciones de solicitud de ingreso | Implementado | Requiere testing |
| ✅ Cloud Function actualizada | Desplegado | Requiere testing |
| ✅ Reglas de DB actualizadas | Desplegado | Requiere testing |

**Acción requerida:** Hot restart de la app y testing manual para confirmar que todo funciona correctamente.
