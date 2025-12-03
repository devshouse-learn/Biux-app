# 📱 Guía de Simuladores para Biux

**Fecha**: 2 de diciembre de 2025  
**Estado**: ✅ Configurado y Listo

---

## 🎯 Simuladores Disponibles

### 📱 **iOS Simuladores (5)**

| ID | Dispositivo | UUID | Estado |
|---|---|---|---|
| `16promax` | iPhone 16 Pro Max | D0BCD630-71C9-4042-943A-E9FD1A8572DD | ✅ Booted |
| `16pro` | iPhone 16 Pro | 8A60CA7F-41E8-484E-9E52-F0F06788A4B7 | Shutdown |
| `16e` | iPhone 16e | B3906FB5-2AA6-488B-B16A-48212193E79C | Shutdown |
| `16` | iPhone 16 | 1EDBA709-B5B4-4248-85EB-A967E6ADBDFC | Shutdown |
| `16plus` | iPhone 16 Plus | F912C1B0-6784-4626-AB89-F7356840B58F | Shutdown |

**Especificaciones:**
- iOS: 18.6
- Runtime: com.apple.CoreSimulator.SimRuntime.iOS-18-6
- Xcode: Latest

### 🤖 **Android Emuladores (1)**

| ID | Dispositivo | Estado |
|---|---|---|
| `android` | Medium Phone API 36.0 | ✅ Disponible |

**Especificaciones:**
- API Level: 36.0
- Generic Device

### 🌐 **Web (1)**

| ID | Plataforma | URL | Estado |
|---|---|---|---|
| `chrome` | Google Chrome | http://localhost:9090 | ✅ Funcionando |

**Especificaciones:**
- Browser: Chrome 142.0.7444.176
- Server: Python HTTP Server (Puerto 9090)

---

## 🚀 Uso del Script de Lanzamiento

### Script Principal: `launch_biux_simulators.sh`

```bash
# Ver lista de dispositivos
./launch_biux_simulators.sh

# Lanzar en iPhone 16 Pro Max
./launch_biux_simulators.sh 16promax

# Lanzar en iPhone 16 Pro
./launch_biux_simulators.sh 16pro

# Lanzar en iPhone 16e
./launch_biux_simulators.sh 16e

# Lanzar en iPhone 16
./launch_biux_simulators.sh 16

# Lanzar en iPhone 16 Plus
./launch_biux_simulators.sh 16plus

# Lanzar en Android
./launch_biux_simulators.sh android

# Lanzar en Chrome
./launch_biux_simulators.sh chrome
```

### Comandos Especiales

```bash
# Ver estado de todos los dispositivos
./launch_biux_simulators.sh estado

# Reconstruir proyecto completo
./launch_biux_simulators.sh rebuild

# Detener todos los procesos
./launch_biux_simulators.sh stop
```

---

## 📋 Comandos Manuales (Alternativa)

### iOS Simuladores

#### Abrir Simulator App
```bash
open -a Simulator
```

#### Listar Dispositivos
```bash
# Ver todos los simuladores
xcrun simctl list devices available

# Ver solo iPhones
xcrun simctl list devices available iPhone

# Ver dispositivos con Flutter
flutter devices
```

#### Encender Simulador Específico
```bash
# iPhone 16 Pro Max
xcrun simctl boot D0BCD630-71C9-4042-943A-E9FD1A8572DD

# iPhone 16 Pro
xcrun simctl boot 8A60CA7F-41E8-484E-9E52-F0F06788A4B7

# iPhone 16e
xcrun simctl boot B3906FB5-2AA6-488B-B16A-48212193E79C

# iPhone 16
xcrun simctl boot 1EDBA709-B5B4-4248-85EB-A967E6ADBDFC

# iPhone 16 Plus
xcrun simctl boot F912C1B0-6784-4626-AB89-F7356840B58F
```

#### Apagar Simulador
```bash
# Apagar uno específico
xcrun simctl shutdown D0BCD630-71C9-4042-943A-E9FD1A8572DD

# Apagar todos
xcrun simctl shutdown all
```

