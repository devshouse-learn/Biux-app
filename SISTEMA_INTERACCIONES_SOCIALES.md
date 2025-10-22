# Sistema de Interacciones Sociales - Biux

## 📋 Índice
1. [Arquitectura General](#arquitectura-general)
2. [Estructura de Datos](#estructura-de-datos)
3. [Reglas de Seguridad](#reglas-de-seguridad)
4. [Casos de Uso](#casos-de-uso)
5. [Implementación en Flutter](#implementación-en-flutter)

---

## 🏗️ Arquitectura General

### Tecnología Base
- **Firebase Realtime Database** para datos en tiempo real
- **Cloud Firestore** para datos estructurados (usuarios, posts, rodadas)
- **Cloud Functions** para lógica del servidor (contadores, limpieza)

### Componentes Principales
1. **Notificaciones** - Sistema de alertas de interacciones
2. **Me Gusta** - Likes en posts, comentarios y stories
3. **Comentarios** - Comentarios anidados en posts y rodadas
4. **Asistentes** - Lista de participantes en rodadas

---

## 📊 Estructura de Datos

### 1. Notificaciones (`/notifications/{userId}/{notificationId}`)

```json
{
  "notifications": {
    "user123": {
      "notif_001": {
        "id": "notif_001",
        "type": "like_post",
        "fromUserId": "user456",
        "fromUserName": "Carlos Mendez",
        "fromUserPhoto": "https://...",
        "targetType": "post",
        "targetId": "post789",
        "targetPreview": "Mi mejor rodada...",
        "message": "le dio me gusta a tu publicación",
        "isRead": false,
        "createdAt": 1698765432000,
        "metadata": {
          "postPhoto": "https://..."
        }
      },
      "notif_002": {
        "id": "notif_002",
        "type": "comment_post",
        "fromUserId": "user789",
        "fromUserName": "Ana López",
        "fromUserPhoto": "https://...",
        "targetType": "post",
        "targetId": "post789",
        "targetPreview": "Mi mejor rodada...",
        "message": "comentó en tu publicación: \"Qué genial!\"",
        "isRead": false,
        "createdAt": 1698765433000,
        "metadata": {
          "commentText": "Qué genial!",
          "commentId": "comment_123"
        }
      },
      "notif_003": {
        "id": "notif_003",
        "type": "like_comment",
        "fromUserId": "user456",
        "fromUserName": "Carlos Mendez",
        "fromUserPhoto": "https://...",
        "targetType": "comment",
        "targetId": "comment_123",
        "targetPreview": "Excelente ruta!",
        "message": "le dio me gusta a tu comentario",
        "isRead": true,
        "createdAt": 1698765434000,
        "metadata": {
          "postId": "post789"
        }
      },
      "notif_004": {
        "id": "notif_004",
        "type": "reply_comment",
        "fromUserId": "user999",
        "fromUserName": "Pedro Silva",
        "fromUserPhoto": "https://...",
        "targetType": "comment",
        "targetId": "comment_123",
        "targetPreview": "Excelente ruta!",
        "message": "respondió a tu comentario: \"Totalmente de acuerdo\"",
        "isRead": false,
        "createdAt": 1698765435000,
        "metadata": {
          "replyText": "Totalmente de acuerdo",
          "replyId": "comment_456",
          "postId": "post789"
        }
      },
      "notif_005": {
        "id": "notif_005",
        "type": "like_story",
        "fromUserId": "user555",
        "fromUserName": "María Torres",
        "fromUserPhoto": "https://...",
        "targetType": "story",
        "targetId": "story_001",
        "message": "le dio me gusta a tu historia",
        "isRead": false,
        "createdAt": 1698765436000,
        "metadata": {
          "storyThumbnail": "https://..."
        }
      },
      "notif_006": {
        "id": "notif_006",
        "type": "ride_join",
        "fromUserId": "user777",
        "fromUserName": "Luis García",
        "fromUserPhoto": "https://...",
        "targetType": "ride",
        "targetId": "ride_001",
        "targetPreview": "Rodada Cerros Orientales",
        "message": "se unió a tu rodada",
        "isRead": false,
        "createdAt": 1698765437000,
        "metadata": {
          "rideDate": "2025-10-25"
        }
      },
      "notif_007": {
        "id": "notif_007",
        "type": "comment_ride",
        "fromUserId": "user888",
        "fromUserName": "Sandra Ruiz",
        "fromUserPhoto": "https://...",
        "targetType": "ride",
        "targetId": "ride_001",
        "targetPreview": "Rodada Cerros Orientales",
        "message": "comentó en tu rodada: \"A qué hora nos vemos?\"",
        "isRead": false,
        "createdAt": 1698765438000,
        "metadata": {
          "commentText": "A qué hora nos vemos?",
          "commentId": "comment_789"
        }
      }
    }
  }
}
```

**Tipos de Notificaciones:**
- `like_post` - Me gusta en publicación
- `like_comment` - Me gusta en comentario
- `like_story` - Me gusta en historia
- `comment_post` - Comentario en publicación
- `comment_ride` - Comentario en rodada
- `reply_comment` - Respuesta a comentario
- `ride_join` - Alguien se une a tu rodada
- `mention` - Mención en comentario
- `follow` - Nuevo seguidor

---

### 2. Me Gusta en Posts (`/likes/posts/{postId}/{userId}`)

```json
{
  "likes": {
    "posts": {
      "post789": {
        "user456": {
          "userId": "user456",
          "userName": "Carlos Mendez",
          "userPhoto": "https://...",
          "timestamp": 1698765432000
        },
        "user999": {
          "userId": "user999",
          "userName": "Pedro Silva",
          "userPhoto": "https://...",
          "timestamp": 1698765433000
        }
      }
    }
  }
}
```

**Metadata en Firestore** (`/posts/{postId}`):
```json
{
  "likesCount": 2,
  "lastLikedAt": 1698765433000
}
```

---

### 3. Me Gusta en Comentarios (`/likes/comments/{commentId}/{userId}`)

```json
{
  "likes": {
    "comments": {
      "comment_123": {
        "user456": {
          "userId": "user456",
          "userName": "Carlos Mendez",
          "userPhoto": "https://...",
          "timestamp": 1698765434000
        }
      }
    }
  }
}
```

**Metadata en Realtime Database** (`/comments/{postId}/{commentId}`):
```json
{
  "likesCount": 1
}
```

---

### 4. Me Gusta en Stories (`/likes/stories/{storyId}/{userId}`)

```json
{
  "likes": {
    "stories": {
      "story_001": {
        "user555": {
          "userId": "user555",
          "userName": "María Torres",
          "userPhoto": "https://...",
          "timestamp": 1698765436000,
          "expiresAt": 1698851836000
        }
      }
    }
  }
}
```

**Características especiales:**
- Los likes en stories expiran en 24 horas
- Se eliminan automáticamente con Cloud Functions

---

### 5. Comentarios en Posts (`/comments/posts/{postId}/{commentId}`)

```json
{
  "comments": {
    "posts": {
      "post789": {
        "comment_123": {
          "id": "comment_123",
          "userId": "user789",
          "userName": "Ana López",
          "userPhoto": "https://...",
          "text": "Qué genial! Me encanta esta ruta 🚴‍♀️",
          "createdAt": 1698765433000,
          "updatedAt": null,
          "likesCount": 5,
          "repliesCount": 2,
          "isEdited": false,
          "isDeleted": false,
          "parentCommentId": null,
          "mentions": ["user123"]
        },
        "comment_456": {
          "id": "comment_456",
          "userId": "user999",
          "userName": "Pedro Silva",
          "userPhoto": "https://...",
          "text": "Totalmente de acuerdo! @Ana López",
          "createdAt": 1698765435000,
          "updatedAt": null,
          "likesCount": 1,
          "repliesCount": 0,
          "isEdited": false,
          "isDeleted": false,
          "parentCommentId": "comment_123",
          "mentions": ["user789"]
        }
      }
    }
  }
}
```

**Metadata en Firestore** (`/posts/{postId}`):
```json
{
  "commentsCount": 2,
  "lastCommentedAt": 1698765435000
}
```

---

### 6. Comentarios en Rodadas (`/comments/rides/{rideId}/{commentId}`)

```json
{
  "comments": {
    "rides": {
      "ride_001": {
        "comment_789": {
          "id": "comment_789",
          "userId": "user888",
          "userName": "Sandra Ruiz",
          "userPhoto": "https://...",
          "text": "A qué hora nos vemos?",
          "createdAt": 1698765438000,
          "updatedAt": null,
          "likesCount": 0,
          "repliesCount": 1,
          "isEdited": false,
          "isDeleted": false,
          "parentCommentId": null,
          "mentions": []
        },
        "comment_790": {
          "id": "comment_790",
          "userId": "user123",
          "userName": "Organizador",
          "userPhoto": "https://...",
          "text": "@Sandra Ruiz A las 7am en el punto de encuentro",
          "createdAt": 1698765440000,
          "updatedAt": null,
          "likesCount": 2,
          "repliesCount": 0,
          "isEdited": false,
          "isDeleted": false,
          "parentCommentId": "comment_789",
          "mentions": ["user888"]
        }
      }
    }
  }
}
```

---

### 7. Asistentes a Rodadas (`/rides/attendees/{rideId}/{userId}`)

```json
{
  "rides": {
    "attendees": {
      "ride_001": {
        "user123": {
          "userId": "user123",
          "userName": "Juan Pérez",
          "userPhoto": "https://...",
          "fullName": "Juan Andrés Pérez",
          "bikeType": "MTB",
          "level": "intermediate",
          "joinedAt": 1698765420000,
          "status": "confirmed",
          "canEdit": true
        },
        "user777": {
          "userId": "user777",
          "userName": "Luis García",
          "userPhoto": "https://...",
          "fullName": "Luis Fernando García",
          "bikeType": "Road",
          "level": "advanced",
          "joinedAt": 1698765437000,
          "status": "confirmed",
          "canEdit": false
        }
      }
    }
  }
}
```

**Status posibles:**
- `confirmed` - Confirmado
- `maybe` - Tal vez
- `cancelled` - Canceló asistencia

**Metadata en Firestore** (`/rides/{rideId}`):
```json
{
  "attendeesCount": 2,
  "attendees": ["user123", "user777"]
}
```

---

### 8. Contador de No Leídas (`/notifications/unread/{userId}`)

```json
{
  "notifications": {
    "unread": {
      "user123": {
        "count": 5,
        "lastUpdated": 1698765438000
      }
    }
  }
}
```

---

## 🔒 Reglas de Seguridad

### Realtime Database Rules (`database.rules.json`)

```json
{
  "rules": {
    // ================== NOTIFICACIONES ==================
    "notifications": {
      "$userId": {
        // Solo el usuario puede leer sus propias notificaciones
        ".read": "auth != null && auth.uid === $userId",
        
        "$notificationId": {
          // Cualquier usuario autenticado puede crear notificaciones para otros
          ".write": "auth != null",
          
          // Validar estructura de notificación
          ".validate": "newData.hasChildren(['id', 'type', 'fromUserId', 'fromUserName', 'message', 'isRead', 'createdAt']) && 
                        newData.child('id').val() === $notificationId &&
                        newData.child('type').isString() &&
                        newData.child('fromUserId').isString() &&
                        newData.child('fromUserName').isString() &&
                        newData.child('message').isString() &&
                        newData.child('isRead').isBoolean() &&
                        newData.child('createdAt').isNumber()",
          
          // Campos obligatorios
          "id": { ".validate": "newData.val() === $notificationId" },
          "type": { 
            ".validate": "newData.isString() && 
                         (newData.val() === 'like_post' || 
                          newData.val() === 'like_comment' || 
                          newData.val() === 'like_story' ||
                          newData.val() === 'comment_post' ||
                          newData.val() === 'comment_ride' ||
                          newData.val() === 'reply_comment' ||
                          newData.val() === 'ride_join' ||
                          newData.val() === 'mention' ||
                          newData.val() === 'follow')"
          },
          "fromUserId": { ".validate": "newData.isString() && newData.val().length > 0" },
          "fromUserName": { ".validate": "newData.isString() && newData.val().length > 0" },
          "fromUserPhoto": { ".validate": "!newData.exists() || newData.isString()" },
          "targetType": { ".validate": "!newData.exists() || newData.isString()" },
          "targetId": { ".validate": "!newData.exists() || newData.isString()" },
          "targetPreview": { ".validate": "!newData.exists() || newData.isString()" },
          "message": { ".validate": "newData.isString() && newData.val().length > 0" },
          "isRead": { 
            ".validate": "newData.isBoolean() && (
                          // Nueva notificación debe ser false
                          (!data.exists() && newData.val() === false) ||
                          // Solo el propietario puede marcar como leída
                          (data.exists() && auth.uid === $userId)
                         )"
          },
          "createdAt": { ".validate": "newData.isNumber() && newData.val() <= now" },
          "metadata": { 
            ".validate": "!newData.exists() || newData.hasChildren()"
          },
          
          // No permitir otros campos
          "$other": { ".validate": false }
        }
      },
      
      // Contador de no leídas
      "unread": {
        "$userId": {
          ".read": "auth != null && auth.uid === $userId",
          ".write": "auth != null",
          
          "count": { ".validate": "newData.isNumber() && newData.val() >= 0" },
          "lastUpdated": { ".validate": "newData.isNumber()" },
          
          "$other": { ".validate": false }
        }
      }
    },
    
    // ================== ME GUSTA ==================
    "likes": {
      // Me gusta en posts
      "posts": {
        "$postId": {
          // Todos pueden leer los likes de un post
          ".read": "auth != null",
          
          "$userId": {
            // Solo el usuario puede dar/quitar su propio like
            ".write": "auth != null && auth.uid === $userId",
            
            // Validar estructura
            ".validate": "newData.hasChildren(['userId', 'timestamp']) &&
                         newData.child('userId').val() === $userId",
            
            "userId": { ".validate": "newData.val() === $userId" },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "timestamp": { ".validate": "newData.isNumber() && newData.val() <= now" },
            
            "$other": { ".validate": false }
          }
        }
      },
      
      // Me gusta en comentarios
      "comments": {
        "$commentId": {
          ".read": "auth != null",
          
          "$userId": {
            ".write": "auth != null && auth.uid === $userId",
            
            ".validate": "newData.hasChildren(['userId', 'timestamp']) &&
                         newData.child('userId').val() === $userId",
            
            "userId": { ".validate": "newData.val() === $userId" },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "timestamp": { ".validate": "newData.isNumber() && newData.val() <= now" },
            
            "$other": { ".validate": false }
          }
        }
      },
      
      // Me gusta en stories (expiran en 24h)
      "stories": {
        "$storyId": {
          ".read": "auth != null",
          
          "$userId": {
            ".write": "auth != null && auth.uid === $userId",
            
            ".validate": "newData.hasChildren(['userId', 'timestamp', 'expiresAt']) &&
                         newData.child('userId').val() === $userId &&
                         newData.child('expiresAt').val() <= newData.child('timestamp').val() + 86400000",
            
            "userId": { ".validate": "newData.val() === $userId" },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "timestamp": { ".validate": "newData.isNumber() && newData.val() <= now" },
            "expiresAt": { ".validate": "newData.isNumber()" },
            
            "$other": { ".validate": false }
          }
        }
      }
    },
    
    // ================== COMENTARIOS ==================
    "comments": {
      // Comentarios en posts
      "posts": {
        "$postId": {
          // Todos pueden leer comentarios
          ".read": "auth != null",
          
          "$commentId": {
            // Solo el autor puede editar/eliminar
            ".write": "auth != null && (
                       !data.exists() || 
                       data.child('userId').val() === auth.uid
                      )",
            
            // Validar estructura
            ".validate": "newData.hasChildren(['id', 'userId', 'userName', 'text', 'createdAt']) &&
                         newData.child('id').val() === $commentId &&
                         newData.child('text').val().length >= 1 &&
                         newData.child('text').val().length <= 500",
            
            "id": { ".validate": "newData.val() === $commentId" },
            "userId": { 
              ".validate": "newData.isString() && 
                           (!data.exists() && newData.val() === auth.uid || 
                            data.exists() && newData.val() === data.val())"
            },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "text": { 
              ".validate": "newData.isString() && 
                           newData.val().length >= 1 && 
                           newData.val().length <= 500"
            },
            "createdAt": { 
              ".validate": "newData.isNumber() && 
                           (!data.exists() && newData.val() <= now ||
                            data.exists() && newData.val() === data.val())"
            },
            "updatedAt": { ".validate": "!newData.exists() || newData.isNumber()" },
            "likesCount": { ".validate": "!newData.exists() || (newData.isNumber() && newData.val() >= 0)" },
            "repliesCount": { ".validate": "!newData.exists() || (newData.isNumber() && newData.val() >= 0)" },
            "isEdited": { ".validate": "!newData.exists() || newData.isBoolean()" },
            "isDeleted": { ".validate": "!newData.exists() || newData.isBoolean()" },
            "parentCommentId": { ".validate": "!newData.exists() || newData.isString()" },
            "mentions": { 
              ".validate": "!newData.exists() || newData.hasChildren()",
              "$mentionIndex": {
                ".validate": "newData.isString()"
              }
            },
            
            "$other": { ".validate": false }
          }
        }
      },
      
      // Comentarios en rodadas (misma estructura)
      "rides": {
        "$rideId": {
          ".read": "auth != null",
          
          "$commentId": {
            ".write": "auth != null && (
                       !data.exists() || 
                       data.child('userId').val() === auth.uid
                      )",
            
            ".validate": "newData.hasChildren(['id', 'userId', 'userName', 'text', 'createdAt']) &&
                         newData.child('id').val() === $commentId &&
                         newData.child('text').val().length >= 1 &&
                         newData.child('text').val().length <= 500",
            
            "id": { ".validate": "newData.val() === $commentId" },
            "userId": { 
              ".validate": "newData.isString() && 
                           (!data.exists() && newData.val() === auth.uid || 
                            data.exists() && newData.val() === data.val())"
            },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "text": { 
              ".validate": "newData.isString() && 
                           newData.val().length >= 1 && 
                           newData.val().length <= 500"
            },
            "createdAt": { 
              ".validate": "newData.isNumber() && 
                           (!data.exists() && newData.val() <= now ||
                            data.exists() && newData.val() === data.val())"
            },
            "updatedAt": { ".validate": "!newData.exists() || newData.isNumber()" },
            "likesCount": { ".validate": "!newData.exists() || (newData.isNumber() && newData.val() >= 0)" },
            "repliesCount": { ".validate": "!newData.exists() || (newData.isNumber() && newData.val() >= 0)" },
            "isEdited": { ".validate": "!newData.exists() || newData.isBoolean()" },
            "isDeleted": { ".validate": "!newData.exists() || newData.isBoolean()" },
            "parentCommentId": { ".validate": "!newData.exists() || newData.isString()" },
            "mentions": { 
              ".validate": "!newData.exists() || newData.hasChildren()",
              "$mentionIndex": {
                ".validate": "newData.isString()"
              }
            },
            
            "$other": { ".validate": false }
          }
        }
      }
    },
    
    // ================== ASISTENTES A RODADAS ==================
    "rides": {
      "attendees": {
        "$rideId": {
          // Todos pueden ver la lista de asistentes
          ".read": "auth != null",
          
          "$userId": {
            // Solo el usuario puede unirse/salirse
            ".write": "auth != null && auth.uid === $userId",
            
            // Validar estructura
            ".validate": "newData.hasChildren(['userId', 'userName', 'joinedAt', 'status']) &&
                         newData.child('userId').val() === $userId",
            
            "userId": { ".validate": "newData.val() === $userId" },
            "userName": { ".validate": "newData.isString()" },
            "userPhoto": { ".validate": "!newData.exists() || newData.isString()" },
            "fullName": { ".validate": "!newData.exists() || newData.isString()" },
            "bikeType": { ".validate": "!newData.exists() || newData.isString()" },
            "level": { 
              ".validate": "!newData.exists() || (
                           newData.isString() && 
                           (newData.val() === 'beginner' || 
                            newData.val() === 'intermediate' || 
                            newData.val() === 'advanced')
                          )"
            },
            "joinedAt": { ".validate": "newData.isNumber() && newData.val() <= now" },
            "status": { 
              ".validate": "newData.isString() && 
                           (newData.val() === 'confirmed' || 
                            newData.val() === 'maybe' || 
                            newData.val() === 'cancelled')"
            },
            "canEdit": { ".validate": "!newData.exists() || newData.isBoolean()" },
            
            "$other": { ".validate": false }
          }
        }
      }
    }
  }
}
```

---

## 🎯 Casos de Uso

### 1. Dar Me Gusta a un Post

**Flujo:**
1. Usuario da like en UI
2. Escribir en `/likes/posts/{postId}/{userId}`
3. Incrementar contador en Firestore `/posts/{postId}`
4. Crear notificación en `/notifications/{postAuthorId}/{notifId}`
5. Incrementar contador no leídas

**Código:**
```dart
Future<void> likePost(String postId, String postAuthorId) async {
  final userId = auth.currentUser!.uid;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  // 1. Agregar like en Realtime Database
  await realtimeDb.ref('likes/posts/$postId/$userId').set({
    'userId': userId,
    'userName': currentUser.userName,
    'userPhoto': currentUser.photo,
    'timestamp': timestamp,
  });
  
  // 2. Incrementar contador en Firestore
  await firestore.collection('posts').doc(postId).update({
    'likesCount': FieldValue.increment(1),
    'lastLikedAt': timestamp,
  });
  
  // 3. Si no es tu propio post, crear notificación
  if (postAuthorId != userId) {
    final notifId = 'notif_${timestamp}_$userId';
    await realtimeDb.ref('notifications/$postAuthorId/$notifId').set({
      'id': notifId,
      'type': 'like_post',
      'fromUserId': userId,
      'fromUserName': currentUser.userName,
      'fromUserPhoto': currentUser.photo,
      'targetType': 'post',
      'targetId': postId,
      'targetPreview': postPreview,
      'message': 'le dio me gusta a tu publicación',
      'isRead': false,
      'createdAt': timestamp,
      'metadata': {
        'postPhoto': postPhoto,
      },
    });
    
    // 4. Incrementar contador no leídas
    await realtimeDb.ref('notifications/unread/$postAuthorId').update({
      'count': ServerValue.increment(1),
      'lastUpdated': timestamp,
    });
  }
}
```

### 2. Comentar en un Post

**Flujo:**
1. Usuario escribe comentario
2. Detectar menciones (@usuario)
3. Crear comentario en `/comments/posts/{postId}/{commentId}`
4. Incrementar contador en Firestore
5. Crear notificación para autor del post
6. Crear notificaciones para usuarios mencionados

**Código:**
```dart
Future<void> commentOnPost(
  String postId,
  String postAuthorId,
  String text,
  String? parentCommentId,
) async {
  final userId = auth.currentUser!.uid;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final commentId = 'comment_${timestamp}_$userId';
  
  // Detectar menciones
  final mentions = _extractMentions(text);
  
  // 1. Crear comentario
  await realtimeDb.ref('comments/posts/$postId/$commentId').set({
    'id': commentId,
    'userId': userId,
    'userName': currentUser.userName,
    'userPhoto': currentUser.photo,
    'text': text,
    'createdAt': timestamp,
    'likesCount': 0,
    'repliesCount': 0,
    'isEdited': false,
    'isDeleted': false,
    'parentCommentId': parentCommentId,
    'mentions': mentions,
  });
  
  // 2. Incrementar contadores
  if (parentCommentId != null) {
    // Es una respuesta
    await realtimeDb.ref('comments/posts/$postId/$parentCommentId').update({
      'repliesCount': ServerValue.increment(1),
    });
  }
  
  await firestore.collection('posts').doc(postId).update({
    'commentsCount': FieldValue.increment(1),
    'lastCommentedAt': timestamp,
  });
  
  // 3. Notificar al autor del post
  if (postAuthorId != userId) {
    final notifId = 'notif_${timestamp}_${userId}_comment';
    await realtimeDb.ref('notifications/$postAuthorId/$notifId').set({
      'id': notifId,
      'type': parentCommentId != null ? 'reply_comment' : 'comment_post',
      'fromUserId': userId,
      'fromUserName': currentUser.userName,
      'fromUserPhoto': currentUser.photo,
      'targetType': 'post',
      'targetId': postId,
      'targetPreview': postPreview,
      'message': parentCommentId != null 
          ? 'respondió a tu comentario: "$text"'
          : 'comentó en tu publicación: "$text"',
      'isRead': false,
      'createdAt': timestamp,
      'metadata': {
        'commentText': text,
        'commentId': commentId,
      },
    });
  }
  
  // 4. Notificar a usuarios mencionados
  for (final mentionedUserId in mentions) {
    if (mentionedUserId != userId) {
      final notifId = 'notif_${timestamp}_${userId}_mention_$mentionedUserId';
      await realtimeDb.ref('notifications/$mentionedUserId/$notifId').set({
        'id': notifId,
        'type': 'mention',
        'fromUserId': userId,
        'fromUserName': currentUser.userName,
        'fromUserPhoto': currentUser.photo,
        'targetType': 'post',
        'targetId': postId,
        'message': 'te mencionó en un comentario',
        'isRead': false,
        'createdAt': timestamp,
        'metadata': {
          'commentText': text,
          'commentId': commentId,
        },
      });
    }
  }
}
```

### 3. Unirse a una Rodada

**Código:**
```dart
Future<void> joinRide(String rideId, String rideOrganizerId) async {
  final userId = auth.currentUser!.uid;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  // 1. Agregar a lista de asistentes
  await realtimeDb.ref('rides/attendees/$rideId/$userId').set({
    'userId': userId,
    'userName': currentUser.userName,
    'userPhoto': currentUser.photo,
    'fullName': currentUser.fullName,
    'bikeType': currentUser.bikeType,
    'level': currentUser.cyclingLevel,
    'joinedAt': timestamp,
    'status': 'confirmed',
    'canEdit': false,
  });
  
  // 2. Actualizar Firestore
  await firestore.collection('rides').doc(rideId).update({
    'attendeesCount': FieldValue.increment(1),
    'attendees': FieldValue.arrayUnion([userId]),
  });
  
  // 3. Notificar al organizador
  if (rideOrganizerId != userId) {
    final notifId = 'notif_${timestamp}_${userId}_join';
    await realtimeDb.ref('notifications/$rideOrganizerId/$notifId').set({
      'id': notifId,
      'type': 'ride_join',
      'fromUserId': userId,
      'fromUserName': currentUser.userName,
      'fromUserPhoto': currentUser.photo,
      'targetType': 'ride',
      'targetId': rideId,
      'targetPreview': rideTitle,
      'message': 'se unió a tu rodada',
      'isRead': false,
      'createdAt': timestamp,
      'metadata': {
        'rideDate': rideDate,
      },
    });
  }
}
```

---

## 📱 Implementación en Flutter

### Estructura de Carpetas

```
lib/
├── features/
│   ├── social/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── notifications_realtime_datasource.dart
│   │   │   │   ├── likes_realtime_datasource.dart
│   │   │   │   ├── comments_realtime_datasource.dart
│   │   │   │   └── attendees_realtime_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── notification_model.dart
│   │   │   │   ├── like_model.dart
│   │   │   │   ├── comment_model.dart
│   │   │   │   └── attendee_model.dart
│   │   │   └── repositories/
│   │   │       └── social_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── notification_entity.dart
│   │   │   │   ├── like_entity.dart
│   │   │   │   ├── comment_entity.dart
│   │   │   │   └── attendee_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── social_repository.dart
│   │   │   └── usecases/
│   │   │       ├── like_post_usecase.dart
│   │   │       ├── comment_post_usecase.dart
│   │   │       ├── get_notifications_usecase.dart
│   │   │       └── join_ride_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── notifications_provider.dart
│   │       │   ├── likes_provider.dart
│   │       │   ├── comments_provider.dart
│   │       │   └── attendees_provider.dart
│   │       ├── screens/
│   │       │   ├── notifications_screen.dart
│   │       │   ├── comments_screen.dart
│   │       │   └── attendees_list_screen.dart
│   │       └── widgets/
│   │           ├── notification_item.dart
│   │           ├── comment_item.dart
│   │           ├── like_button.dart
│   │           └── attendee_card.dart
```

---

## 🚀 Próximos Pasos

1. **Implementar modelos y entidades**
2. **Crear datasources de Realtime Database**
3. **Implementar providers con streams**
4. **Crear widgets de UI**
5. **Configurar Cloud Functions** para:
   - Limpiar likes de stories expiradas
   - Actualizar contadores automáticamente
   - Enviar push notifications
6. **Agregar índices en Realtime Database** para optimizar queries
7. **Implementar paginación** en comentarios y notificaciones
8. **Testing** de reglas de seguridad

---

## 📝 Notas Técnicas

### Performance
- Usar `limitToLast()` para paginación
- Cachear datos con Provider
- Usar `keepSynced(true)` para datos críticos

### Seguridad
- Todas las escrituras validadas
- Solo usuarios autenticados pueden interactuar
- Validación de longitud de textos
- Prevención de spam con rate limiting (Cloud Functions)

### Escalabilidad
- Contadores incrementales con `ServerValue.increment()`
- Índices compuestos en Firestore
- Limpieza periódica de datos antiguos
