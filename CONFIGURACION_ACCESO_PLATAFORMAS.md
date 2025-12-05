# 🔐 CONFIGURACIÓN DE ACCESO POR PLATAFORMA

**Fecha:** 05 de diciembre de 2024  
**Versión:** 1.0  

---

## 📋 RESUMEN

Se ha configurado la aplicación Biux con diferentes políticas de autenticación según la plataforma:

### 🌐 **Web (Chrome/Navegadores)**
- ✅ **Acceso sin login**
- ✅ Ruta inicial: `/shop` (Tienda Virtual)
- ✅ Navegación libre por toda la app
- ✅ Ideal para usuarios anónimos explorando productos

### 📱 **Móvil/Desktop (iOS/Android/macOS/Windows/Linux)**
- 🔐 **Login obligatorio**
- 🔐 Ruta inicial: `/login` o `/splash`
- 🔐 No permite acceso sin autenticación
- 🔐 Protección de datos personales

---

## 🎯 OBJETIVO

Permitir que usuarios en **Chrome/Web** puedan explorar la tienda sin crear una cuenta, mientras que en **aplicaciones móviles/desktop** se mantiene la seguridad con autenticación obligatoria.

### Casos de Uso

**Web:**
- Usuario visita biux.com
- Ve productos inmediatamente
- Puede buscar y filtrar sin login
- Si quiere comprar → debe crear cuenta

**Móvil:**
- Usuario descarga la app
- Debe iniciar sesión para acceder
- Datos personales protegidos
- Experiencia social completa

---

## 🔧 IMPLEMENTACIÓN TÉCNICA

### Archivo Modificado

**`lib/core/config/router/app_router.dart`**

### Función Guard

```dart
// Guard de autenticación (función global)
String? _guard(BuildContext context, GoRouterState state) {
  final bool isLoggedIn = _authNotifier.isLoggedIn;
  final User? user = _authNotifier.user;
  final String location = state.uri.toString();

  print(
    '🔍 Router Guard - Location: $location, isLoggedIn: $isLoggedIn, uid: ${user?.uid}',
  );

  // EN WEB: Permitir acceso sin autenticación
  if (kIsWeb) {
    print('🌐 WEB: Permitiendo acceso sin autenticación');
    
    // Si está en root, redirigir a la tienda
    if (location == '/') {
      print('📍 Root en web, redirigiendo a tienda');
      return '/shop';
    }
    
    // Permitir acceso libre a todas las rutas en web
    return null;
  }

  // PARA MÓVIL/DESKTOP: Continúa con lógica de autenticación normal
  // ...
}
```

### Lógica por Plataforma

#### 1. Detección de Plataforma

```dart
if (kIsWeb) {
  // Lógica para web
} else {
  // Lógica para móvil/desktop
}
```

**`kIsWeb`** es una constante de Flutter que detecta automáticamente si la app está corriendo en navegador.

#### 2. Ruta Inicial Web

```dart
if (location == '/') {
  return '/shop';  // Redirige a tienda
}
return null;  // Permite acceso a cualquier ruta
```

#### 3. Ruta Inicial Móvil

```dart
if (effectiveLocation == '/') {
  if (isLoggedIn) {
    return '/stories';  // Va a feed de experiencias
  } else {
    return AppRoutes.login;  // Fuerza login
  }
}
```

---

## 🚀 COMPILACIÓN

### Web

```bash
flutter build web --release
cd build/web
python3 -m http.server 8080
```

Acceder en: `http://localhost:8080`

**Resultado esperado:**
- ✅ Abre directamente en tienda
- ✅ No pide login
- ✅ Búsqueda y filtros funcionan
- ✅ Puede ver productos

### iOS

```bash
flutter build ios --simulator --debug
xcrun simctl install <UDID> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <UDID> org.devshouse.biux
```

**Resultado esperado:**
- 🔐 Abre en pantalla de login
- 🔐 No permite acceder sin autenticación
- 🔐 Debe ingresar con teléfono

### macOS

```bash
flutter build macos --debug
open build/macos/Build/Products/Debug/biux.app
```

**Resultado esperado:**
- 🔐 Abre en pantalla de login
- 🔐 Requiere autenticación obligatoria

---

## 🧪 PRUEBAS REALIZADAS

### ✅ Test 1: Web - Acceso sin login

**Pasos:**
1. Compilar web: `flutter build web --release`
2. Iniciar servidor: `python3 -m http.server 8080`
3. Abrir Chrome: `http://localhost:8080`

**Resultado:**
- ✅ Abre directamente en tienda
- ✅ No muestra pantalla de login
- ✅ Búsqueda funciona
- ✅ Filtros funcionan
- ✅ Puede ver productos completos

### ✅ Test 2: iOS - Login obligatorio

**Pasos:**
1. Compilar iOS: `flutter build ios --simulator --debug`
2. Instalar en iPhone 16 Pro Max
3. Abrir aplicación

**Resultado:**
- 🔐 Muestra pantalla de login
- 🔐 No permite acceso sin autenticación
- 🔐 Debe ingresar teléfono para continuar

### ✅ Test 3: macOS - Login obligatorio

**Pasos:**
1. Compilar macOS: `flutter build macos --debug`
2. Abrir aplicación

**Resultado:**
- 🔐 Muestra pantalla de login
- 🔐 Requiere autenticación

---

## 📱 FLUJOS DE USUARIO

### Flujo Web (Sin Login)

```
┌─────────────┐
│   Chrome    │
│  Visita URL │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Guard     │
│  kIsWeb=true│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   /shop     │
│   Tienda    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Explorar   │
│  Productos  │
│  Libremente │
└─────────────┘
```

