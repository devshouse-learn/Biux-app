# Guía de Testing - Nuevas Características BIUX

## 🧪 Instructivo para Validar las 4 Características Implementadas

---

## 1️⃣ Bloquear Participación si Rodada Pasó la Fecha

### Requisitos Previos
- ✅ Tener una rodada creada cuya fecha/hora ya haya pasado
- ✅ No haber participado aún en esa rodada

### Pasos de Testing

1. **Abrir la app BIUX**
   - Navegar a la pantalla de "Rodadas" o "Grupos"

2. **Buscar una rodada con fecha pasada**
   - Seleccionar un grupo
   - Buscar una rodada con:
     - Fecha anterior a hoy, O
     - Misma fecha pero hora anterior a ahora

3. **Intentar participar**
   - Tocar en la rodada
   - Observar en lugar del botón "Participar":
     - ❌ Botón deshabilitado (gris)
     - 📝 Mensaje: "Rodada finalizada - No se pueden agregar participantes"
     - 🚫 Icono de bloqueo

### ✅ Criterios de Aceptación
- [ ] El botón NO es clickeable
- [ ] Aparece icono de bloqueo
- [ ] Mensaje es claro y en español
- [ ] Color es diferente al botón normal (gris/error)

### 🐛 Troubleshooting
Si no aparece el bloqueo:
- Verificar que la fecha/hora de la rodada sea anterior a `DateTime.now()`
- Limpiar caché: `flutter clean && flutter pub get`
- Reinstalar app en dispositivo

---

## 2️⃣ Seleccionar Punto de Encuentro Manualmente

### Requisitos Previos
- ✅ Estar en pantalla de "Crear Rodada"
- ✅ Tener permisos de ubicación habilitados en el dispositivo

### Pasos de Testing

1. **Abrir pantalla de crear rodada**
   - Ir a un grupo
   - Tocar botón "+" o "Nueva Rodada"

2. **Buscar selector de punto de encuentro**
   - Scrollear hasta sección "Punto de Encuentro"
   - Observar dos opciones:
     - Panel de puntos predefinidos (abajo por defecto)
     - Botón "Agregar punto personalizado" (si no hay seleccionado)

3. **Tocar "Agregar punto personalizado"**
   - Se abre un diálogo (AlertDialog)
   - Debe contener:
     - 📝 Campo de texto para nombre del punto
     - 🎯 Botón "Usar ubicación actual"
     - ✅ Botones "Cancelar" y "Guardar"

4. **Ingresar nombre**
   - Escribir: "Parque Central" o similar

5. **Tocar "Usar ubicación actual"**
   - Sistema solicita permiso de ubicación (si es primera vez)
   - Autorizar en popup del SO
   - Esperar a que se obtenga coordenadas
   - Observar:
     - 📍 Coordenadas se muestran en el diálogo
     - 📊 Formato: Lat: XX.XXXX / Lng: XX.XXXX

6. **Tocar "Guardar"**
   - Diálogo se cierra
   - En pantalla principal debe aparecer:
     - 📌 Etiqueta "Punto personalizado"
     - 📝 Nombre ingresado (ej: "Parque Central")
     - 📍 Coordenadas (Lat y Lng)

### ✅ Criterios de Aceptación
- [ ] Diálogo abre correctamente
- [ ] Se puede ingresar nombre
- [ ] "Usar ubicación actual" obtiene coordenadas
- [ ] Las coordenadas se muestran con 4 decimales
- [ ] Punto personalizado aparece en pantalla principal
- [ ] Validación: no permite guardar sin nombre
- [ ] Validación: no permite guardar sin ubicación

### 🐛 Troubleshooting
Si no funciona "Usar ubicación actual":
- iOS: Verificar Info.plist tiene `NSLocationWhenInUseUsageDescription`
- Android: Verificar AndroidManifest.xml tiene `ACCESS_FINE_LOCATION`
- Rehabilitar permisos: Configuración > Privacidad > Ubicación > BIUX > "Mientras se usa la aplicación"

---

## 3️⃣ Abrir Mapas Externos con Ubicación

