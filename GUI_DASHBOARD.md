# 🎨 BIUX Deploy GUI - Dashboard Visual

## 🚀 Inicio Rápido

### Abrir el Dashboard
```bash
bash /Users/macmini/biux/deploy-gui.sh
```

Se abrirá automáticamente en: **http://localhost:8888**

---

## 📊 Características del Dashboard

### 1️⃣ Estado del Daemon
- **Mostrador Visual**: Verde (activo) o Rojo (detenido)
- **Botones**:
  - ▶️ **Iniciar**: Inicia el daemon automático
  - 🔄 **Reiniciar**: Reinicia el servicio
  - ⏹️ **Detener**: Pausa el daemon

### 2️⃣ Deploy Manual
Desplegar sin esperar commits automáticos:
- 🚀 **Deploy Completo** (5-20 minutos)
  - `flutter build ios` → Compilar
  - Exportar IPA
  - Subir a TestFlight
  
- 📱 **Solo Compilar** (5-15 minutos)
  - Solo ejecuta `flutter build ios`
  - Útil para verificar errores
  
- 📦 **Solo Exportar** (1-2 minutos)
  - Requiere compilación previa
  - Genera IPA
  
- 📤 **Solo Subir** (1-2 minutos)
  - Requiere IPA generado
  - Sube a TestFlight

### 3️⃣ Configuración
Muestra la configuración actual:
- Apple ID
- Team ID
- Nombre del daemon
- Frecuencia de verificación

### 4️⃣ Estadísticas
Monitoreo de despliegues:
- Total de commits detectados
- Deployments exitosos
- Deployments fallidos
- Último deploy realizado

### 5️⃣ Logs en Tiempo Real
- **Actualización Automática**: Cada 3 segundos
- **Botón Actualizar**: Refresh manual
- **Scroll Automático**: Muestra últimas líneas
- **Últimas 50 líneas**: De `/Users/macmini/biux/.deploy-daemon.log`

---

## 🎯 Flujo de Uso Típico

### Escenario 1: Ver Estado
```
1. Abrir: bash deploy-gui.sh
2. Dashboard se abre en navegador
3. Ver estado del daemon (verde/rojo)
4. Ver logs en tiempo real
5. Si está rojo, click en "Iniciar"
```

### Escenario 2: Deploy Manual Inmediato
```
1. Hacer cambios en código
2. Abrir dashboard
3. Click en "🚀 Deploy Completo"
4. Confirmar en popup
5. Ver progreso en logs (5-20 minutos)
6. Daemon muestra "✅ Deploy exitoso"
```

### Escenario 3: Solo Compilar para Testing
```
1. Click en "📱 Solo Compilar"
2. Ver compilación en logs
3. Si hay errores, aparecerán en rojo
4. Puedes corregir y reintentar
```

### Escenario 4: Verificar Daemon Automático
```
1. Daemon está corriendo en background
2. Dashboard se conecta vía HTTP
3. Cada 3 segundos actualiza estado
4. Si hay commit nuevo → automáticamente compila
5. Logs muestran progreso en tiempo real
```

---

## 🔧 API Interna (Para Desarrolladores)

El dashboard usa una API REST interna:

```
POST /api/daemon-status       → Estado del daemon
POST /api/daemon-start        → Iniciar daemon
POST /api/daemon-stop         → Detener daemon
POST /api/daemon-restart      → Reiniciar daemon
POST /api/deploy-now          → Deploy completo
POST /api/deploy-compile      → Solo compilar
POST /api/deploy-export       → Solo exportar
POST /api/deploy-upload       → Solo subir
POST /api/logs                → Obtener logs
POST /api/stats               → Estadísticas
```

### Ejemplo: Compilar desde Terminal
```bash
curl -X POST http://localhost:8888/api/deploy-compile
```

---

## 📋 Logs en Detalle

Cada acción genera logs formateados:

### Compilación
```
[2025-11-26 19:20:06] 📦 Nuevo commit: abc1234d
[2025-11-26 19:20:06] 📊 Build: 10 → 11
[2025-11-26 19:20:08] 🧹 Limpiando builds anteriores...
[2025-11-26 19:20:12] 📱 Ejecutando flutter build ios...
[2025-11-26 19:20:45] ✅ Compilación y archivado completados
```

### Exportación
```
[2025-11-26 19:20:46] 📦 Exportando IPA...
[2025-11-26 19:20:55] ✅ IPA exportado: build/ipa/Runner.ipa
```

### Subida a TestFlight
```
[2025-11-26 19:21:00] 📤 Subiendo a TestFlight...
[2025-11-26 19:21:10] ✅ Subida a TestFlight completada
[2025-11-26 19:21:10] 📲 La versión estará disponible en ~30 minutos
```

### Si falla
```
[2025-11-26 19:21:15] ❌ Deploy falló
```

---

## 🎨 Diseño Responsivo

