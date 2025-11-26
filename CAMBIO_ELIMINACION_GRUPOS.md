# Cambio: Eliminación de "Grupos" y "Mis Grupos" del Menú

## Descripción del Cambio
Se removieron completamente las opciones "Grupos" y "Mis Grupos" del menú principal (AppDrawer). Los usuarios ya no verán estas opciones en el menú lateral.

## Archivo Modificado

### `/lib/shared/widgets/app_drawer.dart`

**Cambios realizados:**

Se removieron dos ListTiles completos:

#### 1. ListTile "Grupos" (REMOVIDO)
```dart
// REMOVIDO:
ListTile(
  leading: Icon(
    Icons.group,
    color: Theme.of(context).iconTheme.color,
  ),
  title: Text('Grupos'),
  onTap: () {
    Navigator.pop(context);
    context.go(AppRoutes.groupList);
  },
),
```

#### 2. ListTile "Mis Grupos" (REMOVIDO)
```dart
// REMOVIDO:
ListTile(
  leading: Icon(
    Icons.group_work,
    color: Theme.of(context).iconTheme.color,
  ),
  title: Text('Mis Grupos'),
  onTap: () {
    Navigator.pop(context);
    context.go(AppRoutes.myGroups);
  },
),
```

## Orden del Menú Actual (después de este cambio)

1. **Perfil** - Icono de usuario
2. [Divisor]
3. **Configuración** - Icono de engranaje
4. **Ayuda** - Icono de signo de interrogación (ayuda)
5. [Más opciones...]

## Impacto

### ✅ Cambios en el Código
- **Eliminación:** 2 ListTiles removidos (~30 líneas de código)
- **Parámetros:** 2 rutas removidas (AppRoutes.groupList y AppRoutes.myGroups)
- **Imports:** Se mantiene app_routes.dart (aún usado por otras opciones)
- **Estructura del menú:** Simplificada y más limpia

### ✅ Verificación
- **Sin errores de compilación** - Verificado con `get_errors`
- **Imports intactos** - app_routes.dart aún necesario
- **Estructura de UI** - Mantiene coherencia visual

## Notas
- El import de `app_routes.dart` se mantiene ya que es usado en Perfil y Configuración
- El divisor (Divider) se mantiene para separación visual
- La funcionalidad de grupos no está más accesible desde el menú
