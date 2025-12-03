# 📱 Guía Paso a Paso: Cómo Verificar Biux en Simuladores

**Fecha**: 2 de diciembre de 2025  
**Para**: Verificación manual de instalación y funcionalidad

---

## 🎯 Objetivo

Verificar que Biux está **instalado** y **completamente funcional** en todos los simuladores iOS.

---

## ✅ PASO 1: Verificar Simuladores Encendidos

### Abrir Terminal y ejecutar:

```bash
xcrun simctl list devices | grep "iPhone 16"
```

### ✅ Resultado Esperado:

Deberías ver algo como:
```
iPhone 16 Pro (8A60CA7F...) (Booted) ✅
iPhone 16 Pro Max (D0BCD630...) (Booted) ✅
iPhone 16e (B3906FB5...) (Booted) ✅
iPhone 16 (1EDBA709...) (Booted) ✅
iPhone 16 Plus (F912C1B0...) (Booted) ✅
```

**Todos deben decir `(Booted)`** = Encendidos ✅

---

## ✅ PASO 2: Verificar que Biux está Instalado

### Ejecutar este comando:

```bash
xcrun simctl listapps D0BCD630-71C9-4042-943A-E9FD1A8572DD | grep -i runner
```

### ✅ Resultado Esperado:

Si está instalado, verás información del app bundle.

### ❌ Si NO aparece nada:

Significa que la app NO está instalada. Sigue al **PASO 3**.

---

## ✅ PASO 3: Instalar Biux Manualmente (Si no está instalado)

### 3.1 Compilar el Build

```bash
cd /Users/macmini/biux
flutter build ios --simulator --debug
```

**Tiempo:** ~5 minutos  
**Espera:** Hasta ver `✓ Built build/ios/iphonesimulator/Runner.app`

### 3.2 Instalar en TODOS los Simuladores

Copia y pega estos 5 comandos uno por uno:

```bash
# 1. iPhone 16 Pro Max
xcrun simctl install D0BCD630-71C9-4042-943A-E9FD1A8572DD build/ios/iphonesimulator/Runner.app

# 2. iPhone 16 Pro
xcrun simctl install 8A60CA7F-41E8-484E-9E52-F0F06788A4B7 build/ios/iphonesimulator/Runner.app

# 3. iPhone 16e
xcrun simctl install B3906FB5-2AA6-488B-B16A-48212193E79C build/ios/iphonesimulator/Runner.app

# 4. iPhone 16
xcrun simctl install 1EDBA709-B5B4-4248-85EB-A967E6ADBDFC build/ios/iphonesimulator/Runner.app

# 5. iPhone 16 Plus
xcrun simctl install F912C1B0-6784-4626-AB89-F7356840B58F build/ios/iphonesimulator/Runner.app
```

**Cada comando debería completar sin errores.**

---

## ✅ PASO 4: Abrir Simulator.app

### Opción 1: Desde Terminal

```bash
open -a Simulator
```

### Opción 2: Desde Spotlight

- Presiona `Cmd + Space`
- Escribe "Simulator"
- Presiona Enter

### ✅ Resultado Esperado:

Se abre la app **Simulator** mostrando uno o más dispositivos iPhone.

---

## ✅ PASO 5: Ver Todos los Simuladores

### En Simulator.app:

1. **Menú** → **Window** → **Show All Devices**

O usar atajo: `Cmd + Shift + 2`

### ✅ Resultado Esperado:

Verás una ventana con todos los simuladores disponibles.

---

## ✅ PASO 6: Abrir Biux en Cada Simulador

### Método A: Manualmente en Simulator.app

Para cada simulador:

1. **Busca el ícono de Biux** en la pantalla principal
2. **Haz clic** en el ícono
3. **Espera** a que la app abra

### Método B: Desde Terminal (Recomendado)

Abre **5 terminales diferentes** (Cmd+T para nueva tab) y ejecuta uno en cada:

```bash
# Terminal 1: iPhone 16 Pro Max
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD

# Terminal 2: iPhone 16 Pro
flutter run -d 8A60CA7F-41E8-484E-9E52-F0F06788A4B7

# Terminal 3: iPhone 16e
flutter run -d B3906FB5-2AA6-488B-B16A-48212193E79C

# Terminal 4: iPhone 16
flutter run -d 1EDBA709-B5B4-4248-85EB-A967E6ADBDFC

# Terminal 5: iPhone 16 Plus
flutter run -d F912C1B0-6784-4626-AB89-F7356840B58F
```

