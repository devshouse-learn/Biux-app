#!/bin/bash

# 🚀 BIUX Deploy Daemon - Versión mejorada (launchd)
# Servicio que verifica cada minuto si hay commits para desplegar a TestFlight
# Usa launchd en macOS para persistencia

BIUX_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAEMON_SCRIPT="$BIUX_PATH/deploy-daemon-worker.sh"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.biux.deploy.plist"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# Crear script worker
# ============================================

create_worker_script() {
  cat > "$DAEMON_SCRIPT" << 'WORKER_EOF'
#!/bin/bash

BIUX_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAST_COMMIT_FILE="$BIUX_PATH/.last-deployed-commit"

log_message() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $1" >> "$DAEMON_LOG"
}

cd "$BIUX_PATH" || exit 1

# Obtener último commit
current_commit=$(git rev-parse HEAD 2>/dev/null)
if [ -z "$current_commit" ]; then
  exit 0
fi

# Obtener último commit desplegado
last_deployed=""
if [ -f "$LAST_COMMIT_FILE" ]; then
  last_deployed=$(cat "$LAST_COMMIT_FILE")
fi

# Si son diferentes, desplegar
if [ "$current_commit" != "$last_deployed" ]; then
  log_message "📦 Nuevo commit: ${current_commit:0:8}"
  
  commit_msg=$(git log -1 --pretty=%B 2>/dev/null | head -1)
  
  if [[ "$commit_msg" =~ \[testflight\]|\[deploy\] ]]; then
    log_message "🚀 Desplegando: $commit_msg"
    
    if cd "$BIUX_PATH" && bash deploy.sh testflight >> "$DAEMON_LOG" 2>&1; then
      log_message "✅ Deploy exitoso"
      echo "$current_commit" > "$LAST_COMMIT_FILE"
    else
      log_message "❌ Error en deploy"
    fi
  fi
fi
WORKER_EOF

  chmod +x "$DAEMON_SCRIPT"
}

# ============================================
# Crear launchd plist
# ============================================

create_launchd_plist() {
  mkdir -p "$(dirname "$LAUNCH_AGENT")"
  
  cat > "$LAUNCH_AGENT" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.biux.deploy</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$DAEMON_SCRIPT</string>
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
</dict>
</plist>
PLIST_EOF
}

# ============================================
# Funciones principales
# ============================================

start_daemon() {
  echo -e "${BLUE}🚀 Instalando Deploy Daemon...${NC}"
  
  create_worker_script
  create_launchd_plist
  
  launchctl load "$LAUNCH_AGENT" 2>/dev/null || launchctl unload "$LAUNCH_AGENT" 2>/dev/null ; launchctl load "$LAUNCH_AGENT"
  
  echo -e "${GREEN}✅ Daemon instalado y activo${NC}"
  echo -e "${BLUE}📍 Ubicación:${NC} $LAUNCH_AGENT"
  echo -e "${BLUE}📝 Log:${NC} $DAEMON_LOG"
  echo ""
  echo "Verifica con: $0 status"
}

stop_daemon() {
  echo -e "${YELLOW}⏹️  Deteniendo daemon...${NC}"
  launchctl unload "$LAUNCH_AGENT" 2>/dev/null || true
  echo -e "${GREEN}✅ Daemon detenido${NC}"
}

status_daemon() {
  if launchctl list com.biux.deploy &>/dev/null; then
    echo -e "${GREEN}✅ Daemon activo (launchd)${NC}"
    echo -e "${BLUE}📝 Log:${NC} $DAEMON_LOG"
    echo ""
    echo "Últimos eventos:"
    if [ -f "$DAEMON_LOG" ]; then
      tail -n 5 "$DAEMON_LOG" | sed 's/^/  /'
    fi
  else
    echo -e "${RED}❌ Daemon no está activo${NC}"
    echo "Inicia con: $0 start"
  fi
}

# ============================================
# Main
# ============================================

case "${1:-status}" in
  start)
    start_daemon
    ;;
  stop)
    stop_daemon
    ;;
  restart)
    stop_daemon
    sleep 1
    start_daemon
    ;;
  status)
    status_daemon
    ;;
  tail)
    if [ -f "$DAEMON_LOG" ]; then
      tail -f "$DAEMON_LOG"
    else
      echo "Log no existe aún"
    fi
    ;;
  *)
    echo "Uso: $0 {start|stop|restart|status|tail}"
    echo ""
    echo "Comandos:"
    echo "  start    - Instalar y activar el daemon"
    echo "  stop     - Desactivar el daemon"
    echo "  restart  - Reiniciar"
    echo "  status   - Ver estado"
    echo "  tail     - Ver log en tiempo real"
    echo ""
    echo "Para desplegar a TestFlight:"
    echo "  git commit -m 'Mensaje [testflight]'"
    ;;
esac
