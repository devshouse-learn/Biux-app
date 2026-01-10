# Corrección del Sistema de Login - 13 de Diciembre 2025

## 🔧 Problema Identificado

**Problema**: El código de autenticación no se envía al número de teléfono.

**Causa Raíz Encontrada**: 
- La URL base predeterminada en `AuthRepository` estaba configurada como `'TU_URL_BASE'` en lugar de la URL real de N8N
- Faltaban headers HTTP necesarios para la comunicación con el webhook

## ✅ Correcciones Aplicadas

### 1. AuthRepository - URL Base y Headers

**Archivo**: `lib/features/authentication/data/repositories/auth_repository.dart`

**Cambio realizado**:
```dart
// ANTES:
AuthRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? 'TU_URL_BASE' {
  _dio.options.connectTimeout = const Duration(seconds: 30);
  _dio.options.receiveTimeout = const Duration(seconds: 30);
  _dio.options.sendTimeout = const Duration(seconds: 30);
}

// DESPUÉS:
AuthRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? 'https://n8n.oktavia.me/webhook' {
  _dio.options.connectTimeout = const Duration(seconds: 30);
  _dio.options.receiveTimeout = const Duration(seconds: 30);
  _dio.options.sendTimeout = const Duration(seconds: 30);
  _dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  print('🔧 [AuthRepo] Inicializado con URL: $_baseUrl');
}
```

**Beneficios**:
- ✅ Fallback correcto a la URL de producción
- ✅ Headers HTTP adecuados para API REST
- ✅ Log de inicialización para debugging

## 📡 Configuración de N8N Webhook

### Endpoints Utilizados

1. **Enviar OTP**:
   - URL: `https://n8n.oktavia.me/webhook/send-otp`
   - Método: `POST`
   - Body:
   ```json
   {
     "phone": "+573001234567",
     "timestamp": "2025-12-13T14:30:00.000Z"
   }
   ```

2. **Validar OTP**:
   - URL: `https://n8n.oktavia.me/webhook/validate-otp`
   - Método: `POST`
   - Body:
   ```json
   {
     "phone": "+573001234567",
     "code": "123456",
     "timestamp": "2025-12-13T14:32:00.000Z"
   }
   ```

### Respuesta Esperada (validate-otp)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 🧪 Pruebas a Realizar

### Test Manual en macOS

1. **Abrir app en macOS** (ya en pantalla de login)

2. **Ingresar número de prueba**:
   - Formato: `3001234567` (solo dígitos, sin +57)
   - El sistema agregará automáticamente el prefijo +57

3. **Click en "Enviar código"**

4. **Verificar logs esperados**:
```
📲 [AuthProvider] Iniciando proceso de envío de código
   Teléfono: +573001234567
   Intento: 1/3
🔧 [AuthRepo] Inicializado con URL: https://n8n.oktavia.me/webhook
📱 [AuthRepo] Iniciando envío de OTP para: +573001234567
✓ [AuthRepo] Número validado correctamente
📤 [AuthRepo] Enviando request a: https://n8n.oktavia.me/webhook/send-otp
📨 [AuthRepo] Respuesta recibida - Status: 200
📝 [AuthRepo] Body: {...}
✅ [AuthRepo] OTP enviado exitosamente
✅ [AuthProvider] Código enviado - Esperando validación
```

5. **Recibir código SMS**

6. **Ingresar código (6 dígitos)**

7. **Verificar autenticación**:
```
🔐 [AuthProvider] Iniciando validación de código
📤 Enviando validación a N8N...
✅ [AuthProvider] Código validado correctamente
🔐 Autenticando con Firebase...
✅ [AuthProvider] ¡Autenticación completada exitosamente!
```

### Test de Conectividad con cURL

Puedes probar manualmente la conectividad con N8N:

```bash
# Test de envío de OTP
curl -X POST https://n8n.oktavia.me/webhook/send-otp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "phone": "+573001234567",
    "timestamp": "2025-12-13T14:30:00.000Z"
  }'
```

## ⚠️ Posibles Errores y Soluciones

### 1. Error de Conexión
```
❌ Sin conexión a internet. Verifica tu WiFi o datos móviles.
```
**Solución**: Verificar conexión de red

### 2. Timeout
```
❌ Tiempo de espera agotado. Verifica tu conexión a internet.
```
**Solución**: 
- Verificar que N8N esté funcionando
- Aumentar timeout si es necesario

### 3. Error 400 - Bad Request
```
❌ Número de teléfono inválido.
```
**Solución**: 
- Usar formato E.164: +573001234567
- Verificar que tenga 10-15 dígitos

### 4. Error 429 - Too Many Requests
```
❌ Demasiados intentos. Intenta en unos minutos.
```
**Solución**: Esperar antes de reintentar

### 5. Error 500 - Server Error
```
❌ Error del servidor. Por favor intenta más tarde.
```
**Solución**: 
- Verificar estado del webhook N8N
- Contactar al administrador del sistema

## 🔍 Debugging Avanzado

### Logs Detallados

El sistema ahora incluye logs completos en cada paso:

1. **Inicialización**: `🔧 [AuthRepo] Inicializado con URL: ...`
2. **Envío OTP**: `📱 [AuthRepo] Iniciando envío de OTP...`
3. **Validación número**: `✓ [AuthRepo] Número validado correctamente`
4. **Request HTTP**: `📤 [AuthRepo] Enviando request a: ...`
5. **Respuesta**: `📨 [AuthRepo] Respuesta recibida - Status: ...`
6. **Éxito**: `✅ [AuthRepo] OTP enviado exitosamente`

### Verificar Estado de N8N

```bash
# Ping al servidor
curl -I https://n8n.oktavia.me

# Verificar endpoint específico
curl -X POST https://n8n.oktavia.me/webhook/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+573001234567", "timestamp": "2025-12-13T14:30:00.000Z"}' \
  -v
```

## 📋 Checklist de Verificación

- [x] URL base corregida en AuthRepository
- [x] Headers HTTP configurados
- [x] Log de inicialización agregado
- [ ] Probar envío de código en macOS
- [ ] Verificar que llegue SMS
- [ ] Probar validación de código
- [ ] Confirmar autenticación exitosa
- [ ] Probar en iOS
- [ ] Probar en Chrome (si aplica)

## 🎯 Próximos Pasos

1. **Esperar que compile macOS** (~1-2 minutos)
2. **Probar flujo completo de login**
3. **Capturar logs de cualquier error**
4. **Ajustar según sea necesario**

## 📞 Contacto Backend

Si el problema persiste, verificar:
- Estado del webhook N8N: https://n8n.oktavia.me
- Configuración de envío de SMS
- Generación de tokens Firebase custom

---
**Fecha**: 13 de diciembre 2025
**Hora**: 14:40
**Estado**: Corrección aplicada, esperando pruebas
**Archivos modificados**: 1 (`auth_repository.dart`)
