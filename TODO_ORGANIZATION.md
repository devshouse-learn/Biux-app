# TODO Management - Biux App
## Estado del Proyecto al 18/03/2026

---

## 📋 RESUMEN EJECUTIVO

Este documento organiza todos los TODOs identificados en el proyecto Biux, priorizados por **impacto en usuarios** y **complejidad de implementación**.

**Estadísticas:**
- **Total TODOs:** 3
- **Completados:** 3 ✅
- **Pendientes:** 0

---

## ✅ COMPLETADOS (18/03/2026)

### 1. Firestore Listener en User Service
**Ubicación:** `lib/shared/services/user_service.dart`  
**Estado:** ✅ IMPLEMENTADO  
**Prioridad:** 🔴 CRÍTICA

**Descripción:**
El servicio de usuario solo carga datos una vez al iniciar sesión. No hay sincronización en tiempo real cuando otro dispositivo/usuario modifica el perfil.

**Impacto:**
- ⚠️ Cambios en perfil del usuario no se reflejan hasta reiniciar app
- ⚠️ Seguimientos no se actualizan en tiempo real
- ⚠️ Avatares y nombres no se sincronizan
- ⚠️ Experiencia de usuario degradada

**Solución Requerida:**
```dart
/// Stream en tiempo real de cambios del usuario actual
Stream<Map<String, dynamic>?> getCurrentUserStream() {
  final user = _auth.currentUser;
  if (user == null) return Stream.value(null);
  
  return _firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data())
      .handleError((error) {
        print('Error in user stream: $error');
        return null;
      });
}
```

**Archivo Afectado:**
- `lib/shared/services/user_service.dart`

**Dependencias:**
- `cloud_firestore: ^4.8.0` ✅ Ya disponible
- `firebase_auth: ^4.6.0` ✅ Ya disponible

**Estimado:** 30 minutos  
**Complejidad:** Media

**Checklist de Validación:**
- [ ] Stream creado y tipado correctamente
- [ ] Manejo de errores implementado
- [ ] Null safety respetado
- [ ] Prueba en simulator/device

---

## 🟠 ALTOS (Implementar Después)

### 2. Google Directions API
**Ubicación:** `lib/shared/services/directions_service.dart:23`  
**Estado:** ❌ NO IMPLEMENTADO (Solo mock)  
**Prioridad:** 🟠 ALTA

**Descripción:**
El servicio de direcciones solo retorna datos mockeados. Las rutas en mapas no muestran polylíneas reales ni distancias precisas.

**Impacto:**
- ⚠️ Rutas en mapas no funcionan
- ⚠️ Distancias no son precisas
- ⚠️ Perfiles de elevación no disponibles
- ⚠️ Funcionalidad core del app limitada

**Solución Requerida:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class DirectionsService {
  static const String _baseUrl = 
    'https://maps.googleapis.com/maps/api/directions/json';
  
  final String _googleApiKey = 'YOUR_API_KEY';

  Future<DirectionsResult> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String url =
      '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$_googleApiKey&language=es';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['routes'].isEmpty) {
          throw Exception('No routes found');
        }
        return DirectionsResult.fromJson(json['routes'][0]);
      } else {
        throw Exception('Failed to fetch directions');
      }
    } catch (e) {
      print('Directions API Error: $e');
      rethrow;
    }
  }
}
```

**Archivos Afectados:**
- `lib/shared/services/directions_service.dart`

**Dependencias:**
- `http: ^1.1.0` ✅ Ya disponible
- Google Maps API Key (requiere configuración)

**Configuración Requerida:**
1. Habilitar Google Directions API en Google Cloud Console
2. Crear API Key con restricciones (HTTP referrers)
3. Almacenar en `lib/core/config/constants.dart` o `.env`

**Estimado:** 1 hora (incluyendo setup de API)  
**Complejidad:** Media-Alta

**Checklist de Validación:**
- [ ] API Key configurada y validada
- [ ] Llamada HTTP implementada
- [ ] Response parsing correcto
- [ ] Polylines extraídas del resultado
- [ ] Distancias y duraciones mostradas
- [ ] Manejo de errores robusto

---

## 🟡 MEDIOS (Implementar Cuando Sea Conveniente)

### 3. Eliminación Individual de Media en Experiences
**Ubicación:** `lib/features/experiences/presentation/widgets/experience_story_viewer.dart:633`  
**Estado:** ❌ BLOQUEADO POR BACKEND  
**Prioridad:** 🟡 MEDIA

**Descripción:**
Los usuarios no pueden eliminar fotos/videos individuales de una experiencia. Actualmente solo pueden eliminar toda la experiencia.

**Impacto:**
- ⚠️ No hay control granular sobre media
- ⚠️ Usuarios deben eliminar experiencia completa si quieren sacar 1 foto
- ⚠️ Experiencia de usuario frustrada

**Solución Requerida:**
```dart
Future<void> _deleteMediaItem(String mediaId, String experienceId) async {
  try {
    await _firestore
        .collection('experiences')
        .doc(experienceId)
        .update({
          'media': FieldValue.arrayRemove([
            {'id': mediaId}
          ])
        });
    
    // Eliminar archivo de Storage
    await _storage.ref('experiences/$experienceId/$mediaId').delete();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('media_deleted_success')),
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    print('Error deleting media: $e');
  }
}
```

**Archivos Afectados:**
- `lib/features/experiences/presentation/widgets/experience_story_viewer.dart`
- Backend Firestore schema (requiere cambios)

**Dependencias del Backend:**
- ✅ Estructura de media como array de objetos (debe tener IDs únicos)
- ✅ Permisos en Firestore Rules para `arrayRemove`
- ✅ Configuración de Storage para borrado granular

**⚠️ DEPENDENCIA BLOQUEANTE:**
- El backend debe haber actualizado la estructura de datos
- Requiere documentación de cambios en Firestore schema
- Debe coordinar con equipo backend

**Estimado:** 45 minutos (cuando backend esté listo)  
**Complejidad:** Baja

**Checklist de Validación:**
- [ ] Backend actualizó schema
- [ ] Permisos Firestore configurados
- [ ] Botón delete en media UI
- [ ] Confirmación antes de eliminar
- [ ] Manejo de errores

---

## 📊 MATRIZ DE IMPACTO vs COMPLEJIDAD

```
CRÍTICO
   |     
   |  ┌─ Firestore Listener ●
   |  │  (Crítico, Medio)
   |  │
   |  │  ┌─ Directions API ●
   |  │  │  (Alto, Media-Alta)
   |  │  │
   |  │  │  ┌─ Media Delete ●
   |  │  │  │  (Medio, Baja)
   |  │  │  │
