# 🔔 Sistema de Notificaciones Push - Backend (Cloud Functions)

## 📦 Estructura del Proyecto

```
biux-cloud/
├── functions/
│   ├── index.js              # Punto de entrada principal
│   ├── notifications.js      # Módulo de notificaciones
│   ├── package.json         # Dependencias
│   └── node_modules/        # Paquetes instalados
├── .firebaserc              # Configuración de Firebase
└── firebase.json            # Configuración de despliegue
```

---

## 🚀 Triggers Implementados

### 1. **onLikeCreated** 
**Ruta**: `experiences/{experienceId}/likes/{likeId}`

**Trigger**: Cuando alguien le da like a una experiencia

**Lógica**:
- Obtiene el dueño de la experiencia
- Verifica que no sea el mismo usuario (no auto-notificar)
- Verifica preferencias de notificaciones (`enableLikes`)
- Envía: "A [usuario] le gustó tu publicación"

**Datos**:
```javascript
{
  type: "like",
  senderId: userId, // Usuario que dio like
  relatedId: experienceId
}
```

---

### 2. **onCommentCreated**
**Ruta**: `experiences/{experienceId}/comments/{commentId}`

**Trigger**: Cuando alguien comenta en una experiencia

**Lógica**:
- Obtiene el dueño de la experiencia
- Verifica que no sea el mismo usuario
- Verifica preferencias (`enableComments`)
- Trunca comentario a 50 caracteres
- Envía: "[Usuario]: [comentario...]"

**Datos**:
```javascript
{
  type: "comment",
  senderId: userId,
  relatedId: experienceId
}
```

---

### 3. **onFollowCreated**
**Ruta**: `users/{userId}/followers/{followerId}`

**Trigger**: Cuando alguien comienza a seguir a un usuario

**Lógica**:
- Obtiene nombre del seguidor
- Verifica preferencias (`enableFollows`)
- Envía: "[Usuario] comenzó a seguirte"

**Datos**:
```javascript
{
  type: "follow",
  senderId: followerId
}
```

---

### 4. **onRideInvitationCreated**
**Ruta**: `rides/{rideId}/invitations/{invitationId}`

**Trigger**: Cuando alguien invita a una rodada

**Lógica**:
- Obtiene información de la rodada
- Obtiene nombre del que invita
- Verifica preferencias (`enableRideInvitations`)
- Envía: "[Usuario] te invitó a [nombre rodada]"

**Datos**:
```javascript
{
  type: "ride_invitation",
  senderId: inviterId,
  relatedId: rideId
}
```

**Estructura esperada en Firestore**:
```javascript
// rides/{rideId}/invitations/{invitationId}
{
  inviterId: string,
  invitedUserId: string,
  timestamp: Timestamp
}
```

---

### 5. **onGroupInvitationCreated**
**Ruta**: `groups/{groupId}/invitations/{invitationId}`

**Trigger**: Cuando alguien invita a un grupo

**Lógica**:
- Obtiene información del grupo
- Obtiene nombre del que invita
- Verifica preferencias (`enableGroupInvitations`)
- Envía: "[Usuario] te invitó a unirte a [nombre grupo]"

**Datos**:
```javascript
{
  type: "group_invitation",
  senderId: inviterId,
  relatedId: groupId
}
```

**Estructura esperada en Firestore**:
```javascript
// groups/{groupId}/invitations/{invitationId}
{
  inviterId: string,
  invitedUserId: string,
  timestamp: Timestamp
}
```

---

### 6. **onStoryCreated**
**Ruta**: `stories/{storyId}`

**Trigger**: Cuando alguien publica una nueva historia

**Lógica**:
- Obtiene todos los seguidores del usuario
- Verifica preferencias de cada seguidor (`enableStories`)
- Envía a todos: "[Usuario] publicó una nueva historia"

**Datos**:
```javascript
{
  type: "story",
  senderId: userId
}
```

---

### 7. **sendRideReminders** (Scheduled)
**Schedule**: Cada 24 horas

**Trigger**: Cron job que se ejecuta diariamente

**Lógica**:
- Busca todas las rodadas que sean mañana
- Notifica a todos los participantes
- Verifica preferencias (`enableRideReminders`)
- Envía: "La rodada [nombre] es mañana a las [hora]"

**Datos**:
```javascript
{
  type: "ride_reminder",
  relatedId: rideId
}
```

