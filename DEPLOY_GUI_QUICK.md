# ⚡ Deploy GUI - Guía Rápida 2025

## 🎯 En 10 Segundos

### Opción 1: Ver Dashboard (Recomendado)
```bash
bash /Users/macmini/biux/deploy-gui.sh
```
✨ Se abre en navegador automáticamente

### Opción 2: Deploy AHORA
```bash
bash /Users/macmini/biux/deploy-now.sh
```
⏱️ Comienza compilación inmediata (sin esperar daemon)

### Opción 3: Solo Compilar
```bash
cd /Users/macmini/biux
bash deploy.sh compile
```

### Opción 4: Ver Logs en Vivo
```bash
bash /Users/macmini/biux/deploy-daemon.sh tail
```

---

## 🚀 Flujo Normal de Trabajo

```bash
# 1. Cambios en código
nano lib/main.dart

# 2. Commitear
git add -A
git commit -m "Mi cambio"

# 3. Daemon automáticamente:
#    - Detecta commit (cada 60 seg)
#    - Compila con flutter build ios
#    - Exporta IPA
#    - Sube a TestFlight
#
# ¡LISTO! En 30 min en TestFlight
```

---

## 🔥 Comandos Útiles

| Comando | Qué hace |
|---------|----------|
| `bash deploy-gui.sh` | Dashboard en navegador |
| `bash deploy-now.sh` | Deploy inmediato (compile + export + upload) |
| `bash deploy.sh compile` | Solo compilar con flutter |
| `bash deploy.sh export` | Solo exportar IPA |
| `bash deploy.sh upload` | Solo subir a TestFlight |
| `bash deploy-daemon.sh start` | Iniciar daemon |
| `bash deploy-daemon.sh stop` | Detener daemon |
| `bash deploy-daemon.sh tail` | Ver logs en vivo |

---

## 📊 Estado Actual (26 Nov 2025)

- ✅ **Compilación**: Usa `flutter build ios` (no xcodebuild directo)
- ✅ **Flutter PATH**: Configurado en `/Users/macmini/dev/flutter/bin`
- ✅ **Daemon**: Corriendo (monitorea cada 60 seg)
- ✅ **Credenciales**: Guardadas (`oecd-jqgg-kpxv-bqmb`)
- ✅ **GUI**: Dashboard bonito con API REST en puerto 8888
- ✅ **Auto-increment**: Build number sube automáticamente (agvtool)

---

## 🎨 Dashboard - Lo Que Ves

```
┌─────────────────────────────────────┐
│  🚀 BIUX DEPLOY                     │
│  🟢 Estado: Activo                  │
└─────────────────────────────────────┘

[ESTADO DEL DAEMON]      [DEPLOY MANUAL]
🟢 En ejecución          🚀 Deploy Completo
▶️ Iniciar               📱 Solo Compilar
🔄 Reiniciar             📦 Solo Exportar
⏹️ Detener               📤 Solo Subir

[CONFIGURACIÓN]          [ESTADÍSTICAS]
Apple ID: ...            Total: 5
Team ID: 552JRWRZ88      Exitosos: 4
Daemon: com.biux.deploy  Fallidos: 1

┌─────────────────────────────────────┐
│ 📋 LOGS EN TIEMPO REAL               │
├─────────────────────────────────────┤
│ [19:20] 📦 Nuevo commit: abc1234d   │
│ [19:20] 🚀 Compilando...             │
│ [19:25] ✅ Compilación completada   │
│ [19:26] 📤 Subiendo a TestFlight... │
│ [19:27] ✅ Deploy exitoso           │
└─────────────────────────────────────┘
```

---

## 🎯 Flujo Completo Real

```
Tu código:
  $ nano lib/main.dart
  $ git add -A
  $ git commit -m "Bug fix"
           ⬇️
Daemon detecta (cada 60 seg):
  [19:20] 📦 Nuevo commit detectado
           ⬇️
Comienza compilación:
  [19:20] 🚀 Compilando: Bug fix
  [19:20] 📊 Build: 10 → 11
  [19:20] 🧹 Limpiando builds
  [19:20] 📱 flutter build ios
  [19:25] ✅ Compilación OK
           ⬇️
Exporta IPA:
  [19:25] 📦 Exportando IPA
  [19:26] ✅ IPA exportado
           ⬇️
Sube a TestFlight:
  [19:26] 📤 Subiendo a TestFlight
  [19:27] ✅ Subida completada
  [19:27] 📲 Disponible en ~30 min
           ⬇️
Tú haces:
  $ bash deploy-gui.sh
  [Ves dashboard mostrando progreso]
  [Esperas 5-20 minutos]
  [Ves ✅ Deploy exitoso]
           ⬇️
Resultado:
  📲 App en TestFlight
  ✅ Testers pueden descargar
  🎉 LISTO
```

---

## ✅ Verificación Rápida

```bash
# ¿Está el daemon corriendo?
launchctl list com.biux.deploy

# Output esperado: "-  0  com.biux.deploy"
# (El 0 = sin errores)

# Ver logs en vivo:
tail -f /Users/macmini/biux/.deploy-daemon.log
```

---

## 💡 Tips & Tricks

**1. Abre GUI en background**
```bash
bash /Users/macmini/biux/deploy-gui.sh &
# Dashboard abierto, terminal disponible
```

**2. Deploy super urgente (sin esperar 60 seg)**
```bash
bash /Users/macmini/biux/deploy-now.sh
# Comienza AHORA
```

**3. Solo verificar compilación**
```bash
bash /Users/macmini/biux/deploy.sh compile
# Si hay errores, aparecen aquí
```

**4. Monitorea mientras codeas**
```bash
# Terminal 1:
bash /Users/macmini/biux/deploy-daemon.sh tail

# Terminal 2:
# ... tu trabajo normal ...
```

---

## 🆘 Troubleshooting

| Problema | Solución |
|----------|----------|
| Dashboard no abre | `bash deploy-gui.sh` otra vez |
| Daemon no compila | `bash deploy.sh compile` (ver error) |
| Demora mucho | Normal: 5-15 min compil + 1-2 min subida |
| Error "flutter: command not found" | Ya arreglado en deploy.sh (PATH incluido) |
| Daemon no detecta commits | `bash deploy-daemon.sh restart` |

---

## 📁 Archivos Importantes

```
/Users/macmini/biux/
├── deploy.sh              ← Script principal (compile + export + upload)
├── deploy-gui.sh          ← Dashboard en navegador
├── deploy-now.sh          ← Deploy inmediato
├── deploy-daemon.sh       ← Control del daemon
├── deploy-worker.sh       ← Worker que corre cada 60 seg
├── .env.deploy            ← Credenciales guardadas
├── .deploy-daemon.log     ← Logs de todo
└── ios/build/ipa/
    └── Runner.ipa         ← Último IPA generado
```

---

## 🎉 Resumen

**Nueva compilación**: Usa `flutter build ios` (completo)  
**Nueva GUI**: Dashboard bonito con API REST  
**Sin tag obligatorio**: Cualquier commit se deploya  
**Auto todo**: Build number, compilación, exportación, subida  

---

## 🚀 ¡Comienza Ahora!

Elige uno:
```bash
bash /Users/macmini/biux/deploy-gui.sh    # Ver dashboard (recomendado)
bash /Users/macmini/biux/deploy-now.sh    # Deploy AHORA
```

¡A deployar! 🚀

---

**Documentación completa**: Lee `GUI_DASHBOARD.md` para más detalles