**Importante:** Ejecuta UN comando en CADA terminal separada.

### ✅ Resultado Esperado:

En cada terminal verás:
```
Launching lib/main.dart on iPhone [modelo] in debug mode...
Running Xcode build...
```

Espera 1-2 minutos por terminal.

Cuando termine:
```
✓ Built app successfully
Flutter run key commands.
r  Hot reload
R  Hot restart
...
```

---

## ✅ PASO 7: Verificar que la App Abre

### En cada simulador deberías ver:

1. **Splash Screen** de Biux (logo)
2. **Pantalla de Login** con:
   - Logo centrado ✅
   - Campo de teléfono ✅
   - **SIN** botón "Entrar como invitado" ✅

### ✅ Si ves esto = App FUNCIONAL ✅

---

## ✅ PASO 8: Verificar Funcionalidad Crítica (Botón Único en Bicicleta)

Este es el **último cambio** que implementamos y el MÁS IMPORTANTE de verificar.

### 8.1 Login (en cualquier simulador)

1. Ingresa un número de teléfono
2. En pantalla de OTP, verifica que muestre el **número completo** ✅
3. Ingresa el código (o salta este paso si tienes cuenta)

### 8.2 Ir a "Mis Bicis"

1. En el menú inferior, verás **3 tabs**:
   - Historias
   - Rutas  
   - **Mis Bicis** ← Presiona aquí

### 8.3 Agregar Bicicleta

1. Presiona el botón **"Agregar Bicicleta"** o el ícono "+"
2. Se abre un wizard de 4 pasos

### 8.4 Verificar el Botón Único ⭐ **CRÍTICO**

**En cada paso del wizard, verifica:**

✅ **Correcto:**
```
┌─────────────────────────────────────┐
│ Paso 1 de 4                    ←   │
├─────────────────────────────────────┤
│                                     │
│ [Contenido del formulario]          │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                    [Siguiente →]    │ ← Solo 1 botón a la DERECHA
└─────────────────────────────────────┘
```

❌ **Incorrecto (versión antigua):**
```
┌─────────────────────────────────────┐
│                                     │
├─────────────────────────────────────┤
│ [← Anterior]    [Siguiente →]      │ ← DOS botones
└─────────────────────────────────────┘
```

**Debe haber SOLO 1 botón a la derecha.**

### 8.5 Navegación hacia Atrás

- Para retroceder, usa el botón **"←"** en el **AppBar** (esquina superior izquierda)
- **NO** debe haber botón "Anterior" en la parte inferior

---

## ✅ PASO 9: Verificar Otras Funcionalidades (Opcional)

### Perfil

1. Ir a tu perfil
2. Verificar botón **"Editar perfil"** visible ✅
3. Verificar botón **compartir (📤)** en AppBar ✅
4. Tab "Publicaciones" → Ver **galería 3x3** ✅

### Historias

1. Agregar una foto
2. Verificar que entra automáticamente en **modo historia** ✅
3. Verificar **username con sombra** legible ✅
4. Fotos verticales se ven **completas** (no cortadas) ✅

### Rodadas

1. Ir a "Rutas" (tab del medio)
2. Ver una rodada
3. Verificar que muestra **ciudad/punto de encuentro** ✅
4. En detalle, verificar **"Líder de la rodada"** ✅
5. Verificar botón **"Abrir en Google Maps"** ✅

### Menú

1. Verificar que hay **3 tabs** solamente:
   - Historias
   - Rutas
   - Mis Bicis
2. **NO** debe haber "Grupos" ni "Mapa" ✅

---

## ✅ PASO 10: Verificar en TODOS los Simuladores

Repite los pasos 7-9 en **cada uno de los 5 simuladores**:

