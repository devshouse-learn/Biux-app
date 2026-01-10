# 🎨 GUÍA VISUAL DE LA TIENDA BIUX

## 📱 Lo que Verás Cuando Se Abra la App

### 1️⃣ Pantalla de Login/Bienvenida

```
┌─────────────────────────────────┐
│         🚴 BIUX                 │
│                                 │
│   ┌───────────────────────┐    │
│   │  Email o Teléfono     │    │
│   └───────────────────────┘    │
│                                 │
│   ┌───────────────────────┐    │
│   │  Contraseña           │    │
│   └───────────────────────┘    │
│                                 │
│   [ Iniciar Sesión ]            │
│                                 │
│   ¿No tienes cuenta?            │
│   Regístrate                    │
└─────────────────────────────────┘
```

### 2️⃣ Menú Principal (Después del Login)

```
┌─────────────────────────────────┐
│ ☰  BIUX              🛒 👤     │
├─────────────────────────────────┤
│                                 │
│  🏠 Inicio                      │
│  🗺️  Mapa                       │
│  🚴 Rodadas                     │
│  👥 Grupos                      │
│  🛣️  Rutas                      │
│  📖 Experiencias                │
│  🏪 TIENDA  ← NUEVA             │
│  ⚙️  Configuración              │
│                                 │
└─────────────────────────────────┘
```

### 3️⃣ Pantalla Principal de la Tienda (shop_screen_pro.dart)

```
┌─────────────────────────────────────────┐
│  ← Tienda              🛒(2)  ⋮        │
├─────────────────────────────────────────┤
│  🔍 [Buscar productos, marcas...]       │
├─────────────────────────────────────────┤
│                                         │
│  🎉 PRODUCTOS DE CICLISMO               │
│     Encuentra todo lo que necesitas     │
│     Calidad garantizada          🛍️    │
│                                         │
├─────────────────────────────────────────┤
│  [Todos] [Jerseys] [Culotes] [...]  → │
├─────────────────────────────────────────┤
│  📊 156 productos  🔽 Ordenar  ▦ ☰    │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │  Imagen  │  │  Imagen  │           │
│  │          │  │          │           │
│  │ Jersey   │  │ Casco    │           │
│  │ $89.990  │  │ $245.000 │           │
│  │ ⭐⭐⭐⭐⭐ │  │ ⭐⭐⭐⭐⭐  │           │
│  │    🛒    │  │    🛒    │           │
│  └──────────┘  └──────────┘           │
│                                         │
│  ┌──────────┐  ┌──────────┐           │
│  │  Imagen  │  │  Imagen  │           │
│  │          │  │          │           │
│  │ Guantes  │  │ Botella  │           │
│  │ $45.000  │  │ $12.000  │           │
│  │ ⭐⭐⭐⭐⭐ │  │ ⭐⭐⭐⭐   │           │
│  │    🛒    │  │    🛒    │           │
│  └──────────┘  └──────────┘           │
│                                         │
└─────────────────────────────────────────┘
         [ ⚙️ ]  [ 🔍 ]  [ ↑ ]
```

### 4️⃣ Menú Desplegable (⋮)

```
┌─────────────────────────────┐
│  📦 Mis Pedidos             │
│  ⭐ Favoritos               │
│  📋 Solicitar Vender        │ ← Para usuarios
│  ──────────────────────────  │
│  👥 Solicitudes Vendedores  │ ← Solo Admin
│  🏪 Gestionar Vendedores    │ ← Solo Admin
│  🗑️  Eliminar Productos     │ ← Solo Admin
│  ──────────────────────────  │
│  ❓ Ayuda                   │
└─────────────────────────────┘
```

### 5️⃣ Detalle de Producto

