# 📋 Plan de Migración Completa - Clean Architecture Feature-First

## 📊 Estado Actual de la Migración

### ✅ Características COMPLETAMENTE Migradas
1. **authentication** - ✅ Migrado completamente
2. **cities** - ✅ Migrado completamente  
3. **groups** - ✅ Migrado completamente
4. **maps** - ✅ Migrado completamente
5. **rides** - ✅ Migrado completamente
6. **roads** - ✅ Migrado completamente
7. **stories** - ✅ Migrado completamente
8. **users** - ✅ Migrado completamente

### ❌ Características PENDIENTES de Migrar
Las siguientes características permanecen en la estructura centralizada antigua (`lib/data/`):

#### 🚴‍♂️ **bikes** (Bicicletas)
- **Modelos**: `bike.dart`, `stole_bikes.dart`, `trademark_bike.dart`, `type_bike.dart`
- **Repositorios**: `bikes/`, `stoles_bikes/`, `trademarks_bikes/`, `types_bikes/`
- **Importancia**: Media - Funcionalidad de gestión de bicicletas

#### 🚨 **accidents** (Accidentes)
- **Modelos**: `situation_accident.dart`
- **Repositorios**: `accidents/`
- **Importancia**: Alta - Funcionalidad de seguridad

#### 🏥 **eps** (Entidades Promotoras de Salud)
- **Modelos**: `eps.dart`
- **Repositorios**: `eps/`
- **Importancia**: Media - Funcionalidad de salud

#### 👥 **members** (Miembros)
- **Modelos**: `member.dart`, `membership.dart`, `user_membership.dart`
- **Repositorios**: `members/`
- **Importancia**: **CRÍTICA** - Esta característica es referenciada por múltiples features migradas

#### 💳 **payments** (Pagos)
- **Repositorios**: `payments/`
- **Importancia**: Alta - Funcionalidad de monetización

#### 📍 **sites** (Sitios/Lugares)
- **Modelos**: `sites.dart`, `types_sites.dart`
- **Repositorios**: `sites/`
- **Importancia**: Media - Funcionalidad de ubicaciones

#### 📢 **advertisements** (Publicidad)
- **Modelos**: `advertising.dart`
- **Repositorios**: `advertisements/`
- **Importancia**: Baja - Funcionalidad de marketing

### 🚨 Modelos de Soporte Pendientes
- **response.dart** - Modelo de respuesta genérico (Usado en múltiples features)
- **analitics.dart** / **analitycs.dart** - Modelos de analíticas
- **country.dart**, **state.dart** - Modelos geográficos
- **event.dart** - Modelo de eventos
- **bike_parking.dart** - Modelo de parqueaderos

## 🔧 Importaciones Problemáticas Identificadas

### 📂 Archivos con Importaciones Antiguas a Corregir:
```dart
// Archivos que importan desde lib/data/models/
lib/shared/widgets/list_group_widget.dart               // member.dart
lib/shared/widgets/main_menu_bloc.dart                  // user_membership.dart
lib/features/groups/presentation/screens/               // member.dart (3 archivos)
lib/features/groups/data/repositories/                  // member.dart (3 archivos)  
lib/features/users/presentation/screens/                // competitor_road.dart
lib/features/users/data/                                // varios modelos
lib/features/roads/                                     // competitor_road.dart, member.dart
```

## 🎯 Plan de Ejecución por Fases

### **FASE 1: Migración de Members (CRÍTICA)**
**Prioridad**: 🔴 URGENTE

**¿Por qué primero?**: La característica `members` es referenciada por múltiples features ya migradas.

#### Pasos:
1. **Crear estructura de feature**:
   ```
   lib/features/members/
   ├── data/
   │   ├── models/
   │   │   ├── member.dart
   │   │   ├── membership.dart
   │   │   └── user_membership.dart
   │   ├── datasources/
   │   │   └── members_remote_datasource.dart
   │   └── repositories/
   │       ├── members_repository.dart
   │       └── members_firebase_repository.dart
   ├── domain/
   │   ├── entities/
   │   │   ├── member_entity.dart
   │   │   ├── membership_entity.dart
   │   │   └── user_membership_entity.dart
   │   ├── repositories/
   │   │   └── members_repository.dart
   │   └── usecases/
   │       ├── get_member_usecase.dart
   │       └── manage_membership_usecase.dart
   └── presentation/
       └── providers/
           └── member_provider.dart
   ```

2. **Migrar archivos**:
   - `lib/data/models/member.dart` → `lib/features/members/data/models/member.dart`
   - `lib/data/models/membership.dart` → `lib/features/members/data/models/membership.dart`
   - `lib/data/models/user_membership.dart` → `lib/features/members/data/models/user_membership.dart`
   - `lib/data/repositories/members/*` → `lib/features/members/data/repositories/`

3. **Actualizar importaciones en todos los archivos que referencian members**

### **FASE 2: Migración de Accidents**
**Prioridad**: 🟠 ALTA

#### Pasos:
1. **Crear feature accidents**
2. **Migrar**: 
   - `lib/data/models/situation_accident.dart`
   - `lib/data/repositories/accidents/`
3. **Actualizar importaciones en users feature**

### **FASE 3: Migración de Bikes**
**Prioridad**: 🟡 MEDIA

#### Pasos:
1. **Crear feature bikes**
2. **Migrar modelos**: `bike.dart`, `stole_bikes.dart`, `trademark_bike.dart`, `type_bike.dart`, `bike_parking.dart`
3. **Migrar repositorios**: `bikes/`, `stoles_bikes/`, `trademarks_bikes/`, `types_bikes/`

