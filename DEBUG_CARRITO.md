# 🐛 DEBUG: CARRITO NO AGREGA PRODUCTOS
## 6 de diciembre de 2025

---

## ❌ **PROBLEMA REPORTADO**

**Descripción:** El carrito no agrega productos cuando el usuario toca "Agregar al carrito"

**Síntomas posibles:**
- Botón no responde al hacer clic
- Producto no aparece en el carrito
- Contador del carrito no se actualiza
- Sin mensaje de confirmación

---

## 🔍 **DIAGNÓSTICO APLICADO**

### **Logs Agregados para Debug**

#### **1. En ProductDetailScreen (_addToCart)**

Agregamos logs detallados para rastrear el flujo:

```dart
void _addToCart() {
  if (_product == null) {
    print('⚠️ ERROR: Producto es null');
    return;
  }

  print('🛒 Intentando agregar al carrito: ${_product!.name}');
  print('  - ID: ${_product!.id}');
  print('  - Precio: \$${_product!.price}');
  print('  - Cantidad: $_quantity');
  print('  - Talla seleccionada: $_selectedSize');
  print('  - Disponible: ${_product!.isAvailable}');
  print('  - Stock: ${_product!.stock}');
  print('  - Activo: ${_product!.isActive}');
  print('  - Vendido: ${_product!.isSold}');

  // ... resto del código con más logs
}
```

#### **2. En ShopProvider (addToCart)**

Agregamos logs para verificar que el provider se llama correctamente:

```dart
void addToCart(ProductEntity product, {String? selectedSize}) {
  print('🛒 ShopProvider.addToCart llamado:');
  print('  - Producto: ${product.name} (ID: ${product.id})');
  print('  - Talla: $selectedSize');
  print('  - Carrito actual: ${_cartItems.length} items');
  
  // ... lógica de agregar
  
  print('  - Carrito actualizado: ${_cartItems.length} items');
  print('  - Total items: $cartItemCount');
  print('  - Total precio: \$$cartTotal');
  notifyListeners();
  print('  ✅ notifyListeners() llamado');
}
```

---

## 🧪 **CÓMO PROBAR Y VER LOS LOGS**

### **Pasos para Diagnosticar:**

1. **Abrir Herramientas de Desarrollador**
   ```
   - Chrome: F12 o Cmd+Option+I (Mac)
   - Ir a la pestaña "Console"
   ```

2. **Navegar a un Producto**
   ```
   - Login en http://localhost:8080
   - Ir a Tienda
   - Tocar cualquier producto
   ```

3. **Intentar Agregar al Carrito**
   ```
   - Tocar botón "Agregar al carrito"
   - Observar los logs en la consola
   ```

4. **Logs Esperados (Si funciona correctamente):**
   ```
   🛒 Intentando agregar al carrito: Bicicleta MTB
     - ID: prod-001
     - Precio: $1500000
     - Cantidad: 1
     - Talla seleccionada: M
     - Disponible: true
     - Stock: 5
     - Activo: true
     - Vendido: false
   📦 Carrito antes: 0 items
   🛒 ShopProvider.addToCart llamado:
     - Producto: Bicicleta MTB (ID: prod-001)
     - Talla: M
     - Carrito actual: 0 items
     ✓ Agregando nuevo producto al carrito
     - Carrito actualizado: 1 items
     - Total items: 1
     - Total precio: $1500000
     ✅ notifyListeners() llamado
   📦 Carrito después: 1 items
   ✅ Producto agregado exitosamente
   ```

5. **Posibles Errores que Podrías Ver:**

   **A) Producto no disponible:**
   ```
   🛒 Intentando agregar al carrito: Producto X
     - Disponible: false  ← PROBLEMA AQUÍ
     - Stock: 0  o  isSold: true
   ```
   **Solución:** El botón está deshabilitado si `isAvailable = false`

   **B) Debe seleccionar talla:**
   ```
   ⚠️ ERROR: Debe seleccionar una talla
   ```
   **Solución:** Seleccionar una talla antes de agregar

   **C) Provider no se actualiza:**
   ```
   📦 Carrito después: 1 items
   ✅ Producto agregado exitosamente
   [Pero el carrito sigue mostrando 0 en la UI]
   ```
   **Solución:** Problema con Consumer<ShopProvider> en CartScreen

---

## 🔧 **POSIBLES CAUSAS Y SOLUCIONES**

### **Causa 1: Producto No Disponible**

**Problema:** El botón está deshabilitado porque `product.isAvailable == false`

**Verificación:**
```dart
// En ProductEntity
bool get isAvailable => isActive && stock > 0 && !isSold;
```

