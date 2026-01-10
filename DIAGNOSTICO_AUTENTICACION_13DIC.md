# 🔐 Diagnóstico de Autenticación - 13 Diciembre 2025

## ✅ Estado Actual

### Compilación y Despliegue
- ✅ **iOS (iPhone 16 Pro)**: Compilado exitosamente, app corriendo
- ✅ **macOS**: Compilado exitosamente, app corriendo con pantalla de login
- ❌ **Chrome**: Pendiente (timeout en compilación, requiere reinicio manual)

### Configuración del Sistema

#### AuthRepository (`auth_repository.dart`)
```dart
✅ URL Base: 'https://n8n.oktavia.me/webhook'
✅ Headers: 
   - Content-Type: application/json
   - Accept: application/json
✅ Timeouts: 30 segundos (connect/send/receive)
✅ Validación de número: E.164 format (10-15 dígitos)
✅ Logging completo: Request/Response/Errors con separadores visuales
```

#### Endpoints Verificados
```bash
✅ N8N Server: https://n8n.oktavia.me
   - IP: 3.231.126.102
   - Puerto: 443 (HTTPS)
   - Status: ✅ Respondiendo HTTP 200

✅ Endpoint /send-otp:
   POST https://n8n.oktavia.me/webhook/send-otp
   Request: {"phone": "+573XXXXXXXXX", "timestamp": "ISO8601"}
   Response: 200 OK

⏳ Endpoint /validate-otp:
   POST https://n8n.oktavia.me/webhook/validate-otp
   (Pendiente de prueba con código real)
```

## 🧪 Pruebas Requeridas

### Test 1: Envío de OTP en macOS ✨
**Estado**: App lista, esperando input del usuario

**Pasos**:
1. Abrir app macOS (ya está corriendo con pantalla de login)
2. Ingresar número real en formato internacional: `+573XXXXXXXXX`
3. Presionar botón "Enviar código"
4. Observar logs detallados en terminal:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📱 [AuthRepo] INICIANDO ENVÍO DE OTP
   📞 Número de teléfono: +573XXXXXXXXX
   📤 [AuthRepo] Enviando POST a: https://n8n.oktavia.me/webhook/send-otp
   📊 Status Code: 200
   ✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```
5. Verificar recepción de SMS en teléfono
6. Ingresar código de 6 dígitos
7. Verificar autenticación exitosa

**Logs Esperados en Caso de Error**:
```
❌ [AuthRepo] ERROR DE CONEXIÓN
🔴 Tipo de error: [timeout|connectionError|badResponse]
💬 Mensaje: [Descripción detallada]
📍 URL intentada: https://n8n.oktavia.me/webhook/send-otp
📦 Datos enviados: {"phone":"..."}
📨 Response Status: [código]
```

### Test 2: Validación de OTP
**Dependencia**: Test 1 completado con SMS recibido

**Pasos**:
1. Ingresar código de 6 dígitos recibido por SMS
2. Observar logs de validación
3. Verificar autenticación en Firestore
4. Verificar navegación a pantalla principal

### Test 3: Manejo de Errores

**Escenarios a probar**:
- ❌ Número inválido (menos de 10 dígitos)
- ❌ Código incorrecto (6 dígitos incorrectos)
- ❌ Código expirado
- ❌ Demasiados intentos
- ❌ Sin conexión a internet

## 📊 Sistema de Logging Implementado

### Logs de Inicio
```
🔧 [AuthRepo] Inicializado con URL: https://n8n.oktavia.me/webhook
```

### Logs de Envío OTP
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 [AuthRepo] INICIANDO ENVÍO DE OTP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📞 Número de teléfono: +573XXXXXXXXX
🌐 URL Base: https://n8n.oktavia.me/webhook
⏰ Timestamp: 2025-12-13T20:XX:XXZ
✅ [AuthRepo] Número validado correctamente
📤 [AuthRepo] Enviando POST a: https://n8n.oktavia.me/webhook/send-otp
📋 [AuthRepo] Datos: {phone: +573XXX, timestamp: ...}
🔧 [AuthRepo] Headers: {Content-Type: application/json, ...}
```

