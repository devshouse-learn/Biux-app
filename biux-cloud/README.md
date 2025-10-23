# 🚀 Biux Cloud Functions

Backend serverless para la aplicación Biux, implementado con Firebase Cloud Functions.

## 📋 Características

### ✅ Implementado

- **🔔 Sistema de Notificaciones Push**
  - 8 triggers automáticos para eventos de la app
  - Verificación de preferencias de usuario
  - Limpieza automática de tokens inválidos
  - Guardado de notificaciones en Firestore
  
- **🔐 Autenticación**
  - Generación de custom tokens para login con teléfono

### 🔄 Funciones de Notificación

| Función | Trigger | Descripción |
|---------|---------|-------------|
| `onLikeCreated` | Firestore | Cuando alguien da like a una publicación |
| `onCommentCreated` | Firestore | Cuando alguien comenta en una experiencia |
| `onFollowCreated` | Firestore | Cuando alguien sigue a un usuario |
| `onRideInvitationCreated` | Firestore | Cuando se invita a alguien a una rodada |
| `onGroupInvitationCreated` | Firestore | Cuando se invita a alguien a un grupo |
| `onStoryCreated` | Firestore | Cuando se publica una nueva historia |
| `sendRideReminders` | Scheduled (24h) | Recordatorios de rodadas próximas |
| `onGroupUpdate` | Firestore | Actualizaciones en grupos |

## 🛠️ Tecnologías

- **Node.js** v22
- **Firebase Admin SDK** v13.5.0
- **Firebase Functions** v6.4.0

## 📦 Instalación

### Pre-requisitos

```bash
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Autenticarse
firebase login
```

### Configurar Proyecto

```bash
# Navegar al directorio
cd biux-cloud/functions

# Instalar dependencias
npm install
```

## 🚀 Despliegue

### Opción 1: Script Automatizado (Recomendado)

```powershell
# Desde biux-cloud/
.\deploy.ps1
```

### Opción 2: Manual

```bash
# Desplegar todas las funciones
firebase deploy --only functions

# Desplegar función específica
firebase deploy --only functions:onLikeCreated

# Desplegar múltiples funciones
firebase deploy --only functions:onLikeCreated,functions:onCommentCreated
```

## 🧪 Testing Local

```bash
# Iniciar emuladores
firebase emulators:start --only functions

# En otra terminal, probar funciones
curl http://localhost:5001/biux-1576614678644/us-central1/createCustomToken \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+573001234567"}'
```

## 📊 Monitoreo

### Ver Logs en Tiempo Real

```bash
# Todos los logs
firebase functions:log

# Función específica
firebase functions:log --only onLikeCreated

# Solo errores
firebase functions:log --only onLikeCreated --only-errors
```

### Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona proyecto "biux"
3. **Functions** → Ver métricas y logs

## 📝 Estructura del Proyecto

```
biux-cloud/
├── functions/
│   ├── index.js              # Punto de entrada, exporta funciones
│   ├── notifications.js      # Lógica de notificaciones
│   ├── package.json         # Dependencias
│   └── node_modules/        # Paquetes instalados
├── .firebaserc              # Configuración del proyecto
├── firebase.json            # Configuración de despliegue
├── deploy.ps1               # Script de despliegue
├── BACKEND_NOTIFICACIONES.md # Documentación detallada
└── README.md                # Este archivo
```

## 🔧 Configuración

### Variables de Entorno

Las funciones usan la configuración por defecto de Firebase Admin SDK.

Para configuración personalizada:

```bash
firebase functions:config:set someservice.key="THE_KEY"
```

### Permisos de Firestore

Las funciones necesitan acceso de lectura/escritura a:
- `users/{userId}`
- `users/{userId}/notifications/{notificationId}`
- `experiences/{experienceId}`
- `experiences/{experienceId}/likes/{likeId}`
- `experiences/{experienceId}/comments/{commentId}`
- `users/{userId}/followers/{followerId}`
- `rides/{rideId}`
- `rides/{rideId}/invitations/{invitationId}`
- `groups/{groupId}`
- `groups/{groupId}/invitations/{invitationId}`
- `groups/{groupId}/posts/{postId}`
- `stories/{storyId}`

## 📖 Documentación Completa

Para más detalles sobre:
- Estructura de datos
- Lógica de cada trigger
- Sistema de preferencias
- Troubleshooting

Ver: [BACKEND_NOTIFICACIONES.md](./BACKEND_NOTIFICACIONES.md)

## 🐛 Solución de Problemas

### Error: "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### Error: "Not authenticated"
```bash
firebase login
```

### Error: "Deployment failed"
1. Verifica que estás en el proyecto correcto: `firebase use`
2. Comprueba permisos en Firebase Console
3. Revisa logs: `firebase functions:log`

### Notificaciones no llegan

**Checklist**:
- [ ] Funciones desplegadas correctamente
- [ ] Usuario tiene token FCM guardado
- [ ] Preferencias de notificaciones habilitadas
- [ ] Estructura de Firestore correcta
- [ ] Revisa logs de errores

## 🔄 Actualizar Funciones

```bash
# 1. Edita el código en functions/notifications.js
# 2. Despliega los cambios
firebase deploy --only functions

# O usa el script
.\deploy.ps1
```

## 📈 Métricas

Ver en Firebase Console:
- Número de invocaciones
- Tiempo de ejecución promedio
- Tasa de errores
- Uso de memoria

## 🤝 Contribuir

1. Crea una rama para tu feature
2. Haz tus cambios en `functions/`
3. Prueba localmente con emuladores
4. Despliega y verifica
5. Documenta cambios en este README

## 📞 Contacto

Para problemas o preguntas sobre el backend, revisa primero:
1. [BACKEND_NOTIFICACIONES.md](./BACKEND_NOTIFICACIONES.md)
2. Logs en Firebase Console
3. [Firebase Functions Docs](https://firebase.google.com/docs/functions)

---

**Proyecto**: Biux  
**Versión**: 1.0.0  
**Última actualización**: 22 de octubre de 2025
