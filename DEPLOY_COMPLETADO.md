# ✅ BIUX Deploy - Sistema Completamente Configurado

## 🎯 Estado Actual

**✅ COMPLETAMENTE LISTO PARA USAR**

- Daemon instalado y activo ✅
- Credenciales configuradas ✅
- Scripts listos ✅

---

## 🚀 Cómo Usar

### Opción 1: AUTOMÁTICO (Recomendado)

El daemon está **corriendo ahora mismo** verificando cada minuto si hay commits.

**Para desplegar a TestFlight:**

```bash
git add -A
git commit -m "Tu mensaje [testflight]"
```

**Eso es todo.** El daemon:
1. Detectará el commit en el próximo minuto
2. Compilará la app automáticamente
3. Exportará el IPA
4. **Lo subirá a TestFlight automáticamente**

**Ver progreso:**
```bash
bash /Users/macmini/biux/deploy-daemon.sh tail
```

### Opción 2: MANUAL (Ahora mismo)

Si necesitas compilar y subir AHORA:

```bash
bash /Users/macmini/biux/deploy-now.sh
```

O con pasos individuales:
```bash
bash /Users/macmini/biux/deploy.sh compile   # Solo compilar
bash /Users/macmini/biux/deploy.sh full      # Compilar + exportar + subir
```

---

## 📊 Información Configurada

| Ítem | Valor |
|------|-------|
| **Apple ID** | tu-email@icloud.com |
| **Contraseña** | local deploy |
| **Team ID** | 552JRWRZ88 |
| **Build auto-increment** | ✅ Sí |
| **Daemon Status** | ✅ Activo |
| **Verificación** | Cada 60 segundos |

---

## 📝 Scripts Disponibles

| Script | Propósito |
|--------|-----------|
| `deploy.sh` | Compilar, exportar, subir |
| `deploy-daemon.sh` | Controlar el daemon |
| `deploy-now.sh` | Deploy inmediato ahora |
| `deploy-worker.sh` | Worker del daemon |

---

## 🎛️ Comandos Útiles

```bash
# Ver estado del daemon
bash deploy-daemon.sh status

# Ver logs en tiempo real
bash deploy-daemon.sh tail

# Parar el daemon (si necesitas)
bash deploy-daemon.sh stop

# Reiniciar el daemon
bash deploy-daemon.sh restart

# Compilar ahora (sin esperar)
bash deploy-now.sh

# Solo ver si compila (sin subir)
bash deploy.sh compile
```

---

## 📋 Flujo Completo

```
1. Haces cambios en el código
2. git commit -m "Feature X [testflight]"
3. Esperas 60 segundos
4. El daemon detecta el commit
5. Compila automáticamente (5-15 min)
6. Exporta el IPA
7. Sube a TestFlight
8. TestFlight lo notifica en ~30 min
```

---

## 🔢 Build Number

Se incrementa automáticamente cada deploy:

```
Build 1 → deploy → Build 2 → deploy → Build 3...
```

Visible en: `/Users/macmini/biux/ios/Runner/Info.plist`

---

## 🧪 Prueba Rápida

Para verificar que todo funciona:

```bash
# 1. Hacer un cambio pequeño
echo "// test" >> lib/main.dart

# 2. Commitear con [testflight]
git add -A
git commit -m "Test deploy [testflight]"

# 3. Ver logs
bash deploy-daemon.sh tail

# Deberías ver:
# 📦 Nuevo commit: xxx
# 🚀 Compilando...
# ✅ Deploy exitoso
```

---

## 🔐 Credenciales Guardadas

Las credenciales están en: `/Users/macmini/biux/.env.deploy`

```bash
export APPLE_ID="tu-email@icloud.com"
export APPLE_PASSWORD="oecd-jqgg-kpxv-bqmb"  # local deploy
export TEAM_ID="552JRWRZ88"
```

**Seguridad**: Este archivo tiene permisos de lectura solo para ti (600).

---

## ✨ Ventajas del Sistema

✅ **Automatizado** - Verifica cada minuto  
✅ **Sin intervención** - Compila y sube solo  
✅ **Build auto-increment** - No tendrás que hacerlo manualmente  
✅ **Logs detallados** - Ves exactamente qué está pasando  
✅ **Confiable** - Usa herramientas oficiales de Apple (Transporter)  
✅ **Seguro** - Las credenciales se guardan localmente

---

## ❌ Troubleshooting

### El daemon no compila
```bash
# Ver logs completos
bash deploy-daemon.sh tail

# Verificar que xcodebuild existe
which xcodebuild

# Instalar si necesario
xcode-select --install
```

### Error de credenciales
```bash
# Verificar que la contraseña es correcta
echo $APPLE_PASSWORD

# Debe mostrar: oecd-jqgg-kpxv-bqmb
```

### IPA no se subió
```bash
# Ver logs detallados
cat /Users/macmini/biux/.deploy-daemon.log | tail -50

# O subirlo manualmente desde Xcode Organizer
```

---

## 📞 Cheat Sheet

```bash
# Desplegar
git commit -m "msg [testflight]"

# Ver logs
bash deploy-daemon.sh tail

# Compilar ahora
bash deploy-now.sh

# Estado
bash deploy-daemon.sh status

# Parar/Reiniciar
bash deploy-daemon.sh stop
bash deploy-daemon.sh restart
```

---

## 🎉 ¡Todo Listo!

Tu sistema de deployment está completamente configurado y corriendo.

**Solo recuerda**: Cuando quieras desplegar, agrega `[testflight]` al mensaje del commit:

```bash
git commit -m "Tu cambio [testflight]"
```

¡Y listo! El daemon se encargará del resto. 🚀
