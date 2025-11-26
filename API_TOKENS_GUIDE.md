# 🔐 CONFIGURACIÓN DE API TOKENS - FASTLANE BIUX

## ¿Por qué API Tokens en lugar de contraseñas?

| Aspecto | Contraseña | API Token |
|--------|-----------|-----------|
| Seguridad | ⚠️ Menos seguro | ✅ Muy seguro |
| Credenciales | ❌ Expone contraseña | ✅ Token específico |
| Permisos | ❌ Acceso completo | ✅ Permisos limitados |
| Revocable | ⚠️ Cambiar contraseña | ✅ Revocar token fácilmente |
| Automatización | ⚠️ Requiere 2FA | ✅ Sin 2FA |
| Profesional | ❌ Usuario personal | ✅ App-específico |

---

## 📋 3 Métodos de Autenticación (del más seguro al más simple)

### Opción 1: API Token (RECOMENDADO) ⭐⭐⭐

**Ventajas:**
- ✅ Más seguro que contraseña
- ✅ Permisos granulares
- ✅ Fácil de revocar
- ✅ Sin 2FA requerido
- ✅ Profesional y escalable

**Desventajas:**
- ⚠️ Requiere más pasos de configuración

---

### Opción 2: Xcode/Keychain (AUTOMÁTICO) ⭐⭐

**Ventajas:**
- ✅ Automático con Xcode
- ✅ Sin necesidad de tokens
- ✅ Seguro en Keychain
- ✅ Funciona si ya tienes Xcode configurado

**Desventajas:**
- ⚠️ Requiere 2FA configurado
- ⚠️ Depende de Xcode

---

### Opción 3: App-Specific Password ⭐

**Ventajas:**
- ✅ Más seguro que contraseña principal
- ✅ Rápido de configurar

**Desventajas:**
- ❌ Menos seguro que API Token
- ⚠️ Requiere 2FA

---

## 🎯 SETUP OPCIÓN 1: API Token (RECOMENDADO)

### Paso 1: Crear API Token en Apple

1. Ve a: https://appstoreconnect.apple.com/access/api
2. Haz clic en "Generate API Key" (esquina superior derecha)
3. Selecciona "App Manager" como rol
4. Descarga el archivo `AuthKey_XXXXXXXXXX.p8`

📌 **Importante:** 
- Guarda el archivo en lugar seguro
- No compartas con nadie
- Puedes descargar una sola vez

### Paso 2: Obtener IDs

Después de crear el token, verás:
- **Key ID** (ej: ABC123DEF45)
- **Issuer ID** (ej: 12345678-1234-1234-1234-123456789012)

Cópialos para el siguiente paso.

### Paso 3: Configurar en Fastlane

#### 3a. Copiar archivo de token

```bash
# Copiar el archivo AuthKey descargado
cp ~/Downloads/AuthKey_XXXXXXXXXX.p8 ios/fastlane/AuthKey.p8

# Verificar permisos
chmod 600 ios/fastlane/AuthKey.p8
```

#### 3b. Editar `.env.local`

```bash
nano ios/fastlane/.env.local
```

Agregar:
```bash
# API Token Configuration (RECOMENDADO)
APP_STORE_CONNECT_KEY_ID=ABC123DEF45
APP_STORE_CONNECT_ISSUER_ID=12345678-1234-1234-1234-123456789012

# Team Configuration
TEAM_ID=XXXXXXXXXX
TEAM_NAME="Tu Team Name"

# App Configuration
APP_IDENTIFIER=org.devshouse.biux
```

#### 3c. Verificar Fastfile

El Fastfile ya detecta automáticamente el token:

```ruby
if use_api_key
  UI.message("🔐 Usando API Token para autenticación")
  app_store_connect_api_key(
    key_id: ENV["APP_STORE_CONNECT_KEY_ID"],
    issuer_id: ENV["APP_STORE_CONNECT_ISSUER_ID"],
    key_filepath: api_key_path,
    in_house: false
  )
end
```

### Paso 4: Probar

```bash
./deploy.sh version
```

Si funciona, verás:
```
🔐 Usando API Token para autenticación
📊 Version: 1.0.0 (Build: 42)
```

---

## 🎯 SETUP OPCIÓN 2: Xcode/Keychain (AUTOMÁTICO)

### Paso 1: Configurar 2FA en Apple ID

1. Ve a: https://appleid.apple.com
2. Seguridad → Número de teléfono verificado
3. Habilitar "Verificación en dos pasos"

### Paso 2: Xcode se conecta automáticamente

Abre Xcode y:
1. Xcode → Preferences → Accounts
2. Agregar tu Apple ID
3. Xcode guardará credenciales en Keychain

### Paso 3: Fastlane usa automáticamente

