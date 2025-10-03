# Biux - Flutter Cycling App - Copilot Instructions

## Project Overview
Biux is a Spanish-language Flutter app for cyclists featuring social networking, ride organization, group management, and mapping capabilities. The app uses Firebase for authentication and data persistence, with Google Maps integration for location-based features.

## Architecture & Structure

### Feature-First Clean Architecture
The project follows **Feature-First Clean Architecture** with each feature having its own data/domain/presentation layers:

```
lib/
├── core/                     # Shared configurations & utilities
├── shared/                   # Shared widgets & services
├── features/                 # Feature-specific modules
│   ├── authentication/
│   ├── groups/
│   ├── rides/
│   ├── users/
│   ├── maps/
│   └── ... (other features)
└── main.dart
```

### Clean Architecture Layers (per feature)
- **Domain Layer**: `entities/`, `repositories/`, `usecases/` - Business logic & rules
- **Data Layer**: `datasources/`, `models/`, `repositories/` - External data sources
- **Presentation Layer**: `providers/`, `screens/`, `widgets/` - UI components

### Provider Pattern Architecture
- **State Management**: Uses Provider pattern with `ChangeNotifier` classes in each feature
- **Provider Setup**: All providers initialized in `main.dart` with `MultiProvider`
- **Feature Providers**: Located in `features/{feature}/presentation/providers/`

### Navigation with Go Router
- **Router**: Centralized routing in `core/config/router/app_router.dart`
- **Authentication Guard**: Global auth guard function `_guard()` controls access
- **Shell Navigation**: `MainShell` in `shared/widgets/` with `CurvedNavigationBar`
- **Routes**: Named routes defined in `core/config/router/app_routes.dart`

## Core Configuration Patterns

### Theme System
- **Dynamic Theming**: `ThemeNotifier` with Provider for theme switching
- **Colors**: Centralized in `core/config/colors.dart` with `AppColors.blackPearl` primary
- **Styles**: Text and component styles in `core/config/styles.dart`

### Localization & Constants
- **Strings**: All text constants in `core/config/strings.dart` with `AppStrings` class
- **Images**: Asset references in `core/config/images.dart` with `Images` class
- **Language**: Spanish-focused with some English fallbacks

### Firebase Integration
- **Configuration**: Auto-generated `firebase_options.dart` with platform-specific configs
- **Services**: Firebase Auth, Firestore, Storage, Analytics, Messaging
- **Project ID**: `biux-1576614678644`

### Shared Services
- **Local Storage**: `shared/services/local_storage.dart` for app preferences
- **Network**: API clients and HTTP services in `core/network/`

## Development Workflows

### Asset Management
```yaml
# All images in img/ folder
assets:
  - img/
```
- **Icons**: Adaptive launcher icons with `#16242D` (blackPearl) background
- **Splash**: Native splash screen with brand colors

### Dependencies & Build
- **Flutter SDK**: `>=2.12.0 <3.0.0`
- **Key Packages**: `go_router`, `provider`, `firebase_*`, `google_maps_flutter`
- **Dev Tools**: `flutter_launcher_icons`, `flutter_native_splash`

### Code Standards
- **Lints**: Uses `package:flutter_lints/flutter.yaml`
- **Analysis**: Standard Flutter analysis options
- **Imports**: Relative imports for internal modules, absolute for packages

## Feature Development Patterns

### Clean Architecture Structure per Feature
```
features/example/
├── data/
│   ├── datasources/          # External data sources (API, local DB)
│   ├── models/              # Data models with JSON serialization
│   └── repositories/        # Repository implementations
├── domain/
│   ├── entities/            # Business entities (pure Dart objects)
│   ├── repositories/        # Repository interfaces
│   └── usecases/           # Business logic use cases
└── presentation/
    ├── providers/           # State management (ChangeNotifier)
    ├── screens/            # UI screens
    └── widgets/            # Feature-specific widgets
```

### Screen Structure
```dart
// Feature screen pattern
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExampleProvider>(
      builder: (context, provider, child) {
        return Scaffold(/* ... */);
      },
    );
  }
}
```

### Use Case Pattern
```dart
class GetUserProfileUseCase {
  final UserRepository repository;
  
  GetUserProfileUseCase(this.repository);
  
  Future<UserEntity> call(String userId) async {
    return await repository.getUserById(userId);
  }
}
```

### Provider Usage
- **Consumer**: Wrap widgets that need provider data
- **Context.read()**: For triggering actions without rebuilding
- **Context.watch()**: For reactive UI updates
- **Location**: Each feature has providers in `features/{feature}/presentation/providers/`

### Authentication Flow
1. Phone number verification via Firebase Auth
2. Custom backend integration at `https://n8n.oktavia.me/webhook`
3. Token-based session management with `AuthProvider` in `features/authentication/`

## External Integrations

### Maps & Location
- **Google Maps**: `google_maps_flutter` for map display
- **Geolocation**: `geolocator` for GPS coordinates
- **Location Services**: `location` package for real-time tracking

### Social Features
- **Social Login**: Google Sign-In, Facebook Auth, Apple Sign-In
- **Media**: `image_picker` for photos, `photo_manager` for gallery access
- **Sharing**: `share_plus` for content sharing

### Backend APIs
- **Base URL**: `https://biux-prod.ibacrea.com/api/v1/`
- **Endpoints**: `/grupos`, `/usuarios`, `/rodadas`, `/historias`
- **HTTP Client**: Uses `http` and `dio` packages

## Common Conventions

### File Naming
- **Screens**: `*_screen.dart` in `features/{feature}/presentation/screens/`
- **Providers**: `*_provider.dart` with ChangeNotifier in `features/{feature}/presentation/providers/`
- **Entities**: `*_entity.dart` in `features/{feature}/domain/entities/`
- **Models**: `*_model.dart` in `features/{feature}/data/models/`
- **Repositories**: 
  - Interface: `*_repository.dart` in `features/{feature}/domain/repositories/`
  - Implementation: `*_repository_impl.dart` in `features/{feature}/data/repositories/`
- **Use Cases**: `*_usecase.dart` in `features/{feature}/domain/usecases/`
- **Data Sources**: `*_datasource.dart` in `features/{feature}/data/datasources/`

### Import Organization
```dart
// Core imports first
import 'package:biux/core/config/strings.dart';

// Feature imports (organized by layer)
import 'package:biux/features/users/domain/entities/user_entity.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';

// Shared imports
import 'package:biux/shared/widgets/custom_button.dart';

// External packages last
import 'package:flutter/material.dart';
```

### State Management
- **Loading States**: Enum-based state management (e.g., `AuthState`)
- **Error Handling**: Provider-level error state with `notifyListeners()`
- **Navigation**: Programmatic navigation with `context.go()`

### UI Patterns
- **AppBar**: Consistent `AppColors.blackPearl` background
- **Navigation**: `CurvedNavigationBar` with image icons in `shared/widgets/main_shell.dart`
- **Dialogs**: Custom dialogs with `proste_dialog` package
- **Loading**: `loading_overlay` for async operations

## Testing & Debugging
- **Hot Reload**: Standard Flutter hot reload supported
- **Debugging**: Firebase debugging enabled in debug mode
- **Analytics**: Firebase Analytics integration for user tracking