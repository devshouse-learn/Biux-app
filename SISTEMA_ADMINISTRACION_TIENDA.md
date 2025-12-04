# 🛡️ Sistema de Administración de Tienda - Biux

## 📋 Descripción

La tienda de Biux ahora cuenta con un sistema de **control de acceso basado en roles** que permite que solo usuarios designados como **administradores** puedan subir productos a la tienda.

## 🔐 Control de Acceso

### Características de Seguridad:

1. **Solo Admins pueden subir productos**: El acceso al panel de administración (`/shop/admin`) está restringido a usuarios con el campo `isAdmin: true`.

2. **Validación en múltiples niveles**:
   - **UI Level**: El botón flotante "+" solo aparece para usuarios admin en la pantalla de tienda.
   - **Screen Level**: La pantalla AdminShopScreen valida permisos y muestra "Acceso Denegado" si el usuario no es admin.

3. **Mensaje de Acceso Denegado**: Si un usuario sin permisos intenta acceder al panel, verá:
   - 🚫 Icono de advertencia
   - Título: "Acceso Denegado"
   - Mensaje: "Solo los administradores designados pueden subir productos a la tienda."
   - Botón para volver

## 👤 Cómo Designar Administradores

### Método 1: Manualmente en Firebase Console (Recomendado)

1. Abre **Firebase Console**: https://console.firebase.google.com
2. Selecciona el proyecto: `biux-1576614678644`
3. Ve a **Firestore Database**
4. Navega a la colección: `users`
5. Busca el documento del usuario por su UID
6. Agrega o edita el campo:
   ```json
   {
     "isAdmin": true
   }
   ```
7. Guarda los cambios
8. El usuario ahora tiene permisos de administrador

### Método 2: Mediante Función de Cloud Functions (Futuro)

Puedes crear una Cloud Function para asignar permisos:

```javascript
// functions/index.js
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Verificar que quien llama sea super admin
  if (!context.auth || !context.auth.token.superAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Solo super admins pueden asignar roles'
    );
  }

  const userId = data.userId;
  
  // Actualizar Firestore
  await admin.firestore().collection('users').doc(userId).update({
    isAdmin: true
  });
  
  return { message: `Usuario ${userId} ahora es admin` };
});
```

### Método 3: Script de Migración Masiva

Si necesitas hacer múltiples usuarios admin a la vez:

```javascript
// scripts/assign-admins.js
const admin = require('firebase-admin');
admin.initializeApp();

const adminUsers = [
  'uid-usuario-1',
  'uid-usuario-2',
  'uid-usuario-3',
];

async function assignAdmins() {
  const batch = admin.firestore().batch();
  
  for (const uid of adminUsers) {
    const userRef = admin.firestore().collection('users').doc(uid);
    batch.update(userRef, { isAdmin: true });
  }
  
  await batch.commit();
  console.log(`${adminUsers.length} usuarios ahora son admins`);
}

assignAdmins();
```

## 📱 Experiencia de Usuario

### Para Usuarios Regulares:
- ✅ Pueden ver todos los productos en la tienda
- ✅ Pueden buscar productos
- ✅ Pueden comprar productos
- ✅ Pueden agregar al carrito
- ❌ **NO** ven el botón flotante "+" para agregar productos
- ❌ **NO** pueden acceder a `/shop/admin`

### Para Usuarios Admin:
- ✅ Todo lo que pueden hacer usuarios regulares
- ✅ Ven el botón flotante "+" en la pantalla de tienda
- ✅ Pueden acceder al panel de administración
- ✅ Pueden subir fotos y videos de productos
- ✅ Pueden crear, editar y eliminar productos
- ✅ Pueden buscar en sus propios productos

## 🔍 Estructura de Datos

### UserModel/UserEntity:
```dart
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "phoneNumber": "string",
  "isAdmin": false, // Por defecto false
  // ... otros campos
}
```

