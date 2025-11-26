# 🔍 GUÍA DE DEBUGGING - ACTUALIZACIÓN DE PERFIL

## 📋 ¿Qué debes hacer?

1. **Abre la aplicación** en el simulador o dispositivo
2. **Completa el registro** con tus datos (nombre, email, etc.)
3. **Ve al perfil** - Presiona el botón de perfil
4. **Modifica los datos** (nombre y/o email)
5. **Presiona "Actualizar Perfil"**
6. **Abre la consola** de Flutter (donde ves los logs)

---

## 🔴 Posibles Errores y Soluciones

### ❌ Error 1: "Por favor ingresa tu nombre"
**Causa**: El campo de nombre está vacío o solo tiene espacios
**Solución**: 
- Asegúrate de escribir un nombre real
- No dejes espacios en blanco
- Intenta algo como: "Juan" o "María"

```
Ejemplo en la consola:
❌ ERROR: Nombre vacío
```

---

### ❌ Error 2: "Por favor ingresa tu email"
**Causa**: El campo de email está vacío
**Solución**:
- Completa el campo email
- Ejemplo correcto: usuario@gmail.com

```
Ejemplo en la consola:
❌ ERROR: Email vacío
```

---

### ❌ Error 3: "Por favor ingresa un email válido"
**Causa**: El email no tiene el formato correcto
**Soluciones válidas**:
- ✅ usuario@gmail.com
- ✅ juan@hotmail.com
- ✅ maria.garcia@empresa.com
- ✅ test.email@dominio.co

**Formatos inválidos** ❌:
- ❌ @gmail.com (sin usuario)
- ❌ usuario@.com (sin dominio)
- ❌ usuarioATgmail.com (sin @)
- ❌ usuario (sin @dominio.com)

```
Ejemplo en la consola:
❌ ERROR: Email inválido - "usuariogmail.com"
   Ejemplo válido: usuario@dominio.com
```

---

### ❌ Error 4: "Usuario no cargado"
**Causa**: El usuario no se ha inicializado correctamente
**Solución**:
- Cierra la aplicación
- Abre nuevamente
- Completa el registro
- Intenta actualizar

```
Ejemplo en la consola:
👤 Usuario actual: null
❌ ERROR: _user es NULL
```

---

### ❌ Error 5: "Error al actualizar el perfil. Intenta nuevamente"
**Causa**: Problema con la conexión a Firebase o permisos
**Soluciones**:
1. Verifica tu conexión a Internet
2. Comprueba que Firebase está configurado correctamente
3. Verifica los permisos en Firestore:
   - Colección: `users`
   - Documento: Tu UID (tu número telefónico)

```
Ejemplo en la consola:
📊 Respuesta del servicio: false
❌ El servicio retornó false
```

---

### ❌ Error 6: "Error al actualizar perfil: [mensaje de excepción]"
**Causa**: Excepción no manejada en el servicio
**Soluciones**:
1. Mira el mensaje de error específico
2. Si dice "permission-denied" → Problema de permisos en Firestore
3. Si dice "network-error" → Problema de conexión

```
Ejemplo en la consola:
❌ EXCEPCIÓN en updateUserProfile: permission-denied
   Tipo: FirebaseException
```

---

## 🎯 Pasos para Reportar el Error

### Cuando veas un error en la app:
1. **Copia el mensaje que aparece en rojo** en la app
2. **Abre la consola de Flutter** (Terminal)
3. **Busca las líneas que empiezan con** 🔍, ❌, ✅, 📝, 📊
4. **Copia TODO desde** 🔍 ====== INICIANDO ACTUALIZACIÓN ======
5. **Hasta** 🔍 ====== FIN DE ACTUALIZACIÓN ======

---

## 📱 Ejemplo de Flujo Exitoso

```
🔍 ====== INICIANDO ACTUALIZACIÓN DE PERFIL ======
📝 Nombre: "Juan García"
📧 Email: "juan@gmail.com"
✅ Validaciones pasadas
🚀 Enviando datos al provider...
🔍 ====== USER PROVIDER: updateProfile ======
👤 Usuario actual: BiuxUser(uid: 573018xxxx, ...)
📝 Nombre recibido: "Juan García"
📧 Email recibido: "juan@gmail.com"
📝 Iniciando actualización de perfil...
🆔 UID del usuario: 573018xxxx
🔍 ====== USER SERVICE: updateUserProfile ======
🆔 UID: 573018xxxx
📝 Nombre: "Juan García"
📧 Email: "juan@gmail.com"
✅ Nombre agregado a updateData
✅ Email agregado a updateData
⏰ Timestamp agregado: 2025-11-26T10:30:45.123456Z
📦 Datos a guardar en Firestore: {name: Juan García, email: juan@gmail.com, updatedAt: 2025-11-26T...}
🗄️ Colección: users, Documento: 573018xxxx
✅ Actualización guardada exitosamente en Firestore
🔍 ====== FIN DE ACTUALIZACIÓN ======
📊 Resultado: ÉXITO
✅ Perfil actualizado localmente
   Nuevo nombre: Juan García
   Nuevo email: juan@gmail.com
🔍 ====== FIN DE ACTUALIZACIÓN ======

✅ En la app aparecerá: "Perfil actualizado correctamente ✅"
```

---

## 📊 Flujo Completo del Debugging

```
1. Llena el nombre y email en la pantalla de perfil
       ↓
2. Presiona "Actualizar Perfil"
       ↓
3. Se ejecutan las validaciones (Nombre, Email formato)
       ↓
4. Se envía al UserProvider
       ↓
5. El UserProvider valida el UID y llama al UserService
       ↓
6. El UserService valida y envía a Firestore
       ↓
7. Firestore actualiza la base de datos
       ↓
8. Se retorna true/false
       ↓
9. Se muestra el mensaje en la app
```

---

## 🔧 Validaciones que se ejecutan automáticamente

✅ Nombre no vacío
✅ Email no vacío
✅ Email con formato válido (ejemplo@dominio.com)
✅ UID del usuario existe
✅ Conexión a Firestore funciona

---

## 💡 Tips

- Los logs ahora son MÁS DETALLADOS
- Busca las líneas con 🔍 para saber en qué etapa falla
- Los ❌ indican ERRORES
- Los ✅ indican ÉXITO
- Los 📝 indican DATOS
- Los 📊 indican RESULTADOS

---

**¿Problema?** → Copia los logs desde 🔍 hasta 🔍 FIN y compártelos. 😊
