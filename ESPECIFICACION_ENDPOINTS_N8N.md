# 📡 Especificación Técnica - Endpoints N8N para OTP

**URL Base**: `https://n8n.oktavia.me/webhook`  
**Versión**: 1.0  
**Fecha**: 26 de noviembre de 2025  
**Estado**: Especificación esperada para que la app funcione correctamente

---

## 🔌 Endpoint 1: Envío de OTP

### URL
```
POST https://n8n.oktavia.me/webhook/send-otp
```

### Request

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "phone": "+573001234567",
  "timestamp": "2025-11-26T12:30:45.123Z"
}
```

**Campos**:
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `phone` | string | ✅ Sí | Número internacional con formato E.164 o solo dígitos |
| `timestamp` | string | ✅ Sí | ISO 8601 para validación de timeout |

### Response Exitosa (200)

```json
{
  "success": true,
  "message": "OTP enviado exitosamente",
  "reference_id": "otp_573001234567_1234567890"
}
```

### Response Errores

**400 - Número Inválido**:
```json
{
  "success": false,
  "error": "INVALID_PHONE",
  "message": "Formato de teléfono inválido"
}
```

**429 - Demasiados Intentos**:
```json
{
  "success": false,
  "error": "RATE_LIMIT",
  "message": "Demasiados intentos. Intenta en 60 segundos"
}
```

**500 - Error del Servidor**:
```json
{
  "success": false,
  "error": "SERVER_ERROR",
  "message": "Error al enviar WhatsApp"
}
```

### Notas de Implementación

1. **Validación de Número**
   - Aceptar formato: `+CC-NUMERO` (E.164)
   - Aceptar formato: Solo números (10-15 dígitos)
   - Si es solo números, agregar prefijo +57 (Colombia) por defecto

2. **Generación de OTP**
   - Código de 6 dígitos numéricos
   - Almacenar con teléfono como clave única
   - Tiempo de expiración: 10-15 minutos
   - Usar timestamp para validar expiración

3. **Envío WhatsApp**
   - Usar WhatsApp Business API (Meta)
   - Plantilla: "Tu código de verificación BIUX es: XXXXXX"
   - Incluir link para reportar problemas

4. **Rate Limiting**
   - Máximo 3 intentos por número en 1 hora
   - Esperar 60 segundos entre reintentos
   - Responder con HTTP 429 si se excede

5. **Logging**
   - Registrar cada intento en base de datos
   - Incluir timestamp, IP, teléfono, resultado
   - Permitir búsqueda por referencia_id

---

## 🔐 Endpoint 2: Validación de OTP

### URL
```
POST https://n8n.oktavia.me/webhook/validate-otp
```

### Request

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "phone": "+573001234567",
  "code": "123456",
  "timestamp": "2025-11-26T12:30:55.123Z"
}
```

**Campos**:
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `phone` | string | ✅ Sí | Mismo número del envío |
| `code` | string | ✅ Sí | Código OTP de 6 dígitos |
| `timestamp` | string | ✅ Sí | ISO 8601 para validación |

### Response Exitosa (200)

```json
{
  "success": true,
  "message": "Código validado",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwaG9uZV81NzMwMDEyMzQ1NjciLCJpYXQiOjE3MzI2MTIyNTUsImV4cCI6MTczMjY5ODY1NX0.kI8h-VFsK8bQ2c...",
  "uid": "phone_573001234567",
  "expires_in": 86400
}
```

**Respuesta**:
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `success` | boolean | Siempre true en 200 |
| `message` | string | Mensaje confirmación |
| `token` | string | JWT o custom token para Firebase |
| `uid` | string | ID único del usuario en formato `phone_XXXXXXXXXXX` |
| `expires_in` | number | Segundos de validez del token (típicamente 86400 = 1 día) |

### Response Errores

**401 - Código Incorrecto**:
```json
{
  "success": false,
  "error": "INVALID_CODE",
  "message": "Código incorrecto. Intenta nuevamente",
  "attempts_remaining": 2
}
```

