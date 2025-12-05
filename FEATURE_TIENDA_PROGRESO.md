# 🛍️ Feature de Tienda - Biux App

**Fecha de Inicio:** 4 de diciembre de 2025  
**Estado:** 🔄 En desarrollo (60% completado)

---

## 📋 Descripción General

Nueva funcionalidad de tienda para la app Biux, permitiendo a los usuarios comprar productos de ciclismo y a los administradores gestionar el inventario.

### Características Principales

✅ **Para Usuarios:**
- Ver catálogo de productos de ciclismo
- Filtrar por categorías (Jerseys, Shorts, Cascos, Gafas, Guantes, Zapatos, Accesorios)
- Buscar productos por nombre/descripción
- Agregar productos al carrito
- Seleccionar tallas (cuando aplique)
- Crear órdenes de compra
- Ver historial de órdenes

✅ **Para Administradores:**
- Subir nuevos productos
- Editar productos existentes
- Gestionar inventario (stock)
- Ver todas las órdenes
- Actualizar estados de órdenes

---

## 🏗️ Arquitectura Implementada

### Clean Architecture - Feature-First

```
lib/features/shop/
├── domain/                    ✅ COMPLETADO
│   ├── entities/             
│   │   ├── product_entity.dart        ✅
│   │   ├── category_entity.dart       ✅
│   │   ├── cart_item_entity.dart      ✅
│   │   └── order_entity.dart          ✅
│   └── repositories/
│       ├── product_repository.dart    ✅
│       └── order_repository.dart      ✅
│
├── data/                      ✅ COMPLETADO
│   ├── models/
│   │   ├── product_model.dart         ✅
│   │   └── order_model.dart           ✅
│   ├── datasources/
│   │   ├── product_remote_datasource.dart  ✅
│   │   └── order_remote_datasource.dart    ✅
│   └── repositories/
│       ├── product_repository_impl.dart    ✅
│       └── order_repository_impl.dart      ✅
│
└── presentation/              ⏳ EN PROGRESO
    ├── providers/
    │   └── shop_provider.dart         ✅
    ├── screens/               ⏳ PENDIENTE
    │   ├── shop_screen.dart           ⏳
    │   ├── product_detail_screen.dart ⏳
    │   ├── cart_screen.dart           ⏳
    │   └── admin_shop_screen.dart     ⏳
    └── widgets/               ⏳ PENDIENTE
        ├── product_card.dart          ⏳
        ├── category_filter.dart       ⏳
        ├── cart_button.dart           ⏳
        └── price_tag.dart             ⏳
```

---

## ✅ Componentes Completados

### 1. Entidades del Dominio (4/4)

#### ProductEntity
- **Campos:** id, name, description, price, images[], category, sizes[], stock, sellerId, sellerName, createdAt, isActive, metadata
- **Métodos:** isAvailable, hasMultipleSizes, mainImage, copyWith()

#### CategoryEntity
- **Campos:** id, name, icon, productCount
- **Categorías Predefinidas:** Todos, Jerseys, Shorts, Cascos, Gafas, Guantes, Zapatos, Accesorios

#### CartItemEntity
- **Campos:** product, quantity, selectedSize
- **Métodos:** subtotal, needsSize, copyWith()

#### OrderEntity
- **Campos:** id, userId, userName, items[], total, status, deliveryAddress, phoneNumber, notes, createdAt, completedAt
- **Estados:** pending, processing, completed, cancelled

### 2. Modelos de Datos (2/2)

#### ProductModel
- Serialización completa con toJson/fromJson
- Integración con Firebase Firestore
- Manejo de Timestamps

#### OrderModel
- Serialización completa con toJson/fromJson
- Manejo de items del carrito
- Integración con Firebase Firestore

### 3. Repositories (4/4)

#### ProductRepository (Interface + Implementation)
- **Métodos:**
  - getProducts()
  - getProductsByCategory(category)
  - getProductById(id)
  - searchProducts(query)
  - createProduct(product) [Admin]
  - updateProduct(product) [Admin]
  - deleteProduct(id) [Admin]
  - updateStock(productId, newStock)
  - getProductsBySeller(sellerId)