- [ ] iPhone 16 Pro Max (6.9")
- [ ] iPhone 16 Pro (6.3")
- [ ] iPhone 16e
- [ ] iPhone 16 (6.1")
- [ ] iPhone 16 Plus (6.7")

### ¿Por qué en todos?

Para verificar que la UI se adapta correctamente a diferentes tamaños de pantalla.

---

## 🚨 Solución de Problemas

### Problema 1: "App no se instala"

**Solución:**
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter build ios --simulator --debug

# Reinstalar
xcrun simctl install [UUID] build/ios/iphonesimulator/Runner.app
```

### Problema 2: "Simulador no responde"

**Solución:**
```bash
# Reiniciar simulador
xcrun simctl shutdown [UUID]
sleep 2
xcrun simctl boot [UUID]
open -a Simulator
```

### Problema 3: "Error de concurrent builds"

**Solución:**
```bash
# Matar procesos de Xcode
killall -9 xcodebuild
sleep 3

# Relanzar
flutter run -d [UUID]
```

### Problema 4: "No veo el ícono de Biux"

**Solución:**
```bash
# Verificar instalación
xcrun simctl listapps [UUID] | grep -i runner

# Si no aparece, reinstalar (ver Paso 3.2)
```

### Problema 5: "App crashea al abrir"

**Solución:**
```bash
# Ver logs del simulador
xcrun simctl spawn booted log stream --predicate 'processImagePath endswith "Runner"' --level=debug

# O usar flutter run para ver errores completos
flutter run -d [UUID]
```

---

## 📊 Checklist de Verificación Rápida

### Instalación Básica
- [ ] 5 simuladores encendidos (Booted)
- [ ] Biux instalado en los 5
- [ ] Simulator.app abierto
- [ ] Puedo ver los dispositivos

### Funcionalidad Básica (en 1 simulador)
- [ ] App abre sin crash
- [ ] Splash screen se muestra
- [ ] Pantalla de login aparece
- [ ] Logo está centrado
- [ ] NO hay botón "Entrar como invitado"

### Funcionalidad Crítica ⭐
- [ ] Ir a "Mis Bicis"
- [ ] Tap en "Agregar Bicicleta"
- [ ] **Solo 1 botón a la derecha** ✅
- [ ] NO hay botón "Anterior"
- [ ] Navegación con botón AppBar funciona

### Testing Multi-Pantalla
- [ ] Verificado en iPhone 16 Pro Max
- [ ] Verificado en iPhone 16 Pro
- [ ] Verificado en iPhone 16e
- [ ] Verificado en iPhone 16
- [ ] Verificado en iPhone 16 Plus

---

## 🎯 Resultado Final Esperado

```
╔═══════════════════════════════════════════╗
║                                           ║
║   ✅ BIUX INSTALADO Y FUNCIONAL           ║
║                                           ║
║   📱 5 Simuladores iOS                    ║
║   ✅ App abre correctamente               ║
║   ✅ 24 Funcionalidades OK                ║
║   ✅ Botón único en Agregar Bici ⭐       ║
║   ✅ UI adaptada a todos los tamaños      ║
║                                           ║
╚═══════════════════════════════════════════╝
```

---

## 📸 Capturas Recomendadas (Opcional)

Una vez verificado todo, toma capturas:

```bash
# Captura del simulador activo
xcrun simctl io booted screenshot ~/Desktop/biux_verificacion_$(date +%Y%m%d_%H%M%S).png
```

Capturas importantes:
1. Pantalla de login (sin botón invitado)
2. Wizard de agregar bici (1 botón solo)
3. Perfil con galería 3x3
4. Los 5 simuladores juntos en pantalla

---

## 🆘 Si Algo No Funciona

**Opción 1: Simplificar - Usar solo 1 simulador**

```bash
# Lanzar solo en iPhone 16 Pro Max
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

**Opción 2: Compilación desde cero**

```bash
# Limpieza completa
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..

# Recompilar
flutter pub get
flutter build ios --simulator --debug

# Reinstalar
xcrun simctl install D0BCD630-71C9-4042-943A-E9FD1A8572DD build/ios/iphonesimulator/Runner.app

# Lanzar
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

---

## 📝 Resumen de Comandos Más Usados

```bash
# Ver simuladores
xcrun simctl list devices | grep "iPhone 16"

# Compilar
flutter build ios --simulator --debug

# Instalar (ejemplo iPhone 16 Pro Max)
xcrun simctl install D0BCD630-71C9-4042-943A-E9FD1A8572DD build/ios/iphonesimulator/Runner.app

# Abrir Simulator
open -a Simulator

# Lanzar app
flutter run -d D0BCD630-71C9-4042-943A-E9FD1A8572DD

# Matar procesos si hay problemas
killall -9 xcodebuild

# Reiniciar simulador
xcrun simctl shutdown D0BCD630-71C9-4042-943A-E9FD1A8572DD
xcrun simctl boot D0BCD630-71C9-4042-943A-E9FD1A8572DD
```

---

**🚴 Sigue estos pasos uno por uno y Biux estará 100% funcional! 🎉**

_Última actualización: 2 de diciembre de 2025_