#### Lanzar Biux
```bash
# iPhone 16 Pro Max (recomendado)
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD

# iPhone 16 Pro
flutter run -d 8A60CA7F-41E8-484E-9E52-F0F06788A4B7

# iPhone 16e
flutter run -d B3906FB5-2AA6-488B-B16A-48212193E79C

# iPhone 16
flutter run -d 1EDBA709-B5B4-4248-85EB-A967E6ADBDFC

# iPhone 16 Plus
flutter run -d F912C1B0-6784-4626-AB89-F7356840B58F
```

### Android Emulador

#### Listar Emuladores
```bash
flutter emulators
```

#### Lanzar Emulador
```bash
flutter emulators --launch Medium_Phone_API_36.0
```

#### Lanzar Biux en Android
```bash
flutter run -d emulator-5554
```

### Web (Chrome)

#### Iniciar Servidor Web
```bash
cd build/web
python3 -m http.server 9090 &
```

#### Abrir en Chrome
```bash
open -a "Google Chrome" http://localhost:9090
```

#### Verificar Servidor Corriendo
```bash
lsof -i :9090
```

#### Detener Servidor
```bash
lsof -ti:9090 | xargs kill -9
```

---

## 🛠️ Gestión de Simuladores

### Verificar Estado
```bash
# Ver qué simuladores están encendidos
xcrun simctl list devices | grep "Booted"

# Ver todos con detalles
flutter devices
```

### Limpiar Simulador (Reset)
```bash
# Borrar datos de un simulador específico
xcrun simctl erase D0BCD630-71C9-4042-943A-E9FD1A8572DD

# Borrar todos
xcrun simctl erase all
```

### Instalar App Manualmente
```bash
# Compilar
flutter build ios --simulator

# Instalar en simulador específico
xcrun simctl install D0BCD630-71C9-4042-943A-E9FD1A8572DD build/ios/iphonesimulator/Runner.app
```

### Abrir App Instalada
```bash
# Con bundle identifier
xcrun simctl launch D0BCD630-71C9-4042-943A-E9FD1A8572DD com.devshouse.biux
```

---

## 🔧 Solución de Problemas

### Problema: "Xcode build failed due to concurrent builds"
```bash
# Detener todos los builds de Xcode
killall -9 xcodebuild

# Esperar 2 segundos y reintentar
sleep 2
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

### Problema: Simulador no responde
```bash
# Apagar y reiniciar
xcrun simctl shutdown D0BCD630-71C9-4042-943A-E9FD1A8572DD
sleep 2
xcrun simctl boot D0BCD630-71C9-4042-943A-E9FD1A8572DD
open -a Simulator
```

### Problema: Error de dependencias iOS
```bash
# Limpiar pods
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install

# Volver a compilar
cd ..
flutter clean
flutter pub get
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

### Problema: Servidor web no inicia
```bash
# Detener proceso en puerto 9090
lsof -ti:9090 | xargs kill -9

# Reconstruir web
flutter build web --release

# Iniciar servidor
cd build/web && python3 -m http.server 9090 &
```

### Problema: Hot reload no funciona
```bash
# En el terminal de Flutter, presionar:
r  → Hot reload (mantiene estado)
R  → Hot restart (reinicia app)
q  → Quit (salir)
```

---

## 📊 Estado Actual de Simuladores

### ✅ **Configurado y Listo**

```
iOS Simuladores:
  ● iPhone 16 Pro Max - BOOTED (listo para usar)
  ○ iPhone 16 Pro - Shutdown
  ○ iPhone 16e - Shutdown
  ○ iPhone 16 - Shutdown
  ○ iPhone 16 Plus - Shutdown

Android:
  ● Medium Phone API 36.0 - Disponible

Web:
  ● Chrome (localhost:9090) - Funcionando
```

### 🎯 Simulador Recomendado

**iPhone 16 Pro Max (ID: D0BCD630-71C9-4042-943A-E9FD1A8572DD)**

**Razones:**
- ✅ Ya está encendido (Booted)
- ✅ Pantalla grande para testing UI
- ✅ iOS 18.6 (última versión)
- ✅ Mejor para demo y capturas
- ✅ Compatible con todas las features de Biux

---

## 🚀 Flujo de Trabajo Recomendado

### Para Desarrollo Rápido (iOS)
```bash
# 1. Abrir simulador (si no está abierto)
open -a Simulator

# 2. Lanzar Biux con hot reload
./launch_biux_simulators.sh 16promax

# 3. Hacer cambios en código

# 4. Hot reload automático (o presionar 'r' en terminal)

# 5. Para cambios grandes, hot restart (presionar 'R')
```

