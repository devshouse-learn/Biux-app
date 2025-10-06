# 🎨 Sistema de Diseño Biux - Inventario Completo
## Basado en Atomic Design

---

## 📐 Fundamentos (Tokens)

### 🎨 Colores (color_tokens.dart)

#### Primary (Azul Oscuro - blackPearl)
- `primary10` - `#0A1014` - Más oscuro
- `primary20` - `#0F1A1F` - AppBar dark mode
- `primary30` - `#16242D` - **Principal (blackPearl)** - AppBar light
- `primary40` - `#1E303B`
- `primary50` - `#2B4251`
- `primary60` - `#3A5567`
- `primary70` - `#4B6A7E`
- `primary80` - `#5E8195` - Primary dark mode
- `primary90` - `#7399AD`
- `primary95` - `#8AB2C6`
- `primary99` - `#F0F6F8` - Backgrounds muy claros

**Uso**: AppBar, botones primarios, navegación principal

---

#### Secondary (Cyan - strongCyan)
- `secondary10` - `#0D1919`
- `secondary20` - `#1A3333`
- `secondary30` - `#2B4D4D`
- `secondary40` - `#3D6767`
- `secondary50` - `#519192` - **Principal (strongCyan)**
- `secondary60` - `#67A4A5`
- `secondary70` - `#80B7B8`
- `secondary80` - `#9BCACB`
- `secondary90` - `#B7DDDE` - Secondary dark mode
- `secondary95` - `#D5F0F1`
- `secondary99` - `#F5FBFB`

**Uso**: Accents, highlights, indicadores de tab activo

---

#### Success (Verde)
- `success10` - `#0D2212`
- `success20` - `#1B4425`
- `success30` - `#2E6B3A`
- `success40` - `#4CAF50` - **softGreen** - Principal
- `success50` - `#66BB6A` - **mutedGreen** - Badges
- `success60` - `#81C784`
- `success70` - `#9CCC9E`
- `success80` - `#B8D4B9`
- `success90` - `#D4E5D5`
- `success95` - `#E8F5E9` - Backgrounds
- `success99` - `#F7FDF7`

**Uso**: 
- Confirmaciones ("Voy a ir")
- Badges de admin
- Dificultad "Fácil"
- Mensajes de éxito

---

#### Warning (Naranja)
- `warning10` - `#331400`
- `warning20` - `#662900`
- `warning30` - `#994200`
- `warning40` - `#CC5C00`
- `warning50` - `#FF9800` - **softOrange** - Principal
- `warning60` - `#FFAD33`
- `warning70` - `#FFC266`
- `warning80` - `#FFD699`
- `warning90` - `#FFEBCC`
- `warning95` - `#FFF5E6` - Backgrounds
- `warning99` - `#FFFCF5`

**Uso**:
- Estado "Tal vez"
- Dificultad "Media"
- Alertas
- Solicitudes pendientes

---

#### Error (Rojo)
- `error10` - `#2D1616`
- `error20` - `#5A2C2C`
- `error30` - `#874343`
- `error40` - `#B45A5A`
- `error50` - `#E57373` - **mutedRed** - Principal
- `error60` - `#EA8F8F`
- `error70` - `#EFABAB`
- `error80` - `#F4C7C7`
- `error90` - `#F9E3E3`
- `error95` - `#FCF1F1` - Backgrounds
- `error99` - `#FEFAFA`

**Uso**:
- Errores
- Cancelaciones
- Dificultad "Difícil"
- Botón "Salir del grupo"

---

#### Info (Cyan Claro)
- `info40` - `#80CBC4` - **lightCyan** - Principal
- `info90` - `#E0F2F1` - Backgrounds

**Uso**:
- Badges de nivel de ruta
- Estado "Ya eres miembro"
- Información neutral

---

#### Neutral (Grises)
- `neutral0` - `#000000` - Negro puro
- `neutral10` - `#1A1A1A` - Texto principal light
- `neutral20` - `#2E2E2E` - Surfaces dark mode
- `neutral30` - `#424242` - Texto secundario light
- `neutral40` - `#575757`
- `neutral50` - `#6C6C6C` - Texto terciario
- `neutral60` - `#828282`
- `neutral70` - `#999999` - Iconos deshabilitados
- `neutral80` - `#B0B0B0`
- `neutral90` - `#C8C8C8` - Texto dark mode
- `neutral95` - `#E0E0E0` - Bordes
- `neutral99` - `#F5F5F5` - Backgrounds light
- `neutral100` - `#FFFFFF` - Blanco puro

**Uso**: Textos, bordes, backgrounds, estados deshabilitados

---

## 🧩 Átomos (Componentes Básicos)

### 1. BiuxButton (`biux_button.dart`)
**Estado**: ✅ Implementado