```bash
./deploy.sh testflight
```

Fastlane detectará automáticamente Keychain.

---

## 🎯 SETUP OPCIÓN 3: App-Specific Password

### Paso 1: Crear contraseña de app

1. Ve a: https://appleid.apple.com/account/manage
2. Seguridad → Contraseña de app
3. Selecciona "Other (Custom name)" → "fastlane"
4. Copia la contraseña generada

### Paso 2: Configurar en `.env.local`

```bash
nano ios/fastlane/.env.local
```

Agregar:
```bash
FASTLANE_USER=tu_email@apple.com
FASTLANE_PASSWORD=xxxx-xxxx-xxxx-xxxx
```

### Paso 3: Probar

```bash
./deploy.sh testflight
```

---

## 🔒 Seguridad - ¿Dónde van los tokens/contraseñas?

### ✅ SEGURO (Local en tu Mac)
```
~/.fastlane/FastlaneSessionToken
ios/fastlane/AuthKey.p8
ios/fastlane/.env.local
```

Estos archivos están en `.gitignore` - nunca se suben a Git.

### ✅ EXTRA SEGURO (Keychain)
Xcode guarda credenciales directamente en Keychain del Mac.

### ❌ NUNCA HAGAS ESTO
- ❌ No subas `AuthKey.p8` a Git
- ❌ No compartas tokens/contraseñas
- ❌ No pongas credenciales en commits

---

## 📝 Comparativa: ¿Cuál usar?

```
┌─────────────────┬──────────┬─────────────┬────────────┐
│ Método          │ Seguridad│ Complejidad │ Recomendado│
├─────────────────┼──────────┼─────────────┼────────────┤
│ API Token       │ ⭐⭐⭐   │ ⭐⭐       │ ✅ SÍ      │
│ Xcode/Keychain  │ ⭐⭐⭐   │ ⭐         │ ✅ SÍ      │
│ App Password    │ ⭐⭐    │ ⭐         │ ⭐ Opcional│
└─────────────────┴──────────┴─────────────┴────────────┘
```

---

## ✅ Opción Recomendada: COMBINAR

**Mejor práctica profesional:**

```
1. Configurar API Token (principal)
2. Tener Xcode/Keychain como fallback
3. Fastlane automáticamente elige la mejor
```

Así si falla uno, funciona el otro automáticamente.

---

## 🔄 Si falla la autenticación

### ❌ Error: "Authentication failed"

**Soluciones:**
```bash
# 1. Verificar archivo de token existe
ls -la ios/fastlane/AuthKey.p8

# 2. Verificar variables de entorno
cat ios/fastlane/.env.local | grep APP_STORE

# 3. Verificar Xcode logged in
xcode-select --install

# 4. Login a Xcode
security unlock-keychain -p tu_contraseña_mac
```

### ❌ Error: "File not found: AuthKey.p8"

```bash
# Verificar ubicación del archivo
cp ~/Downloads/AuthKey_XXXXXXXXXX.p8 ios/fastlane/AuthKey.p8
```

### ❌ Error: "Invalid Key ID"

```bash
# Verificar IDs en Apple Developer
# Debe coincidir exactamente con:
# - APP_STORE_CONNECT_KEY_ID
# - APP_STORE_CONNECT_ISSUER_ID
```

---

## 🚀 Flujo Final

```bash
# 1. Setup inicial (una sola vez)
./setup-fastlane.sh

# 2. Configurar API Token
# - Descargar AuthKey.p8
# - Copiar a ios/fastlane/
# - Editar .env.local con Key ID e Issuer ID

# 3. Probar
./deploy.sh version

# 4. ¡A usar!
./deploy.sh testflight
```

---

## 📚 Links Útiles

- **Apple Developer:** https://developer.apple.com
- **App Store Connect:** https://appstoreconnect.apple.com
- **API Tokens:** https://appstoreconnect.apple.com/access/api
- **Fastlane Docs:** https://docs.fastlane.tools
- **App-Specific Passwords:** https://appleid.apple.com/account/manage

---

## ✨ Resumen

| Método | Setup | Seguridad | Automático |
|--------|-------|-----------|-----------|
| **API Token** | 15 min | ⭐⭐⭐ | ✅ Recomendado |
| **Xcode** | 5 min | ⭐⭐⭐ | ✅ Si está configurado |
| **App Password** | 5 min | ⭐⭐ | ✅ Funciona |

---

**Recomendación Final:** Usa **API Token** para máxima seguridad y profesionalismo. 🔐

Después elige entre:
- ✅ **Automático:** `./deploy.sh testflight` sin preguntas
- ✅ **Seguro:** Tokens en Keychain
- ✅ **Profesional:** Escalable a múltiples desarrolladores
