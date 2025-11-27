#!/bin/bash

# 🎨 BIUX Deploy - GUI Dashboard
# Interfaz visual para controlar el daemon

BIUX_PATH="/Users/macmini/biux"
DAEMON_LOG="$BIUX_PATH/.deploy-daemon.log"
PORT=8888
HTML_FILE="/tmp/biux-deploy-gui.html"

# Generar HTML
generate_html() {
  cat > "$HTML_FILE" << 'HTML'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BIUX Deploy Dashboard</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: linear-gradient(135deg, #1e1e2e 0%, #16242d 100%);
      color: #e0e0e0;
      padding: 20px;
      min-height: 100vh;
    }

    .container {
      max-width: 900px;
      margin: 0 auto;
    }

    header {
      text-align: center;
      margin-bottom: 40px;
      padding: 20px 0;
      border-bottom: 2px solid #16242d;
    }

    h1 {
      font-size: 2.5rem;
      margin-bottom: 10px;
      background: linear-gradient(135deg, #00d4ff, #0099ff);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .status-badge {
      display: inline-block;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 600;
      font-size: 0.9rem;
      margin-top: 10px;
    }

    .status-active {
      background: #10b981;
      color: white;
    }

    .status-inactive {
      background: #ef4444;
      color: white;
    }

    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 30px;
    }

    .card {
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 12px;
      padding: 20px;
      backdrop-filter: blur(10px);
      transition: all 0.3s ease;
    }

    .card:hover {
      background: rgba(255, 255, 255, 0.08);
      border-color: rgba(255, 255, 255, 0.2);
      transform: translateY(-2px);
    }

    .card h2 {
      font-size: 1.1rem;
      margin-bottom: 15px;
      color: #00d4ff;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .card p {
      font-size: 0.95rem;
      line-height: 1.6;
      color: #b0b0b0;
      margin-bottom: 8px;
    }

    .stat-value {
      font-size: 2rem;
      font-weight: bold;
      color: #00d4ff;
      margin: 10px 0;
    }

    .button-group {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
      margin-top: 15px;
    }

    button {
      flex: 1;
      min-width: 120px;
      padding: 10px 16px;
      border: none;
      border-radius: 8px;
      font-size: 0.9rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }

    .btn-primary {
      background: linear-gradient(135deg, #00d4ff, #0099ff);
      color: white;
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(0, 212, 255, 0.3);
    }

    .btn-danger {
      background: #ef4444;
      color: white;
    }

    .btn-danger:hover {
      background: #dc2626;
      transform: translateY(-2px);
    }

    .btn-secondary {
      background: rgba(255, 255, 255, 0.1);
      color: #e0e0e0;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .btn-secondary:hover {
      background: rgba(255, 255, 255, 0.15);
    }

    .logs-section {
      grid-column: 1 / -1;
      background: rgba(0, 0, 0, 0.3);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 12px;
      padding: 20px;
      margin-top: 20px;
    }

    .logs-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }

    .logs-header h2 {
      color: #00d4ff;
      font-size: 1.1rem;
      margin: 0;
    }

    .log-viewer {
      background: rgba(0, 0, 0, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 8px;
      padding: 15px;
      font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
      font-size: 0.85rem;
      color: #00d4ff;
      max-height: 400px;
      overflow-y: auto;
      line-height: 1.6;
      white-space: pre-wrap;
      word-wrap: break-word;
    }

    .log-viewer::-webkit-scrollbar {
      width: 8px;
    }

    .log-viewer::-webkit-scrollbar-track {
      background: rgba(255, 255, 255, 0.05);
      border-radius: 4px;
    }

    .log-viewer::-webkit-scrollbar-thumb {
      background: rgba(0, 212, 255, 0.3);
      border-radius: 4px;
    }

    .log-viewer::-webkit-scrollbar-thumb:hover {
      background: rgba(0, 212, 255, 0.5);
    }

    .spinner {
      display: inline-block;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }

    .info-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-top: 15px;
      font-size: 0.9rem;
    }

    .info-item {
      background: rgba(255, 255, 255, 0.05);
      padding: 10px;
      border-radius: 6px;
      border-left: 3px solid #00d4ff;
    }

    .info-label {
      color: #888;
      font-size: 0.85rem;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .info-value {
      color: #00d4ff;
      font-weight: 600;
      margin-top: 4px;
    }

    .alert {
      padding: 12px 16px;
      border-radius: 8px;
      margin-bottom: 15px;
      font-size: 0.95rem;
    }

    .alert-info {
      background: rgba(59, 130, 246, 0.1);
      border-left: 4px solid #3b82f6;
      color: #93c5fd;
    }

    .alert-success {
      background: rgba(16, 185, 129, 0.1);
      border-left: 4px solid #10b981;
      color: #6ee7b7;
    }

    .alert-warning {
      background: rgba(245, 158, 11, 0.1);
      border-left: 4px solid #f59e0b;
      color: #fcd34d;
    }

    @media (max-width: 768px) {
      .grid {
        grid-template-columns: 1fr;
      }

      h1 {
        font-size: 1.8rem;
      }

      .button-group {
        flex-direction: column;
      }

      button {
        min-width: unset;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>🚀 BIUX Deploy</h1>
      <p>Control automático de despliegues a TestFlight</p>
      <div id="statusBadge" class="status-badge"></div>
    </header>

    <div class="grid">
      <!-- Estado del Daemon -->
      <div class="card">
        <h2>🔧 Estado del Daemon</h2>
        <div class="stat-value" id="daemonStatus">Verificando...</div>
        <p id="daemonMessage">Cargando estado...</p>
        <div class="button-group">
          <button class="btn-primary" onclick="startDaemon()">▶️ Iniciar</button>
          <button class="btn-secondary" onclick="restartDaemon()">🔄 Reiniciar</button>
          <button class="btn-danger" onclick="stopDaemon()">⏹️ Detener</button>
        </div>
      </div>

      <!-- Deploy Manual -->
      <div class="card">
        <h2>📦 Deploy Manual</h2>
        <p>Desplegar ahora sin esperar commits</p>
        <div class="button-group">
          <button class="btn-primary" onclick="deployNow()">🚀 Deploy Completo</button>
        </div>
        <div class="button-group">
          <button class="btn-secondary" onclick="compileOnly()">📱 Solo Compilar</button>
          <button class="btn-secondary" onclick="exportOnly()">📦 Solo Exportar</button>
          <button class="btn-secondary" onclick="uploadOnly()">📤 Solo Subir</button>
        </div>
      </div>

      <!-- Información de Configuración -->
      <div class="card">
        <h2>⚙️ Configuración</h2>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">Apple ID</div>
            <div class="info-value">tu-email@icloud.com</div>
          </div>
          <div class="info-item">
            <div class="info-label">Team ID</div>
            <div class="info-value">552JRWRZ88</div>
          </div>
          <div class="info-item">
            <div class="info-label">Daemon</div>
            <div class="info-value">com.biux.deploy</div>
          </div>
          <div class="info-item">
            <div class="info-label">Verificación</div>
            <div class="info-value">Cada 60 seg</div>
          </div>
        </div>
      </div>

      <!-- Últimos Despliegues -->
      <div class="card">
        <h2>📊 Estadísticas</h2>
        <div id="stats">
          <div class="info-grid">
            <div class="info-item">
              <div class="info-label">Total Deploys</div>
              <div class="info-value" id="totalDeploys">0</div>
            </div>
            <div class="info-item">
              <div class="info-label">Exitosos</div>
              <div class="info-value" id="successDeploys">0</div>
            </div>
            <div class="info-item">
              <div class="info-label">Fallidos</div>
              <div class="info-value" id="failedDeploys">0</div>
            </div>
            <div class="info-item">
              <div class="info-label">Último Deploy</div>
              <div class="info-value" id="lastDeploy">-</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Logs -->
      <div class="logs-section">
        <div class="logs-header">
          <h2>📋 Logs en Tiempo Real</h2>
          <button class="btn-secondary" onclick="refreshLogs()" style="width: auto; padding: 8px 12px;">🔄 Actualizar</button>
        </div>
        <div class="log-viewer" id="logViewer">Cargando logs...</div>
      </div>
    </div>
  </div>

  <script>
    const API_URL = 'http://localhost:8888/api';

    // Actualizar estado cada 3 segundos
    setInterval(() => {
      updateDaemonStatus();
      refreshLogs();
      updateStats();
    }, 3000);

    // Cargar estado inicial
    window.addEventListener('load', () => {
      updateDaemonStatus();
      refreshLogs();
      updateStats();
    });

    async function apiCall(action, data = {}) {
      try {
        const response = await fetch(`${API_URL}/${action}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });
        return await response.json();
      } catch (e) {
        console.error('Error:', e);
        return { error: e.message };
      }
    }

    async function updateDaemonStatus() {
      const result = await apiCall('daemon-status');
      const badge = document.getElementById('statusBadge');
      const status = document.getElementById('daemonStatus');
      const message = document.getElementById('daemonMessage');

      if (result.running) {
        badge.className = 'status-badge status-active';
        badge.textContent = '🟢 Activo';
        status.textContent = 'En ejecución';
        message.textContent = `Último reinicio: ${result.uptime || 'hace poco'}`;
      } else {
        badge.className = 'status-badge status-inactive';
        badge.textContent = '🔴 Inactivo';
        status.textContent = 'Detenido';
        message.textContent = 'El daemon no está ejecutándose';
      }
    }

    async function refreshLogs() {
      const result = await apiCall('logs');
      const viewer = document.getElementById('logViewer');
      if (result.logs) {
        viewer.textContent = result.logs;
        viewer.scrollTop = viewer.scrollHeight;
      }
    }

    async function updateStats() {
      const result = await apiCall('stats');
      if (result.stats) {
        document.getElementById('totalDeploys').textContent = result.stats.total || 0;
        document.getElementById('successDeploys').textContent = result.stats.success || 0;
        document.getElementById('failedDeploys').textContent = result.stats.failed || 0;
        document.getElementById('lastDeploy').textContent = result.stats.lastDeploy || '-';
      }
    }

    async function startDaemon() {
      if (confirm('¿Iniciar el daemon?')) {
        await apiCall('daemon-start');
        setTimeout(updateDaemonStatus, 1000);
      }
    }

    async function stopDaemon() {
      if (confirm('¿Detener el daemon? Los despliegues automáticos se pausarán.')) {
        await apiCall('daemon-stop');
        setTimeout(updateDaemonStatus, 1000);
      }
    }

    async function restartDaemon() {
      if (confirm('¿Reiniciar el daemon?')) {
        await apiCall('daemon-restart');
        setTimeout(updateDaemonStatus, 1500);
      }
    }

    async function deployNow() {
      if (confirm('¿Iniciar deploy completo AHORA? (5-20 minutos)')) {
        await apiCall('deploy-now');
        setTimeout(() => {
          refreshLogs();
          updateStats();
        }, 2000);
      }
    }

    async function compileOnly() {
      if (confirm('¿Compilar solo (sin exportar ni subir)?')) {
        await apiCall('deploy-compile');
      }
    }

    async function exportOnly() {
      if (confirm('¿Exportar IPA (requiere compilación previa)?')) {
        await apiCall('deploy-export');
      }
    }

    async function uploadOnly() {
      if (confirm('¿Subir a TestFlight (requiere IPA)?')) {
        await apiCall('deploy-upload');
      }
    }
  </script>
</body>
</html>
HTML
}

# Servidor HTTP simple
start_server() {
  generate_html
  
  log "🌐 Iniciando servidor en http://localhost:$PORT"
  
  # Crear script Python para servidor
  python3 << 'PYTHON'
import http.server
import socketserver
import json
import subprocess
import os
from datetime import datetime

PORT = 8888
BIUX_PATH = '/Users/macmini/biux'
DAEMON_LOG = f'{BIUX_PATH}/.deploy-daemon.log'
HTML_FILE = '/tmp/biux-deploy-gui.html'

class APIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            with open(HTML_FILE, 'rb') as f:
                self.wfile.write(f.read())
        else:
            self.send_error(404)

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json; charset=utf-8')
        self.end_headers()
        
        path = self.path
        response = {}
        
        try:
            if path == '/api/daemon-status':
                result = subprocess.run(['launchctl', 'list', 'com.biux.deploy'], 
                                      capture_output=True, text=True)
                response = {'running': result.returncode == 0}
                
            elif path == '/api/daemon-start':
                subprocess.run(['launchctl', 'start', 'com.biux.deploy'], check=False)
                response = {'message': 'Daemon iniciado'}
                
            elif path == '/api/daemon-stop':
                subprocess.run(['launchctl', 'stop', 'com.biux.deploy'], check=False)
                response = {'message': 'Daemon detenido'}
                
            elif path == '/api/daemon-restart':
                subprocess.run(['launchctl', 'stop', 'com.biux.deploy'], check=False)
                subprocess.run(['launchctl', 'start', 'com.biux.deploy'], check=False)
                response = {'message': 'Daemon reiniciado'}
                
            elif path == '/api/deploy-now':
                os.chdir(BIUX_PATH)
                subprocess.Popen(['bash', f'{BIUX_PATH}/deploy.sh', 'full'], 
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                response = {'message': 'Deploy iniciado'}
                
            elif path == '/api/deploy-compile':
                os.chdir(BIUX_PATH)
                subprocess.Popen(['bash', f'{BIUX_PATH}/deploy.sh', 'compile'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                response = {'message': 'Compilación iniciada'}
                
            elif path == '/api/deploy-export':
                os.chdir(BIUX_PATH)
                subprocess.Popen(['bash', f'{BIUX_PATH}/deploy.sh', 'export'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                response = {'message': 'Exportación iniciada'}
                
            elif path == '/api/deploy-upload':
                os.chdir(BIUX_PATH)
                subprocess.Popen(['bash', f'{BIUX_PATH}/deploy.sh', 'upload'],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                response = {'message': 'Subida iniciada'}
                
            elif path == '/api/logs':
                try:
                    with open(DAEMON_LOG, 'r') as f:
                        logs = f.read()
                        # Últimas 50 líneas
                        logs = '\n'.join(logs.split('\n')[-50:])
                except:
                    logs = 'Sin logs disponibles'
                response = {'logs': logs}
                
            elif path == '/api/stats':
                try:
                    with open(DAEMON_LOG, 'r') as f:
                        logs = f.read()
                        total = logs.count('Nuevo commit')
                        success = logs.count('✅ Deploy exitoso')
                        failed = logs.count('❌ Deploy falló')
                        
                        # Último deploy
                        last_line = [l for l in logs.split('\n') if l][-1] if logs else ''
                except:
                    total = success = failed = 0
                    last_line = '-'
                
                response = {
                    'stats': {
                        'total': total,
                        'success': success,
                        'failed': failed,
                        'lastDeploy': last_line
                    }
                }
            else:
                response = {'error': 'Endpoint no encontrado'}
                
        except Exception as e:
            response = {'error': str(e)}
        
        self.wfile.write(json.dumps(response).encode('utf-8'))

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), APIHandler) as httpd:
        print(f'Servidor en puerto {PORT}...')
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print('\nServidor detenido')
PYTHON
}

# Iniciar
generate_html
echo "🎨 GUI Dashboard"
echo "📍 http://localhost:$PORT"
echo ""
echo "Abriendo en navegador..."
sleep 1
open "http://localhost:$PORT"

start_server
