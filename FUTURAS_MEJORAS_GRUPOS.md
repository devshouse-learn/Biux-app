# 🔮 Guía de Futuras Mejoras - Sistema de Grupos

**Documento**: Hoja de ruta para implementaciones adicionales  
**Última actualización**: 26 de Noviembre de 2025  
**Estado actual**: Base implementada y funcionando

---

## 1. 📊 Conteos Dinámicos de Rodadas

### Descripción
Actualmente los badges muestran "Próxima", "Cancelada", "Realizada" como categorías.  
Mejora: Mostrar conteos reales como "Próxima (5)", "Cancelada (2)", "Realizada (12)"

### Implementación Paso a Paso

#### Paso 1: Agregar método en GroupProvider
```dart
Future<Map<String, int>> getRideCountsByStatus(String groupId) async {
  try {
    final rides = await _rideRepository.getGroupRides(groupId).first;
    
    int upcoming = rides.where((r) => r.status == RideStatus.upcoming).length;
    int cancelled = rides.where((r) => r.status == RideStatus.cancelled).length;
    int completed = rides.where((r) => r.status == RideStatus.completed).length;
    
    return {
      'upcoming': upcoming,
      'cancelled': cancelled,
      'completed': completed,
    };
  } catch (e) {
    print('Error obteniendo conteos: $e');
    return {'upcoming': 0, 'cancelled': 0, 'completed': 0};
  }
}
```

#### Paso 2: Modificar UI con FutureBuilder
```dart
FutureBuilder<Map<String, int>>(
  future: provider.getRideCountsByStatus(group.id),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final counts = snapshot.data!;
      return Row(
        children: [
          _buildRideStatusBadgeWithCount('Próxima', counts['upcoming']!, ColorTokens.warning50),
          const SizedBox(width: 8),
          _buildRideStatusBadgeWithCount('Cancelada', counts['cancelled']!, ColorTokens.error50),
          const SizedBox(width: 8),
          _buildRideStatusBadgeWithCount('Realizada', counts['completed']!, ColorTokens.success40),
        ],
      );
    }
    return SizedBox.shrink(); // O mostrar loading
  },
)
```

#### Paso 3: Agregar método helper con conteo
```dart
Widget _buildRideStatusBadgeWithCount(String label, int count, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color, width: 0.5),
    ),
    child: Text(
      '$label ($count)',
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
```

### Consideraciones
- ⚠️ Performance: Esto suma una llamada a Firestore por tarjeta de grupo
- 💡 Solución: Cachear resultados durante 5 minutos
- 🔄 Actualización: El caché se invalida al crear/editar rodadas

---

## 2. 💾 Sistema de Caché de Usuarios

### Descripción
El método `getUserAdminInfo()` hace una llamada a Firestore por cada tarjeta.  
Mejora: Cachear usuarios para evitar llamadas redundantes.

### Implementación

#### Opción A: Caché en Provider (Simple)
```dart
Future<Map<String, dynamic>> getUserAdminInfo(String userId) async {
  // Verificar si está en caché
  if (_userCache.containsKey(userId)) {
    final user = _userCache[userId]!;
    return {
      'fullName': user.name ?? 'Usuario',
      'userName': user.username ?? 'usuario',
      'photo': user.photoUrl ?? '',
      'email': user.email ?? '',
    };
  }

  try {
    final user = await _userRepository.getUserById(userId);
    
    if (user != null) {
      // Guardar en caché
      _userCache[userId] = user;
      
      return {
        'fullName': user.name ?? 'Usuario',
        'userName': user.username ?? 'usuario',
        'photo': user.photoUrl ?? '',
        'email': user.email ?? '',
      };
    }
    
    return defaultUserInfo;
  } catch (e) {
    print('Error: $e');
    return defaultUserInfo;
  }
}
```

#### Opción B: Caché con Expiración (Robusto)
```dart
// En GroupProvider
final Map<String, (UserModel, DateTime)> _userCacheWithExpiry = {};
final Duration _cacheDuration = const Duration(minutes: 5);

Future<Map<String, dynamic>> getUserAdminInfo(String userId) async {
  // Verificar caché y validez
  if (_userCacheWithExpiry.containsKey(userId)) {
    final (cachedUser, cacheTime) = _userCacheWithExpiry[userId]!;
    
    if (DateTime.now().difference(cacheTime) < _cacheDuration) {
      return userToMap(cachedUser);
    } else {
      // Caché expirado, remover
      _userCacheWithExpiry.remove(userId);
    }
  }

  try {
    final user = await _userRepository.getUserById(userId);
    
    if (user != null) {
      _userCacheWithExpiry[userId] = (user, DateTime.now());
      return userToMap(user);
    }
    
    return defaultUserInfo;
  } catch (e) {
    return defaultUserInfo;
  }
}

Map<String, dynamic> userToMap(UserModel user) {
  return {
    'fullName': user.name ?? 'Usuario',
    'userName': user.username ?? 'usuario',
    'photo': user.photoUrl ?? '',
    'email': user.email ?? '',
  };
}
```

