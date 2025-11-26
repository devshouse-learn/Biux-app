# 🚀 GUÍA DE DEPLOYMENT AUTOMATIZADO - BIUX TESTFLIGHT

## 📋 Contenido

1. [Instalación](#instalación)
2. [Uso Rápido](#uso-rápido)
3. [Comandos Disponibles](#comandos-disponibles)
4. [Automatización con Git Hooks](#automatización-con-git-hooks)
5. [Troubleshooting](#troubleshooting)
6. [Configuración Avanzada](#configuración-avanzada)

---

## 📦 Instalación

### Paso 1: Verificar que Fastlane está instalado

```bash
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane --version
```

Si no está instalado:
```bash
sudo gem install fastlane -NV
```

### Paso 2: Verificar estructura de directorios

```bash
ls -la ios/fastlane/
```

Debes ver:
- `Fastfile` - Configuración de tareas
- `.env` - Variables de entorno

### Paso 3: Preparar App Store Connect

1. Asegúrate de que tu Team ID esté configurado
2. Certificados y provisioning profiles actualizados
3. Credenciales en:
   ```
   ~/.fastlane/FastlaneSessionToken
   ```

---

## 🎯 Uso Rápido

### Opción A: Usar script wrapper (RECOMENDADO)

```bash
# Desde la raíz del proyecto
./deploy.sh testflight
```

### Opción B: Usar fastlane directamente

```bash
# Desde el directorio ios/
cd ios
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane testflight
```

---

## 📚 Comandos Disponibles

### 1. Enviar a TestFlight (Autoincremento + Build + Upload)

```bash
./deploy.sh testflight
```

**¿Qué hace?**
- ✅ Incrementa automáticamente el build number
- ✅ Compila la app en modo Release
- ✅ Envia a TestFlight
- ✅ Muestra mensajes de progreso

**Ejemplo de salida:**
```
================================
🚀 ENVIANDO A TESTFLIGHT
================================
✅ Build number incrementado a: 42
🔨 Compilando para iOS...
✅ Build completado exitosamente
📤 Enviando a TestFlight...
✅ ¡Subida a TestFlight completada!
```

---

### 2. Solo Compilar (sin TestFlight)

```bash
./deploy.sh build
```

**Útil para:** Verificar que todo compila antes de enviar

---

### 3. Ver Versión Actual

```bash
./deploy.sh version
```

**Ejemplo de salida:**
```
Version: 1.0.0 (Build: 42)
```

---

### 4. Incrementar Build Number

```bash
./deploy.sh increment
```

**Manual:** Useful para preparar antes de hacer commit

---

### 5. Ver Estado del Proyecto

```bash
./deploy.sh status
```

**Muestra:** Versión, build number y archivos principales

---

### 6. Mostrar Ayuda

```bash
./deploy.sh help
```

---

## 🔄 Automatización con Git Hooks

### Método 1: Commit con etiqueta [testflight]

El hook post-commit automáticamente detecta `[testflight]` en el mensaje y envía a TestFlight:

```bash
# Hacer commit con etiqueta especial
git commit -m "feat: nueva funcionalidad [testflight]"

# El hook automáticamente:
# ✅ Incrementa build number
# ✅ Compila
# ✅ Envía a TestFlight
```

**Ventajas:**
- ✅ Semiautomático (decidir por commit)
- ✅ Control total
- ✅ Logs disponibles

---

### Método 2: Script personalizado

Crear archivo `~/bin/biux-deploy`:

```bash
#!/bin/bash
cd ~/path/to/biux
./deploy.sh testflight
```

Luego usar desde cualquier lugar:
```bash
biux-deploy
```

---

## 🐛 Troubleshooting

### ❌ "Fastlane command not found"

**Solución:**
```bash
# Usar path completo
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane testflight

# O crear alias en ~/.zshrc:
echo "alias fastlane='/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane'" >> ~/.zshrc
source ~/.zshrc
```

---

### ❌ "No provisioning profile found"

**Soluciones:**
1. Actualizar certificados en Xcode:
   ```bash
   xcode-select --install
   ```

2. Verificar Team ID:
   ```bash
   cd ios
   grep -r "DEVELOPMENT_TEAM" Runner.xcodeproj/project.pbxproj
   ```

3. Actualizar provisioning profiles:
   - Ve a Apple Developer Console
   - Regenera los provisioning profiles
   - Descárgalos en Xcode

---

### ❌ "Authentication required"

**Solución:**
```bash
# Login a App Store Connect
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane action init
```

Luego seguir las instrucciones de login

---

### ❌ "Build failed"

**Opciones de debugging:**
1. Ver logs completos:
   ```bash
   cd ios
   /opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane testflight --verbose
   ```

2. Compilar manualmente:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   flutter build ios --release
   ```

---

## 🔧 Configuración Avanzada

### Personalizar Fastfile

Editar `ios/fastlane/Fastfile`:

#### Cambiar canal de TestFlight

```ruby
lane :testflight do |options|
  # ... código previo ...
  
  upload_to_testflight(
    ipa: "Runner.ipa",
    beta_app_feedback_email: "tu@email.com",  # Email de contacto
    skip_waiting_for_build_processing: false  # Esperar a que procese
  )
end
```

#### Notificaciones personalizado

```ruby
lane :testflight do |options|
  # ... código previo ...
  
  # Slack notification
  build_number = get_build_number(xcodeproj: "Runner.xcodeproj")
  slack(
    message: "🚀 Build #{build_number} enviado a TestFlight",
    success: true
  )
end
```

#### Cambiar configuración de compilación

```ruby
lane :testflight do |options|
  build_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    configuration: "Release",
    # Aumentar timeout si tienes máquina lenta:
    destination_timeout: 600,  # 10 minutos
    # Ver más output:
    verbose: true
  )
end
```

---

## 📊 Monitoreo

### Ver historial de builds

```bash
cd ios
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane action pilot
```

### Ver logs del post-commit hook

```bash
cat .git/hooks/testflight.log
```

### Limpiar logs antiguos

```bash
rm .git/hooks/testflight.log
```

---

## ⚡ Tips & Tricks

### 1. Hacer alias en zsh

Agregar a `~/.zshrc`:

```bash
alias deploy='cd ~/path/to/biux && ./deploy.sh'
alias deploy-tf='cd ~/path/to/biux && ./deploy.sh testflight'
alias deploy-status='cd ~/path/to/biux && ./deploy.sh status'
```

Luego:
```bash
source ~/.zshrc
deploy-tf  # Directamente!
```

### 2. Schedule automático

Crear cron job (ejecutar diariamente):

```bash
# Abrir crontab
crontab -e

# Agregar línea (ejecutar a las 6 AM cada día):
0 6 * * * cd ~/path/to/biux && ./deploy.sh testflight >> ~/.deploy.log 2>&1
```

### 3. Pre-flight checks

Crear script de validación:

```bash
#!/bin/bash
echo "🔍 Verificando antes de deploy..."
flutter analyze && echo "✅ Análisis OK"
flutter test && echo "✅ Tests OK"
./deploy.sh testflight && echo "✅ Deploy OK"
```

### 4. Rollback de build number

Si necesitas revertir:

```bash
cd ios
# Ver build number actual
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane action get_build_number

# Cambiar a específico
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane action set_build_number number:40
```

---

## 📱 Flujo Típico de Desarrollo

```bash
# 1. Hacer cambios en código
nano lib/main.dart

# 2. Testear localmente
flutter run

# 3. Commit con análisis
git add .
git commit -m "feat: nueva pantalla de login"

# 4. Cuando listo para TestFlight:
git commit --amend -m "feat: nueva pantalla de login [testflight]"

# Automáticamente:
# ✅ Post-commit hook detecta [testflight]
# ✅ Incrementa build number
# ✅ Compila
# ✅ Envia a TestFlight

# 5. Chequear estado
./deploy.sh status

# 6. Ver en TestFlight (App Store Connect)
open https://appstoreconnect.apple.com
```

---

## 🎉 ¡Listo!

Ahora tienes deployment automatizado con:
- ✅ Autoincremento de build number
- ✅ Compilación simplificada
- ✅ Upload a TestFlight automatizado
- ✅ Git hooks para semiautomación
- ✅ Logging completo para debugging

**Próximo paso:** 
```bash
./deploy.sh testflight
```

¡Que disfrutes del deployment automatizado! 🚀
