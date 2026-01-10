# 🛍️ Productos de Prueba para Firestore

## Opción 1: Script Automático (Recomendado)

### Pasos:

1. **Actualizar el vendedorId:**
   ```bash
   # Abre el archivo del script
   code lib/scripts/seed_products.dart
   
   # Busca la línea 20 y cambia:
   const vendedorId = 'TU_USER_ID_AQUI';
   # Por tu ID real de Firestore (lo puedes obtener de Firebase Console > Firestore > usuarios)
   ```

2. **Ejecutar el script:**
   ```bash
   dart run lib/scripts/seed_products.dart
   ```

3. **Verificar en Firebase Console:**
   - Ve a https://console.firebase.google.com
   - Selecciona tu proyecto "biux-1576614678644"
   - Cloud Firestore > productos
   - Deberías ver 8 productos creados

---

## Opción 2: Creación Manual en Firebase Console

Si el script no funciona, sigue estos pasos:

### 1. Accede a Firebase Console
- URL: https://console.firebase.google.com
- Proyecto: biux-1576614678644
- Navega a: **Firestore Database** > **Data**

### 2. Crea la colección "productos" (si no existe)
- Click en "Start collection"
- Nombre: `productos`
- Click "Next"

### 3. Agrega cada producto manualmente

#### 📝 IMPORTANTE: 
- Reemplaza `"TU_USER_ID_AQUI"` con tu ID real de usuario
- Para obtenerlo: Firestore > usuarios > copia el ID de tu documento de usuario

---

## 🚴 Producto 1: Bicicleta Trek X-Caliber 8

```json
{
  "nombre": "Bicicleta Trek X-Caliber 8",
  "descripcion": "Bicicleta de montaña profesional con cuadro de aluminio Alpha Silver, suspensión RockShox Judy Silver y frenos hidráulicos. Perfecta para trail y cross-country.",
  "precio": 25000,
  "descuento": 15,
  "categoria": "bicicletas",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=800",
    "https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=800"
  ],
  "stock": 5,
  "destacado": true,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["mtb", "trek", "montaña", "aluminio", "rockshox"],
  "especificaciones": {
    "Material": "Aluminio Alpha Silver",
    "Suspensión": "RockShox Judy Silver 100mm",
    "Frenos": "Hidráulicos Shimano MT200",
    "Cambios": "Shimano Deore 12 velocidades",
    "Ruedas": "29 pulgadas",
    "Peso": "13.5 kg"
  }
}
```

**Pasos en Firebase Console:**
1. Click "Add document"
2. Auto-ID (deja que Firebase genere el ID)
3. Click "Add field" para cada campo
4. Para arrays (imagenes, tags): tipo "array", agrega cada valor
5. Para maps (especificaciones): tipo "map", agrega cada key-value
6. Click "Save"

---

## 🪖 Producto 2: Casco POC Ventral Air SPIN

```json
{
  "nombre": "Casco POC Ventral Air SPIN",
  "descripcion": "Casco de carretera de alta gama con tecnología SPIN para mayor protección. Diseño aerodinámico con excelente ventilación.",
  "precio": 4500,
  "descuento": null,
  "categoria": "proteccion",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1519620149092-a0d3ce7446e1?w=800"
  ],
  "stock": 12,
  "destacado": true,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["casco", "poc", "seguridad", "aerodinámico"],
  "especificaciones": {
    "Tallas": "S, M, L",
    "Peso": "250g",
    "Certificación": "CE EN 1078",
    "Tecnología": "SPIN",
    "Ventilación": "22 vents"
  }
}
```

---

## 👕 Producto 3: Jersey Castelli Aero Race 6.0

```json
{
  "nombre": "Jersey Castelli Aero Race 6.0",
  "descripcion": "Jersey aerodinámico profesional con tejido Velocity Rev2. Corte race fit para máxima velocidad.",
  "precio": 2800,
  "descuento": 20,
  "categoria": "ropa",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1581888227599-779811939961?w=800"
  ],
  "stock": 8,
  "destacado": false,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["jersey", "castelli", "ropa", "aero"],
  "especificaciones": {
    "Material": "Velocity Rev2",
    "Tallas": "XS, S, M, L, XL",
    "Corte": "Race Fit",
    "Bolsillos": "3 traseros",
    "Cremallera": "YKK Vislon"
  }
}
```

---

## 🦶 Producto 4: Pedales Shimano PD-M8100 XT

```json
{
  "nombre": "Pedales Shimano PD-M8100 XT",
  "descripcion": "Pedales automáticos de MTB de alta gama. Plataforma amplia y fácil enganche/desenganche.",
  "precio": 1800,
  "descuento": null,
  "categoria": "componentes",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1576778969066-5b59fc37e885?w=800"
  ],
  "stock": 15,
  "destacado": false,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["pedales", "shimano", "xt", "mtb"],
  "especificaciones": {
    "Peso": "310g (par)",
    "Eje": "Cromoly",
    "Plataforma": "Amplia",
    "Tensión": "Ajustable"
  }
}
```

---

## 💡 Producto 5: Luz Delantera Lezyne Mega Drive 1800

```json
{
  "nombre": "Luz Delantera Lezyne Mega Drive 1800",
  "descripcion": "Luz delantera ultra potente de 1800 lúmenes. Recargable vía USB-C. Ideal para ciclismo nocturno.",
  "precio": 1500,
  "descuento": 10,
  "categoria": "electronica",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800"
  ],
  "stock": 20,
  "destacado": true,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["luz", "lezyne", "seguridad", "nocturno"],
  "especificaciones": {
    "Lumens": "1800",
    "Batería": "Li-ion recargable",
    "Autonomía": "Hasta 50 horas",
    "Carga": "USB-C",
    "Modos": "8"
  }
}
```

