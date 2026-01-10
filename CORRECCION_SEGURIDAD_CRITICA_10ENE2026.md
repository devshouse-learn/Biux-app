# 🔒 CORRECCIÓN CRÍTICA DE SEGURIDAD - 10 ENE 2026

## 🚨 PROBLEMA ENCONTRADO

**Archivo:** `deploy-worker.sh`  
**Severidad:** 🔴 **CRÍTICA**  
**Tipo:** Credenciales expuestas en texto plano

### Credenciales Expuestas
```bash
# ANTES (INSEGURO - CORREGIDO)
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="oecd-jqgg-kpxv-bqmb"  # ❌ PASSWORD EN TEXTO PLANO
```

---

## ✅ SOLUCIÓN APLICADA

### Archivo Corregido: `deploy-worker.sh`

```bash
# DESPUÉS (SEGURO)
# Credenciales - DEBEN ser configuradas como variables de entorno del sistema
# NO incluir credenciales directamente en este archivo
if [ -z "$APPLE_ID" ]; then
  echo "ERROR: APPLE_ID no está configurado en las variables de entorno" >> "$DAEMON_LOG"
  exit 1
fi

if [ -z "$APPLE_PASSWORD" ]; then
  echo "ERROR: APPLE_PASSWORD no está configurado en las variables de entorno" >> "$DAEMON_LOG"
  exit 1
fi

if [ -z "$TEAM_ID" ]; then
  export TEAM_ID="552JRWRZ88"  # Este es un ID público de equipo, no es secreto
fi
```

---

## 🔧 PASOS PARA CONFIGURAR CORRECTAMENTE

### 1. Configurar Variables de Entorno del Sistema

**En macOS (para LaunchAgent):**

Editar el archivo `.zprofile` o `.zshrc`:

```bash
nano ~/.zprofile
```

Agregar las siguientes líneas:

```bash
# Credenciales de Apple para deploy automatizado
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="tu-app-specific-password"
export TEAM_ID="552JRWRZ88"
```

Guardar y recargar:

```bash
source ~/.zprofile
```

---

### 2. Verificar Variables

```bash
echo $APPLE_ID
echo $APPLE_PASSWORD  # NO compartir la salida
echo $TEAM_ID
```

---

### 3. Reiniciar LaunchAgent (si aplica)

```bash
launchctl unload ~/Library/LaunchAgents/com.biux.deploy.plist
launchctl load ~/Library/LaunchAgents/com.biux.deploy.plist
```

---

## 🔐 MEJORES PRÁCTICAS DE SEGURIDAD

### ✅ Hacer:

1. **Usar variables de entorno** del sistema operativo
2. **App-Specific Passwords** para servicios de Apple
3. **Nunca** commitear credenciales al repositorio
4. Usar `.env` files con `.gitignore`
5. Rotar passwords periódicamente
6. Usar gestores de secretos (Keychain, 1Password, etc.)

### ❌ NO Hacer:

1. **NUNCA** incluir passwords en código fuente
2. **NUNCA** incluir tokens API en archivos versionados
3. **NUNCA** compartir credenciales por email o chat
4. **NUNCA** usar el mismo password para múltiples servicios
5. **NUNCA** hacer screenshots con credenciales visibles

---

## 📋 CHECKLIST DE SEGURIDAD POST-CORRECCIÓN

- [x] ✅ Credenciales removidas de `deploy-worker.sh`
- [x] ✅ Variables de entorno requeridas documentadas
- [x] ✅ Validación de variables agregada al script
- [ ] ⚠️ **URGENTE:** Revocar el password expuesto `oecd-jqgg-kpxv-bqmb`
- [ ] ⚠️ **URGENTE:** Generar nuevo App-Specific Password en iCloud
- [ ] ⚠️ Configurar nuevas variables de entorno en el sistema
- [ ] ⚠️ Verificar que `.gitignore` incluya archivos sensibles
- [ ] ⚠️ Buscar credenciales en otros archivos del proyecto

---

## 🔍 ARCHIVOS A REVISAR

Verificar que estos archivos NO contengan credenciales:

```bash
# Buscar posibles credenciales expuestas
grep -r "password\|apiKey\|secret\|token" --include="*.sh" --include="*.env" .

# Excluir de git
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo "*.key" >> .gitignore
echo "*.pem" >> .gitignore
```

---

## 🚨 ACCIONES INMEDIATAS REQUERIDAS

### 1. Revocar Password Expuesto

1. Ir a https://appleid.apple.com
2. Iniciar sesión
3. Ir a "Seguridad" → "Contraseñas específicas de apps"
4. Revocar el password `oecd-jqgg-kpxv-bqmb`
5. Generar uno nuevo

### 2. Configurar Nuevo Password

```bash
# 1. Editar archivo de entorno
nano ~/.zprofile

# 2. Agregar (con el NUEVO password)
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="tu-nuevo-app-specific-password"

# 3. Recargar
source ~/.zprofile

# 4. Verificar (SIN mostrar el password)
[ -n "$APPLE_PASSWORD" ] && echo "✅ Password configurado" || echo "❌ Password NO configurado"
```

### 3. Verificar Historial de Git

```bash
# Verificar si el password fue commiteado
git log -p --all -S "oecd-jqgg-kpxv-bqmb"

# Si aparece en commits, considerar reescribir historia
# (SOLO si no se ha hecho push público)
```

---

## 📚 RECURSOS ADICIONALES

- [Apple App-Specific Passwords](https://support.apple.com/en-us/HT204397)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Git Security Best Practices](https://owasp.org/www-project-top-ten/2017/A3_2017-Sensitive_Data_Exposure)

---

## 📝 LECCIÓN APRENDIDA

**Nunca incluir credenciales en código fuente**, incluso en scripts de deployment. Siempre usar variables de entorno del sistema, gestores de secretos, o archivos `.env` excluidos de git.

---

**Fecha de Corrección:** 10 de Enero de 2026  
**Prioridad:** 🔴 CRÍTICA  
**Estado:** ✅ Script Corregido | ⚠️ Password debe ser revocado  
**Responsable:** Debe completar pasos de seguridad inmediatamente