#### OrderRepository (Interface + Implementation)
- **Métodos:**
  - createOrder(order)
  - getUserOrders(userId)
  - getAllOrders() [Admin]
  - getOrderById(id)
  - updateOrderStatus(orderId, status)
  - cancelOrder(orderId)

### 4. DataSources (2/2)

#### ProductRemoteDataSource
- Conexión con Firestore collection 'products'
- Queries optimizadas con índices
- Manejo de errores completo
- Soft delete (isActive flag)

#### OrderRemoteDataSource
- Conexión con Firestore collection 'orders'
- Gestión de estados de órdenes
- Registro de fechas de creación y completado

### 5. Provider de Estado (1/1)

#### ShopProvider
- **Estado de Productos:** loading, filtering, searching
- **Estado de Carrito:** items, total, count
- **Estado de Órdenes:** user orders, loading
- **Métodos para Usuarios:**
  - loadProducts()
  - filterByCategory(category)
  - searchProducts(query)
  - addToCart(product, size)
  - removeFromCart(productId, size)
  - updateCartItemQuantity(productId, quantity, size)
  - clearCart()
  - createOrderFromCart(...)
  - loadUserOrders(userId)
  - cancelOrder(orderId)
- **Métodos para Admins:**
  - createProduct(product)
  - updateProduct(product)
  - deleteProduct(productId)

---

## ⏳ Pendientes

### Pantallas (4)
1. ⏳ ShopScreen - Pantalla principal con grid de productos
2. ⏳ ProductDetailScreen - Detalle del producto con imágenes
3. ⏳ CartScreen - Carrito de compras
4. ⏳ AdminShopScreen - Panel de administración

### Widgets (4+)
1. ⏳ ProductCard - Tarjeta de producto en grid
2. ⏳ CategoryFilter - Filtros de categoría
3. ⏳ CartButton - Botón del carrito con badge
4. ⏳ PriceTag - Etiqueta de precio

### Integración (5)
1. ⏳ Agregar pestaña "Tienda" al MainShell
2. ⏳ Configurar rutas en app_router.dart
3. ⏳ Registrar ShopProvider en main.dart
4. ⏳ Agregar iconos/assets a Images
5. ⏳ Verificar/agregar campo isAdmin en UserEntity

### Testing (1)
1. ⏳ Probar funcionalidad completa en simuladores

### Deploy (1)
1. ⏳ Commit y push a GitHub

---

## 📊 Estructura de Firebase

### Colección: `products`

```json
{
  "id": "auto-generated",
  "name": "Jersey Pro Cycling",
  "description": "Jersey profesional de ciclismo...",
  "price": 45000,
  "images": [
    "https://...",
    "https://..."
  ],
  "category": "jerseys",
  "sizes": ["S", "M", "L", "XL"],
  "stock": 25,
  "sellerId": "uid-del-admin",
  "sellerName": "Biux Store",
  "createdAt": "Timestamp",
  "isActive": true,
  "metadata": {
    "brand": "Pro Brand",
    "color": "Azul"
  }
}
```

### Colección: `orders`

```json
{
  "id": "auto-generated",
  "userId": "uid-del-usuario",
  "userName": "Juan Pérez",
  "items": [
    {
      "product": { /* ProductEntity completo */ },
      "quantity": 2,
      "selectedSize": "M"
    }
  ],
  "total": 90000,
  "status": "pending",
  "deliveryAddress": "Calle 123 #45-67, Bogotá",
  "phoneNumber": "+573001234567",
  "notes": "Entregar después de las 2pm",
  "createdAt": "Timestamp",
  "completedAt": null
}
```

---

## 🎨 Categorías de Productos

| Categoría | Emoji | Ejemplos de Productos |
|-----------|-------|----------------------|
| Todos | 🛍️ | (Todos los productos) |
| Jerseys | 👕 | Camisetas ciclismo, maillots |
| Shorts | 🩳 | Culotes, pantalones cortos |
| Cascos | 🪖 | Cascos MTB, ruta, urbanos |
| Gafas | 🕶️ | Gafas deportivas, protección UV |
| Guantes | 🧤 | Guantes largos, cortos, térmicos |
| Zapatos | 👟 | Zapatillas MTB, ruta |
| Accesorios | 🎒 | Botellas, luces, bombas, herramientas |

