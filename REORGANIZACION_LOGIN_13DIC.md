# Reorganización Completa del Sistema de Login - 13 Diciembre 2025

## 🎯 Objetivo
Organizar y mejorar el sistema de autenticación para que el código SMS llegue correctamente al número de teléfono.

## ✅ Cambios Realizados

### 1. AuthRepository - Sistema de Logs Mejorado

**Archivo**: `lib/features/authentication/data/repositories/auth_repository.dart`

#### Mejoras Implementadas:

1. **Logs Detallados con Separadores Visuales**
   ```dart
   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
   print('📱 [AuthRepo] INICIANDO ENVÍO DE OTP');
   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
   ```

2. **Información Completa de la Petición**
   - 📞 Número de teléfono
   - 🌐 URL base configurada
   - ⏰ Timestamp del request
   - 📦 Datos completos enviados
   - 🔧 Headers HTTP

3. **Información Detallada de la Respuesta**
   - 📊 Código de estado HTTP
   - 📝 Cuerpo completo de la respuesta
   - ✅ Indicador de éxito

4. **Manejo Exhaustivo de Errores**
   - Tipos específicos de DioException
   - Mensajes claros por tipo de error
   - Logs completos del error con todos los detalles

5. **URL Base Predeterminada Correcta**
   ```dart
   _baseUrl = baseUrl ?? 'https://n8n.oktavia.me/webhook'
   ```

6. **Headers HTTP Configurados**
   ```dart
   _dio.options.headers = {
     'Content-Type': 'application/json',
     'Accept': 'application/json',
   };
   ```

## 📋 Estructura del Flujo de Autenticación

### Paso 1: Usuario Ingresa Número
```
LoginPhonePage
  ├─ TextField con validación (10 dígitos)
  ├─ Prefijo +57 automático
  └─ Botón "Enviar código"
```

### Paso 2: Validación y Envío
```dart
_handleSendCode() {
  1. Validar longitud (10 dígitos)
  2. Agregar prefijo +57
  3. Llamar AuthProvider.sendCode(fullPhone)
}
```

### Paso 3: AuthProvider Procesa
```dart
AuthProvider.sendCode(phoneNumber) {
  1. Cambiar estado a AuthState.loading
  2. Llamar AuthRepository.sendOTP(phoneNumber)
  3. Si éxito → AuthState.codeSent
  4. Si error → AuthState.error con mensaje
  5. Iniciar timer de reenvío (60s)
}
```

### Paso 4: AuthRepository Envía Request
```dart
AuthRepository.sendOTP(phoneNumber) {
  1. Validar formato E.164
  2. Preparar datos JSON
  3. POST a https://n8n.oktavia.me/webhook/send-otp
  4. Esperar respuesta
  5. Retornar true si status 200/201
}
```

### Paso 5: N8N Procesa y Envía SMS
```
N8N Webhook
  ├─ Recibe POST /send-otp
  ├─ Valida número de teléfono
  ├─ Genera código OTP (6 dígitos)
  ├─ Envía SMS via proveedor
  └─ Responde status 200
```

### Paso 6: Usuario Ingresa Código
```
LoginPhonePage
  ├─ 6 campos de texto individuales
  ├─ Auto-focus entre campos
  └─ Botón "Validar código"
```

### Paso 7: Validación de Código
```dart
AuthProvider.validateCode(code) {
  1. Verificar longitud (6 dígitos)
  2. Llamar AuthRepository.validateOTP(phone, code)
  3. Recibir token Firebase custom
  4. Autenticar con Firebase
  5. Estado → AuthState.authenticated
}
```

## 🧪 Logs Esperados (Caso Exitoso)

### Al Presionar "Enviar código":

```
📲 [AuthProvider] Iniciando proceso de envío de código
   Teléfono: +573001234567
   Intento: 1/3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 [AuthRepo] INICIANDO ENVÍO DE OTP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📞 Número de teléfono: +573001234567
🌐 URL Base: https://n8n.oktavia.me/webhook
⏰ Timestamp: 2025-12-13T14:55:30.123Z
✅ [AuthRepo] Número validado correctamente
📤 [AuthRepo] Enviando POST a: https://n8n.oktavia.me/webhook/send-otp
📦 [AuthRepo] Datos: {phone: +573001234567, timestamp: 2025-12-13T14:55:30.123Z}
🔧 [AuthRepo] Headers: {Content-Type: application/json, Accept: application/json}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📨 [AuthRepo] RESPUESTA RECIBIDA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Status Code: 200
📝 Response Data: {success: true, message: OTP sent}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ [AuthRepo] ¡OTP ENVIADO EXITOSAMENTE!
✅ [AuthProvider] Código enviado - Esperando validación
```

