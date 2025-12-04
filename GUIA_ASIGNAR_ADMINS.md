# 🎯 Guía Rápida: Asignar Administradores de Tienda

## 📋 Pasos Simples para Designar un Administrador

### Opción 1: Firebase Console (Lo más fácil) ⭐

1. **Abre Firebase Console**
   - Ve a: https://console.firebase.google.com
   - Proyecto: `biux-1576614678644`

2. **Navega a Firestore**
   - En el menú lateral: **Firestore Database**
   - Haz clic en la colección: `users`

3. **Encuentra el Usuario**
   - Busca el documento por UID o busca por nombre
   - Ejemplo: `uid_abc123...`

4. **Agrega el Campo isAdmin**
   - Haz clic en "Agregar campo" o edita si existe
   - Campo: `isAdmin`
   - Tipo: `boolean`
   - Valor: `true` ✅
   - Guarda

5. **¡Listo!** 🎉
   - El usuario ahora es administrador
   - Puede subir productos a la tienda
   - Verá el botón "+" en la tienda

---

## 🔍 ¿Cómo Saber Quién Puede Ser Admin?

### Usuarios Recomendados:
- ✅ Dueños de tiendas de bicicletas
- ✅ Vendedores verificados
- ✅ Personal de Biux
- ✅ Partners comerciales

### NO recomendado:
- ❌ Usuarios nuevos sin verificar
- ❌ Usuarios con reporte de spam
- ❌ Cuentas de prueba

---

## 🧪 Cómo Probar que Funciona

### Test Rápido:

**ANTES de hacer Admin:**
```
1. Usuario inicia sesión
2. Va a la tienda (/shop)
3. NO ve el botón flotante "+"
4. Si intenta ir a /shop/admin → "Acceso Denegado"
```

**DESPUÉS de hacer Admin:**
```
1. Usuario cierra sesión y vuelve a entrar
2. Va a la tienda (/shop)
3. ✅ Ve el botón flotante "+" (color naranja)
4. Hace clic en "+"
5. ✅ Se abre el panel de administración
6. ✅ Puede crear productos, subir fotos/videos
```

---

## 📊 Estructura del Campo en Firestore

```json
// Documento en users/{userId}
{
  "uid": "abc123xyz...",
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "phoneNumber": "+573001234567",
  "photoUrl": "https://...",
  "username": "juanperez",
  "isAdmin": true  // ← ESTE CAMPO ES LA CLAVE
}
```

---

## 🚨 Problemas Comunes

### Problema: "No veo el botón + después de cambiar isAdmin"
**Solución**: El usuario debe cerrar sesión y volver a iniciar para que se actualice el perfil.

### Problema: "El campo isAdmin no aparece en el documento"
**Solución**: 
1. En Firebase Console, asegúrate de estar en la colección `users`
2. Haz clic en el documento del usuario
3. Usa "Agregar campo" (botón + en la parte inferior)
4. Campo: `isAdmin`, Tipo: `boolean`, Valor: `true`

### Problema: "Agregué isAdmin pero sigue sin funcionar"
**Solución**:
1. Verifica que el tipo sea `boolean`, no `string`
2. Verifica que el valor sea `true`, no "true" (sin comillas)
3. El usuario debe cerrar sesión y volver a iniciar
4. Si persiste, revisa la consola del navegador por errores

---

## 📱 Capturas de Pantalla de Referencia

### Vista de Usuario Regular (NO Admin):
```
┌─────────────────────────┐
│     🛒 TIENDA           │
├─────────────────────────┤
│  [Buscar productos...]  │
│                         │
│  📦 Producto 1          │
│  📦 Producto 2          │
│  📦 Producto 3          │
│                         │
│  (NO hay botón +)       │
└─────────────────────────┘
```

### Vista de Usuario Admin:
```
┌─────────────────────────┐
│     🛒 TIENDA           │
├─────────────────────────┤
│  [Buscar productos...]  │
│                         │
│  📦 Producto 1          │
│  📦 Producto 2          │
│  📦 Producto 3          │
│                         │
│                    [+]  │ ← Botón flotante naranja
└─────────────────────────┘
```

### Pantalla de Acceso Denegado:
```
┌─────────────────────────────┐
│   Administrar Productos     │
├─────────────────────────────┤
│                             │
│          🚫                 │
│    (icono grande)           │
│                             │
│    Acceso Denegado          │
│                             │
│  Solo los administradores   │
│  designados pueden subir    │
│  productos a la tienda.     │
│                             │
│      [← Volver]             │
│                             │
└─────────────────────────────┘
```

---

## 💡 Tips Pro

### Para Revocar Permisos:
1. Ve al documento del usuario en Firestore
2. Cambia `isAdmin` a `false`
3. O elimina el campo completamente
4. Usuario pierde acceso inmediatamente

### Para Ver Todos los Admins:
1. En Firestore, colección `users`
2. Haz clic en "Filtros"
3. Campo: `isAdmin`
4. Operador: `==`
5. Valor: `true`
6. Ver lista de todos los admins

### Backup de Seguridad:
Antes de hacer cambios masivos:
```bash
# Exportar lista de admins actuales
firebase firestore:export gs://biux-backup/admins-backup
```

---

## 📞 Soporte

**¿Necesitas ayuda?**
- Revisa: `SISTEMA_ADMINISTRACION_TIENDA.md` (documentación completa)
- Contacta al equipo de desarrollo
- Reporta bugs en GitHub

---

**Fecha**: 4 de diciembre de 2025  
**Versión**: 2.1.0