#### Tipos (BiuxButtonType)
- `primary` - Color primario (blackPearl)
- `secondary` - Color secundario (strongCyan)
- `danger` - Color error (mutedRed)
- `success` - Color success (softGreen)

#### Tamaños (BiuxButtonSize)
- `small` - 32px altura (8px padding vertical)
- `medium` - 44px altura (12px padding vertical) **[Por defecto]**
- `large` - 56px altura (16px padding vertical)

#### Props
- `text`: String (requerido)
- `onPressed`: VoidCallback?
- `type`: BiuxButtonType (default: primary)
- `size`: BiuxButtonSize (default: medium)
- `isLoading`: bool (default: false)
- `isFullWidth`: bool (default: false)
- `leadingIcon`: IconData?
- `trailingIcon`: IconData?

#### Ejemplos de Uso
```dart
// Botón primario con ancho completo
BiuxButton(
  text: 'Confirmar Asistencia',
  onPressed: () {},
  type: BiuxButtonType.success,
  isFullWidth: true,
  leadingIcon: Icons.check,
)

// Botón pequeño de cancelar
BiuxButton(
  text: 'Cancelar',
  onPressed: () {},
  type: BiuxButtonType.danger,
  size: BiuxButtonSize.small,
)
```

**Reemplaza**: Todos los `ElevatedButton`, `TextButton` con estilos personalizados

---

### 2. BiuxCard (`biux_card.dart`)
**Estado**: ✅ Implementado

#### Props
- `child`: Widget (requerido)
- `padding`: EdgeInsetsGeometry? (default: 16px all)
- `margin`: EdgeInsetsGeometry?
- `onTap`: VoidCallback? (hace clickable)
- `backgroundColor`: Color? (auto por tema)
- `elevation`: double? (auto: 1 light, 2 dark)
- `borderRadius`: BorderRadius? (default: 12px)
- `showBorder`: bool (default: false)

#### Ejemplos de Uso
```dart
// Card clickable simple
BiuxCard(
  onTap: () => context.go('/groups/${group.id}'),
  child: Column(
    children: [
      Text('Rodada Dominical'),
      Text('10:00 AM'),
    ],
  ),
)

// Card con borde
BiuxCard(
  showBorder: true,
  margin: EdgeInsets.only(bottom: 16),
  child: GroupInfo(group),
)
```

**Reemplaza**: Todos los `Card` wrapeados en `InkWell` o `GestureDetector`

---

### 3. BiuxTextField (`biux_text_field.dart`)
**Estado**: ✅ Implementado

#### Props
- `label`: String?
- `hint`: String?
- `errorText`: String?
- `controller`: TextEditingController?
- `onChanged`: ValueChanged<String>?
- `onEditingComplete`: VoidCallback?
- `keyboardType`: TextInputType?
- `inputFormatters`: List<TextInputFormatter>?
- `obscureText`: bool (default: false)
- `prefixIcon`: Widget?
- `suffixIcon`: Widget?
- `maxLines`: int? (default: 1)
- `minLines`: int?
- `enabled`: bool (default: true)
- `focusNode`: FocusNode?
- `textCapitalization`: TextCapitalization
- `validator`: String? Function(String?)?

#### Ejemplos de Uso
```dart
// Input con label e ícono
BiuxTextField(
  label: 'Nombre del Grupo',
  hint: 'Ingresa el nombre',
  prefixIcon: Icon(Icons.group),
  controller: _nameController,
)

// Password field
BiuxTextField(
  label: 'Contraseña',
  obscureText: true,
  prefixIcon: Icon(Icons.lock),
)
```

**Reemplaza**: Todos los `TextFormField` y `TextField` con decoración personalizada

---

### 4. BiuxChip (PENDIENTE)
**Estado**: 🔴 Por Crear

#### Tipos
- `status` - Para estados (Confirmado, Pendiente, etc)
- `difficulty` - Para niveles de dificultad
- `role` - Para roles (Admin, Miembro)
- `info` - Información neutral

#### Props Sugeridas
```dart
BiuxChip({
  required String label,
  ChipType type = ChipType.info,
  ChipSize size = ChipSize.medium,
  IconData? icon,
  VoidCallback? onTap,
  bool showCloseButton = false,
})
```

**Reemplaza**: Todos los `Chip`, `Container` con badges

---

### 5. BiuxAvatar (PENDIENTE)
**Estado**: 🔴 Por Crear

#### Tamaños
- `small` - 32px
- `medium` - 48px
- `large` - 80px
- `xlarge` - 120px

#### Props Sugeridas
```dart
BiuxAvatar({
  String? imageUrl,
  String? initials,
  IconData? fallbackIcon = Icons.person,
  AvatarSize size = AvatarSize.medium,
  bool showBorder = false,
})
```

**Reemplaza**: Todos los `CircleAvatar`

---

### 6. BiuxBadge (PENDIENTE)
**Estado**: 🔴 Por Crear