**410 - Código Expirado**:
```json
{
  "success": false,
  "error": "EXPIRED_CODE",
  "message": "Código expirado. Solicita uno nuevo"
}
```

**400 - Teléfono No Encontrado**:
```json
{
  "success": false,
  "error": "NOT_FOUND",
  "message": "No hay código pendiente para este teléfono"
}
```

**429 - Demasiados Intentos**:
```json
{
  "success": false,
  "error": "TOO_MANY_ATTEMPTS",
  "message": "Demasiados intentos. Solicita un código nuevo",
  "retry_after": 300
}
```

### Notas de Implementación

1. **Almacenamiento de OTP**
   - Estructura:
   ```
   {
     "phone": "+573001234567",
     "code": "123456",
     "created_at": "2025-11-26T12:30:45.123Z",
     "expires_at": "2025-11-26T12:45:45.123Z",
     "attempts": 0,
     "max_attempts": 5,
     "status": "pending"
   }
   ```

2. **Validación**
   - Verificar que código coincida exactamente
   - Verificar que no haya expirado (> 15 min)
   - Verificar que no exceda 5 intentos fallidos
   - Marcar como usado después de validar

3. **Generación de Token**
   - Crear Firebase Custom Token con UID: `phone_XXXXXXXXXXX`
   - Claims: `{ uid: "phone_573001234567", auth_time: timestamp }`
   - Válido por 1 hora (3600 segundos)
   - Criptar con clave privada Firebase

4. **Seguridad**
   - No revelar si el código es inválido O no existe
   - Usar mensajes genéricos: "Código incorrecto"
   - Rate limit: 5 intentos por OTP, luego bloquear
   - Registrar intentos fallidos para detectar ataques

5. **Logging**
   - Registrar cada validación (exitosa o no)
   - Incluir: teléfono, timestamp, resultado, IP
   - Permitir búsqueda y análisis de patrones

---

## 🔄 Flujo de Datos Completo

```
┌─ APP FLUTTER ─────────┐
│ {phone: "+573..."}    │
└──────────┬────────────┘
           │
           │ POST /send-otp
           ▼
┌─ N8N WEBHOOK ────────────────────────────────┐
│ 1. Validar formato teléfono                   │
│ 2. Generar OTP (6 dígitos aleatorios)        │
│ 3. Guardar en DB con TTL                      │
│ 4. Enviar por WhatsApp Business API          │
│ 5. Retornar reference_id                      │
└──────────┬───────────────────────────────────┘
           │
           ▼ {reference_id: "..."}
┌─ APP FLUTTER ─────────┐
│ Mostrar pantalla       │
│ de código (6 campos)   │
│ Usuario ingresa código │
└──────────┬────────────┘
           │
           │ POST /validate-otp
           │ {phone, code}
           ▼
┌─ N8N WEBHOOK ────────────────────────────────┐
│ 1. Buscar OTP por teléfono                    │
│ 2. Validar que no haya expirado               │
│ 3. Comparar código (timing-safe)              │
│ 4. Si válido: generar Custom Token Firebase  │
│ 5. Marcar OTP como usado                      │
│ 6. Retornar token + UID                       │
└──────────┬───────────────────────────────────┘
           │
           ▼ {token: "jwt..."}
┌─ APP FLUTTER ─────────┐
│ 1. Usar token para    │
│    Firebase Auth      │
│ 2. signInWithCustom   │
│    Token(token)       │
│ 3. ✅ Usuario logueado│
│ 4. Acceso a la app    │
└───────────────────────┘
```

---

## 🧪 Pruebas de N8N

### Test 1: Envío Exitoso
```bash
curl -X POST https://n8n.oktavia.me/webhook/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+573001234567",
    "timestamp": "2025-11-26T12:30:45.123Z"
  }'
```

**Respuesta Esperada**: HTTP 200 con token o reference_id

### Test 2: Validación Exitosa
```bash
curl -X POST https://n8n.oktavia.me/webhook/validate-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+573001234567",
    "code": "123456",
    "timestamp": "2025-11-26T12:30:55.123Z"
  }'
```

