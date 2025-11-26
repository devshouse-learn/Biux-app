# 🔍 Guía de Verificación Visual - Mejoras en Grupos

**Propósito**: Verificar que las mejoras se ven correctamente en el simulador  
**Fecha**: 26 de Noviembre de 2025

---

## ✅ Checklist de Verificación

### 1. 📍 Ciudad del Grupo

**Lo que debes buscar**:
```
┌─ En cada tarjeta de grupo
│
├─ ícono de ubicación 📍 (gris)
├─ Nombre de la ciudad (Bogotá, Medellín, etc)
└─ Una sola línea (sin saltos)
```

**Ubicación en pantalla**: Debajo del nombre + miembros, encima de "Estados de Rodadas"

**Pruebas**:
- [ ] Ciudad se muestra correctamente
- [ ] El ícono se ve gris (color neutro)
- [ ] El texto no se corta si es muy largo
- [ ] Funciona con todas las 15 ciudades

**Si no lo ves**:
1. Verifica que el grupo tenga `cityId` establecido en Firestore
2. Revisa que el ID esté en minúsculas (ej: 'bogota', no 'Bogotá')
3. Si el ID no existe en el mapeo, mostrará el ID original

---

### 2. 🎯 Estados de Rodadas

**Lo que debes buscar**:
```
┌─ En cada tarjeta de grupo
│
├─ Línea que dice "Estados de Rodadas:"
├─ Tres badges (pillitas) de colores:
│  ├─ 🔵 [Próxima] - AZUL
│  ├─ 🔴 [Cancelada] - ROJO
│  └─ 🟢 [Realizada] - VERDE
└─ Separadas por 8px de espacio
```

**Ubicación en pantalla**: Después de la ciudad, antes del líder

**Diseño de cada badge**:
```
┌──────────────────┐
│ Próxima          │  ← Fondo azul claro (20% opacidad)
└──────────────────┘    Borde azul delgado
 11pt, peso w600
```

**Pruebas**:
- [ ] Se muestran 3 badges
- [ ] Los colores son correctos (azul, rojo, verde)
- [ ] La fuente es pequeña (11pt)
- [ ] El texto es legible
- [ ] Los badges están alineados horizontalmente
- [ ] Hay espacio entre ellos

**Si no lo ves**:
1. Recarga la pantalla (hot reload)
2. Verifica que haya espacio suficiente en la tarjeta
3. Aumenta el tamaño de fuente si es muy pequeño

---

### 3. 👑 Líder del Grupo

**Lo que debes buscar**:
```
┌──────────────────────────────────┐
│ ┌─ Avatar circular (32px)       │
│ │ [Foto del creador]            │
│ │                               │
│ └─────────────┬─────────────────┤
│ 👑 Juan Pérez (o nombre creador)│
│ @juanperez (username)           │
└──────────────────────────────────┘
Fondo púrpura claro (10% opacidad)
Borde púrpura (30% opacidad)
```

**Ubicación en pantalla**: Después de "Estados de Rodadas", antes de la descripción

**Elementos**:
- [ ] Avatar circular con foto del creador
- [ ] Emoji 👑 al inicio del nombre
- [ ] Nombre completo del creador
- [ ] @ símbolo antes del username
- [ ] Fondo y borde con tono púrpura
- [ ] 8px padding alrededor

**Estados posibles**:
1. **Loading**: Mostrará "👤 Cargando líder..."
2. **Success**: Mostrará avatar + nombre + username
3. **Error**: Mostrará "👤 Líder no disponible"

**Pruebas**:
- [ ] La foto del creador se carga (puede tardar 1-2 seg)
- [ ] Si no hay foto, muestra un ícono de persona gris
- [ ] El nombre está centrado verticalmente con el avatar
- [ ] El username se ve más pequeño que el nombre
- [ ] El emoji 👑 aparece antes del nombre completo

**Si no lo ves o está roto**:
1. Verifica que el admin exista en Firestore (collection 'users')
2. El usuario admin debe tener campos: `name`, `username`, `photoUrl`
3. Si la foto no carga, es un problema de Firebase Storage (normal al inicio)

---

## 🎨 Validación de Colores

### Código Hex de Colores Esperados

```dart
ColorTokens.warning50    → #FF9500 (Azul/Naranja)
ColorTokens.error50      → #FF3B30 (Rojo)
ColorTokens.success40    → #34C759 (Verde)
ColorTokens.primary30    → #007AFF (Azul primario)
ColorTokens.neutral60    → #8E8E93 (Gris)
ColorTokens.neutral100   → #000000 (Negro)
```

**Verificación visual**:
- [ ] Badge Próxima: Azul/Naranja
- [ ] Badge Cancelada: Rojo
- [ ] Badge Realizada: Verde
- [ ] Contenedor Líder: Fondo púrpura claro
- [ ] Contenedor Líder: Borde púrpura

---

## 📏 Validación de Espaciado

### Distancias verticales esperadas

```
Logo + Nombre + Estado     ← Línea 1
        ↓ 12px
📍 Ciudad                  ← Línea 2
        ↓ 8px
Estados de Rodadas:        ← Línea 3
[Próxima] [Cancelada]... ← Línea 4
        ↓ 12px
👑 Líder del Grupo         ← Línea 5
        ↓ 12px
Descripción del grupo      ← Línea 6
```

**Pruebas**:
- [ ] No hay espacios vacíos anormales
- [ ] Todos los elementos están bien distribuidos
- [ ] La tarjeta no es demasiado alta
- [ ] El texto no se superpone

---

## 🖥️ Validación en Diferentes Tamaños

### iPhone 16 Pro (375px wide)
- [ ] Todo se ajusta sin cortes
- [ ] El texto no está muy pequeño

