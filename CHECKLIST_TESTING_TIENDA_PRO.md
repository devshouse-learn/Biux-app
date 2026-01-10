# ✅ CHECKLIST DE TESTING - TIENDA PROFESIONAL

**Fecha:** 05 de diciembre de 2024  
**Versión:** 3.0 Professional  

---

## 🎯 TESTING FUNCIONAL

### 1. AppBar y Búsqueda

- [ ] AppBar se colapsa correctamente al scroll
- [ ] AppBar queda sticky después de colapsar
- [ ] Search bar es visible en todo momento
- [ ] Placeholder dice "Buscar productos, marcas, categorías..."
- [ ] Icono de lupa aparece a la izquierda
- [ ] Icono QR scanner aparece a la derecha
- [ ] Botón X de limpiar aparece cuando hay texto
- [ ] Búsqueda filtra productos en tiempo real
- [ ] Badge del carrito muestra número correcto
- [ ] Menú PopupMenu se abre correctamente
- [ ] Opciones del menú: Mis Pedidos, Favoritos, Ayuda

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 2. Banner Promocional

- [ ] Banner se muestra debajo de la búsqueda
- [ ] Gradiente morado/azul es visible
- [ ] Patrón de fondo se ve correctamente
- [ ] Badge "🎉 ENVÍO GRATIS" aparece
- [ ] Texto "En compras superiores a $200.000" visible
- [ ] Texto "Válido hasta fin de mes" visible
- [ ] Icono de camión (48px) aparece a la derecha
- [ ] Sombra del banner es visible
- [ ] Bordes redondeados correctos

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 3. Tabs de Categorías

- [ ] Tabs aparecen debajo del banner
- [ ] 8 tabs visibles: Todos, Jerseys, Culotes, Guantes, Cascos, Gafas, Calzado, Accesorios
- [ ] Tabs quedan fijos al scroll (sticky)
- [ ] Indicador verde se muestra en tab activo
- [ ] Tap en cada tab filtra productos correctamente
- [ ] Scroll horizontal funciona si no caben todos los tabs
- [ ] Tab "Todos" muestra todos los productos
- [ ] Cada tab muestra solo productos de esa categoría

**Resultado por tab:**
- [ ] Todos
- [ ] Jerseys
- [ ] Culotes
- [ ] Guantes
- [ ] Cascos
- [ ] Gafas
- [ ] Calzado
- [ ] Accesorios

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 4. Toolbar de Controles

- [ ] Toolbar aparece debajo de las tabs
- [ ] Contador "X productos" muestra número correcto
- [ ] Dropdown "Ordenar por" se abre correctamente
- [ ] Dropdown muestra 5 opciones:
  - [ ] Más relevantes
  - [ ] Menor precio
  - [ ] Mayor precio
  - [ ] Más recientes
  - [ ] Más vendidos
- [ ] Cada opción de sort reordena productos
- [ ] Botón Grid (⊞) cambia a vista grid
- [ ] Botón List (☰) cambia a vista lista
- [ ] Icono activo se marca correctamente
- [ ] Fondo blanco y bordes sutiles visibles

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 5. Panel de Filtros Avanzados

- [ ] FAB de filtros (blanco) visible en bottom-right
- [ ] Tap en FAB abre/cierra panel de filtros
- [ ] Panel se expande con animación smooth
- [ ] Título "Filtros Avanzados" visible
- [ ] Botón "Limpiar" funciona correctamente

#### 5.1 Filtro Precio
- [ ] Slider de rango aparece
- [ ] Valores mínimo $0 y máximo $1.000.000
- [ ] Arrastrar thumb izquierdo ajusta mínimo
- [ ] Arrastrar thumb derecho ajusta máximo
- [ ] Valores se actualizan en tiempo real
- [ ] Formato $XXX.XXX correcto