#### Props Sugeridas
```dart
BiuxBadge({
  required String text,
  Color? backgroundColor,
  Color? textColor,
  bool isCircle = false,
})
```

**Reemplaza**: Badges de notificaciones, contadores

---

## 🔧 Moléculas (Componentes Compuestos)

### 1. BiuxListTile (PENDIENTE)
**Estado**: 🔴 Por Crear

Combina: Avatar + Textos + Trailing widget

**Reemplaza**: `ListTile` con estilos personalizados

---

### 2. BiuxStatusCard (PENDIENTE)
**Estado**: 🔴 Por Crear

Card con estado visual (success/warning/error)

**Uso**: Mostrar "Ya eres miembro", "Eres administrador"

---

### 3. BiuxRideCard (PENDIENTE)
**Estado**: 🔴 Por Crear

Card especializada para rodadas

**Incluye**: Avatar, nombre, fecha, distancia, dificultad, botones

---

### 4. BiuxGroupCard (PENDIENTE)
**Estado**: 🔴 Por Crear

Card especializada para grupos

**Incluye**: Logo, nombre, descripción, miembros, badge admin

---

### 5. BiuxEmptyState (PENDIENTE)
**Estado**: 🔴 Por Crear

Estado vacío con ícono, mensaje y acción

**Uso**: Listas vacías, sin resultados

---

### 6. BiuxLoadingOverlay (PENDIENTE)
**Estado**: 🔴 Por Crear

Overlay con spinner y mensaje opcional

**Reemplaza**: `loading_overlay` package

---

## 🏗️ Organismos (Secciones Completas)

### 1. BiuxAppBar (PENDIENTE)
**Estado**: 🔴 Por Crear

AppBar consistente con acciones predefinidas

---

### 2. BiuxBottomNav (PENDIENTE)
**Estado**: 🔴 Por Crear

Navegación inferior con `CurvedNavigationBar` integrada

---

### 3. BiuxDrawer (PENDIENTE)
**Estado**: 🔴 Por Crear

Drawer con header de usuario y opciones

---

## 📋 Templates (Layouts)

### 1. BiuxScaffold (PENDIENTE)
**Estado**: 🔴 Por Crear

Scaffold con AppBar y navegación pre-configurada

---

## 🎭 Temas (app_theme.dart)

### Light Theme
- Surface: `neutral100` (#FFFFFF)
- onSurface: `neutral10` (#1A1A1A)
- Primary: `primary30` (#16242D)
- AppBar: `primary30`

### Dark Theme
- Surface: `neutral30` (#424242)
- onSurface: `neutral90` (#C8C8C8)
- Primary: `primary80` (#5E8195)
- AppBar: `primary20` (#0F1A1F)

---

## 📝 Reglas de Uso

### ✅ SIEMPRE Usar
1. **Consultar este inventario primero**
2. **ColorTokens** en lugar de valores hardcoded
3. **BiuxButton** en lugar de ElevatedButton/TextButton
4. **BiuxCard** en lugar de Card + InkWell
5. **BiuxTextField** en lugar de TextFormField
6. **Theme.of(context).colorScheme** para colores dinámicos
7. **Theme.of(context).textTheme** para tipografía

### ❌ NUNCA Usar
1. Colores hardcoded: `Color(0xFF...)` directo
2. `AppColors` antiguos (migrando a `ColorTokens`)
3. Estilos inline sin usar tema
4. Widgets nativos sin wrapper cuando existe componente Biux

### 🔄 En Proceso de Migración
- `AppColors.blackPearl` → `ColorTokens.primary30`
- `AppColors.strongCyan` → `ColorTokens.secondary50`
- `AppColors.softGreen` → `ColorTokens.success40`
- `AppColors.mutedGreen` → `ColorTokens.success50`
- `AppColors.softOrange` → `ColorTokens.warning50`
- `AppColors.mutedRed` → `ColorTokens.error50`
- `AppColors.lightCyan` → `ColorTokens.info40`

---

## 📊 Próximos Componentes Prioritarios

1. **BiuxChip** - Alto uso en badges
2. **BiuxAvatar** - Alto uso en perfiles
3. **BiuxEmptyState** - Mejora UX
4. **BiuxStatusCard** - Info contextual
5. **BiuxLoadingOverlay** - Feedback visual

---

## 🎯 Estado del Proyecto

### ✅ Completado
- Sistema de colores completo
- Temas light/dark
- BiuxButton
- BiuxCard
- BiuxTextField
- ThemeNotifier

### 🟡 En Progreso
- Migración de colores en toda la app
- Reemplazo de widgets nativos

### 🔴 Pendiente
- 6 Átomos adicionales
- 6 Moléculas
- 3 Organismos
- 1 Template
- Documentación de cada componente
- Storybook/Galería de componentes

---

**Última actualización**: 5 de octubre de 2025
**Mantenedor**: Sistema de Diseño Biux