### iPad (768px wide)
- [ ] Todo se distribuye bien
- [ ] Los badges tienen espacio suficiente

### Modo Dark vs Light
- [ ] Los colores se ven bien en ambos modos
- [ ] El contraste es suficiente
- [ ] El texto es legible

---

## 🔄 Flujo de Actualización

### ¿Qué pasa cuando...?

**1. Se crea una nueva rodada**
- Los conteos de "Próxima/Cancelada/Realizada" NO se actualizan automáticamente
- ℹ️ Esto es normal en la implementación actual
- 🔮 Futuro: Agregar refreshing cuando se crea rodada

**2. El creador del grupo cambia su foto**
- La nueva foto se actualizará después de 5 minutos (caché)
- O después de hacer hot restart

**3. Se cambia la ciudad del grupo**
- Necesitarás hacer hot restart para verlo actualizado
- 🔮 Futuro: Agregar listener en tiempo real

---

## 🐛 Problemas Comunes y Soluciones

### Problema 1: No veo la ciudad

**Causa**: El grupo no tiene `cityId` en Firestore

**Solución**:
1. Ir a Firebase Console → Firestore → grupos
2. Editar el documento del grupo
3. Agregar campo `cityId` con valor como "bogota" (minúsculas)
4. Hot restart la app

### Problema 2: Los badges se ven muy juntos

**Causa**: Puede ser un problema de rendering

**Solución**:
1. Hot reload la pantalla
2. Si persiste, hot restart
3. Verifica el tamaño de fuente (debe ser 11pt)

### Problema 3: El avatar del líder no carga

**Causa**: Firebase Storage no tiene la foto o la URL es inválida

**Solución**:
1. Verifica que el usuario tenga `photoUrl` en Firestore
2. La URL debe ser accesible desde Internet
3. El archivo debe existir en Firebase Storage
4. Espera 1-2 segundos, a veces tarda la primera carga

### Problema 4: Dice "Cargando líder..." pero nunca carga

**Causa**: El admin no existe en Firestore o error de red

**Solución**:
1. Verifica que exista documento en collection 'users' con id = adminId
2. Revisa la consola de Firebase para errores
3. Intenta con un grupo cuyo admin tenga perfil completo

### Problema 5: El nombre del líder se ve cortado

**Causa**: Nombre muy largo y sin espacio

**Solución**:
1. Es normal con nombres muy largos
2. Se mostrará con `maxLines: 1` y `overflow: TextOverflow.ellipsis`
3. Si quieres más espacio, puedes ajustar el `fontSize` en grupo_list_screen.dart

---

## 📸 Captura de Pantalla Esperada

```
═════════════════════════════════════════════════
║           GRUPOS DISPONIBLES                   ║
═════════════════════════════════════════════════
║                                               ║
║ ┌───────────────────────────────────────┐    ║
║ │ [LOGO] Rodada Bogotá      [Miembro]  │    ║
║ │        15 miembros                    │    ║
║ │ 📍 Bogotá                             │    ║
║ │                                       │    ║
║ │ Estados de Rodadas:                   │    ║
║ │ [Próxima] [Cancelada] [Realizada]    │    ║
║ │                                       │    ║
║ │ ┌─────────────────────────────────┐  │    ║
║ │ │ [IMG] 👑 Juan Pérez             │  │    ║
║ │ │       @juanperez                │  │    ║
║ │ └─────────────────────────────────┘  │    ║
║ │                                       │    ║
║ │ Descripción del grupo...              │    ║
║ │                                       │    ║
║ │              [UNIRSE]                 │    ║
║ └───────────────────────────────────────┘    ║
║                                               ║
║ ┌───────────────────────────────────────┐    ║
║ │ [LOGO] Ciclorutas Medellín  [Miembro]│    ║
║ │        8 miembros                     │    ║
║ │ 📍 Medellín                           │    ║
║ │                                       │    ║
║ │ Estados de Rodadas:                   │    ║
║ │ [Próxima] [Cancelada] [Realizada]    │    ║
║ │                                       │    ║
║ │ ┌─────────────────────────────────┐  │    ║
║ │ │ [IMG] 👑 María García            │  │    ║
║ │ │       @mariagarcia               │  │    ║
║ │ └─────────────────────────────────┘  │    ║
║ │                                       │    ║
║ │ Grupos de ciclismo en Medellín...    │    ║
║ │                                       │    ║
║ │              [SOLICITAR]              │    ║
║ └───────────────────────────────────────┘    ║
║                                               ║
═════════════════════════════════════════════════
```

---

## ✅ Checklist Final de Verificación

**Antes de dar por completado**:
- [ ] Se ve la ciudad en cada grupo
- [ ] Se ven los 3 badges de estado
- [ ] Se ve el líder con avatar + nombre + username
- [ ] Los colores son correctos
- [ ] El espaciado se ve bien
- [ ] No hay textos cortados
- [ ] Sin errores en la consola
- [ ] La app no se traba
- [ ] Las imágenes cargan dentro de 2 segundos
- [ ] Funciona en iPhone 16 Pro simulator

---

## 🚀 Próximo Paso

Una vez verificado todo:

1. **Compilar release**
```bash
flutter build ios --release
```

2. **Probar en dispositivo real** (si es posible)

3. **Documentar cualquier problema encontrado**

4. **Hacer commit a git**
```bash
git add .
git commit -m "✨ feat: Mejoras en vista de grupos

- Agregar ciudad con icono de ubicacion
- Mostrar estados de rodadas (Próxima/Cancelada/Realizada)
- Mostrar creador del grupo como lider con avatar
- Colorear badges según estado"
```

---

**Guía creada**: 26 de Noviembre de 2025  
**Versión**: 1.0  
**Responsable**: GitHub Copilot