```
┌─────────────────────────────────────────┐
│  ← Jersey Castelli         🛒(2)        │
├─────────────────────────────────────────┤
│                                         │
│      [  Imagen Principal  ]             │
│         ● ○ ○ ○ ○                      │
│                                         │
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐                      │
│  └─┘ └─┘ └─┘ └─┘                      │
│                                         │
├─────────────────────────────────────────┤
│  Jersey Castelli Aero Race 6.0         │
│  🏷️ Ropa                               │
│                                         │
│  $̶3̶5̶0̶.̶0̶0̶0̶  $280.000  [-20% OFF]   │
│                                         │
│  🏪 Vendido por: Tienda Biux           │
│  ✅ En stock: 8 unidades               │
│                                         │
│  ────────────────────────────────────── │
│                                         │
│  📋 Descripción                         │
│  Jersey aerodinámico profesional       │
│  con tejido Velocity Rev2. Corte       │
│  race fit para máxima velocidad.       │
│                                         │
│  📐 Especificaciones                    │
│  • Material: Velocity Rev2             │
│  • Tallas: XS, S, M, L, XL             │
│  • Corte: Race Fit                     │
│  • Bolsillos: 3 traseros               │
│                                         │
│  🏷️ Etiquetas                          │
│  [jersey] [castelli] [ropa] [aero]    │
│                                         │
└─────────────────────────────────────────┘
│  [-] 1 [+]     [Agregar al Carrito]   │
└─────────────────────────────────────────┘
```

### 6️⃣ Carrito de Compras

```
┌─────────────────────────────────────────┐
│  ← Carrito de Compras                  │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ [Img] Jersey Castelli            │ │
│  │       $280.000 c/u               │ │
│  │       [-] 2 [+]     $560.000  🗑️ │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ [Img] Casco POC                  │ │
│  │       $245.000 c/u               │ │
│  │       [-] 1 [+]     $245.000  🗑️ │ │
│  └───────────────────────────────────┘ │
│                                         │
├─────────────────────────────────────────┤
│  Productos: 3 items                    │
│  Total: $805.000                       │
│                                         │
│  [ 💳 Proceder al pago ]               │
│  [ Continuar comprando ]                │
└─────────────────────────────────────────┘
```

### 7️⃣ Solicitar Permiso para Vender (Usuario Normal)

```
┌─────────────────────────────────────────┐
│  Solicitar Permiso para Vender         │
├─────────────────────────────────────────┤
│                                         │
│  Para vender productos en Biux,        │
│  necesitas autorización de un admin.   │
│                                         │
│  Cuéntanos por qué quieres vender:     │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ Me gustaría vender productos en  │ │
│  │ la tienda de Biux. Tengo         │ │
│  │ experiencia en ciclismo y        │ │
│  │ productos de calidad...          │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ℹ️ Un administrador revisará tu       │
│     solicitud y te notificará.         │
│                                         │
│  [ Cancelar ]  [ Enviar Solicitud ]   │
└─────────────────────────────────────────┘
```

### 8️⃣ Panel de Administración (Solo Admin)

```
┌─────────────────────────────────────────┐
│  ← Panel de Administración             │
├─────────────────────────────────────────┤
│  [Usuarios] [Vendedores] [Productos]   │
├─────────────────────────────────────────┤
│                                         │
│  📊 Estadísticas                        │
│                                         │
│  ┌────────────┐  ┌────────────┐       │
│  │ 👥 Usuarios │  │ 🏪 Vendedor│       │
│  │    1,234    │  │     45     │       │
│  └────────────┘  └────────────┘       │
│                                         │
│  ┌────────────┐  ┌────────────┐       │
│  │ 📦 Product │  │ ⭐ Destacad│       │
│  │    156     │  │     12     │       │
│  └────────────┘  └────────────┘       │
│                                         │
│  📋 Acciones Rápidas                   │
│  • Ver Todos los Usuarios              │
│  • Aprobar Solicitudes (🔴 3)          │
│  • Gestionar Vendedores                │
│  • Gestionar Productos                 │
│                                         │
└─────────────────────────────────────────┘
```

### 9️⃣ Solicitudes de Vendedores (Admin)

