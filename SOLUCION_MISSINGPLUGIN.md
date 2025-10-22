# Solución MissingPluginException - Firebase Realtime Database

## 🔴 Problema
```
MissingPluginException al publicar comentario
```

Esto indica que el plugin de Firebase Realtime Database no está correctamente registrado en la app nativa.

## ✅ Solución Paso a Paso

### 1. Rebuild Completo (IMPORTANTE)
El hot reload NO carga plugins nativos. Necesitas rebuild completo:

```powershell
# En PowerShell desde la raíz del proyecto:

# 1. Limpiar todo
flutter clean

# 2. Reinstalar dependencias
flutter pub get

# 3. Limpiar build de Android
cd android
./gradlew clean
cd ..

# 4. Rebuild completo (NO hot reload)
flutter run
```

### 2. Verificar Configuración Android

#### a) Verificar `android/app/google-services.json`
Debe existir y contener la configuración de Firebase Realtime Database.

```json
{
  "project_info": {
    "project_id": "biux-1576614678644",
    ...
  },
  "client": [
    {
      ...
      "api_key": [...],
      "client_info": {
        "mobilesdk_app_id": "..."
      },
      "services": {
        "appinvite_service": {...}
      }
    }
  ],
  "configuration_version": "1"
}
```

#### b) Verificar `android/app/build.gradle.kts`
Debe tener el plugin de Google Services:

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // ← ESTO DEBE ESTAR
    kotlin("android")
}
```

#### c) Verificar `android/build.gradle.kts`
Debe incluir el classpath:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0") // ← ESTO
    }
}
```

### 3. Verificar Configuración iOS

#### a) Verificar `ios/Runner/GoogleService-Info.plist`
Debe existir y estar configurado correctamente.

#### b) Agregar en `ios/Podfile` (si no está):
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### c) Reinstalar pods:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### 4. Verificar Internet en AndroidManifest

En `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

## 🧪 Prueba de Verificación

Después del rebuild, prueba este código en la pantalla:

```dart
import 'package:firebase_database/firebase_database.dart';

// En algún botón de prueba:
onPressed: () async {
  try {
    final ref = FirebaseDatabase.instance.ref('test');
    await ref.set({'timestamp': DateTime.now().toString()});
    print('✅ Firebase Realtime DB funciona!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

Si esto funciona, los comentarios también funcionarán.

## 🚨 Si el Problema Persiste

### Opción A: Verificar Reglas de Firebase
En Firebase Console → Realtime Database → Reglas:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### Opción B: Verificar URL de Database
En Firebase Console, copia la URL exacta de tu database:
```
https://biux-1576614678644-default-rtdb.firebaseio.com/
```

Si es diferente, actualiza en `firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '...',
  appId: '...',
  messagingSenderId: '...',
  projectId: 'biux-1576614678644',
  databaseURL: 'https://TU-DATABASE-URL.firebaseio.com/', // ← VERIFICAR
);
```

### Opción C: Habilitar Multidex (Android)

Si tienes muchas dependencias, necesitas multidex.

En `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        ...
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

## 📋 Checklist Final

Antes de ejecutar `flutter run`:

- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] `android/gradlew clean` ejecutado
- [ ] `google-services.json` existe en `android/app/`
- [ ] `GoogleService-Info.plist` existe en `ios/Runner/`
- [ ] Internet permission en AndroidManifest
- [ ] Plugin de Google Services en build.gradle.kts
- [ ] Reglas de Firebase permiten escritura
- [ ] NO usar hot reload, usar `flutter run`

## 🎯 Comando Completo

```powershell
# Ejecutar todo de una vez:
flutter clean; flutter pub get; cd android; ./gradlew clean; cd ..; flutter run
```

Después del rebuild, el MissingPluginException debería desaparecer.