### Método para Limpiar Caché
```dart
void clearUserCache() {
  _userCacheWithExpiry.clear();
}

// Llamar cuando se actualiza usuario
void refreshUserCache(String userId) {
  _userCacheWithExpiry.remove(userId);
}
```

### Testing
```dart
// Test: Caché funciona
test('getUserAdminInfo usa caché', () async {
  final provider = GroupProvider();
  
  // Primera llamada: consulta Firestore
  final info1 = await provider.getUserAdminInfo('user123');
  
  // Segunda llamada: debe usar caché (no hace llamada extra)
  final info2 = await provider.getUserAdminInfo('user123');
  
  expect(info1, info2);
});
```

---

## 3. 🌆 Sincronización de Ciudades desde Firestore

### Descripción
Actualmente el mapeo de ciudades es local y estático.  
Mejora: Cargar ciudades desde Firestore para actualizaciones dinámicas.

### Estructura Firestore
```
/config/cities (documento)
{
  "cities": {
    "bogota": {"name": "Bogotá", "region": "Cundinamarca", "code": "BOG"},
    "medellin": {"name": "Medellín", "region": "Antioquia", "code": "MDE"},
    ...
  }
}
```

### Implementación

#### Paso 1: Agregar repositorio
```dart
class CityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<Map<String, dynamic>> getCities() {
    return _firestore
        .collection('config')
        .doc('cities')
        .snapshots()
        .map((doc) => doc.data()?['cities'] ?? {});
  }
}
```

#### Paso 2: Agregar al Provider
```dart
class GroupProvider extends ChangeNotifier {
  final CityRepository _cityRepository = CityRepository();
  Map<String, dynamic> _cities = {};
  
  GroupProvider() {
    _initializeCities();
  }
  
  void _initializeCities() {
    _cityRepository.getCities().listen((cities) {
      _cities = cities;
      notifyListeners();
    });
  }
  
  String getCityName(String cityId) {
    final city = _cities[cityId.toLowerCase()];
    if (city is Map) {
      return city['name'] ?? cityId;
    }
    return cityId;
  }
}
```

#### Paso 3: Usar en UI
```dart
Text(
  '📍 ${provider.getCityName(group.cityId)}',
  style: TextStyle(
    color: ColorTokens.neutral60,
    fontSize: 13,
  ),
)
```

### Ventajas
- ✅ Dinámico: agregar ciudades sin recompilar app
- ✅ Escalable: soporta N ciudades
- ✅ Información adicional: región, código

---

## 4. 🎯 Badges Interactivos

### Descripción
Actualizar badges para que sean clickeables y filtren grupos.

### Implementación

#### Paso 1: Agregar estado a screen
```dart
class _GroupListScreenState extends State<GroupListScreen> {
  RideStatus? _selectedStatus; // null = mostrar todos
  
  // ...
}
```

#### Paso 2: Hacer badges clickeables
```dart
GestureDetector(
  onTap: () {
    setState(() {
      _selectedStatus = _selectedStatus == RideStatus.upcoming 
          ? null 
          : RideStatus.upcoming;
    });
  },
  child: _buildRideStatusBadge(
    'Próxima',
    ColorTokens.warning50,
    isSelected: _selectedStatus == RideStatus.upcoming,
  ),
)
```

#### Paso 3: Filtrar grupos basado en selección
```dart
// En Consumer de GroupProvider
List<GroupModel> filteredGroups = groups;
if (_selectedStatus != null) {
  filteredGroups = groups.where((group) {
    // Aquí iría la lógica de filtrado
    return true; // Por ahora solo mostrar todos
  }).toList();
}
```

---

## 5. 🖼️ Optimización de Imágenes

### Descripción
El avatar del líder puede ser lento cargando.  
Mejora: Usar OptimizedNetworkImage o caché local.

### Implementación

