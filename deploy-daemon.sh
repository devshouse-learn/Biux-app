#!/bin/bash

BIUX_PATH="/Users/macmini/biux"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAST_COMMIT="$BIUX_PATH/.last-deployed-commit"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.biux.deploy.plist"

create_worker() {
  cat > "$BIUX_PATH/deploy-worker.sh" << 'WORKER'
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
WORKER
  chmod +x "$BIUX_PATH/deploy-worker.sh"
}

setup_launchd() {
  mkdir -p "$(dirname "$LAUNCH_AGENT")"
  cat > "$LAUNCH_AGENT" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.biux.deploy</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$BIUX_PATH/deploy-worker.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>60</integer>
    <key>StandardOutPath</key>
    <string>$DAEMON_LOG</string>
    <key>StandardErrorPath</key>
    <string>$DAEMON_LOG</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>LANG</key>
        <string>en_US.UTF-8</string>
        <key>LC_ALL</key>
        <string>en_US.UTF-8</string>
        <key>APPLE_ID</key>
        <string>tu-email@icloud.com</string>
        <key>APPLE_PASSWORD</key>
        <string>oecd-jqgg-kpxv-bqmb</string>
        <key>TEAM_ID</key>
        <string>552JRWRZ88</string>
    </dict>
</dict>
</plist>
PLIST
}

start_daemon() {
  echo "🚀 Instalando daemon..."
  create_worker
  setup_launchd
  launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
  sleep 1
  launchctl load "$LAUNCH_AGENT" 2>/dev/null || true
  echo "✅ Daemon activo"
  echo "📝 Log: $DAEMON_LOG"
}

stop_daemon() {
  echo "⏹️ Parando..."
  launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
  echo "✅ Parado"
}

status_daemon() {
  if launchctl list com.biux.deploy &>/dev/null; then
    echo "✅ Daemon activo"
    [ -f "$DAEMON_LOG" ] && tail -5 "$DAEMON_LOG"
  else
    echo "❌ Daemon inactivo"
  fi
}

case "${1:-status}" in
  start) start_daemon ;;
  stop) stop_daemon ;;
  restart) stop_daemon; sleep 1; start_daemon ;;
  status) status_daemon ;;
  tail) tail -f "$DAEMON_LOG" ;;
  *) echo "Uso: $0 {start|stop|restart|status|tail}"; echo "Para desplegar: git commit -m 'msg [testflight]'" ;;
esac
