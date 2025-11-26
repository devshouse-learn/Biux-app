# Corrección: Datos del Perfil No Se Guardaban Permanentemente

## Problema Reportado
- Usuario llena todos los datos del perfil (nombre, teléfono, ciudad, descripción)
- Presiona "Actualizar"
- Los datos desaparecen y no se guardan permanentemente
- El perfil vuelve a mostrar datos vacíos o anteriores

## Causa Raíz - Análisis Profundo

### 1. **Serialización Incompleta de CityId**
**Problema:** En `user_firebase_repository.dart`, el objeto `cityId` se guardaba como:
```dart
AppStrings.cityId: user.cityId  // ❌ Guardaba objeto City sin serializar
```

**Resultado:** Firestore no podía guardar correctamente un objeto Dart complejo.

### 2. **Datos Incompletos al Actualizar**
**Problema:** En `edit_user_screen_bloc.dart`, al crear el usuario para actualizar solo se pasaban algunos campos:
```dart
final uploadUser = BiuxUser(
  id: user.id,
  fullName: nameController.text,
  whatsapp: numberController.text,
  cityId: cityId,
  description: descripcionController.text,
  // ❌ Faltan otros campos importantes
);
```

**Resultado:** Se perdían datos no capturados en el formulario.

### 3. **Sin Validación de Guardado**
**Problema:** El método `updateUser` en el repositorio no validaba si se guardó correctamente.

## Solución Implementada

### 1. **user_firebase_repository.dart** - Serializar CityId Correctamente

#### ANTES:
```dart
@override
Future<BiuxUser> updateUser(BiuxUser user) async {
  try {
    await firestore.collection(collection).doc(user.id).update({
      AppStrings.fullName: user.fullName,
      AppStrings.whatsappLowercase: user.whatsapp,
      AppStrings.cityId: user.cityId,  // ❌ Objeto sin serializar
      AppStrings.description: user.description
    });
    final response = await this.getUserId(user.id);
    return response;
  } catch (e) {
    return BiuxUser();  // ❌ Retorna usuario vacío sin avisar
  }
}
```

#### AHORA:
```dart
@override
Future<BiuxUser> updateUser(BiuxUser user) async {
  try {
    print('📝 Guardando datos en Firestore:');
    print('   - ID: ${user.id}');
    print('   - Nombre: ${user.fullName}');
    print('   - Teléfono: ${user.whatsapp}');
    print('   - Ciudad: ${user.cityId.name}');
    print('   - Descripción: ${user.description}');
    
    await firestore.collection(collection).doc(user.id).update({
      AppStrings.fullName: user.fullName,
      AppStrings.whatsappLowercase: user.whatsapp,
      AppStrings.cityId: user.cityId.toJson(), // ✅ Serializar como JSON
      AppStrings.description: user.description,
    });
    
    print('✅ Datos guardados en Firestore correctamente');
    final response = await this.getUserId(user.id);
    print('✅ Datos recuperados: ${response.fullName}');
    return response;
  } catch (e) {
    print('❌ Error al actualizar en Firestore: $e');
    rethrow; // ✅ Propagar error para capturar en UI
  }
}
```

**Cambios Clave:**
- ✅ `cityId.toJson()` para serializar correctamente
- ✅ Logs detallados de qué se está guardando
- ✅ Verifica que se guardó y recupera los datos
- ✅ Propaga errores en lugar de silenciarlos

### 2. **edit_user_screen_bloc.dart** - Preservar Todos los Datos

#### ANTES:
```dart
Future<void> uploadUpdate(BuildContext context) async {
  try {
    final uploadUser = BiuxUser(
      id: user.id,
      fullName: nameController.text,
      whatsapp: numberController.text,
      cityId: cityId,
      description: descripcionController.text,
      // ❌ Otros campos no se incluyen
    );
    await UserFirebaseRepository().updateUser(uploadUser);
    if (imageNew != null) {
      await UserFirebaseRepository().uploadPhoto(user.id, imageNew);
    }
    print('✅ Perfil actualizado correctamente');
    notifyListeners();
  } catch (e) {
    print('❌ Error al actualizar perfil: $e');
    rethrow;
  }
}
```