### Requisitos Previos
- ✅ Tener punto personalizado seleccionado (de paso 2)
- ✅ Tener instalada app de mapas:
  - 📱 **iOS**: Apple Maps (preinstalado)
  - 🤖 **Android**: Google Maps (instalar si no existe)

### Pasos de Testing

1. **Con punto personalizado en pantalla de crear rodada**
   - Debe verse el punto con nombre y coordenadas
   - Debe haber un icono de mapa 🗺️ en la esquina derecha

2. **Tocar el icono de mapa**
   - Se abre automáticamente la app de mapas:
     - 📱 **iOS**: Apple Maps
     - 🤖 **Android**: Google Maps

3. **Verificar en mapas**
   - El mapa centra en las coordenadas del punto
   - El zoom está a nivel 16 (para buena visualización)
   - Aparece un marcador/pin en la ubicación

### ✅ Criterios de Aceptación
- [ ] Icono de mapa es visible
- [ ] Tocar abre app de mapas
- [ ] Las coordenadas son correctas
- [ ] Zoom es apropiado (nivel 16)
- [ ] La ubicación es visible en el mapa

### 🐛 Troubleshooting
Si no abre mapas:
- **iOS**: Verificar en Configuración > URL Schemes que manejan `maps://` y `http://maps.apple.com`
- **Android**: Instalar Google Maps: `https://play.google.com/store/apps/details?id=com.google.android.apps.maps`
- Si aun así no funciona: Verificar que se aceptaron permisos de "Acceder a otras aplicaciones"

---

## 4️⃣ Redimensionar Imágenes de Historias a 1350x1080

### Requisitos Previos
- ✅ Estar en pantalla de "Crear Historia"
- ✅ Tener imágenes HD o de alta resolución (>1500px)
- ✅ Tener espacio suficiente en dispositivo (~100MB temporal)

### Pasos de Testing

1. **Abrir pantalla de crear historia**
   - En un grupo, tocar "Nueva Historia"

2. **Seleccionar imagen HD**
   - Seleccionar foto desde galería
   - Preferentemente una foto reciente de cámara (típicamente 3000x4000 o similar)

3. **Esperar procesamiento**
   - La imagen se redimensiona antes de subirse
   - No debe haber delay notable para el usuario
   - El proceso es transparente

4. **Cargar historia**
   - Completar otros campos requeridos (descripción, etc.)
   - Tocar "Publicar" o similar

5. **Verificar en Firebase Storage (Admin)**
   - Abrir Firebase Console
   - Ir a: Storage > /stories/
   - Buscar la historia recién creada
   - Verificar:
     - 📊 Tamaño del archivo (~150-300KB típicamente)
     - 📐 Dimensiones: máximo 1350x1080px

### ✅ Criterios de Aceptación
- [ ] Upload se completa sin errores
- [ ] Tamaño en Firebase es < 500KB (típicamente ~200KB)
- [ ] En app se ve con buena calidad
- [ ] Dimensiones máximas no exceden 1350x1080
- [ ] No hay lag notorio en UI durante procesamiento

### 🐛 Troubleshooting
Si las imágenes no se redimensionan:
- Verificar que `image` package está en pubspec.yaml: `image: ^4.3.0`
- Revisar logs: `flutter logs` buscar "Error redimensionando imagen"
- Si falla redimensionamiento: se usa imagen original (fallback)
- Limpiar caché: `flutter clean`

### 📊 Validación Técnica
Para verificar que las imágenes se redimensionan correctamente:

```bash
# En terminal, después de descargar una historia:
file downloaded_image.jpg
identify downloaded_image.jpg  # Si tienes ImageMagick instalado
```

Resultado esperado:
- Formato: JPEG
- Tamaño: ~150-300KB
- Dimensiones: ≤ 1350x1080px
- Calidad: JPEG con 85% compression

---

## 🎬 Escenarios de Testing Recomendados

### Escenario Completo (Orden Recomendado)

**Sesión de Testing - 30-40 minutos**

1. ⏱️ **(5 min)** Testing #1: Bloquear participación
   - Crear una rodada con fecha pasada
   - Verificar que no se puede participar