**Respuesta Esperada**: HTTP 200 con JWT token

### Test 3: Código Inválido
```bash
curl -X POST https://n8n.oktavia.me/webhook/validate-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+573001234567",
    "code": "000000",
    "timestamp": "2025-11-26T12:30:55.123Z"
  }'
```

**Respuesta Esperada**: HTTP 401 con error INVALID_CODE

### Test 4: Número Inválido
```bash
curl -X POST https://n8n.oktavia.me/webhook/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "123",
    "timestamp": "2025-11-26T12:30:45.123Z"
  }'
```

**Respuesta Esperada**: HTTP 400 con error INVALID_PHONE

---

## 🔐 Consideraciones de Seguridad

### Autenticación
- [ ] Verificar timestamp dentro de ±5 minutos
- [ ] Usar HTTPS obligatoriamente
- [ ] Validar Content-Type: application/json

### Validación
- [ ] Sanitizar entrada de teléfono
- [ ] Escapar caracteres especiales
- [ ] Usar regex E.164 para validación

### Rate Limiting
- [ ] Máximo 3 OTPs por número en 1 hora
- [ ] Máximo 5 validaciones por OTP
- [ ] Máximo 10 requests por IP en 1 hora (ddos protection)

### Datos Sensibles
- [ ] Nunca loguear código OTP completo (usar *)
- [ ] Nunca retornar código en respuesta de error
- [ ] Limpiar OTPs expirados cada hora
- [ ] Encriptar tokens en tránsito (TLS 1.2+)

### Monitoreo
- [ ] Alertas si > 10 fallos por teléfono/hora
- [ ] Alertas si > 100 requests/IP/hora
- [ ] Dashboard de métricas en tiempo real
- [ ] Logs auditados y no modificables

---

## 📊 Métricas Esperadas

### Éxito
- ✅ 99.9% de OTPs entregados
- ✅ < 5 segundos tiempo de envío
- ✅ < 100ms tiempo de validación

### Errores Aceptables
- ⚠️ < 1% timeouts (conexión lenta)
- ⚠️ < 0.1% números inválidos (usuario error)
- ⚠️ < 0.01% códigos expirados

### Alertas
- 🔴 Si tasa de error > 5%
- 🔴 Si latencia > 500ms
- 🔴 Si disponibilidad < 99.5%

---

## 🆘 Troubleshooting

### "Código no llega a WhatsApp"
- [ ] Verificar que número está en formato correcto
- [ ] Confirmar que cuenta WhatsApp Business está activa
- [ ] Revisar logs de N8N para ver si se envió
- [ ] Verificar que número no está bloqueado
- [ ] Comprobar quota de mensajes del mes

### "Error al validar código"
- [ ] Confirmar que código tiene 6 dígitos
- [ ] Verificar que código no expiró (< 15 min)
- [ ] Comprobar que el número coincide
- [ ] Revisar que no se excedieron reintentos

### "Token rechazado por Firebase"
- [ ] Verificar que custom token está bien formado
- [ ] Confirmar que está firmado con clave privada correcta
- [ ] Comprobar que UID tiene formato `phone_XXXXXXXXXXX`
- [ ] Revisar que token no ha expirado

---

## 📞 Contacto y Soporte

Para problemas con estos endpoints:

1. **Verificar Logs N8N**
   - URL: https://n8n.oktavia.me
   - Buscar webhook send-otp / validate-otp
   - Revisar execuciones recientes

2. **Comprobar Firebase Console**
   - Verificar custom token generado
   - Revisar usuarios creados
   - Buscar errores de autenticación

3. **Testing Manual**
   - Usar curl/Postman para probar endpoints
   - Verificar que todos retornan formato JSON correcto
   - Confirmar códigos HTTP esperados

---

**Versión**: 1.0  
**Última actualización**: 26 de noviembre de 2025  
**Estado**: 🟢 Listo para implementación en N8N
