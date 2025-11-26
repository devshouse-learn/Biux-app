# Cambio: Foto de Perfil Opcional en Registro y Edición de Usuario

## Descripción del Cambio
Se confirmó y documentó que la foto de perfil es **OPCIONAL** en la pantalla de edición de usuario. Los usuarios pueden completar su perfil sin subir una foto, si así lo desean.

## Archivos Modificados

### 1. `/lib/features/users/presentation/screens/edit_user_screen/edit_user_screen.dart`

**Cambio realizado:**
- Mejorado el mensaje de error cuando la validación falla
- Antes: `''` (vacío) si pasaba todas las validaciones específicas
- Después: `'Por favor completa todos los campos obligatorios'` como fallback

**Validaciones del Formulario (Obligatorias):**
1. ✅ **Nombre completo** - Obligatorio
2. ✅ **Número de teléfono** - Obligatorio
3. ✅ **Ciudad** - Obligatoria
4. ✅ **Descripción** - Obligatoria

**Elemento OPCIONAL:**
- ❌ **Foto de perfil** - NO REQUERIDA

### 2. `/lib/features/users/presentation/widgets/profile_image_picker.dart`

**Cambio realizado:**
- Agregado comentario de documentación indicando que la foto es opcional
- Comentario: `/// La foto es OPCIONAL - el usuario puede dejar su perfil sin foto`

## Lógica de Guardado

En el BLoC (`edit_user_screen_bloc.dart`):

```dart
Future<void> uploadUpdate(BuildContext context) async {
  final uploadUser = BiuxUser(
    id: user.id,
    fullName: nameController.text,
    whatsapp: numberController.text,
    cityId: cityId,
    description: descripcionController.text,
  );
  await UserFirebaseRepository().updateUser(uploadUser);
  
  // La foto solo se sube si el usuario la seleccionó
  if (imageNew != null)
    await UserFirebaseRepository().uploadPhoto(user.id, imageNew);
  
  notifyListeners();
}
```

## Impacto en la Funcionalidad

### ✅ Cambios en el Código
- **Validaciones mejoradas** - Mejor feedback de error
- **Documentación clara** - Comentario sobre opción de foto
- **Sin cambios en lógica** - Foto ya era opcional, solo documentamos

### ✅ Flujo de Usuario

1. **Llenar formulario:**
   - Nombre completo ← Requerido
   - Nombre de usuario ← Solo lectura (editable en pantalla separada)
   - Número teléfono ← Requerido
   - Ciudad ← Requerido
   - Descripción ← Requerido
   - Foto ← OPCIONAL (puede saltarla)

2. **Guardar perfil:**
   - Se valida que todos los campos obligatorios estén completos
   - Si la foto fue seleccionada, se sube a Firebase Storage
   - Si NO fue seleccionada, se guarda el perfil sin foto

3. **Resultado:**
   - Usuario con perfil sin foto → Ver emoji 🚫 en drawer
   - Usuario con perfil con foto → Ver emoji 📸 en drawer

## Flujo Completo de Visualización

**En el Drawer (app_drawer.dart):**
```dart
accountEmail: Text(
  (user?.email ?? currentUser?.phoneNumber ?? 'Sin email') +
      ' ${user?.photoUrl != null ? '📸' : '🚫'}',
  // Si tiene foto → 📸
  // Si no tiene foto → 🚫
),
currentAccountPicture:
    user?.photoUrl != null && user!.photoUrl!.isNotEmpty
        ? CachedNetworkImage(imageUrl: user.photoUrl!)
        : CircleAvatar(
            child: Icon(Icons.person),  // Icono por defecto
          ),
```

## Beneficios

✅ Mayor flexibilidad para usuarios
✅ Usuarios pueden registrarse rápidamente
✅ No se requiere foto de perfil
✅ Foto se puede agregar después si lo desean
✅ Código ya lo soportaba, solo documentamos

## Notas Técnicas

- La foto se almacena en Firebase Storage en `users/{userId}/profile_photo`
- El campo `photoUrl` en Firestore es nullable
- Si no hay foto, se muestra un Icon(Icons.person) por defecto
- En el drawer se diferencia con emoji: 📸 (con foto) vs 🚫 (sin foto)

## Cambios en Validación

**ANTES:**
```dart
content: bloc.nameController.text.isEmpty
    ? AppStrings.fullNameIsEmpty
    : bloc.numberController.text.isEmpty
    ? AppStrings.numberIsEmpty
    : bloc.cityController.text.isEmpty
    ? AppStrings.cityIsEmpty
    : bloc.descripcionController.text.isEmpty
    ? AppStrings.descritionIsEmpty
    : '',  // ← Vacío si todo está bien (confuso)
```

**DESPUÉS:**
```dart
content: bloc.nameController.text.isEmpty
    ? AppStrings.fullNameIsEmpty
    : bloc.numberController.text.isEmpty
    ? AppStrings.numberIsEmpty
    : bloc.cityController.text.isEmpty
    ? AppStrings.cityIsEmpty
    : bloc.descripcionController.text.isEmpty
    ? AppStrings.descritionIsEmpty
    : 'Por favor completa todos los campos obligatorios',
    // ← Mensaje más claro como fallback
```

## Próximos Pasos Opcionales

Si quieres mejorar más esto:
1. Agregar texto "Foto (opcional)" en la UI del ProfileImagePicker
2. Mostrar un mensaje "Puedes agregar una foto posteriormente"
3. Agregar un botón "Omitir foto" explícito