**Estructura esperada en Firestore**:
```javascript
// rides/{rideId}
{
  title: string,
  date: Timestamp,
  time: string,
  participants: [userId1, userId2, ...]
}
```

---

### 8. **onGroupUpdate**
**Ruta**: `groups/{groupId}/posts/{postId}`

**Trigger**: Cuando hay una nueva publicación en un grupo

**Lógica**:
- Obtiene información del grupo
- Obtiene todos los miembros del grupo
- Verifica preferencias de cada miembro (`enableGroupUpdates`)
- Notifica a todos excepto al autor
- Envía: "[Usuario] publicó en el grupo"

**Datos**:
```javascript
{
  type: "group_update",
  senderId: userId,
  relatedId: groupId
}
```

**Estructura esperada en Firestore**:
```javascript
// groups/{groupId}
{
  name: string,
  members: [userId1, userId2, ...]
}

// groups/{groupId}/posts/{postId}
{
  userId: string,
  content: string,
  timestamp: Timestamp
}
```

---

## 🔐 Sistema de Preferencias

### Verificación de Configuración
Cada trigger verifica las preferencias del usuario antes de enviar:

```javascript
function isNotificationEnabled(userId, notificationType) {
  // Verifica users/{userId}/notificationSettings
  // O users/{userId} -> notificationSettings
}
```

### Campos de Preferencias
```javascript
{
  enablePushNotifications: boolean,  // Master switch
  enableLikes: boolean,
  enableComments: boolean,
  enableFollows: boolean,
  enableRideInvitations: boolean,
  enableGroupInvitations: boolean,
  enableStories: boolean,
  enableRideReminders: boolean,
  enableGroupUpdates: boolean,
  enableSystemNotifications: boolean
}
```

### Lógica de Verificación
1. Si `enablePushNotifications === false` → No enviar nada
2. Si tipo específico === false → No enviar ese tipo
3. Si no hay configuración → Enviar (default: habilitado)

---

## 📱 Envío de Notificaciones

### Función Principal: `sendNotificationToUser()`

**Parámetros**:
```javascript
{
  userId: string,          // Usuario destinatario
  notification: {
    title: string,         // Título de la notificación
    body: string,          // Cuerpo del mensaje
    type: string,          // Tipo de notificación
    senderId?: string,     // Usuario que genera la notificación
    relatedId?: string     // ID del recurso relacionado
  }
}
```

**Proceso**:
1. Verifica preferencias del usuario
2. Obtiene tokens FCM del usuario (`users/{userId}/fcmTokens`)
3. Guarda notificación en Firestore (`users/{userId}/notifications/{id}`)
4. Envía mensaje FCM a todos los tokens
5. Limpia tokens inválidos automáticamente

### Estructura de Notificación en Firestore
```javascript
// users/{userId}/notifications/{notificationId}
{
  title: string,
  body: string,
  type: string,
  senderId: string | null,
  relatedId: string | null,
  timestamp: Timestamp,
  read: boolean
}
```

---

## 🛠️ Despliegue

### Pre-requisitos
```bash
npm install -g firebase-tools
firebase login
```

### Instalar Dependencias
```bash
cd biux-cloud/functions
npm install
```

### Probar Localmente
```bash
firebase emulators:start --only functions
```

### Desplegar a Producción
```bash
# Todas las funciones
firebase deploy --only functions

# Una función específica
firebase deploy --only functions:onLikeCreated

# Varias funciones
firebase deploy --only functions:onLikeCreated,functions:onCommentCreated
```

### Ver Logs
```bash
firebase functions:log
```

---

## 📊 Monitoreo

### Firebase Console
1. Ve a **Firebase Console** → Tu Proyecto
2. **Functions** → Verás todas las funciones desplegadas
3. Click en cada función para ver:
   - Número de invocaciones
   - Tiempo de ejecución
   - Errores
   - Logs

### Logs en Tiempo Real
```bash
firebase functions:log --only onLikeCreated
```

---

## 🧪 Testing

### Probar Triggers Manualmente

#### 1. Simular Like
```javascript
// En Firebase Console → Firestore
// Agregar documento en:
experiences/{testExperienceId}/likes/{testLikeId}

{
  userId: "testUser123",
  timestamp: Timestamp.now()
}
```

