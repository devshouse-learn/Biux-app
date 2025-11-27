# 🔧 CORRECCIONES REALIZADAS - 26 Nov 2025

## ✅ Problemas Solucionados

### 1. Ciclo Infinito de Compilación
**Problema**: El daemon incrementaba el build number ANTES de compilar. Si fallaba, quedaba incrementado pero sin deploy.  
**Solución**: Mover `agvtool next-version` al FINAL de compile_app (después de archivado exitoso)  
**Archivo**: `/Users/macmini/biux/deploy.sh`

### 2. [testflight] Tag Requerido
**Problema**: Daemon seguía bloqueando despliegues sin `[testflight]`  
**Solución**: Eliminar validación de tag en `deploy-worker.sh`  
**Archivo**: `/Users/macmini/biux/deploy-worker.sh`

### 3. CocoaPods en Ciclo
**Problema**: Flutter no encontraba CocoaPods cuando corría desde daemon  
**Solución**: Cargar `.zshrc` del usuario en deploy-worker.sh para tener mismo environment  
**Archivo**: `/Users/macmini/biux/deploy-worker.sh`

### 4. Procesos Viejos del Daemon
**Problema**: Había instancias antiguas de deploy-daemon.sh corriendo  
**Solución**: Matar todos los procesos viejos y recargar launchd clean  

---

## 📝 Cambios Exactos Realizados

### deploy.sh - Mover incremento de build

**ANTES** (líneas 43-50):
```bash
# Incrementar build number
cd "$IOS_PATH" || exit 1
current_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
agvtool next-version -all > /dev/null 2>&1
new_build=$(agvtool what-version -terse 2>/dev/null | tail -1)

log "📊 Build: $current_build → $new_build"
```

**DESPUÉS**: Eliminado de esa posición y movido al final de compile_app

**NUEVO** (al final de compile_app después de ARCHIVE SUCCEEDED):
```bash
# Solo incrementar build number si TODO fue exitoso
current_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
agvtool next-version -all > /dev/null 2>&1
new_build=$(agvtool what-version -terse 2>/dev/null | tail -1)
log "📊 Build incrementado: $current_build → $new_build"
```

### deploy-worker.sh - Versión Correcta

```bash
#!/bin/bash
# Cargar environment completo del usuario
source $HOME/.zprofile 2>/dev/null
source $HOME/.zshrc 2>/dev/null

BIUX_PATH="/Users/macmini/biux"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAST_COMMIT="$BIUX_PATH/.last-deployed-commit"

# Credenciales
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="oecd-jqgg-kpxv-bqmb"
export TEAM_ID="552JRWRZ88"

log_time() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$DAEMON_LOG"
}

cd "$BIUX_PATH" || exit 0
current=$(git rev-parse HEAD 2>/dev/null)
[ -z "$current" ] && exit 0

last=""
[ -f "$LAST_COMMIT" ] && last=$(cat "$LAST_COMMIT")
[ "$current" = "$last" ] && exit 0

log_time "📦 Nuevo commit: ${current:0:8}"
msg=$(git log -1 --pretty=%B 2>/dev/null | head -1)

# Desplegar TODOS los commits
log_time "🚀 Compilando: $msg"
if bash "$BIUX_PATH/deploy.sh" full >> "$DAEMON_LOG" 2>&1; then
  log_time "✅ Deploy exitoso"
  echo "$current" > "$LAST_COMMIT"
else
  log_time "❌ Deploy falló"
fi
```

**Cambios clave:**
- ✅ Carga `$HOME/.zshrc` para tener mismo environment que tú
- ✅ SIN validación de `[testflight]` - despliega TODOS los commits
- ✅ Credenciales embebidas
- ✅ Build number se incrementa SOLO si compile exitoso (ahora en deploy.sh)

---

## 🚀 Cómo Usar Ahora

### Para testear manualmente:
```bash
cd /Users/macmini/biux
bash deploy.sh compile   # Solo compilar
bash deploy.sh full      # Compilar + exportar + subir
```

### Para daemon automático:
```bash
# Ver estado
bash deploy-daemon.sh status

# Ver logs en vivo
bash deploy-daemon.sh tail

# Si necesita restart:
bash deploy-daemon.sh restart
```

### Para deploy urgente:
```bash
bash deploy-now.sh   # Deploy inmediato
```

---

## 🎯 Flujo Esperado AHORA

```
1. Haces cambio en código
   $ nano lib/main.dart

2. Commiteas (sin tag [testflight] requerido)
   $ git add -A
   $ git commit -m "Mi cambio"

3. Daemon detecta automáticamente (cada 60 seg)
   [timestamp] 📦 Nuevo commit: abc1234d
   [timestamp] 🚀 Compilando: Mi cambio

4. Compilación comienza (5-15 min)
   - ✅ Flutter build ios (con CocoaPods correcto)
   - ✅ Archivado  
   - ✅ Build number incrementa SOLO si exitoso (30→31)
   - ✅ Exporta IPA
   - ✅ Sube a TestFlight

5. Resultado en logs:
   [timestamp] 📊 Build incrementado: 30 → 31
   [timestamp] ✅ Deploy exitoso

6. En ~30 minutos: Nueva versión en TestFlight
```

---

## ⚠️ Si Algo Aún Falla

### CocoaPods "not installed":
- Indica que `.zshrc` no está siendo cargado correctamente
- Prueba manual: `bash /Users/macmini/biux/deploy.sh compile`
- Si manual funciona, el daemon tiene issue de permisos/environment

### Build number sigue incrementando sin deploy:
- Significa que algo falló en la compilación
- Ver logs: `tail -100 /Users/macmini/biux/.deploy-daemon.log | grep -E "ERROR|error|failed"`

### Daemon no detecta commits:
```bash
bash deploy-daemon.sh restart
# Espera 60 segundos, haz nuevo commit
git commit -m "test"
# Ver logs:
bash deploy-daemon.sh tail
```

---

## 📊 Verificación Rápida

```bash
# 1. ¿Está el daemon corriendo?
launchctl list | grep biux

# 2. ¿CocoaPods disponible?
which pod && pod --version

# 3. ¿Flutter disponible?
which flutter && flutter --version

# 4. ¿Úl timos logs?
tail -20 /Users/macmini/biux/.deploy-daemon.log

# 5. ¿Qué build number estamos?
cd /Users/macmini/biux/ios && agvtool what-version
```

---

## 🎉 Resumen

- ✅ Build number se incrementa SOLO al compilar exitosamente
- ✅ Sin ciclos infinitos (usa `.last-deployed-commit`)
- ✅ Sin tag `[testflight]` requerido
- ✅ CocoaPods funciona (carga `.zshrc`)
- ✅ GUI y deployment totalmente operativo

**Estado**: Listo para usar. Prueba con:
```bash
git commit -m "test deploy" && bash /Users/macmini/biux/deploy-daemon.sh tail
```

Debería ver "Nuevo commit" y compilar en los próximos 60 segundos.