### Para Testing Multi-Dispositivo
```bash
# Terminal 1: iPhone 16 Pro Max
./launch_biux_simulators.sh 16promax

# Terminal 2: iPhone 16 (esperar a que termine el anterior)
./launch_biux_simulators.sh 16

# Terminal 3: Web
./launch_biux_simulators.sh chrome
```

### Para Builds de Producción
```bash
# 1. Limpiar todo
./launch_biux_simulators.sh rebuild

# 2. Build iOS release
flutter build ios --release

# 3. Build Android release
flutter build apk --release

# 4. Build Web release
flutter build web --release
```

---

## 📱 Características de Cada Simulador

### iPhone 16 Pro Max ⭐ **RECOMENDADO**
- **Pantalla**: 6.9" (largest)
- **Resolución**: 1320 x 2868 px
- **Ideal para**: Demo, UI testing, capturas de pantalla
- **Uso**: Desarrollo principal

### iPhone 16 Pro
- **Pantalla**: 6.3"
- **Resolución**: 1206 x 2622 px
- **Ideal para**: Testing Pro features, Dynamic Island
- **Uso**: Testing alternativo

### iPhone 16e
- **Pantalla**: Estándar
- **Ideal para**: Budget device testing
- **Uso**: Compatibility testing

### iPhone 16
- **Pantalla**: 6.1"
- **Resolución**: 1179 x 2556 px
- **Ideal para**: Testing dispositivo más común
- **Uso**: User experience testing

### iPhone 16 Plus
- **Pantalla**: 6.7"
- **Resolución**: 1290 x 2796 px
- **Ideal para**: Large screen testing
- **Uso**: Alternative large device

---

## 🎨 Tips para Mejor Experiencia

### Hot Reload Shortcuts
```
r   → Reload (rápido, mantiene estado)
R   → Restart (reinicia app completa)
p   → Grid painting mode
P   → Performance overlay
q   → Quit
```

### Simulador Shortcuts (en app Simulator)
```
Cmd + 1/2/3  → Zoom del simulador
Cmd + K      → Mostrar/ocultar teclado
Cmd + Shift + H  → Home button
Cmd + Shift + L  → Lock screen
Cmd + R      → Rotate device
```

### Performance Tips
```
# Usar release mode para mejor performance
flutter run --release -d D0BCD630-71C9-4042-943A-E9FD1A8572DD

# Profile mode para debugging de performance
flutter run --profile -d D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

---

## 📝 Checklist Pre-Testing

### Antes de Lanzar en Simulador
- [ ] Verificar que no hay builds previos corriendo
- [ ] Simulador está encendido (o script lo encenderá)
- [ ] Código compilado sin errores (`flutter analyze`)
- [ ] Dependencies actualizadas (`flutter pub get`)

### Para Nuevo Simulador
- [ ] Borrar datos previos (`xcrun simctl erase [ID]`)
- [ ] Encender simulador (`xcrun simctl boot [ID]`)
- [ ] Esperar 5 segundos para que cargue
- [ ] Lanzar app (`flutter run -d [ID]`)

### Después de Cambios Importantes
- [ ] Flutter clean (`flutter clean`)
- [ ] Pub get (`flutter pub get`)
- [ ] Pod install si cambios iOS (`cd ios && pod install`)
- [ ] Rebuild completo

---

## 🎯 Próximos Pasos

1. ✅ **Script Creado** - `launch_biux_simulators.sh` listo
2. ✅ **Simuladores Identificados** - 5 iOS + 1 Android + 1 Web
3. ✅ **iPhone 16 Pro Max** - Ya está encendido
4. 🔄 **Listo para Lanzar** - Usa el script para comenzar

### Comando Recomendado para Empezar:
```bash
./launch_biux_simulators.sh 16promax
```

Esto iniciará automáticamente:
- ✅ Verificación de estado del simulador
- ✅ Encendido si está apagado
- ✅ Apertura de Simulator.app
- ✅ Compilación de Biux
- ✅ Instalación y lanzamiento en el dispositivo

---

**🚴 ¡Biux listo para probar en todos los simuladores! 🎉**

_Última actualización: 2 de diciembre de 2025_