## 🧪 Logs Esperados (Caso con Error)

### Error de Conexión:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ [AuthRepo] ERROR DE CONEXIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Tipo de error: DioExceptionType.unknown
💬 Mensaje: SocketException: Failed host lookup...
📍 URL intentada: https://n8n.oktavia.me/webhook/send-otp
📦 Datos enviados: {phone: +573001234567, timestamp: ...}
📨 Response Status: null
📝 Response Data: null
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Mensaje de error final: Sin conexión a internet. Verifica tu WiFi o datos móviles.
❌ [AuthProvider] Error al enviar código:
   Mensaje: Sin conexión a internet. Verifica tu WiFi o datos móviles.
```

## 🔍 Diagnóstico de Problemas

### Problema 1: No se ve ningún log
**Posible causa**: El botón no está llamando correctamente a la función
**Solución**: Verificar que `_handleSendCode` esté conectado al `onPressed`

### Problema 2: Error de URL
**Log esperado**:
```
🔴 Tipo de error: DioExceptionType.badResponse
📊 Status Code: 404
```
**Solución**: Verificar que N8N tenga el endpoint `/webhook/send-otp`

### Problema 3: Timeout
**Log esperado**:
```
🔴 Tipo de error: DioExceptionType.connectionTimeout
```
**Solución**: Aumentar timeout o verificar conectividad

### Problema 4: Sin conexión
**Log esperado**:
```
🔴 Tipo de error: DioExceptionType.unknown
💬 Mensaje: SocketException
```
**Solución**: Verificar conexión a internet del simulador

### Problema 5: Error 500 del servidor
**Log esperado**:
```
📊 Status Code: 500
```
**Solución**: Verificar configuración de N8N y logs del servidor

## 🎬 Pasos para Probar

### 1. Abrir Simulador macOS
```bash
flutter run -d macos
```

### 2. Esperar Pantalla de Login
- Ver log: `🔧 [AuthRepo] Inicializado con URL: https://n8n.oktavia.me/webhook`

### 3. Ingresar Número de Prueba
- Ejemplo: `3001234567`
- El sistema agregará `+57` automáticamente

### 4. Presionar "Enviar código"
- Observar logs detallados en terminal
- Esperar respuesta del servidor

### 5. Verificar SMS
- Revisar teléfono con número +573001234567
- Código debe llegar en segundos

### 6. Ingresar Código
- Escribir los 6 dígitos recibidos
- Presionar "Validar código"

### 7. Verificar Autenticación
- Usuario debe ser redirigido a `/stories` o `/profile`

## 📞 Información de Contacto N8N

- **URL Base**: https://n8n.oktavia.me
- **Endpoint Send OTP**: POST /webhook/send-otp
- **Endpoint Validate OTP**: POST /webhook/validate-otp

### Request Format (send-otp):
```json
{
  "phone": "+573001234567",
  "timestamp": "2025-12-13T14:55:00.000Z"
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

## 🔧 Configuración Actual

- ✅ URL base correcta: `https://n8n.oktavia.me/webhook`
- ✅ Headers HTTP configurados
- ✅ Timeouts configurados (30s)
- ✅ Logs detallados activados
- ✅ Manejo de errores exhaustivo
- ✅ Validación de formato E.164

## 📝 Próximos Pasos

1. [ ] Compilar y ejecutar macOS (en proceso)
2. [ ] Probar envío de código con número real
3. [ ] Capturar todos los logs
4. [ ] Identificar punto exacto de falla (si hay)
5. [ ] Ajustar según logs capturados

---
**Fecha**: 13 de diciembre 2025, 14:55
**Estado**: Sistema reorganizado con logs mejorados
**Listo para**: Pruebas exhaustivas
**Archivos modificados**: 
- `auth_repository.dart` (mejorado con logs detallados)