### Logs de Respuesta
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 [AuthRepo] RESPUESTA RECIBIDA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Status Code: 200
📝 Response Data: {...}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!
```

### Logs de Error (DioException)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ [AuthRepo] ERROR DE CONEXIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Tipo de error: connectionTimeout|badResponse|unknown
💬 Mensaje: [Mensaje de Dio]
📍 URL intentada: https://n8n.oktavia.me/webhook/send-otp
📦 Datos enviados: {phone: ...}
📨 Response Status: 400|500|null
📝 Response Data: {...}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Mensaje de error final: [Mensaje usuario-friendly]
```

## 🔍 Análisis de Estado Actual

### iOS (Usuario ya autenticado)
```
Usuario: phone_573132332038
Username: Taliana1510
Estado: Autenticado ✅
Admin: true
Puede vender: false
Pantalla: Feed (stories)
```

### macOS (Pantalla de Login)
```
Estado: No autenticado
Pantalla: /login
AuthRepo: ✅ Inicializado correctamente
Esperando: Input de usuario
```

## 🎯 Próximos Pasos

### Inmediato (Usuario debe hacer):
1. **Probar login en macOS** con número real
   - Observar logs completos
   - Verificar recepción de SMS
   - Reportar cualquier error visible en logs

2. **Alternativa: Probar en iOS**
   - Cerrar sesión del usuario actual
   - Probar flujo completo de autenticación
   - Verificar logs

### Después de Tests Exitosos:
3. Reiniciar Chrome manualmente: `flutter run -d chrome --web-port=8080`
4. Probar autenticación en web (auto-admin en Chrome)
5. Verificar sistema de seller requests en todos los simuladores

## 🛠️ Mejoras Implementadas

### En AuthRepository:
- ✅ URL base correcta (no placeholder)
- ✅ Headers HTTP completos
- ✅ Logging exhaustivo con separadores visuales
- ✅ Validación de formato de número
- ✅ Manejo de errores específico por tipo (DioExceptionType)
- ✅ Mensajes de error usuario-friendly
- ✅ Timeouts configurados (30s)

### En AuthProvider:
- ✅ Contador de reintentos (_sendAttempts)
- ✅ Máximo de intentos (_maxSendAttempts)
- ✅ Timer de reenvío de código
- ✅ Limpieza de mensajes de excepción

## 📝 Notas Técnicas

### Formato de Números Aceptados:
- **Internacional**: `+573001234567` (preferido)
- **Local**: `3001234567` (10-15 dígitos sin +)
- **Validación**: Acepta 10-15 dígitos después de limpiar caracteres especiales

### Errores Conocidos Manejados:
- `connectionTimeout`: "Tiempo de espera agotado..."
- `sendTimeout`: "Tiempo de envío agotado..."
- `receiveTimeout`: "Servidor tardó demasiado..."
- `badResponse 400`: "Número de teléfono inválido"
- `badResponse 429`: "Demasiados intentos..."
- `badResponse 500`: "Error del servidor..."
- `SocketException`: "Sin conexión a internet..."
- `HandshakeException`: "Error de seguridad SSL..."

### Configuración N8N:
- **Servidor**: n8n.oktavia.me (3.231.126.102)
- **Protocolo**: HTTPS (puerto 443)
- **Endpoints**: 
  - `/webhook/send-otp` ✅ Verificado
  - `/webhook/validate-otp` ⏳ Pendiente

## ✨ Estado del Sistema: LISTO PARA PRUEBAS

El sistema de autenticación está **completamente implementado y configurado**. 
Los logs detallados permitirán diagnosticar cualquier problema inmediatamente.

**Esperando**: Prueba real con número de teléfono del usuario.