**Soluciones:**
1. Verificar que el producto tenga `stock > 0`
2. Verificar que `isActive == true`
3. Verificar que `isSold == false`

---

### **Causa 2: Context Incorrecto**

**Problema:** El `context.read<ShopProvider>()` no encuentra el provider

**Verificación:**
- Asegurarse de que ShopProvider esté en el árbol de widgets
- Verificar que main.dart tenga MultiProvider configurado

**Solución:**
```dart
// En main.dart debe estar:
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ShopProvider()),
    // ...otros providers
  ],
  child: MyApp(),
)
```

---

### **Causa 3: CartScreen No Se Actualiza**

**Problema:** El carrito se agrega pero la UI no se refresca

**Verificación:**
```dart
// CartScreen debe usar Consumer
Consumer<ShopProvider>(
  builder: (context, shopProvider, child) {
    if (shopProvider.cartItems.isEmpty) {
      return Text('Carrito vacío');
    }
    return ListView.builder(
      itemCount: shopProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = shopProvider.cartItems[index];
        // ...
      },
    );
  },
)
```

---

### **Causa 4: Navegación Rota**

**Problema:** El enlace "Ver carrito" no funciona

**Verificación:**
```dart
// Debe ser:
context.push('/shop/cart')  // ✅ Correcto

// NO usar:
context.go('/shop/cart')  // Puede causar problemas en algunos casos
```

---

## 📊 **CHECKLIST DE VALIDACIÓN**

Usa esta lista para verificar cada paso:

### **En la Pantalla de Producto:**
- [ ] Producto tiene `stock > 0`
- [ ] Producto tiene `isActive == true`
- [ ] Producto NO está vendido (`isSold == false`)
- [ ] Botón "Agregar al carrito" está habilitado (no gris)
- [ ] Si hay tallas, una talla está seleccionada
- [ ] Al tocar botón, aparece SnackBar "X productos agregados al carrito"

### **En la Consola del Navegador:**
- [ ] Aparece log: `🛒 Intentando agregar al carrito`
- [ ] Aparece log: `📦 Carrito antes: X items`
- [ ] Aparece log: `🛒 ShopProvider.addToCart llamado`
- [ ] Aparece log: `✓ Agregando nuevo producto` o `✓ Producto ya existe`
- [ ] Aparece log: `📦 Carrito después: X items` (incrementado)
- [ ] Aparece log: `✅ notifyListeners() llamado`

### **En la Pantalla del Carrito:**
- [ ] Navegar a `/shop/cart` muestra el producto agregado
- [ ] Contador de items en el AppBar se actualiza
- [ ] Precio total se calcula correctamente
- [ ] Imagen del producto se muestra
- [ ] Botones +/- funcionan para cambiar cantidad

---

## 🎯 **PRÓXIMOS PASOS**

1. **Abrir la consola del navegador** (F12)
2. **Intentar agregar un producto al carrito**
3. **Copiar TODOS los logs** que aparezcan
4. **Enviarme los logs** para diagnosticar el problema exacto

---

## 📝 **INFORMACIÓN ADICIONAL**

### **Archivos Modificados:**
1. `lib/features/shop/presentation/screens/product_detail_screen.dart`
   - Método `_addToCart()` con logs extensivos

2. `lib/features/shop/presentation/providers/shop_provider.dart`
   - Método `addToCart()` con logs extensivos

### **Compilación:**
```bash
flutter build web --release
# ✓ Built build/web (26.7s)
```

### **Servidor:**
```bash
cd build/web && python3 -m http.server 8080
# Serving HTTP on :: port 8080 (http://[::]:8080/) ...
```

---

## 🚀 **INSTRUCCIONES PARA EL USUARIO**

### **Para Ver los Logs y Diagnosticar:**

1. **Abre Chrome DevTools:**
   - Presiona `F12` o `Cmd+Option+I` (Mac)
   - Ve a la pestaña `Console`

2. **Limpia la consola:**
   - Click en el icono 🚫 (Clear console)

3. **Ve a un producto:**
   - Navega a la tienda
   - Abre cualquier producto

4. **Intenta agregar al carrito:**
   - Toca "Agregar al carrito"
   - Observa la consola

5. **Copia los logs:**
   - Click derecho en la consola → "Save as..."
   - O toma screenshot
   - Envíame los logs para analizar

---

**Fecha:** 6 de diciembre de 2025  
**Estado:** 🔍 Debug mode activado - Esperando logs del usuario  
**Compilación:** ✅ Exitosa con logs  
**Servidor:** ✅ Corriendo en puerto 8080