#### 5.2 Filtro Stock
- [ ] Checkbox "Solo productos en stock" visible
- [ ] Tap activa/desactiva checkbox
- [ ] Filtra productos sin stock cuando activo

#### 5.3 Filtro Envío Gratis
- [ ] Checkbox "Envío gratis" visible
- [ ] Tap activa/desactiva checkbox
- [ ] Filtra productos con envío gratis cuando activo

#### 5.4 Filtro Rating
- [ ] Título "Calificación mínima" visible
- [ ] 5 estrellas aparecen
- [ ] Tap en estrella selecciona rating mínimo
- [ ] Estrellas a la izquierda se llenan
- [ ] Estrellas a la derecha quedan vacías
- [ ] Filtra productos con rating >= seleccionado

#### 5.5 Aplicar Filtros
- [ ] Botón "Aplicar Filtros" visible
- [ ] Tap en botón aplica todos los filtros
- [ ] Productos se filtran correctamente
- [ ] Panel se cierra después de aplicar

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 6. Vista Grid - Product Cards

- [ ] Grid muestra 2 columnas
- [ ] Aspect ratio 0.68 (más vertical que cuadrado)
- [ ] Spacing 12px entre cards
- [ ] Cards tienen bordes redondeados
- [ ] Sombra sutil visible

#### 6.1 Imagen
- [ ] Imagen del producto carga correctamente
- [ ] Placeholder muestra CircularProgressIndicator
- [ ] Error icon aparece si imagen falla
- [ ] Imagen ocupa parte superior del card