#### Opción A: OptimizedNetworkImage (Recomendado)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: OptimizedNetworkImage(
    imageUrl: admin['photo'],
    width: 32,
    height: 32,
    imageType: 'avatar',
    fit: BoxFit.cover,
    errorWidget: Icon(Icons.person, size: 16),
    loadingWidget: Container(
      width: 32,
      height: 32,
      color: ColorTokens.neutral20,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            ColorTokens.primary30,
          ),
        ),
      ),
    ),
  ),
)
```

#### Opción B: Caché Local
```dart
// Usar flutter_cache_manager
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<ImageProvider> getCachedImage(String url) async {
  final file = await DefaultCacheManager().getSingleFile(url);
  return FileImage(file);
}
```

---

## 6. 🔔 Notificaciones al Crear Rodadas

### Descripción
Cuando se crea una rodada, notificar a miembros del grupo.

### Implementación
```dart
// En RideRepository (crear rodada)
Future<bool> createRide(RideModel ride) async {
  try {
    final docRef = await _firestore.collection('rides').add(ride.toMap());
    
    // Notificar al grupo
    final group = await _groupRepository.getGroupById(ride.groupId);
    if (group != null) {
      for (String memberId in group.memberIds) {
        await _notificationService.sendNotification(
          userId: memberId,
          title: '🚴 Nueva rodada: ${ride.name}',
          body: 'Estado: ${ride.status.name}',
          data: {'rideId': docRef.id, 'groupId': ride.groupId},
        );
      }
    }
    
    return true;
  } catch (e) {
    return false;
  }
}
```

---

## 7. 📈 Estadísticas de Grupo

### Descripción
Mostrar estadísticas: miembros activos, rodadas/mes, tasa de participación.

### Interfaz Propuesta
```
┌─────────────────────────────┐
│ 👥 12 Miembros              │
│ 🚴 8 Rodadas/Mes            │
│ 📊 75% Participación        │
│ ⭐ 4.5/5 Calificación      │
└─────────────────────────────┘
```

### Implementación
```dart
class GroupStatistics {
  int totalMembers;
  int ridesPerMonth;
  double participationRate;
  double averageRating;
}

Future<GroupStatistics> getGroupStatistics(String groupId) async {
  final group = await getGroup(groupId);
  final rides = await getRidesByGroup(groupId);
  final participants = countActiveParticipants(rides);
  
  return GroupStatistics(
    totalMembers: group.memberIds.length,
    ridesPerMonth: calculateRidesPerMonth(rides),
    participationRate: (participants / group.memberIds.length) * 100,
    averageRating: calculateAverageRating(group),
  );
}
```

---

## 8. 🎨 Temas Personalizados para Grupos

### Descripción
Permitir que cada grupo tenga su propio tema de colores.

### Implementación
```dart
class GroupTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundColor;
}

// En GroupModel
final GroupTheme? customTheme;

// En UI
Color groupPrimaryColor = group.customTheme?.primaryColor 
    ?? ColorTokens.primary30;
```

---

## ⏰ Timeline Sugerido

| Sprint | Mejoras |
|--------|---------|
| Sprint 1 (1-2 semanas) | 1. Conteos dinámicos, 2. Caché de usuarios |
| Sprint 2 (1-2 semanas) | 3. Ciudades en Firestore, 5. Optimización de imágenes |
| Sprint 3 (2-3 semanas) | 4. Badges interactivos, 6. Notificaciones |
| Sprint 4 (3-4 semanas) | 7. Estadísticas, 8. Temas personalizados |

---

## 🧪 Testing Checklist

- [ ] Test unitarios para conteos de rodadas
- [ ] Test de caché: verificar que no hace llamadas extras
- [ ] Test de integración: Firestore → Provider → UI
- [ ] Test de performance: <200ms por tarjeta de grupo
- [ ] Test de UI: verificar que badges se ven bien en diferentes tamaños
- [ ] Test de error: manejar usuario no encontrado
- [ ] Test de red: simular conexión lenta

---

## 📚 Referencia de Códigos

### RideStatus Enum
```dart
enum RideStatus {
  upcoming,   // Próxima
  ongoing,    // En curso
  completed,  // Completada
  cancelled,  // Cancelada
}
```

### GroupModel Fields
```dart
final String id;
final String name;
final String description;
final String cityId;
final String adminId;
final List<String> memberIds;
final List<String> pendingRequestIds;
final DateTime createdAt;
final DateTime updatedAt;
```

### ColorTokens Disponibles
```dart
ColorTokens.primary30       // Azul principal
ColorTokens.warning50       // Azul/Amarillo para avisos
ColorTokens.error50         // Rojo para errores
ColorTokens.success40       // Verde para éxito
ColorTokens.neutral60       // Gris para texto
ColorTokens.neutral100      // Negro para texto principal
```

---

## 🎯 Prioridades

**Alta Prioridad** (1-2 semanas):
- ✅ Conteos dinámicos de rodadas
- ✅ Caché de usuarios

**Media Prioridad** (2-3 semanas):
- Ciudades desde Firestore
- Optimización de imágenes

**Baja Prioridad** (3+ semanas):
- Badges interactivos
- Estadísticas
- Temas personalizados

---

**Documento creado**: 26 de Noviembre de 2025  
**Versión**: 1.0  
**Responsable**: GitHub Copilot
