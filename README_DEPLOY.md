# 🚀 CONFIGURACIÓN FINAL - Deploy Automático BIUX

## ✅ Estado Actual

**Sistema completamente configurado para macOS local**

Tienes dos formas de usarlo:

---

## 📝 OPCIÓN 1: Daemon Automático (RECOMENDADO)

### Paso 1: Instalar una sola vez

```bash
cd /Users/macmini/biux
bash deploy-daemon.sh start
```

### Paso 2: Para desplegar a TestFlight

```bash
# Hacer cambios
echo "// nuevo código" >> lib/main.dart

# Commitear CON TAG [testflight]
git add -A
git commit -m "Feature X [testflight]"
```

**El daemon automáticamente:**
- Detectará el commit en el próximo minuto
- Incrementará el build number
- Compilará la app
- Exportará el IPA
- Subirá a TestFlight

### Ver logs

```bash
bash deploy-daemon.sh tail
```

---

## 📝 OPCIÓN 2: Manual (cuando necesites compilar ahora)

```bash
cd /Users/macmini/biux
bash deploy.sh full
```

Esto:
1. Compila
2. Exporta IPA
3. Sube a TestFlight

---

## ⚙️ Configurar Credenciales (OPCIONAL)

Para que suba automáticamente a TestFlight:

```bash
# Agregar a tu ~/.zshrc o ~/.bashrc
export APPLE_ID="tu@email.com"
export APPLE_PASSWORD="your-app-specific-password"
```

**Nota:** Apple Password es diferente a tu contraseña regular. Crealas en:
https://appleid.apple.com → Security → App Passwords

---

## 📊 Monitoreo

```bash
# Ver estado del daemon
bash deploy-daemon.sh status

# Ver logs en tiempo real
bash deploy-daemon.sh tail

# Parar el daemon
bash deploy-daemon.sh stop

# Reiniciar el daemon
bash deploy-daemon.sh restart
```

---

## 🧪 Test Rápido

```bash
cd /Users/macmini/biux

# 1. Solo compilar (para probar)
bash deploy.sh compile

# 2. Todo el proceso
bash deploy.sh full
```

---

## ✨ Ejemplo Real

```bash
# 1. (Una sola vez) Instalar daemon
cd /Users/macmini/biux
bash deploy-daemon.sh start

# 2. Hacer cambios en el código
nano lib/main.dart

# 3. Commitear con tag [testflight]
git add -A
git commit -m "Agregué nuevo feature [testflight]"

# 4. Esperar 1-2 minutos...

# 5. Verificar en logs
bash deploy-daemon.sh tail

# OUTPUT esperado:
# 📦 Nuevo commit: 1a2b3c4d
# 🚀 Agregué nuevo feature [testflight]
# 📊 Build: 10 → 11
# 🔨 Compilando...
# ✅ Compilación completada
# 📦 Exportando IPA...
# 📤 Subiendo a TestFlight...
# ✅ Deploy exitoso
```

---

## 🎯 Build Number

Se incrementa automáticamente cada deploy:
- Build 1
- Build 2
- Build 3
- ... y así sucesivamente

El IPA se prepara automaticamente en: `/Users/macmini/biux/ios/build/ipa/Runner.ipa`

---

## ❌ Troubleshooting

### Error: "Permission denied"
```bash
chmod +x /Users/macmini/biux/deploy.sh
chmod +x /Users/macmini/biux/deploy-daemon.sh
```

### Error: "xcodebuild not found"
```bash
sudo xcode-select --install
# O abre Xcode y acepta los términos
```

### Error: "Transporter error"
El IPA se genera pero falla la subida (sin credenciales):
- Verifica que configuraste APPLE_ID y APPLE_PASSWORD
- O sube manualmente desde Xcode Organizer

---

## ✅ Checklist Final

- [ ] Executables: `chmod +x deploy.sh deploy-daemon.sh`
- [ ] Daemon instalado: `bash deploy-daemon.sh start`
- [ ] Credenciales (opcional): `export APPLE_ID=...`
- [ ] Git con tag: `git commit -m "msg [testflight]"`

---

## 🚀 ¡Listo!

Ya está todo configurado. Solo:

1. **Instalar una sola vez:**
   ```bash
   bash deploy-daemon.sh start
   ```

2. **Para desplegar:**
   ```bash
   git commit -m "mensaje [testflight]"
   ```

3. **Esperar 1-2 minutos** y la app compilará automáticamente.

¿Preguntas? Revisa los logs:
```bash
bash deploy-daemon.sh tail
```
