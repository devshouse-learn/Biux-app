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