#### 6.2 Badge Descuento
- [ ] Badge "20% OFF" aparece si hay descuento
- [ ] Color rojo (#FF5252)
- [ ] Posición: esquina superior izquierda
- [ ] Texto blanco, bold

#### 6.3 Botón Favorito
- [ ] Corazón aparece en esquina superior derecha
- [ ] CircleAvatar blanco con sombra
- [ ] Tap marca/desmarca favorito
- [ ] Icono cambia: favorite_border ↔ favorite

#### 6.4 Badge Stock Bajo
- [ ] Badge "Solo X" aparece si stock < 5
- [ ] Color naranja (#FF9800)
- [ ] Posición: esquina inferior izquierda sobre imagen
- [ ] Texto blanco

#### 6.5 Rating
- [ ] 5 estrellas amarillas (#FFC107) aparecen
- [ ] Estrellas llenas según rating
- [ ] Número de reviews "(120)" aparece después
- [ ] Tamaño de estrellas: 16px

#### 6.6 Precios
- [ ] Precio original aparece tachado si hay descuento
- [ ] Precio original más pequeño y gris
- [ ] Precio actual grande y bold
- [ ] Precio actual color verde (#16242D)
- [ ] Formato $XXX.XXX correcto

#### 6.7 Botón Agregar
- [ ] Botón "+" circular en esquina inferior derecha
- [ ] Color verde
- [ ] Tamaño 32x32
- [ ] Tap agrega producto al carrito
- [ ] Badge del carrito incrementa

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 7. Vista Lista - Product Cards

- [ ] Lista muestra cards horizontales
- [ ] Full width menos márgenes (32px)
- [ ] Spacing 6px entre items

#### 7.1 Layout
- [ ] Imagen 80x80 a la izquierda
- [ ] Info en columna al centro
- [ ] Botón agregar a la derecha

#### 7.2 Contenido
- [ ] Nombre del producto visible
- [ ] Rating con estrellas + reviews
- [ ] Precio actual visible
- [ ] Formato correcto

#### 7.3 Interacción
- [ ] Tap en card navega a detalle
- [ ] Botón carrito agrega producto
- [ ] Badge del carrito incrementa

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 8. FABs (Floating Action Buttons)

#### 8.1 FAB Filtros
- [ ] Botón blanco en bottom-right
- [ ] Icono filter_alt verde
- [ ] Tap abre/cierra panel de filtros
- [ ] Animación smooth

#### 8.2 FAB Scroll to Top
- [ ] Botón verde debajo del de filtros
- [ ] Icono arrow_upward blanco
- [ ] Aparece solo después de scroll
- [ ] Tap hace scroll al inicio
- [ ] Animación smooth

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 9. Centro de Ayuda

- [ ] Opción "Ayuda" en PopupMenu
- [ ] Tap abre dialog
- [ ] Título "Centro de Ayuda" visible
- [ ] 3 opciones listadas:
  - [ ] Teléfono: 300 123 4567
  - [ ] Email: ayuda@biux.com
  - [ ] Chat en vivo: Lun-Vie 9am-6pm
- [ ] Iconos correctos para cada opción
- [ ] Botón "Cerrar" funciona

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

### 10. Estados de UI

#### 10.1 Loading
- [ ] CircularProgressIndicator aparece al cargar
- [ ] Texto "Cargando productos..." visible
- [ ] Centrado en pantalla

#### 10.2 Empty State
- [ ] Icono shopping_bag aparece cuando no hay productos
- [ ] Texto "No hay productos disponibles" visible
- [ ] Texto secundario con sugerencia
- [ ] Botón "Limpiar filtros" aparece si hay filtros activos
- [ ] Botón funciona correctamente

#### 10.3 Error State
- [ ] Icono error aparece si falla carga
- [ ] Mensaje de error visible
- [ ] Botón "Reintentar" funciona

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## 🎨 TESTING VISUAL

### Colores
- [ ] Primary (#16242D) usado correctamente
- [ ] Gradiente morado (#667eea → #764ba2) en banner
- [ ] Rojo (#FF5252) en badges de descuento
- [ ] Naranja (#FF9800) en badges de stock
- [ ] Verde en precios y botones
- [ ] Amarillo (#FFC107) en estrellas
- [ ] Gris (#F5F5F5) en background
- [ ] Blanco en cards

### Tipografía
- [ ] Tamaños de fuente correctos
- [ ] Pesos (regular, medium, bold) correctos
- [ ] Jerarquía visual clara
- [ ] Legibilidad en todos los textos

### Espaciado
- [ ] Padding interno de cards: 12px
- [ ] Spacing entre cards grid: 12px
- [ ] Spacing entre items lista: 6px
- [ ] Márgenes laterales: 16px
- [ ] Espaciado consistente en toda la app

### Sombras
- [ ] Cards tienen sombra sutil (0.08 opacity)
- [ ] Banner tiene sombra pronunciada (0.15 opacity)
- [ ] FABs tienen elevation correcta
- [ ] AppBar tiene sombra al scroll

### Bordes
- [ ] Border radius cards: 12px
- [ ] Border radius badges: 4px
- [ ] Border radius banners: 16px
- [ ] Border radius search bar: 24px
- [ ] Border radius FABs: círculo perfecto

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## ⚡ TESTING DE PERFORMANCE

### Scroll
- [ ] Scroll es fluido (60fps)
- [ ] Sin lag al hacer scroll rápido
- [ ] Sticky headers funcionan sin jank
- [ ] Imágenes no causan stuttering

### Carga de Imágenes
- [ ] Placeholders aparecen inmediatamente
- [ ] Imágenes cargan progresivamente
- [ ] Cache funciona (imágenes ya vistas cargan rápido)
- [ ] Sin memory leaks con muchas imágenes

### Filtros y Búsqueda
- [ ] Búsqueda filtra instantáneamente
- [ ] Filtros aplican en < 1 segundo
- [ ] Sin delay perceptible al cambiar categoría
- [ ] Sort reordena rápidamente

### Navegación
- [ ] Transiciones smooth entre vistas
- [ ] Push/pop de rutas es fluido
- [ ] Sin delay al agregar al carrito
- [ ] Badge actualiza instantáneamente

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## 📱 TESTING MULTI-DISPOSITIVO

### iOS Simulators (7 dispositivos)
- [ ] iPhone SE (3rd gen) - 4.7"
- [ ] iPhone 15 - 6.1"
- [ ] iPhone 15 Pro - 6.1"
- [ ] iPhone 15 Pro Max - 6.7"
- [ ] iPhone 16 - 6.1"
- [ ] iPhone 16 Pro - 6.3"
- [ ] iPhone 16 Pro Max - 6.9"

### Web (Chrome)
- [ ] Desktop (1920x1080)
- [ ] Tablet (1024x768)
- [ ] Mobile (375x667)

### Responsive
- [ ] Grid adapta columnas según ancho
- [ ] Textos no se cortan
- [ ] Botones tienen área táctil adecuada (min 44x44)
- [ ] Scroll funciona en todos los tamaños

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## 🔐 TESTING DE AUTENTICACIÓN

### Web (sin login)
- [ ] App abre directamente en /shop
- [ ] No pide login
- [ ] Todas las funciones disponibles
- [ ] Carrito funciona

### Mobile (con login)
- [ ] App pide login al abrir
- [ ] No puede acceder a /shop sin login
- [ ] Login exitoso redirige a /shop
- [ ] Sesión persiste entre aperturas

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## 🛒 TESTING DE CARRITO

- [ ] Badge muestra 0 inicialmente
- [ ] Badge incrementa al agregar producto
- [ ] Badge decrementa al quitar producto
- [ ] Número es correcto siempre
- [ ] Tap en carrito navega a /shop/cart
- [ ] Carrito muestra productos agregados
- [ ] Precio total es correcto

**Resultado:** ⬜ Pendiente | ✅ OK | ❌ Falla

---

## 🐛 BUGS ENCONTRADOS

### Bug #1
**Descripción:**  
**Pasos para reproducir:**  
**Resultado esperado:**  
**Resultado actual:**  
**Severidad:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low  
**Estado:** ⬜ Abierto | 🔧 En progreso | ✅ Resuelto  

### Bug #2
**Descripción:**  
**Pasos para reproducir:**  
**Resultado esperado:**  
**Resultado actual:**  
**Severidad:**  
**Estado:**  

---

## ✅ RESUMEN DE RESULTADOS

### Por Sección
- [ ] 1. AppBar y Búsqueda (11 checks)
- [ ] 2. Banner Promocional (9 checks)
- [ ] 3. Tabs de Categorías (15 checks)
- [ ] 4. Toolbar de Controles (14 checks)
- [ ] 5. Panel de Filtros (25 checks)
- [ ] 6. Vista Grid (35 checks)
- [ ] 7. Vista Lista (12 checks)
- [ ] 8. FABs (8 checks)
- [ ] 9. Centro de Ayuda (9 checks)
- [ ] 10. Estados de UI (12 checks)

### Por Categoría
- [ ] Funcional (150 checks)
- [ ] Visual (20 checks)
- [ ] Performance (12 checks)
- [ ] Multi-dispositivo (11 checks)
- [ ] Autenticación (7 checks)
- [ ] Carrito (7 checks)

**TOTAL:** 207 checks  
**Completados:** 0/207  
**Pendientes:** 207/207  
**Bugs encontrados:** 0  

---

## 📊 MÉTRICAS DE CALIDAD

### Cobertura de Testing
- Funcional: ⬜ 0%
- Visual: ⬜ 0%
- Performance: ⬜ 0%
- Responsive: ⬜ 0%

### Estado General
🔴 No iniciado | 🟡 En progreso | 🟢 Completado

---

## 👥 TESTING TEAM

**Tester:** _____________________  
**Fecha inicio:** 05/12/2024  
**Fecha fin:** _____________________  
**Duración:** _____________________  

---

**Desarrollado con ✅ para Biux**  
**Versión: 3.0 Professional**  
**05 de diciembre de 2024**