#### 2. Simular Comentario
```javascript
experiences/{testExperienceId}/comments/{testCommentId}

{
  userId: "testUser123",
  text: "¡Qué buena rodada!",
  timestamp: Timestamp.now()
}
```

#### 3. Simular Seguidor
```javascript
users/{userId}/followers/{followerId}

{
  timestamp: Timestamp.now()
}
```

---

## 🐛 Solución de Problemas

### Notificaciones no llegan

**Verificar**:
1. ✅ Token FCM guardado en `users/{userId}/fcmTokens`
2. ✅ Preferencias de usuario habilitadas
3. ✅ Función deployada correctamente
4. ✅ Logs de errores en Firebase Console

**Comando para verificar**:
```bash
firebase functions:log --only onLikeCreated
```

### Tokens inválidos

**Solución**: La función limpia automáticamente tokens inválidos.

Para limpiar manualmente:
```javascript
// En Firebase Console → Firestore
users/{userId} → Editar
fcmTokens: [] // Vaciar array
```

### Función no se ejecuta

**Verificar**:
1. Estructura de Firestore correcta
2. Función desplegada: `firebase deploy --only functions`
3. Permisos de Firestore correctos

---

## 📈 Optimizaciones Futuras

### 1. **Batching de Notificaciones**
Agrupar múltiples notificaciones del mismo usuario:
```
"3 personas comentaron en tu publicación"
```

### 2. **Rate Limiting**
Evitar spam de notificaciones:
```javascript
// Máximo 1 notificación del mismo tipo cada 5 minutos
```

### 3. **Notificaciones Programadas**
Para eventos futuros:
```javascript
// Recordatorio 1 hora antes de una rodada
```

### 4. **Notificaciones Ricas**
Con imágenes y acciones:
```javascript
{
  imageUrl: string,
  actions: [
    { title: "Ver", action: "view" },
    { title: "Ignorar", action: "dismiss" }
  ]
}
```

### 5. **Analytics**
Tracking de notificaciones:
- Tasa de apertura
- Tiempo de respuesta
- Notificaciones más efectivas

---

## 📝 Estructura de Datos Requerida

### Collection: `users/{userId}`
```javascript
{
  username: string,
  fcmTokens: string[],
  notificationSettings: {
    enablePushNotifications: boolean,
    enableLikes: boolean,
    // ... resto de preferencias
  }
}
```

### Collection: `experiences/{experienceId}`
```javascript
{
  userId: string,
  content: string,
  // ... otros campos
}
```

### SubCollection: `experiences/{experienceId}/likes/{likeId}`
```javascript
{
  userId: string,
  timestamp: Timestamp
}
```

### SubCollection: `experiences/{experienceId}/comments/{commentId}`
```javascript
{
  userId: string,
  text: string,
  timestamp: Timestamp
}
```

### SubCollection: `users/{userId}/followers/{followerId}`
```javascript
{
  timestamp: Timestamp
}
```

### Collection: `rides/{rideId}`
```javascript
{
  title: string,
  date: Timestamp,
  time: string,
  participants: string[]
}
```

### SubCollection: `rides/{rideId}/invitations/{invitationId}`
```javascript
{
  inviterId: string,
  invitedUserId: string,
  timestamp: Timestamp
}
```

### Collection: `groups/{groupId}`
```javascript
{
  name: string,
  members: string[]
}
```

### SubCollection: `groups/{groupId}/invitations/{invitationId}`
```javascript
{
  inviterId: string,
  invitedUserId: string,
  timestamp: Timestamp
}
```

### SubCollection: `groups/{groupId}/posts/{postId}`
```javascript
{
  userId: string,
  content: string,
  timestamp: Timestamp
}
```

### Collection: `stories/{storyId}`
```javascript
{
  userId: string,
  mediaUrl: string,
  timestamp: Timestamp
}
```

---

## ✅ Checklist de Implementación

- [x] Crear `notifications.js` con todos los triggers
- [x] Actualizar `index.js` para exportar funciones
- [x] Implementar verificación de preferencias
- [x] Implementar limpieza automática de tokens
- [x] Documentar estructura de datos
- [ ] Desplegar funciones a Firebase
- [ ] Probar cada trigger manualmente
- [ ] Verificar logs en Firebase Console
- [ ] Configurar alertas de errores
- [ ] Agregar analytics de notificaciones

---

**Estado**: ✅ Backend completo y listo para desplegar
**Última actualización**: 22 de octubre de 2025