- **Desktop**: 2 columnas + logs completos
- **Tablet**: 1-2 columnas según ancho
- **Móvil**: 1 columna, logs scrolleables

---

## 🔐 Seguridad

- **Puerto Local**: Solo accesible en `localhost:8888`
- **Sin Autenticación**: Es local, no expuesto públicamente
- **Credenciales Seguras**: Nunca se envían en HTTP, están en archivos locales

---

## 🐛 Troubleshooting

### "Connection refused" en dashboard
```bash
# Verifica que el dashboard está corriendo
ps aux | grep deploy-gui

# Reinicia
bash /Users/macmini/biux/deploy-gui.sh
```

### El daemon no aparece como activo
```bash
# Verifica el daemon
launchctl list com.biux.deploy

# Si no está, reinicia
bash /Users/macmini/biux/deploy-daemon.sh restart
```

### Los logs no se actualizan
```bash
# Refresh manual en el dashboard
Click en botón "🔄 Actualizar"

# O ver directamente
tail -f /Users/macmini/biux/.deploy-daemon.log
```

### Deploy falla con "flutter: command not found"
```bash
# El PATH no se propaga correctamente
# Solución: Ya está arreglado en deploy.sh (PATH incluye flutter)
# Si persiste:
export PATH="/Users/macmini/dev/flutter/bin:$PATH"
bash /Users/macmini/biux/deploy.sh full
```

---

## 📝 Combinando GUI + Daemon Automático

**Mejor flujo de trabajo:**

```
┌─ Daemon (deploy-worker.sh) ─────────────────────────────┐
│  • Corre en background (via launchd)                     │
│  • Verifica CADA 60 segundos por nuevos commits           │
│  • Automáticamente compila si hay cambios                 │
│  • Sin interferencia del usuario                          │
└────────────────────────────────────────────────────────────┘
                            ⬇️
┌─ Dashboard (deploy-gui.sh) ──────────────────────────────┐
│  • Interfaz visual para monitorear                        │
│  • Ver logs en tiempo real                               │
│  • Deploy manual si urgencia                              │
│  • Control del daemon (start/stop/restart)               │
│  • Estadísticas y estado                                  │
└────────────────────────────────────────────────────────────┘
```

---

## ⚡ Atajos de Teclado

- **Ctrl+Shift+K**: Limpiar logs en consola
- **Cmd+R**: Actualizar página del dashboard
- **F12**: Developer tools (para debugging)

---

## 💾 Almacenamiento de Datos

```
/Users/macmini/biux/
├── .deploy-daemon.log       ← Todos los logs del daemon
├── .last-deployed-commit    ← Último commit deployado
├── .env.deploy              ← Credenciales (Apple ID, password)
└── ios/build/ipa/
    └── Runner.ipa           ← Último IPA generado
```

---

## 🎓 Ejemplo Real: Ciclo Completo

```
Paso 1: Abrir Dashboard
$ bash /Users/macmini/biux/deploy-gui.sh

Paso 2: Ver estado (debería estar "🟢 Activo")

Paso 3: Hacer cambios en código
$ nano lib/main.dart

Paso 4: Commitear (sin necesidad de tag [testflight])
$ git add -A
$ git commit -m "Fixed UI bug"

Paso 5: Dashboard detecta nuevo commit automáticamente
→ Logs muestran: "[19:25:10] 📦 Nuevo commit: abc1234d"

Paso 6: Comienza compilación automática
→ Logs muestran: "[19:25:12] 🚀 Compilando: Fixed UI bug"

Paso 7: Esperar 5-20 minutos
→ Logs muestran progreso:
   "[19:25:15] 📊 Build: 11 → 12"
   "[19:25:20] 📱 Ejecutando flutter build ios..."
   "[19:26:00] ✅ Compilación completada"
   "[19:26:05] 📦 Exportando IPA..."
   "[19:26:15] ✅ IPA exportado"
   "[19:26:20] 📤 Subiendo a TestFlight..."
   "[19:26:35] ✅ Subida completada"
   "[19:26:35] 📲 La versión estará en ~30 minutos"

Paso 8: En ~30 minutos, nueva versión en TestFlight
✅ ¡HECHO!
```

---

## 📞 Soporte Rápido

| Problema | Solución |
|----------|----------|
| Dashboard no abre | Ejecutar `bash deploy-gui.sh` nuevamente |
| Daemon no compila | Ver logs: `tail -f .deploy-daemon.log` |
| Demora mucho | Normal: 5-15 min compilación + 1-2 min subida |
| Error de contraseña | Verificar `/Users/macmini/biux/.env.deploy` |
| IPA no se exporta | Ejecutar solo compilación primero |

---

## 🎉 ¡Eso es todo!

Tu sistema de deployment está **completamente automatizado con visualización**. 

- Abre el dashboard
- El daemon trabaja en background
- Todo se monitorea en tiempo real

**¡A deployar!** 🚀
