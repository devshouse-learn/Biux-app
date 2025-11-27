#!/bin/bash
BIUX_PATH="/Users/macmini/biux"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
LAST_COMMIT="$BIUX_PATH/.last-deployed-commit"

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

if ! [[ "$msg" =~ \[testflight\]|\[deploy\] ]]; then
  log_time "ℹ️ Sin tag [testflight]"
  exit 0
fi

log_time "🚀 Compilando: $msg"
if bash "$BIUX_PATH/deploy.sh" full >> "$DAEMON_LOG" 2>&1; then
  log_time "✅ Deploy exitoso"
  echo "$current" > "$LAST_COMMIT"
else
  log_time "❌ Deploy falló"
fi