```
┌─────────────────────────────────────────┐
│  ← Solicitudes de Vendedores           │
├─────────────────────────────────────────┤
│  [Pendientes(3)] [Aprobadas] [Rechaz.] │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ 👤 Juan Pérez                     │ │
│  │ 📧 juan@email.com                 │ │
│  │                                   │ │
│  │ Mensaje:                          │ │
│  │ "Me gustaría vender productos..." │ │
│  │                                   │ │
│  │ 🕐 Solicitado: 09/01/2026 14:30  │ │
│  │                                   │ │
│  │ [ ✅ Aprobar ]  [ ❌ Rechazar ]   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ 👤 María García                   │ │
│  │ 📧 maria@email.com                │ │
│  │ ...                               │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### 🔟 Filtros Avanzados (Expandible)

```
┌─────────────────────────────────────────┐
│  🎚️ Filtros Avanzados          [Limpiar]│
├─────────────────────────────────────────┤
│                                         │
│  💰 Rango de precio                     │
│  ├───●─────────────────●───┤           │
│  $0                    $1,000k         │
│                                         │
│  ☑️ Solo productos en stock             │
│                                         │
│  ⭐ Calificación mínima                 │
│  ★ ★ ★ ★ ☆                            │
│                                         │
│  [ Aplicar Filtros ]                   │
│                                         │
└─────────────────────────────────────────┘
```

## 🎯 Flujo de Usuario Recomendado

### Para Explorar la Tienda:

1. **Login** → Inicia sesión con tu cuenta
2. **Navega al menú** → Selecciona "🏪 Tienda"
3. **Explora** → Verás el catálogo completo
4. **Busca** → Usa la barra de búsqueda
5. **Filtra** → Selecciona categorías
6. **Agrega al carrito** → Toca el botón 🛒
7. **Revisa carrito** → Toca el ícono del carrito
8. **Compra** → Procede al pago (demo)

### Para Solicitar Ser Vendedor:

1. **Menú (⋮)** → Toca los tres puntos
2. **Solicitar Vender** → Selecciona la opción
3. **Escribe mensaje** → Explica por qué
4. **Envía** → Espera aprobación

### Para Aprobar Vendedores (Admin):

1. **Menú (⋮)** → Toca los tres puntos
2. **Solicitudes** → Ver pendientes (badge rojo)
3. **Revisa** → Lee cada solicitud
4. **Aprueba/Rechaza** → Toma decisión
5. **Agrega comentario** → Opcional

## 🎨 Características Visuales

### Badges y Etiquetas:
- 🔴 **-20% OFF** - Descuentos en rojo
- 🟢 **En Stock** - Disponibilidad en verde
- 🟠 **Solo 3** - Stock bajo en naranja
- ⭐ **Destacado** - Productos destacados
- 🔵 **(2)** - Contador del carrito

### Colores del Tema:
- **Primary:** Verde Biux (`#4CAF50`)
- **Secondary:** Naranja (`#FF9800`)
- **Accent:** Azul (`#2196F3`)
- **Error:** Rojo (`#F44336`)
- **Success:** Verde (`#4CAF50`)

### Iconografía:
- 🏪 Tienda
- 🛒 Carrito
- ⭐ Favoritos
- 📦 Pedidos
- 👤 Usuario
- ⚙️ Configuración
- 🔍 Búsqueda
- 🎯 Filtros

## 📱 Interacciones

### Gestos Soportados:
- **Tap** → Seleccionar producto, agregar al carrito
- **Long Press** → Ver opciones adicionales
- **Swipe** → Navegar entre imágenes
- **Scroll** → Explorar catálogo
- **Pull to Refresh** → Actualizar productos

### Transiciones:
- ✨ **Hero Animations** en imágenes de productos
- 🔄 **Fade In/Out** en cambios de pantalla
- 📊 **Slide Up** en detalles de producto
- 🎭 **Scale** en botones al presionar

## 🚀 Estado Actual

✅ **Compilando en Xcode...**

La app se abrirá automáticamente cuando termine la compilación.

**Tiempo estimado:** 3-5 minutos

---

**Última actualización:** 10 de Enero de 2026
**Commit:** 720bfde
**Estado:** 🔄 Compilando...