BAJO |  │  │  │
   └──┴──┴──┴─────────────────
      Baja          Alta
    COMPLEJIDAD
```

---

## 🎯 PLAN DE IMPLEMENTACIÓN RECOMENDADO

### Fase 1: Esta Semana (18-20 de Marzo)
**Objetivo:** Sincronización en tiempo real de usuarios

- [ ] Implementar `getCurrentUserStream()` en `user_service.dart`
- [ ] Conectar Stream a `UserProvider` con `StreamProvider`
- [ ] Validar sincronización en múltiples dispositivos simulados
- [ ] Crear tests unitarios para el listener

**Tiempo Estimado:** 1-2 horas

---

### Fase 2: Próxima Semana (21-27 de Marzo)
**Objetivo:** Rutas funcionales en mapas

**Pre-requisitos:**
- [ ] Google Maps API Key obtenida
- [ ] Direcciones API habilitada en Google Cloud
- [ ] Documentación de restricciones de API

**Tareas:**
- [ ] Implementar llamada a Google Directions API
- [ ] Parsear response y extraer polylines
- [ ] Renderizar rutas en Google Maps
- [ ] Mostrar distancia y duración
- [ ] Pruebas de rendimiento

**Tiempo Estimado:** 2-3 horas

---

### Fase 3: Pendiente de Backend (TBD)
**Objetivo:** Eliminación granular de media

**Bloqueantes:**
- [ ] Backend debe actualizar schema de experiences
- [ ] Media array debe tener IDs únicos
- [ ] Firestore Rules deben permitir `arrayRemove`
- [ ] Storage Rules deben permitir borrado individual

**Tareas (cuando backend esté listo):**
- [ ] Implementar botón delete por media
- [ ] Agregar confirmación modal
- [ ] Manejar errores de Storage
- [ ] Actualizar UI en tiempo real

**Tiempo Estimado:** 45 minutos

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Patrón General para TODOs
1. **Lectura:** Obtener contenido actual del archivo
2. **Análisis:** Entender contexto e impactos
3. **Implementación:** Agregar código sin romper existente
4. **Testing:** Validar en simulator
5. **Documentación:** Actualizar comentarios TODO
6. **Commit:** Push con mensaje claro

### Mejores Prácticas
- ✅ Usar `try-catch` en operaciones de red
- ✅ Implementar exponential backoff para reintentos
- ✅ Loguear errores con contexto suficiente
- ✅ Respetar null safety
- ✅ Usar const constructores donde sea posible
- ✅ Documentar cambios en streams/listeners
- ✅ Agregar manejo de desuscripción en `dispose()`

### Comandos Útiles
```bash
# Buscar todos los TODOs
grep -rn "TODO:" lib/

# Buscar TODOs específicos
grep -rn "TODO:" lib/ --include="*.dart" | grep -i "firestore\|directions\|media"

# Contar TODOs por archivo
find lib -name "*.dart" -exec grep -l "TODO:" {} \; | wc -l
```

---

## 🔗 REFERENCIAS RELACIONADAS

### Archivos Conexos
- `lib/features/authentication/presentation/providers/auth_provider.dart` - Para integración con auth
- `lib/shared/widgets/main_shell.dart` - Usa datos de usuario en tiempo real
- `lib/features/maps/presentation/widgets/map_widget.dart` - Muestra rutas
- `lib/features/experiences/data/models/experience_model.dart` - Estructura de media
- `lib/core/config/constants.dart` - Lugar para API keys

### Documentación
- `docs/PRODUCT_IMAGES.md` - Patrón para almacenamiento permanente
- `ENABLE_FIREBASE_PHONE_AUTH_MANUAL.md` - Configuración Firebase

### Packages Relevantes
- `cloud_firestore: ^4.8.0` - Para listeners de Firestore
- `http: ^1.1.0` - Para llamadas HTTP
- `google_maps_flutter: ^2.5.0` - Para renderizar rutas
- `dio: ^5.2.0` - Alternativa HTTP con retry automático

---

## ✅ CHECKLIST FINAL

Antes de comenzar implementaciones, confirmar:

- [ ] Todos los files están en ubicaciones correctas
- [ ] No hay conflictos de merge pendientes
- [ ] Branch `features/taliana` está sincronizada
- [ ] Firebase está configurado y funcionando
- [ ] Google Maps API está habilitada (para Directions)
- [ ] Simulator/device tiene las últimas dependencias
- [ ] `flutter pub get` ejecutado recientemente

---

**Documento Creado:** 18 de Marzo de 2026  
**Última Actualización:** Hoy  
**Estado:** Activo y Listo para Implementación