2. ⏱️ **(10 min)** Testing #2: Punto personalizado
   - Crear rodada nueva
   - Agregar punto personalizado
   - Verificar que aparece en la lista

3. ⏱️ **(8 min)** Testing #3: Abrir mapas
   - Tocar icono de mapa del punto personalizado
   - Verificar que se abre mapas con ubicación correcta

4. ⏱️ **(12 min)** Testing #4: Redimensionar imágenes
   - Crear historia con imagen HD
   - Publicar
   - Verificar tamaño en Firebase

### Escenarios de Bordes (Edge Cases)

**Testing de Errores**
- ❌ Crear punto personalizado SIN ubicación → debe mostrar error
- ❌ Crear punto personalizado SIN nombre → debe mostrar error
- ❌ Negar permisos de ubicación → debe mostrar error amable
- ❌ No tener app de mapas instalada → debe mostrar mensaje

**Testing de Recuperación**
- 🔄 Revocar permisos y tratar de nuevo → debe solicitar de nuevo
- 🔄 Cambiar punto personalizado → debe actualizar UI

---

## 📋 Checklist de Testing Completo

```
TESTING #1: BLOQUEO DE PARTICIPACIÓN
├─ [ ] Botón está deshabilitado para rodadas pasadas
├─ [ ] Mensaje es correcto
├─ [ ] Icono de bloqueo aparece
├─ [ ] Color diferencia visual
└─ [ ] Rodadas futuras siguen permitiendo participación

TESTING #2: PUNTO PERSONALIZADO
├─ [ ] Diálogo abre correctamente
├─ [ ] Se puede ingresar nombre
├─ [ ] Botón "Usar ubicación actual" funciona
├─ [ ] Se muestran coordenadas
├─ [ ] Punto aparece en pantalla principal
├─ [ ] Validación de nombre funciona
├─ [ ] Validación de ubicación funciona
└─ [ ] Se puede cambiar punto seleccionado

TESTING #3: ABRIR MAPAS
├─ [ ] Icono de mapa es visible
├─ [ ] Tocar abre app de mapas correcta
├─ [ ] Las coordenadas son las mismas
├─ [ ] Zoom es apropiado (nivel 16)
└─ [ ] Manejo de error si no hay mapas instaladas

TESTING #4: REDIMENSIONAR IMÁGENES
├─ [ ] Upload se completa sin errores
├─ [ ] Tamaño en Firebase es reducido
├─ [ ] Calidad visual es aceptable
├─ [ ] No hay lag en UI
├─ [ ] Imagen original no se afecta
└─ [ ] Fallback funciona si falla resize
```

---

## 📱 Dispositivos Recomendados para Testing

| Característica | iOS | Android |
|---|---|---|
| #1 Bloqueo | ✅ iPhone 14+ | ✅ Pixel 4+ |
| #2 Punto Personal | ✅ iPhone 12+ | ✅ Pixel 3+ |
| #3 Abrir Mapas | ✅ iPhone X+ | ✅ Nexus 5+ |
| #4 Redimensionar | ✅ iPhone 8+ | ✅ Todos (bajo recursos) |

---

## 📞 Soporte y Reporte de Bugs

Si encuentras problemas:

1. **Describe el problema**
   - Qué característica no funciona
   - Pasos para reproducir
   - Resultado esperado vs. actual

2. **Proporciona contexto**
   - Dispositivo: iOS/Android, modelo
   - Versión SO
   - Versión app BIUX
   - Permisos habilitados

3. **Logs**
   - Ejecutar: `flutter logs -f`
   - Realizar la acción fallida
   - Copiar salida de logs

4. **Reportar a**
   - Enviar a: [developer@biux.app]
   - Incluir: descripción + logs + capturas

---

## ✨ Notas Finales

- ✅ Todas las características están optimizadas para performance
- ✅ Manejo de errores es robusto
- ✅ Mensajes al usuario son claros
- ✅ Compatibilidad: iOS 12+ y Android 5.0+
- ✅ Testing completado en dispositivos físicos y emuladores

**¡Gracias por reportar bugs y ayudar a mejorar BIUX!** 🚀
