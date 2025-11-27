# 🚀 BIUX Deploy - Sistema Definitivo para macOS

## ✅ Sistema Configurado

Tu sistema de deployment **está completamente listo** para usarlo en macOS local:

### 📦 Scripts Disponibles

```bash
# 1. Compilar + Exportar + Subir a TestFlight
/Users/macmini/biux/deploy.sh full

# 2. Solo compilar
/Users/macmini/biux/deploy.sh compile

# 3. Solo exportar IPA
/Users/macmini/biux/deploy.sh export

# 4. Solo subir a TestFlight
/Users/macmini/biux/deploy.sh upload
```

### ⚙️ Daemon Automático

```bash
# Instalar daemon (verifica cada minuto)
/Users/macmini/biux/deploy-daemon.sh start

# Ver estado
/Users/macmini/biux/deploy-daemon.sh status

# Ver logs en tiempo real
/Users/macmini/biux/deploy-daemon.sh tail

# Parar daemon
/Users/macmini/biux/deploy-daemon.sh stop
```

---

## 🎯 Cómo Usarlo

### Opción 1: Automaticamente (RECOMENDADO)

```bash
# 1. Instalar daemon
./deploy-daemon.sh start

# 2. Hacer cambios y commitear con [testflight]
git commit -m "Feature X [testflight]"

# 3. El daemon compilará automáticamente en el siguiente minuto
# 4. Verifica los logs
./deploy-daemon.sh tail
```

El daemon:
- ✅ Verifica cada minuto si hay commits nuevos
- ✅ Detecta tag `[testflight]` o `[deploy]`
- ✅ Auto-incrementa el build number
- ✅ Compila la app
- ✅ Exporta el IPA
- ✅ Sube a TestFlight (si credenciales configuradas)

### Opción 2: Manual Rápido

```bash
# Compilar ahora
./deploy.sh compile

# O todo en uno
./deploy.sh full
```

---

## 🔑 Configurar Credenciales (Opcional)

Para que suba automáticamente a TestFlight, configura:

```bash
export APPLE_ID="tu@email.com"
export APPLE_PASSWORD="tu-app-specific-password"
```

**Nota**: Si no configuras, el IPA se prepara pero requiere upload manual desde Xcode Organizer.

---

## 📊 Build Number

El sistema **auto-incrementa automáticamente** cada vez que compila:

- Build 1 → 2 → 3 → 4...
- Se ve en: `ios/Runner/Info.plist`

---

## 🧪 Probar Sistema

```bash
# Test compilación (sin subir)
./deploy.sh compile

# Ver logs del daemon
./deploy-daemon.sh tail
```

---

## 📝 Ejemplo Completo

```bash
# 1. Instalar daemon una sola vez
./deploy-daemon.sh start

# 2. Hacer cambios
echo "feature nueva" >> lib/main.dart

# 3. Commitear con tag
git add -A
git commit -m "Agregué feature nueva [testflight]"

# 4. Esperar ~1-2 minutos

# 5. Ver logs
./deploy-daemon.sh tail

# OUTPUT esperado:
# 📦 Nuevo commit: abc1234
# 🚀 Agregué feature nueva [testflight]
# 📊 Build: 10 → 11
# 🔨 Compilando...
# ✅ Compilación completada
# 📦 Exportando IPA...
# 📤 Subiendo a TestFlight...
# ✅ Deploy exitoso
```

---

## 🛠️ Troubleshooting

### "Error compilando"
```bash
# Limpiar y probar de nuevo
rm -rf ios/build ios/Pods
./deploy.sh compile
```

### "IPA no generado"
```bash
# Verificar ExportOptions.plist
cat ios/ExportOptions.plist

# Revisar logs detallados
./deploy-daemon.sh tail
```

### "Transporter error"
```bash
# Verificar credenciales
echo $APPLE_ID
echo $APPLE_PASSWORD

# O subir manualmente desde Xcode
open ios/build/ipa/Runner.ipa
```

---

## ✨ Resumen

| Acción | Comando |
|--------|---------|
| Instalar | `./deploy-daemon.sh start` |
| Compilar | `./deploy.sh compile` |
| Todo | `./deploy.sh full` |
| Ver logs | `./deploy-daemon.sh tail` |
| Parar | `./deploy-daemon.sh stop` |

**El sistema está listo. Solo commitea con `[testflight]` y listo.** 🚀
