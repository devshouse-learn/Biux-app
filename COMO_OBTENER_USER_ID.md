# 🔑 Cómo Obtener tu User ID de Firestore

## Método 1: Firebase Console (Más Fácil)

### Pasos:

1. **Abre Firebase Console:**
   ```
   https://console.firebase.google.com/project/biux-1576614678644/firestore/data
   ```

2. **Navega a la colección de usuarios:**
   - En el panel izquierdo, busca la colección: `usuarios` o `users`
   - Click en la colección

3. **Encuentra tu usuario:**
   - Busca tu documento de usuario (por email o nombre)
   - El ID del documento es tu `vendedorId`
   - Ejemplo: `GxK7nYm3RzP4QwXvTa9B` (este formato alfanumérico)

4. **Copia el ID:**
   - Click en el documento
   - Copia el "Document ID" que aparece arriba

---

## Método 2: Desde la App (Con print debug)

Si no tienes usuarios en Firestore aún, puedes crear uno temporal:

### Paso 1: Agregar print en AuthProvider

Abre: `lib/features/authentication/presentation/providers/auth_provider.dart`

Busca la función donde se carga el usuario y agrega:
```dart
print('🔑 TU USER ID ES: ${currentUser?.uid}');
```

### Paso 2: Ejecuta la app y inicia sesión

```bash
flutter run -d chrome
```

Después de iniciar sesión, revisa la consola de Flutter, verás:
```
🔑 TU USER ID ES: abc123xyz456
```

---

## Método 3: Crear Usuario Manualmente en Firestore

Si necesitas un usuario de prueba:

### Pasos en Firebase Console:

1. Ve a: Firestore Database > Data
2. Click "Start collection" (o si ya existe "usuarios", click ahí)
3. Collection ID: `usuarios`
4. Document ID: **Auto-ID** (deja que Firebase genere uno)
5. Agrega estos campos:

```json
{
  "uid": "EL_ID_QUE_GENERO_FIREBASE",
  "email": "admin@biux.com",
  "name": "Admin Biux",
  "username": "admin",
  "photoUrl": "",
  "userRole": "admin",
  "autorizadoPorAdmin": true,
  "isAdmin": true,
  "createdAt": "2025-12-13T10:00:00.000Z"
}
```

6. **IMPORTANTE:** El campo `uid` debe ser igual al Document ID que generó Firebase
7. Copia ese Document ID para usar como `vendedorId`

---

## Método 4: Obtener desde Authentication (Firebase Auth)

Si ya tienes usuarios autenticados:

1. Ve a Firebase Console
2. Authentication > Users
3. Busca tu usuario
4. Copia el "User UID"
5. Ese UID es tu `vendedorId`

---

## 💡 Ejemplo Práctico

Si tu User ID es: `X7mK9pLqR2tNvY4s`

Entonces en el script (`lib/scripts/seed_products.dart`):

```dart
const vendedorId = 'X7mK9pLqR2tNvY4s'; // ✅ Cambia esto
const vendedorNombre = 'Tienda Oficial Biux';
```

---

## 🚀 Una Vez que Tengas el ID

### Opción A: Usar el Script

```bash
# 1. Edita el script
code lib/scripts/seed_products.dart

# 2. Cambia la línea 20:
const vendedorId = 'TU_ID_AQUI'; // Pega tu ID real

# 3. Ejecuta
dart run lib/scripts/seed_products.dart
```

### Opción B: Creación Manual

1. Abre `PRODUCTOS_PRUEBA_FIRESTORE.md`
2. Reemplaza `TU_USER_ID_AQUI` con tu ID en cada JSON
3. Copia cada JSON en Firebase Console
4. Crea 8 documentos en la colección "productos"

---

## ✅ Verificación

Para verificar que todo está bien:

```dart
// En Firebase Console > Firestore
productos/
  ├─ [auto-id-1]/
  │   ├─ vendedorId: "X7mK9pLqR2tNvY4s"  ✅ Tu ID
  │   ├─ nombre: "Bicicleta Trek..."
  │   └─ ...
  ├─ [auto-id-2]/
  │   ├─ vendedorId: "X7mK9pLqR2tNvY4s"  ✅ Mismo ID
  │   └─ ...
```

Todos los productos deben tener el **mismo** `vendedorId`.

---

## 🐛 Problemas Comunes

### "No encuentro la colección usuarios"
**Causa:** Aún no hay usuarios en Firestore  
**Solución:** Usa Método 3 para crear uno manualmente

### "El vendedorId no coincide"
**Causa:** Usaste un ID incorrecto  
**Solución:** Verifica que el ID existe en `usuarios` collection

### "Permission denied"
**Causa:** Firebase rules bloquean escritura  
**Solución:** Temporalmente cambia las rules (ver abajo)

#### Firebase Rules Temporales (Solo para Testing):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ SOLO PARA DESARROLLO
    }
  }
}
```

**⚠️ RECUERDA:** Después de crear los productos, restaura las rules de producción.

---

## 📋 Checklist

- [ ] Obtuve mi User ID de Firestore
- [ ] Actualicé el script con mi ID real
- [ ] Ejecuté el script o creé los productos manualmente
- [ ] Verifiqué en Firebase Console que los productos existen
- [ ] Probé la tienda en Chrome (http://localhost:8080/#/store)
- [ ] Los productos se muestran correctamente

---

¿Listo? Ejecuta el script y disfruta tu tienda! 🎉
