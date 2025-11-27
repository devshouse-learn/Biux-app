#!/bin/bash
# Cargar environment del usuario
source $HOME/.zprofile 2>/dev/null
source $HOME/.zshrc 2>/dev/null

# Asegurar que CocoaPods está disponible
if [ -x "/opt/homebrew/bin/pod" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

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

# Desplegar TODOS los commits (sin tag [testflight] requerido)
log_time "🚀 Compilando: $msg"
if bash "$BIUX_PATH/deploy.sh" full >> "$DAEMON_LOG" 2>&1; then
  log_time "✅ Deploy exitoso"
  echo "$current" > "$LAST_COMMIT"
else
  log_time "❌ Deploy falló"
fi