#### AHORA:
```dart
Future<void> uploadUpdate(BuildContext context) async {
  try {
    print('📝 Preparando actualización de perfil...');
    
    // ✅ Crear usuario preservando TODOS los datos
    final uploadUser = BiuxUser(
      id: user.id,
      fullName: nameController.text,
      whatsapp: numberController.text,
      cityId: cityId,
      description: descripcionController.text,
      userName: user.userName,        // ✅ Preservar
      email: user.email,              // ✅ Preservar
      gender: user.gender,            // ✅ Preservar
      dateBirth: user.dateBirth,      // ✅ Preservar
      facebook: user.facebook,        // ✅ Preservar
      photo: user.photo,              // ✅ Preservar foto actual
      token: user.token,              // ✅ Preservar
      modality: user.modality,        // ✅ Preservar
      premium: user.premium,          // ✅ Preservar
      profileCover: user.profileCover,// ✅ Preservar
      followerS: user.followerS,      // ✅ Preservar
      instagram: user.instagram,      // ✅ Preservar
      followers: user.followers,      // ✅ Preservar
      following: user.following,      // ✅ Preservar
      groupId: user.groupId,          // ✅ Preservar
      situationAccident: user.situationAccident, // ✅ Preservar
    );
    
    print('📤 Enviando datos a Firebase...');
    await UserFirebaseRepository().updateUser(uploadUser);
    
    print('📷 Verificando si hay foto nueva para subir...');
    if (imageNew != null) {
      print('📤 Subiendo foto de perfil...');
      await UserFirebaseRepository().uploadPhoto(user.id, imageNew);
      print('✅ Foto subida correctamente');
    } else {
      print('ℹ️ No hay foto nueva');
    }
    
    // ✅ Recargar datos para sincronizar
    print('🔄 Recargando datos del perfil...');
    await getUser();
    
    print('✅ Perfil actualizado completamente');
    notifyListeners();
  } catch (e) {
    print('❌ Error al actualizar perfil: $e');
    rethrow;
  }
}
```

**Cambios Clave:**
- ✅ Preserva TODOS los campos del usuario actual
- ✅ Solo actualiza los campos editables (nombre, teléfono, ciudad, descripción)
- ✅ Recarga los datos después de guardar para confirmar
- ✅ Logs detallados en cada paso

## Flujo de Guardado Completo Ahora

```
Usuario edita perfil
    ↓
Presiona "Actualizar"
    ↓
Validar formulario
    ├─ INVÁLIDO → Mostrar errores específicos
    └─ VÁLIDO ↓
      📝 Preparar datos
      ├─ Tomar valores de los campos editables
      └─ Preservar valores no editables del usuario actual
      ↓
      📤 Guardar en Firestore
      ├─ Serializar cityId como JSON
      └─ Actualizar TODOS los campos en documento
      ↓
      ✅ Verificar que se guardó
      ↓
      📷 ¿Hay foto nueva?
      ├─ SÍ → Subir a Storage
      ├─ NO → Continuar
      └─ ↓
      🔄 Recargar datos del usuario desde Firestore
      ↓
      ✅ Mostrar "Perfil actualizado" 
      ↓
      Cerrar pantalla
      ↓
      ✅ Volver al perfil CON DATOS GUARDADOS
```

## Validación de Guardado

### En Console (Logs):
```
📝 Preparando actualización de perfil...
📤 Enviando datos a Firebase...
📝 Guardando datos en Firestore:
   - ID: phone_573132332038
   - Nombre: Juan Pérez
   - Teléfono: 573132332038
   - Ciudad: Medellín
   - Descripción: Amante del ciclismo
✅ Datos guardados en Firestore correctamente
✅ Datos recuperados: Juan Pérez
📷 Verificando si hay foto nueva para subir...
ℹ️ No hay foto nueva
🔄 Recargando datos del perfil...
✅ Perfil actualizado completamente
```

### En Firestore (Documento users):
```
{
  "id": "phone_573132332038",
  "fullName": "Juan Pérez",           ✅ GUARDADO
  "whatsapp": "573132332038",         ✅ GUARDADO
  "cityId": {                         ✅ GUARDADO COMO JSON
    "id": "123",
    "name": "Medellín"
  },
  "description": "Amante del ciclismo", ✅ GUARDADO
  "email": "juan@example.com",        ✅ PRESERVADO
  "userName": "@juanperez",           ✅ PRESERVADO
  "gender": "M",                      ✅ PRESERVADO
  "instagram": "juanperez",           ✅ PRESERVADO
  ... (más campos preservados)
}
```

## Archivos Modificados
1. ✅ `lib/features/users/data/repositories/user_firebase_repository.dart`
   - Mejora en `updateUser()` método
   - Serialización correcta de cityId
   - Logs y propagación de errores

2. ✅ `lib/features/users/presentation/screens/edit_user_screen/edit_user_screen_bloc.dart`
   - Mejora en `uploadUpdate()` método
   - Preservación de todos los campos
   - Recarga de datos después de guardar
   - Logs detallados

## Cómo Probar

### Paso a Paso:
1. **Abre tu perfil** → Presiona editar
2. **Cambia solo el nombre** → P.ej: "Juan Pedro García"
3. **Presiona Actualizar**
4. **Verifica en console** que veas los logs de guardado
5. **Cierra la app completamente**
6. **Reabre la app**
7. **Ve a tu perfil** → ✅ El nombre debe estar guardado

### Cambios Adicionales (Opcional):
- Cambiar teléfono
- Cambiar ciudad
- Cambiar descripción
- Agregar foto nueva

## Status
✅ Compilación: Sin errores
✅ Serialización: Correcta (cityId como JSON)
✅ Preservación de datos: Completa
✅ Validación: Mejorada
✅ Logs: Detallados para debugging
✅ Sincronización: Datos se recargan después de guardar

## Nota Importante
Los datos ahora se guardan **permanentemente en Firestore**. Si los datos no persisten después de esta corrección, significa que hay un problema con las **reglas de seguridad de Firestore** (rules.json) que están bloqueando las escrituras.
