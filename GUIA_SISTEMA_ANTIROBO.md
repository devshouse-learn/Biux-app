# 🔒 Guía: Sistema Anti-Robo de Bicicletas

## 📱 Cómo acceder a la funcionalidad

### 1. Ver el Formulario de Verificación (Admin)

**Pasos:**
1. Inicia sesión como **administrador** (tu usuario actual ya lo es)
2. Ve a la **Tienda** desde el menú principal
3. Presiona el botón **"Crear Producto"** (botón flotante verde con ícono +)
4. Se abrirá un formulario deslizable
5. **Desliza hacia abajo** en el formulario después de:
   - Nombre del producto
   - Descripción corta
   - Descripción larga  
   - Precio y Stock
   - Ciudad
   - Categoría
6. **Verás la sección "Sistema Anti-Robo de Bicicletas"** con:
   - 🚴 Ícono de bicicleta
   - 🛡️ Ícono de escudo
   - Checkbox: "¿Este producto es una bicicleta completa?"

### 2. Probar la Verificación

**Cuando marcas el checkbox:**
1. Se mostrarán campos adicionales:
   - **Número de Serie / Chasis** (obligatorio) ⭐
   - Marca (opcional)
   - Modelo (opcional)
   - Color (opcional)
   - Año (opcional)

2. Verás un **banner naranja** que dice:
   > "Obligatorio verificar antes de publicar"

3. Aparece el botón azul:
   > **"Verificar contra Base de Robos"**

4. Si intentas guardar sin verificar:
   - ❌ Se bloqueará el guardado
   - ⚠️ Mensaje: "¡Debes verificar que la bicicleta NO esté reportada como robada!"

5. Al presionar "Verificar":
   - ⏳ Mostrará: "Verificando contra base de robos..."
   - ✅ Si NO está robada: Banner verde "Verificado: NO está robada"
   - ⛔ Si SÍ está robada: Dialog rojo de alerta + bloqueo de guardado

### 3. Ver Base de Datos Pública

**Ruta directa en el navegador:**
- En desarrollo web: `localhost:PORT/shop/stolen-bikes`
- En app: Navega desde la tienda (se puede agregar un botón en el menú)

**Características:**
- 🔍 Búsqueda por marca, modelo, serial, color
- 🏙️ Filtro por ciudad (Bogotá, Medellín, Cali, etc.)
- 🔄 Pull-to-refresh
- 📱 FloatingActionButton "Reportar Robo"
- 🎨 Cards rojas con borde de alerta

## 🎨 Diseño Visual

### Sección Anti-Robo (Formulario)
```
┌─────────────────────────────────────────┐
│ 🚴 Sistema Anti-Robo de Bicicletas  🛡️  │
├─────────────────────────────────────────┤
│ ☐ ¿Este producto es una bicicleta      │
│   completa?                             │
│   Si es bicicleta completa, debe       │
│   verificarse contra base de robos      │
└─────────────────────────────────────────┘

Cuando se marca el checkbox:
┌─────────────────────────────────────────┐
│ 🚴 Sistema Anti-Robo de Bicicletas  🛡️  │ (borde azul)
├─────────────────────────────────────────┤
│ ☑ ¿Este producto es una bicicleta      │
│   completa?                             │
├─────────────────────────────────────────┤
│ ⚠️ Obligatorio verificar antes de      │
│    publicar                             │
├─────────────────────────────────────────┤
│ Número de Serie / Chasis *             │
│ [AB123456789          ]                │
│                                         │
│ Marca                                   │
│ [Trek, Giant, Specialized...]          │
│                                         │
│ Modelo          │ Color                │
│ [X-Caliber]     │ [Rojo]              │
│                                         │
│ Año (opcional)                         │
│ [2024          ]                       │
│                                         │
│ ┌─────────────────────────────────┐   │
│ │ 🔍 Verificar contra Base        │   │
│ │    de Robos                     │   │
│ └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Estados del Botón de Verificación

**1. Sin verificar:**
```
┌─────────────────────────────────────┐
│ 🔍 Verificar contra Base de Robos  │ (azul)
└─────────────────────────────────────┘
```

**2. Verificando:**
```
┌─────────────────────────────────────┐
│ ⏳ Verificando contra base de      │ (azul)
│    robos...                         │
└─────────────────────────────────────┘
```

**3. Verificado OK:**
```
┌─────────────────────────────────────┐
│ ✓ Verificado: NO está robada       │ (verde)
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ ✅ Bicicleta verificada. Puede     │
│    publicarse en la tienda.         │
└─────────────────────────────────────┘
```

**4. Bicicleta Robada Detectada:**
```
┌─────────────────────────────────────┐
│ ✗ ROBADA - No se puede publicar    │ (rojo)
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ ⛔ Esta bicicleta está reportada   │
│    como robada y NO puede          │
│    publicarse.                      │
└─────────────────────────────────────┘
```

## 🧪 Datos de Prueba

Para probar la detección de bicicletas robadas, necesitarías:
1. Registrar una bicicleta en tu perfil
2. Reportarla como robada
3. Intentar venderla en la tienda
4. El sistema la detectará y bloqueará la venta

## 📊 Datos Guardados Automáticamente

Cuando una bicicleta pasa la verificación:
```json
{
  "isBicycle": true,
  "bikeFrameSerial": "AB123456789",
  "bikeBrand": "Trek",
  "bikeModel": "X-Caliber",
  "bikeColor": "Rojo",
  "bikeYear": 2024,
  "isVerifiedNotStolen": true,
  "stolenVerificationDate": "2026-02-13T15:30:00Z",
  "stolenVerificationBy": "phone_573132332038"
}
```

## 🚀 Próximos Pasos

### Mejoras Sugeridas:
1. **Botón en el menú** para acceder a la base de datos pública
2. **Notificaciones push** al dueño cuando se intenta vender su bici
3. **Dashboard de alertas** para administradores
4. **QR code** en cada bicicleta verificada
5. **Integración con policía** para reportes oficiales

## 📞 Soporte

Si tienes dudas o encuentras algún problema, revisa:
- `lib/features/shop/presentation/screens/admin_shop_screen.dart` (línea 1520)
- `lib/features/shop/domain/services/stolen_bike_verification_service.dart`
- `lib/features/shop/presentation/screens/stolen_bikes_screen.dart`

---

**Desarrollado por:** GitHub Copilot
**Fecha:** 13 de febrero de 2026
**Versión:** 1.0.0
