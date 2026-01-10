# Configuración de Administradores

## Cómo configurarte como administrador

### Paso 1: Obtener tu UID

1. Inicia sesión en la app
2. Ve al **Perfil** o abre la **Consola del Navegador** (F12 en Chrome)
3. Busca en los logs un mensaje que diga: **"🔐 TU UID ES: ..."**
4. Copia ese UID completo

### Paso 2: Agregar tu UID a la lista de administradores

1. Abre el archivo: `lib/shared/services/user_service.dart`
2. Busca la constante `ADMIN_UIDS` (línea ~15)
3. Agrega tu UID a la lista:

```dart
static const List<String> ADMIN_UIDS = [
  'TU_UID_AQUI', // Tu número de teléfono o UID
  // Puedes agregar más administradores aquí
];
```

### Paso 3: Recompilar y recargar

```bash
flutter build web --release
cd build/web && python3 -m http.server 8080
```

### Paso 4: Verificar permisos

Una vez que hayas agregado tu UID y recompilado:

1. Cierra sesión y vuelve a iniciar sesión
2. Deberías ver en los logs: **"✅ Usuario promovido a ADMINISTRADOR"**
3. En la **Tienda** verás:
   - Botón flotante naranja **"+"** para agregar productos
   - Opciones adicionales en el menú (Gestionar Vendedores, Eliminar Productos)

## Autorizar a otros usuarios para vender

Como administrador, puedes autorizar a otros usuarios:

1. Ve a la **Tienda**
2. Haz clic en el **menú de 3 puntos** (arriba a la derecha)
3. Selecciona **"Gestionar Vendedores"**
4. Activa el switch de **"Puede vender productos"** para cada usuario
5. Los usuarios autorizados verán el botón **"+"** en la tienda

## Permisos y Roles

### Administrador (`isAdmin: true`)
- ✅ Puede subir/agregar productos
- ✅ Puede autorizar vendedores
- ✅ Puede eliminar todos los productos
- ✅ Acceso al panel de administración
- ✅ Ve opciones exclusivas en menús

### Vendedor Autorizado (`canSellProducts: true`)
- ✅ Puede subir/agregar productos
- ❌ NO puede autorizar otros vendedores
- ❌ NO puede eliminar todos los productos
- ✅ Ve el botón "+" en la tienda

### Usuario Regular
- ❌ NO puede subir productos
- ✅ Puede comprar y ver productos
- ✅ Puede dar "me gusta" a productos
- ✅ Puede agregar al carrito

## Dónde buscar tu UID

Tu UID se imprime automáticamente en los logs cuando:
- Inicias sesión
- Cargas tu perfil
- La app verifica tus permisos

**Ejemplo de log:**
```
🔐 TU UID ES: +573001234567
🔐 COPIA ESTE UID Y AGRÉGALO A ADMIN_UIDS EN user_service.dart
```

## Solución de problemas

### No veo el botón "+" en la tienda
1. Verifica que tu UID esté en `ADMIN_UIDS`
2. Cierra sesión y vuelve a iniciar
3. Revisa los logs para ver "✅ Usuario promovido a ADMINISTRADOR"

### Los cambios no se aplican
1. Asegúrate de haber guardado `user_service.dart`
2. Recompila la app con `flutter build web --release`
3. Recarga completamente el navegador (Ctrl+Shift+R)

### Quiero quitar permisos de admin
1. Elimina el UID de la lista `ADMIN_UIDS`
2. Recompila la app
3. El usuario dejará de tener permisos de admin en el siguiente inicio de sesión