### Firestore Document (users collection):
```json
{
  "uid": "abc123...",
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "phoneNumber": "+573001234567",
  "isAdmin": true,  // ← Este campo determina si es admin
  "photoUrl": "https://...",
  "username": "juanperez"
}
```

## 🛠️ Archivos Modificados

### 1. AdminShopScreen
**Archivo**: `lib/features/shop/presentation/screens/admin_shop_screen.dart`

**Cambios**:
- ✅ Validación de sesión: Verifica que `currentUser != null`
- ✅ Validación de permisos: Verifica que `currentUser.isAdmin == true`
- ✅ Widget `_buildAccessDenied()` para mostrar mensaje de error
- ✅ Usa `context.watch<UserProvider>()` para reactividad

**Código clave**:
```dart
// Validación de permisos
if (currentUser == null) {
  return _buildAccessDenied(
    context,
    'Sesión no iniciada',
    'Debes iniciar sesión para acceder a esta sección.',
    Icons.login,
  );
}

final isAdmin = currentUser.isAdmin;
if (!isAdmin) {
  return _buildAccessDenied(
    context,
    'Acceso Denegado',
    'Solo los administradores designados pueden subir productos a la tienda.',
    Icons.admin_panel_settings_outlined,
  );
}
```

### 2. ShopScreen (Ya existía)
**Archivo**: `lib/features/shop/presentation/screens/shop_screen.dart`

**Validación existente**:
```dart
floatingActionButton: Consumer2<ShopProvider, UserProvider>(
  builder: (context, shopProvider, userProvider, child) {
    // Verificar si el usuario es admin
    final isAdmin = userProvider.user?.isAdmin ?? false;
    
    if (!isAdmin) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: () {
        context.push('/shop/admin');
      },
      // ...
    );
  },
),
```

## ✅ Testing

### Test Manual:

1. **Como Usuario Regular**:
   ```
   1. Iniciar sesión con usuario NO admin
   2. Ir a la tienda (/shop)
   3. Verificar que NO aparece el botón flotante "+"
   4. Intentar navegar a /shop/admin (URL directa)
   5. Debe mostrar "Acceso Denegado"
   ```

2. **Como Usuario Admin**:
   ```
   1. En Firebase Console, asignar isAdmin: true al usuario
   2. Cerrar sesión y volver a iniciar
   3. Ir a la tienda (/shop)
   4. Verificar que aparece el botón flotante "+"
   5. Hacer clic en "+"
   6. Debe abrir el panel de administración
   7. Poder crear/editar/eliminar productos
   ```

### Test de Seguridad:

1. **Intento de Bypass**:
   - Abrir consola del navegador
   - Intentar navegar directamente: `context.push('/shop/admin')`
   - Debe mostrar "Acceso Denegado" en pantalla

2. **Cambio de Sesión**:
   - Iniciar como admin
   - Abrir panel admin
   - Cerrar sesión (desde otra pestaña)
   - Refrescar pantalla
   - Debe mostrar "Sesión no iniciada"

## 🚀 Próximas Mejoras

### Sugerencias futuras:

1. **Niveles de Admin**:
   - Super Admin (puede asignar otros admins)
   - Admin Regular (solo puede subir productos)
   - Moderador (puede editar, no eliminar)

2. **Logs de Auditoría**:
   - Registrar quién creó/editó/eliminó productos
   - Timestamp de cambios
   - Historial de acciones

3. **Panel de Gestión de Admins**:
   - Pantalla para super admins
   - Ver lista de admins actuales
   - Asignar/revocar permisos desde la app

4. **Notificaciones**:
   - Notificar a admins cuando hay nuevos productos pendientes
   - Notificar cuando stock es bajo

## 📞 Contacto

Para más información sobre la administración de usuarios y permisos, contactar al equipo de desarrollo.

---

**Última actualización**: 4 de diciembre de 2025
**Versión**: 2.1.0 (Sistema de Roles implementado)