---

## 🔐 Control de Permisos

### Roles de Usuario

**Usuario Regular:**
- ✅ Ver productos
- ✅ Filtrar y buscar
- ✅ Agregar al carrito
- ✅ Crear órdenes
- ✅ Ver sus órdenes
- ✅ Cancelar órdenes pendientes
- ❌ No puede subir productos
- ❌ No puede editar productos
- ❌ No puede ver todas las órdenes

**Administrador:**
- ✅ Todas las funciones de usuario regular
- ✅ Subir nuevos productos
- ✅ Editar productos existentes
- ✅ Eliminar productos (soft delete)
- ✅ Gestionar stock
- ✅ Ver todas las órdenes
- ✅ Actualizar estados de órdenes

### Implementación de isAdmin

Se debe agregar el campo `isAdmin` a la entidad de usuario existente:

```dart
class UserEntity {
  // ... campos existentes
  final bool isAdmin;
  
  UserEntity({
    // ... parámetros existentes
    this.isAdmin = false,
  });
}
```

**Validación en Firebase:**
```javascript
// Firestore Security Rules
match /products/{productId} {
  // Todos pueden leer
  allow read: if true;
  
  // Solo admins pueden escribir
  allow write: if request.auth != null && 
               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

---

## 💰 Flujo de Compra

### Paso 1: Explorar Productos
1. Usuario entra a la pestaña "Tienda"
2. Ve grid de productos disponibles
3. Puede filtrar por categoría
4. Puede buscar por nombre

### Paso 2: Ver Detalle
1. Usuario toca un producto
2. Ve imágenes, descripción completa, precio
3. Selecciona talla (si aplica)
4. Ve stock disponible

### Paso 3: Agregar al Carrito
1. Usuario toca "Agregar al carrito"
2. Se muestra confirmación
3. Badge del carrito se actualiza

### Paso 4: Revisar Carrito
1. Usuario toca ícono del carrito
2. Ve lista de productos seleccionados
3. Puede modificar cantidades
4. Puede remover productos
5. Ve total a pagar

### Paso 5: Crear Orden
1. Usuario toca "Proceder al pago"
2. Ingresa dirección de entrega
3. Ingresa teléfono de contacto
4. Agrega notas opcionales
5. Confirma orden

### Paso 6: Confirmación
1. Sistema crea orden en Firebase
2. Actualiza stock de productos
3. Limpia el carrito
4. Muestra confirmación al usuario
5. Usuario puede ver orden en "Mis Órdenes"

---

## 🚀 Próximos Pasos (Sesión Actual)

1. **Crear ShopScreen** - Pantalla principal con grid
2. **Crear ProductDetailScreen** - Detalle del producto
3. **Crear CartScreen** - Carrito de compras
4. **Crear AdminShopScreen** - Panel admin
5. **Crear widgets reutilizables**
6. **Integrar en MainShell y Router**
7. **Probar en simuladores**
8. **Commit a GitHub**

---

## 📝 Notas Técnicas

### Dependencias Utilizadas
- ✅ cloud_firestore (ya existe en el proyecto)
- ✅ provider (ya existe en el proyecto)
- ✅ firebase_storage (para imágenes de productos)

### Optimizaciones
- Caching de productos en memoria
- Paginación opcional para grandes catálogos
- Lazy loading de imágenes
- Búsqueda client-side para mejor UX

### Consideraciones de UX
- Indicadores de carga durante operaciones
- Mensajes de error claros
- Confirmaciones antes de acciones destructivas
- Badge en ícono del carrito con cantidad
- Animaciones sutiles en transiciones

---

**Progreso:** 12/20 tareas completadas (60%)  
**Estado:** ✅ Backend completo | ⏳ Frontend en progreso  
**Siguiente:** Crear interfaces de usuario (screens + widgets)
