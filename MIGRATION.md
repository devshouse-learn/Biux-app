# Migración a Feature-First Clean Architecture

## 🏗️ Nueva Estructura del Proyecto

El proyecto Biux ha sido reorganizado siguiendo los principios de **Feature-First Clean Architecture**. Cada feature ahora tiene su propia estructura de capas independiente.

### 📁 Estructura Principal

```
lib/
├── core/                     # Configuraciones y utilidades globales
│   ├── config/              # Configuraciones (colores, strings, router, temas)
│   ├── constants/           # Constantes globales
│   ├── network/            # Cliente HTTP y configuración de red
│   ├── utils/              # Utilidades compartidas
│   └── errors/             # Manejo de errores globales
├── shared/                  # Componentes y servicios compartidos
│   ├── widgets/            # Widgets reutilizables (main_shell, etc.)
│   └── services/           # Servicios compartidos (local_storage, etc.)
├── features/               # Features específicas del negocio
│   ├── authentication/     # Autenticación y login
│   ├── groups/            # Gestión de grupos de ciclistas
│   ├── rides/             # Gestión de rodadas
│   ├── roads/             # Gestión de rutas y caminos
│   ├── users/             # Gestión de usuarios
│   ├── stories/           # Historias y publicaciones
│   ├── maps/              # Mapas y ubicación
│   └── cities/            # Gestión de ciudades
└── main.dart              # Punto de entrada de la app
```

### 🏛️ Estructura de Clean Architecture por Feature

Cada feature sigue el patrón de Clean Architecture con tres capas:

```
features/example/
├── data/                   # Capa de Datos
│   ├── datasources/       # Fuentes de datos (API, local DB)
│   ├── models/            # Modelos de datos con serialización JSON
│   └── repositories/      # Implementaciones de repositorios
├── domain/                # Capa de Dominio (Business Logic)
│   ├── entities/          # Entidades de negocio (objetos Dart puros)
│   ├── repositories/      # Interfaces de repositorios
│   └── usecases/         # Casos de uso (lógica de negocio)
└── presentation/          # Capa de Presentación (UI)
    ├── providers/         # Gestión de estado (ChangeNotifier)
    ├── screens/          # Pantallas de la UI
    └── widgets/          # Widgets específicos del feature
```

## 🔄 Cambios Principales

### Antes (Layer-First)
```
lib/
├── data/
├── ui/
├── providers/
└── config/
```

### Después (Feature-First)
```
lib/
├── core/
├── shared/
└── features/
    ├── authentication/
    ├── groups/
    ├── users/
    └── ...
```

## 📋 Lista de Features Migradas

### ✅ Completadas
- **authentication**: Login, registro, recuperación de contraseña
- **groups**: Creación, edición, listado de grupos
- **users**: Perfiles, edición de usuarios
- **rides**: Creación y gestión de rodadas
- **roads**: Creación y gestión de rutas
- **stories**: Historias y publicaciones
- **maps**: Mapas, ubicación, puntos de encuentro
- **cities**: Gestión de ciudades

## 🛠️ Patrones de Desarrollo

### Entity (Domain Layer)
```dart
class UserEntity {
  final String id;
  final String fullName;
  final String email;
  
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
  });
}
```

### Repository Interface (Domain Layer)
```dart
abstract class UserRepository {
  Future<UserEntity> getUserById(String id);
  Future<List<UserEntity>> getAllUsers();
}
```

### Use Case (Domain Layer)
```dart
class GetUserProfileUseCase {
  final UserRepository repository;
  
  GetUserProfileUseCase(this.repository);
  
  Future<UserEntity> call(String userId) async {
    return await repository.getUserById(userId);
  }
}
```

### Model (Data Layer)
```dart
class UserModel extends UserEntity {
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
    };
  }
}
```

## 📦 Imports Actualizados

### Organización de Imports
```dart
// Core imports
import 'package:biux/core/config/strings.dart';

// Feature imports (por capas)
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

// Shared imports
import 'package:biux/shared/widgets/custom_button.dart';

// External packages
import 'package:flutter/material.dart';
```

## 🎯 Beneficios de la Nueva Arquitectura

1. **Separación de Responsabilidades**: Cada capa tiene una responsabilidad específica
2. **Independencia de Frameworks**: La lógica de negocio no depende de Flutter
3. **Testabilidad**: Cada capa puede ser probada independientemente
4. **Escalabilidad**: Fácil agregar nuevas features sin afectar existentes
5. **Mantenibilidad**: Código más organizado y fácil de mantener
6. **Reutilización**: Componentes compartidos en `core/` y `shared/`

## 🚀 Próximos Pasos

1. **Actualizar Tests**: Adaptar los tests existentes a la nueva estructura
2. **Crear Use Cases**: Implementar casos de uso para cada feature
3. **Interfaces de Repositorio**: Definir contratos claros para cada repositorio
4. **Dependency Injection**: Implementar inyección de dependencias
5. **Error Handling**: Centralizar el manejo de errores en `core/errors/`

## 📚 Referencias

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Feature-First Development](https://feature-sliced.design/)