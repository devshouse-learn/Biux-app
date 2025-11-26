# 🚀 FASTLANE AUTOMATION - BIUX TESTFLIGHT

## 🎯 Objetivo

Automatizar el despliegue a TestFlight con:
- ✅ **Autoincremento** de build number
- ✅ **Compilación automática** de iOS
- ✅ **Upload automático** a TestFlight
- ✅ **Git hooks** para semiautomación
- ✅ **Local execution** - Todo en tu Mac

---

## 📦 Archivos Creados

```
📦 Proyecto BIUX
├── 📄 deploy.sh                    # Script principal
├── 📄 setup-fastlane.sh           # Setup inicial
├── 📄 DEPLOYMENT_GUIDE.md         # Guía completa
├── ios/
│   └── fastlane/
│       ├── Fastfile               # Configuración fastlane
│       ├── .env                   # Variables de entorno
│       └── .env.example           # Plantilla
└── .git/hooks/
    └── post-commit                # Git hook automático
```

---

## ⚡ Quick Start (2 minutos)

### 1️⃣ Setup Inicial

```bash
cd /Users/macmini/biux

# Ejecutar setup (una sola vez)
./setup-fastlane.sh
```

**¿Qué hace?**
- ✅ Verifica Xcode, CocoaPods, Fastlane
- ✅ Instala dependencias
- ✅ Configura Git hooks
- ✅ Verifica todo funciona

---

### 2️⃣ Configurar Credenciales

```bash
# Editar archivo de configuración
nano ios/fastlane/.env.local
```

**Campos a completar:**
```bash
FASTLANE_USER=tu_email@apple.com
FASTLANE_PASSWORD=app_password  # Usar "App-Specific Password"
TEAM_ID=XXXXXXXXXX              # De Apple Developer
APP_IDENTIFIER=org.devshouse.biux
```

📌 **Cómo obtener App-Specific Password:**
1. Ir a https://appleid.apple.com/account/manage
2. Seguridad → Generar contraseña de app
3. Copiar y usar en .env.local

---

### 3️⃣ Enviar a TestFlight

```bash
# Desde raíz del proyecto
./deploy.sh testflight
```

**¿Qué hace automáticamente?**
- 📊 Incrementa build number (ej: 41 → 42)
- 🔨 Compila iOS en Release
- 📦 Genera IPA
- 📤 Sube a TestFlight
- ✅ Listo en 5-10 minutos

---

## 📚 Comandos Disponibles

```bash
# Ver ayuda
./deploy.sh help

# Enviar a TestFlight (completo)
./deploy.sh testflight

# Solo compilar
./deploy.sh build

# Ver versión actual
./deploy.sh version

# Incrementar build number manual
./deploy.sh increment

# Ver estado del proyecto
./deploy.sh status
```

---

## 🔄 Automatización con Git Hooks

**Opción 1: Commit automático a TestFlight**

```bash
# Hacer commit con etiqueta [testflight]
git commit -m "feat: nueva funcionalidad [testflight]"

# Automáticamente:
# ✅ Hook detecta [testflight]
# ✅ Incrementa build number
# ✅ Compila
# ✅ Envía a TestFlight
```

**Opción 2: Manual (por paso)**

```bash
# Hacer cambios
nano lib/main.dart

# Commit normal
git commit -m "feat: nueva funcionalidad"

# Cuando listo para TestFlight
./deploy.sh testflight
```

---

## 🐛 Troubleshooting

### ❌ "Fastlane command not found"

```bash
# Solución: Usar path completo o crear alias
echo "alias fastlane='/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane'" >> ~/.zshrc
source ~/.zshrc
```

### ❌ "No provisioning profile"

```bash
# Verificar Team ID
cd ios && grep DEVELOPMENT_TEAM Runner.xcodeproj/project.pbxproj

# Actualizar en Xcode
open Runner.xcworkspace
# Xcode → Runner → Build Settings → Development Team
```

### ❌ "Authentication failed"