---

## 🍶 Producto 6: Botella Elite Fly 750ml

```json
{
  "nombre": "Botella Elite Fly 750ml",
  "descripcion": "Botella ultraligera y ergonómica. Material biodegradable sin BPA.",
  "precio": 250,
  "descuento": null,
  "categoria": "accesorios",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800"
  ],
  "stock": 50,
  "destacado": false,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["botella", "elite", "hidratación"],
  "especificaciones": {
    "Capacidad": "750ml",
    "Peso": "54g",
    "Material": "Polipropileno biodegradable",
    "Sin BPA": "Sí"
  }
}
```

---

## ⚡ Producto 7: Gel SIS GO Isotonic (Pack 6)

```json
{
  "nombre": "Gel SIS GO Isotonic (Pack 6)",
  "descripcion": "Pack de 6 geles isotónicos para energía rápida durante el ejercicio. Sabor frutas tropicales.",
  "precio": 180,
  "descuento": null,
  "categoria": "nutricion",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800"
  ],
  "stock": 100,
  "destacado": false,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["gel", "nutrición", "energía", "sis"],
  "especificaciones": {
    "Contenido": "6 geles x 60ml",
    "Calorías": "87 kcal por gel",
    "Carbohidratos": "22g",
    "Sabor": "Frutas Tropicales"
  }
}
```

---

## 🔧 Producto 8: Multiherramienta Topeak Mini 20 Pro

```json
{
  "nombre": "Multiherramienta Topeak Mini 20 Pro",
  "descripcion": "Herramienta compacta con 20 funciones. Incluye llaves Allen, destornilladores y tronchacadenas.",
  "precio": 650,
  "descuento": null,
  "categoria": "herramientas",
  "vendedorId": "TU_USER_ID_AQUI",
  "vendedorNombre": "Tienda Oficial Biux",
  "imagenes": [
    "https://images.unsplash.com/photo-1530435460869-d13625c69bbf?w=800"
  ],
  "stock": 25,
  "destacado": false,
  "activo": true,
  "fechaCreacion": "2025-12-13T10:00:00.000Z",
  "tags": ["herramienta", "topeak", "reparación"],
  "especificaciones": {
    "Funciones": "20",
    "Peso": "120g",
    "Incluye": "Llaves Allen 2-8mm, destornilladores, tronchacadenas",
    "Material": "Acero inoxidable"
  }
}
```

---

## 🎯 Verificación Post-Creación

Después de crear los productos, verifica:

### 1. En Firebase Console
- [ ] La colección "productos" existe
- [ ] Hay 8 documentos en la colección
- [ ] Cada producto tiene todos los campos requeridos
- [ ] El vendedorId coincide con un usuario real

### 2. En la App (Chrome)
```bash
# Si la app no está corriendo:
flutter run -d chrome --web-port=8080

# Navega a:
http://localhost:8080/#/store
```

Deberías ver:
- [ ] 8 productos en la tienda
- [ ] Filtros por categoría funcionando
- [ ] 3 productos destacados al inicio
- [ ] Imágenes cargando correctamente
- [ ] Precios con descuento calculados

### 3. Pruebas Funcionales
- [ ] Click en un producto → abre detalle
- [ ] Agregar al carrito → aparece badge con cantidad
- [ ] Ver carrito → muestra productos agregados
- [ ] Búsqueda → filtra productos por nombre

---

## 🐛 Solución de Problemas

### Error: "vendedorId no existe"
**Solución:** Cambia `TU_USER_ID_AQUI` por tu ID real de Firestore

### Error: "Collection does not exist"
**Solución:** Crea manualmente la colección "productos" en Firebase Console

### Productos no aparecen en la app
**Verificar:**
1. Firebase está inicializado correctamente
2. La colección se llama exactamente "productos" (minúsculas)
3. El campo "activo" está en `true`
4. Recarga la app (Ctrl+R en Chrome)

### Imágenes no cargan
**Causa:** URLs de Unsplash pueden requerir configuración CORS
**Solución Temporal:** Las imágenes son de prueba, la funcionalidad del carrito sigue funcionando

---

## 📊 Resumen de Productos Creados

| # | Producto | Categoría | Precio | Stock | Destacado |
|---|----------|-----------|--------|-------|-----------|
| 1 | Trek X-Caliber 8 | Bicicletas | $25,000 | 5 | ✅ |
| 2 | Casco POC Ventral | Protección | $4,500 | 12 | ✅ |
| 3 | Jersey Castelli | Ropa | $2,800 | 8 | ❌ |
| 4 | Pedales Shimano XT | Componentes | $1,800 | 15 | ❌ |
| 5 | Luz Lezyne 1800 | Electrónica | $1,500 | 20 | ✅ |
| 6 | Botella Elite | Accesorios | $250 | 50 | ❌ |
| 7 | Gel SIS Pack 6 | Nutrición | $180 | 100 | ❌ |
| 8 | Multiherramienta Topeak | Herramientas | $650 | 25 | ❌ |

**Total productos:** 8  
**Stock total:** 235 unidades  
**Categorías cubiertas:** 8 de 9 (falta solo "otros")

---

## 🚀 Siguiente Paso

Una vez creados los productos, prueba el flujo completo:

1. **Como Usuario Normal:**
   - Ver tienda → Agregar productos → Checkout
   
2. **Como Vendedor (requiere autorización admin):**
   - Dashboard vendedor → Crear producto → Editar → Desactivar

3. **Como Admin:**
   - Panel admin → Autorizar vendedor → Ver todos los productos

---

¿Necesitas ayuda? Revisa: `TIENDA_COMPLETA_FINAL_13DIC2025.md`
