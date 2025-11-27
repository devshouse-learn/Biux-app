# 🎉 BIUX Deploy - COMPLETAMENTE CONFIGURADO Y FUNCIONANDO

## ✅ Estado Actual: OPERACIONAL

**El daemon está CORRIENDO AHORA MISMO** y verificando cada minuto.

```
✅ Daemon activo
✅ Credenciales guardadas: oecd-jqgg-kpxv-bqmb (local deploy)
✅ Verificación: Cada 60 segundos
✅ Auto-incremento: Build number automático
```

---

## 🚀 Para Desplegar a TestFlight

### Paso 1: Hacer cambios
```bash
# Edita tus archivos
nano lib/main.dart
```

### Paso 2: Commitear CON TAG [testflight]
```bash
git add -A
git commit -m "Tu mensaje [testflight]"
```

### Paso 3: ¡Listo!
El daemon automáticamente:
1. Detectará el commit (en el próximo minuto)
2. Compilará la app
3. Exportará el IPA
4. **Subirá a TestFlight automáticamente**

---

## 📊 Ver Progreso

```bash
# Ver logs en tiempo real
bash /Users/macmini/biux/deploy-daemon.sh tail
```

**Verás:**
```
[19:20:06] 📦 Nuevo commit: abc1234d
[19:20:06] 🚀 Compilando: Tu mensaje [testflight]
[19:20:30] 📊 Build: 10 → 11
[19:20:35] ✅ Compilación completada
[19:20:40] 📦 Exportando IPA...
[19:21:00] 📤 Subiendo a TestFlight...
[19:21:05] ✅ Deploy exitoso
```

---

## ⚙️ Configuración

| Parámetro | Valor |
|-----------|-------|
| **Apple ID** | tu-email@icloud.com |
| **Contraseña** | oecd-jqgg-kpxv-bqmb |
| **Nombre de contraseña** | local deploy |
| **Team ID** | 552JRWRZ88 |
| **Ubicación credenciales** | `/Users/macmini/biux/.env.deploy` |
| **Daemon Status** | ✅ Activo |
| **Verificación** | Cada 60 segundos |

---

## 🎛️ Comandos Útiles

```bash
# Ver estado del daemon
bash /Users/macmini/biux/deploy-daemon.sh status

# Ver logs en tiempo real
bash /Users/macmini/biux/deploy-daemon.sh tail

# Compilar AHORA (sin esperar 60 seg)
bash /Users/macmini/biux/deploy-now.sh

# Parar el daemon (si necesitas)
bash /Users/macmini/biux/deploy-daemon.sh stop

# Reiniciar el daemon
bash /Users/macmini/biux/deploy-daemon.sh restart

# Solo compilar (sin subir)
bash /Users/macmini/biux/deploy.sh compile
```

---

## 📋 Flujo Automático

```
Tu código → git commit [testflight] → Daemon detecta
    ↓
Compila app → Build number ++ → Exporta IPA
    ↓
Sube a TestFlight → TestFlight notifica en ~30 min
    ↓
✅ Usuarios pueden probar en TestFlight
```

---

## 🧪 Test Rápido

Para verificar que todo funciona:

```bash
# 1. Haz un cambio
echo "// test" >> lib/main.dart

# 2. Commitea con [testflight]
git add lib/main.dart
git commit -m "Test [testflight]"

# 3. Ver logs
bash /Users/macmini/biux/deploy-daemon.sh tail

# Espera ~60 segundos para que el daemon lo detecte
# Verás comenzar la compilación automáticamente
```

---

## 🔒 Seguridad de Credenciales

Las credenciales están guardadas en:
```
/Users/macmini/biux/.env.deploy
```

Con permisos restrictivos (solo lectura para ti).

Si necesitas cambiar la contraseña:
```bash
# Editar archivo
nano /Users/macmini/biux/.env.deploy

# Cambiar APPLE_PASSWORD y guardar

# Reiniciar daemon
bash /Users/macmini/biux/deploy-daemon.sh restart
```

---

## 💡 Notas Importantes

1. **Build Number**: Se incrementa automáticamente con cada deploy
   - Visible en: `ios/Runner/Info.plist`
   - No necesitas tocarlo manualmente

2. **App Passwords**: La contraseña `local deploy` es específica
   - No es tu contraseña de Apple regular
   - Es segura porque solo accede a TestFlight
   - Generada en: https://appleid.apple.com → Security

3. **Logs**: Todo se guarda en
   - `/Users/macmini/biux/.deploy-daemon.log`
   - Útil para debugging si algo falla

4. **IPA**: Si falla la subida a TestFlight, el IPA queda en
   - `/Users/macmini/biux/ios/build/ipa/Runner.ipa`
   - Puedes subirlo manualmente desde Xcode Organizer

---

## ✨ Ejemplo Real

```bash
# 1. Hacer cambios
$ nano lib/main.dart
# Editas tu código...

# 2. Commitear con tag
$ git add -A
$ git commit -m "Fixed bug in profile screen [testflight]"
[feature-update-flutter e8c9f2d] Fixed bug in profile screen [testflight]

# 3. Ver logs (opcional)
$ bash deploy-daemon.sh tail

# OUTPUT:
# [20:15:06] 📦 Nuevo commit: e8c9f2d1
# [20:15:06] 🚀 Fixed bug in profile screen [testflight]
# [20:15:10] 📊 Build: 11 → 12
# [20:15:15] 🔨 Compilando...
# [20:15:45] ✅ Compilación completada
# [20:15:50] 📦 Exportando IPA...
# [20:16:05] 📤 Subiendo a TestFlight...
# [20:16:20] ✅ Deploy exitoso
# 📲 La versión estará disponible en TestFlight en ~30 minutos

# ¡LISTO! Ya está en TestFlight
```

---

## 🆘 Si Algo Falla

1. **Ver logs completos**
   ```bash
   bash /Users/macmini/biux/deploy-daemon.sh tail
   ```

2. **Compilar manualmente para testear**
   ```bash
   bash /Users/macmini/biux/deploy.sh compile
   ```

3. **Ver si el daemon está activo**
   ```bash
   launchctl list com.biux.deploy
   ```

4. **Reiniciar daemon si necesario**
   ```bash
   bash /Users/macmini/biux/deploy-daemon.sh restart
   ```

---

## 🎉 ¡LISTO PARA USAR!

Tu sistema de deployment está **100% operacional**.

**Solo recuerda**: Agrega `[testflight]` al mensaje del commit y listo.

```bash
git commit -m "Tu cambio [testflight]"
```

El daemon hará el resto automáticamente. 🚀