```bash
# Verificar credenciales
cat ios/fastlane/.env.local

# Re-login a App Store
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane pilot
```

### ❌ "Build failed"

```bash
# Ver logs detallados
cd ios
/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane testflight --verbose

# Compilar manualmente
cd ..
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

---

## 💡 Tips Profesionales

### Crear alias en zsh

```bash
# Editar ~/.zshrc
nano ~/.zshrc

# Agregar al final:
alias deploy='cd ~/biux && ./deploy.sh'
alias deploy-tf='cd ~/biux && ./deploy.sh testflight'
alias deploy-status='cd ~/biux && ./deploy.sh status'

# Reload
source ~/.zshrc

# Usar desde cualquier lugar:
deploy-tf  # ¡Directo!
```

### Schedule automático (Cron)

```bash
# Abrir crontab
crontab -e

# Ejecutar deploy todos los lunes a las 6 AM
0 6 * * 1 cd ~/biux && ./deploy.sh testflight >> ~/.deploy.log 2>&1
```

### Pre-flight checks

```bash
# Crear script pre-deploy.sh
#!/bin/bash
flutter analyze && \
flutter test && \
./deploy.sh testflight && \
echo "✅ Deploy completado!"
```

---

## 📊 Flujo Típico Diario

```
1. ✍️  Escribir código
   └─ nano lib/features/...

2. 🧪 Testear localmente
   └─ flutter run

3. 💾 Commit a Git
   └─ git commit -m "feat: nueva funcionalidad"

4. 🚀 Cuando listo para testear:
   ├─ Opción A (manual): ./deploy.sh testflight
   ├─ Opción B (automático): git commit -m "fix: bug [testflight]"
   └─ Esperar 5-10 minutos

5. 📱 Checkear en TestFlight
   └─ https://appstoreconnect.apple.com

6. 📊 Ver build number
   └─ ./deploy.sh version
```

---

## 🔐 Seguridad

### Variables sensibles

**No commits:**
- ✅ `ios/fastlane/.env.local` (ignorado en git)
- ✅ `~/.fastlane/FastlaneSessionToken` (local)

**Archivo de configuración:**
- `.env.example` - Plantilla pública
- `.env.local` - Tus credenciales (privado)

### .gitignore

Asegúrate de que existe:
```bash
echo "ios/fastlane/.env.local" >> .gitignore
echo ".git/hooks/testflight.log" >> .gitignore
```

---

## 📚 Documentación Adicional

Para más detalles, ver:
- `DEPLOYMENT_GUIDE.md` - Guía completa con ejemplos
- `ios/fastlane/Fastfile` - Configuración técnica
- `ios/fastlane/.env.example` - Variables de configuración

---

## ✅ Checklist de Setup

- [ ] Ejecuté `./setup-fastlane.sh`
- [ ] Edité `ios/fastlane/.env.local` con mis credenciales
- [ ] Verifiqué Team ID en Xcode
- [ ] Actualicé certificados en Apple Developer
- [ ] Probé `./deploy.sh version` (funciona)
- [ ] Probé `./deploy.sh build` (compila)
- [ ] Listo para hacer `./deploy.sh testflight`

---

## 🎉 ¡Listo!

Ahora tienes:

```
✅ Deployment automatizado
✅ Autoincremento de build
✅ Compilación simplificada
✅ Upload a TestFlight
✅ Git hooks configurados
✅ Todo local en tu Mac
```

**Próximo paso:**
```bash
./deploy.sh testflight
```

¡Disfruta del deployment automatizado! 🚀

---

## 📞 Contacto / Soporte

Si hay problemas:

1. Revisar `DEPLOYMENT_GUIDE.md`
2. Ejecutar con `--verbose`:
   ```bash
   cd ios
   /opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane testflight --verbose
   ```
3. Revisar logs:
   ```bash
   cat .git/hooks/testflight.log
   ```

---

**Última actualización:** 26 de Noviembre 2025  
**Versión:** 1.0.0  
**Fastlane:** 2.229.1