### **FASE 4: Migración de Payments**
**Prioridad**: 🟠 ALTA

#### Pasos:
1. **Crear feature payments**
2. **Migrar repositorios**: `lib/data/repositories/payments/`

### **FASE 5: Migración de Sites**
**Prioridad**: 🟡 MEDIA

#### Pasos:
1. **Crear feature sites**
2. **Migrar**: `sites.dart`, `types_sites.dart`, `lib/data/repositories/sites/`

### **FASE 6: Migración de EPS**
**Prioridad**: 🟡 MEDIA

#### Pasos:
1. **Crear feature eps**
2. **Migrar**: `eps.dart`, `lib/data/repositories/eps/`

### **FASE 7: Migración de Advertisements**
**Prioridad**: 🟢 BAJA

#### Pasos:
1. **Crear feature advertisements**
2. **Migrar**: `advertising.dart`, `lib/data/repositories/advertisements/`

### **FASE 8: Migración de Modelos de Soporte**
**Prioridad**: 🟡 MEDIA

#### Pasos:
1. **Crear feature shared o core para modelos comunes**:
   - `response.dart` → `lib/core/models/response.dart`
   - `analitics.dart` / `analitycs.dart` → `lib/core/models/analytics.dart`
   - `country.dart`, `state.dart` → `lib/core/models/geography/`
   - `event.dart` → `lib/core/models/event.dart`

## 🛠️ Scripts y Herramientas Necesarias

### **Script 1: Migración Automática de Members**
```powershell
# migrate_members_feature.ps1
```

### **Script 2: Actualización Masiva de Importaciones**
```powershell
# update_imports_after_migration.ps1  
```

### **Script 3: Limpieza de Estructura Antigua**
```powershell
# cleanup_old_structure.ps1
```

## 📋 Lista de Verificación por Fase

### ✅ Checklist Fase 1 (Members):
- [ ] Crear estructura `lib/features/members/`
- [ ] Migrar modelos (member, membership, user_membership)
- [ ] Migrar repositorios 
- [ ] Crear entities en domain layer
- [ ] Crear use cases
- [ ] Actualizar 25+ archivos que importan members
- [ ] Ejecutar `flutter analyze` sin errores
- [ ] Ejecutar tests relacionados con members
- [ ] Validar compilación exitosa

### ✅ Checklist Completo:
- [ ] **Fase 1**: Members ✅
- [ ] **Fase 2**: Accidents ✅  
- [ ] **Fase 3**: Bikes ✅
- [ ] **Fase 4**: Payments ✅
- [ ] **Fase 5**: Sites ✅
- [ ] **Fase 6**: EPS ✅
- [ ] **Fase 7**: Advertisements ✅
- [ ] **Fase 8**: Modelos de Soporte ✅
- [ ] **Limpieza**: Eliminar `lib/data/` antigua
- [ ] **Validación**: `flutter analyze` completamente limpio
- [ ] **Testing**: Todos los tests pasando
- [ ] **Build**: Compilación exitosa de la app

## 🎯 Métricas de Éxito

### Antes de la Migración Completa:
- ❌ ~25 archivos con importaciones incorrectas
- ❌ Estructura híbrida (layer-first + feature-first)
- ❌ `lib/data/` con ~60 archivos repositorio y ~20 modelos

### Después de la Migración Completa:
- ✅ 0 archivos con importaciones incorrectas
- ✅ 100% estructura feature-first
- ✅ `lib/data/` eliminado completamente
- ✅ 15+ features organizadas limpiamente
- ✅ `flutter analyze` sin errores

## 🚀 Comandos de Ejecución

### Opción 1: Migración Automática Completa (RECOMENDADO)
```powershell
# Ejecutar todo automáticamente con un solo comando:
.\migrate_all_phases.ps1
```

### Opción 2: Migración Manual Paso a Paso
```powershell
# Ejecutar migración paso a paso:
.\migrate_phase1_members.ps1           # CRÍTICA - Members 
.\migrate_phase2_accidents.ps1         # ALTA - Accidents
.\migrate_phase3-7_remaining.ps1       # MEDIA - Bikes, Payments, Sites, EPS, Ads
.\migrate_phase8_support_models.ps1    # MEDIA - Modelos comunes
.\cleanup_old_structure_fixed.ps1      # LIMPIEZA - Eliminar lib/data/

# Validación final:
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

### Scripts Disponibles:
- `migrate_all_phases.ps1` - **Script maestro** que ejecuta toda la migración
- `migrate_phase1_members.ps1` - Migra feature Members (crítica)  
- `migrate_phase2_accidents.ps1` - Migra feature Accidents
- `migrate_phase3-7_remaining.ps1` - Migra features restantes (Bikes, Payments, Sites, EPS, Ads)
- `migrate_phase8_support_models.ps1` - Migra modelos de soporte a lib/core/
- `cleanup_old_structure_fixed.ps1` - Elimina lib/data/ antigua
- `fix_imports_regex.ps1` - Script de corrección de importaciones (si se necesita)

---

**📅 Fecha de creación**: 4 de octubre de 2025  
**👨‍💻 Estado**: Plan completo - Listo para ejecución  
**⏱️ Tiempo estimado**: 4-6 horas para migración completa  
**🎯 Objetivo**: Completar migración a Clean Architecture Feature-First 100%