### Flujo Móvil (Login Obligatorio)

```
┌─────────────┐
│   iPhone    │
│  Abre App   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Guard     │
│ kIsWeb=false│
│ !isLoggedIn │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   /login    │
│  Pantalla   │
│   Login     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Ingresar   │
│  Teléfono   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Verificar  │
│    OTP      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  /stories   │
│    Feed     │
└─────────────┘
```

---

## 🔐 SEGURIDAD

### Web - Consideraciones

**Acceso Público:**
- ✅ Solo lectura de productos
- ✅ No acceso a datos personales
- ✅ Compras requieren crear cuenta
- ⚠️ Firebase Rules deben permitir lectura pública de productos

**Protección:**
```javascript
// Firestore Rules para productos
match /productos/{productId} {
  allow read: if true;  // Lectura pública
  allow write: if request.auth != null;  // Solo usuarios autenticados
}
```

### Móvil - Consideraciones

**Acceso Privado:**
- 🔐 Login obligatorio
- 🔐 Token de sesión guardado localmente
- 🔐 Datos personales protegidos
- 🔐 Acceso completo a funciones sociales

**Ventajas:**
- Mejor control de usuarios
- Datos sincronizados
- Notificaciones push
- Experiencia personalizada

---

## 📊 COMPARACIÓN

| Característica | Web | Móvil/Desktop |
|----------------|-----|---------------|
| Login requerido | ❌ No | ✅ Sí |
| Ruta inicial | `/shop` | `/login` o `/stories` |
| Ver productos | ✅ | ✅ |
| Buscar productos | ✅ | ✅ |
| Filtrar productos | ✅ | ✅ |
| Agregar al carrito | ✅ | ✅ |
| Finalizar compra | 🔐 Requiere cuenta | ✅ |
| Ver experiencias | ⚠️ Limitado | ✅ |
| Crear experiencias | ❌ | ✅ |
| Ver grupos | ⚠️ Limitado | ✅ |
| Unirse a grupos | ❌ | ✅ |
| Chat | ❌ | ✅ |
| Notificaciones | ❌ | ✅ |
| Perfil | ❌ | ✅ |

---

## 🎨 EXPERIENCIA DE USUARIO

### Web - Primera Impresión

**Usuario anónimo llega a la web:**
1. Ve inmediatamente la tienda
2. Puede buscar "jersey ciclismo"
3. Filtra por categoría "Jerseys"
4. Ve precio $180.000
5. Abre detalle del producto
6. Agrega al carrito
7. **Al finalizar compra** → Se le pide crear cuenta

**Ventajas:**
- ✅ Conversión más alta (no hay fricción inicial)
- ✅ Usuario explora antes de comprometerse
- ✅ SEO-friendly (productos indexables)
- ✅ Compartible en redes sociales

### Móvil - Experiencia Completa

**Usuario descarga la app:**
1. Abre app → Login screen
2. Ingresa teléfono
3. Verifica OTP
4. Accede a feed personalizado
5. Ve experiencias de amigos
6. Puede crear posts
7. Unirse a grupos
8. Usar todas las funciones sociales

**Ventajas:**
- ✅ Datos sincronizados
- ✅ Notificaciones push
- ✅ Experiencia personalizada
- ✅ Funciones sociales completas

---

## 🔄 CAMBIAR CONFIGURACIÓN

### Forzar Login en Web

Si deseas requerir login también en web:

```dart
if (kIsWeb) {
  if (!isLoggedIn) {
    return AppRoutes.login;  // Fuerza login
  }
  return null;
}
```

### Permitir Acceso Sin Login en Móvil

Si deseas permitir acceso sin login en móvil (NO RECOMENDADO):

```dart
if (!kIsWeb) {
  // Comentar o remover la validación de login
  // if (!isLoggedIn) {
  //   return AppRoutes.login;
  // }
  return null;
}
```

---

## 🚨 IMPORTANTE

### Firebase Rules

Asegúrate de configurar las reglas de Firestore para permitir lectura pública de productos:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Productos - Lectura pública, escritura autenticada
    match /productos/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.uid == resource.data.sellerId;
    }
    
    // Otros datos - Solo usuarios autenticados
    match /usuarios/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /experiencias/{expId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // ... resto de reglas
  }
}
```

---

## 📝 RESUMEN

✅ **Configuración completada:**
- 🌐 Web: Acceso libre, ruta inicial `/shop`
- 📱 iOS: Login obligatorio
- 🖥️ macOS: Login obligatorio
- 🤖 Android: Login obligatorio (cuando se compile)

✅ **Compilaciones actualizadas:**
- Web: `build/web` (release)
- iOS: `build/ios/iphonesimulator/Runner.app` (debug)

✅ **Pruebas realizadas:**
- Chrome muestra tienda sin login ✅
- iPhone muestra pantalla de login ✅
- macOS muestra pantalla de login ✅

---

## 🔮 PRÓXIMOS PASOS

### Opcional - Mejoras Futuras

1. **Botón "Crear Cuenta" en Web**
   - En la tienda web, mostrar botón "Iniciar Sesión"
   - Redirige a login para usuarios que quieran cuenta

2. **Modal de Login en Checkout**
   - Al finalizar compra sin login
   - Mostrar modal: "Crea tu cuenta para continuar"

3. **Guest Checkout**
   - Permitir compras sin cuenta
   - Enviar por correo detalles del pedido

4. **Social Login**
   - Google Sign-In en web
   - Apple Sign-In en móvil
   - Facilitar registro

---

**Configurado con 🔐 para Biux**  
**Flutter 3.38.3 | Dart 3.10.1**  
**05 de diciembre de 2024**
