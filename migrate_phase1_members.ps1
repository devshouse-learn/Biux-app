# 🚀 Script para Migrar Members Feature (FASE 1)
Write-Host "🔄 Iniciando migración de Members Feature..." -ForegroundColor Cyan
Write-Host "📋 FASE 1: Característica más crítica - Members" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "lib")) {
    Write-Host "❌ Error: No se encuentra el directorio lib. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Crear estructura de directorios para members feature
Write-Host ""
Write-Host "📁 Creando estructura de directorios..." -ForegroundColor Green

$membersDirectories = @(
    "lib\features\members",
    "lib\features\members\data",
    "lib\features\members\data\models",
    "lib\features\members\data\datasources", 
    "lib\features\members\data\repositories",
    "lib\features\members\domain",
    "lib\features\members\domain\entities",
    "lib\features\members\domain\repositories",
    "lib\features\members\domain\usecases",
    "lib\features\members\presentation",
    "lib\features\members\presentation\providers"
)

foreach ($dir in $membersDirectories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ✅ Creado: $dir" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Ya existe: $dir" -ForegroundColor Yellow
    }
}

# Migrar modelos
Write-Host ""
Write-Host "📦 Migrando modelos..." -ForegroundColor Green

$modelsToMigrate = @(
    @{Old = "lib\data\models\member.dart"; New = "lib\features\members\data\models\member.dart"},
    @{Old = "lib\data\models\membership.dart"; New = "lib\features\members\data\models\membership.dart"},
    @{Old = "lib\data\models\user_membership.dart"; New = "lib\features\members\data\models\user_membership.dart"}
)

foreach ($model in $modelsToMigrate) {
    if (Test-Path $model.Old) {
        # Leer contenido del archivo original
        $content = Get-Content $model.Old -Raw -Encoding UTF8
        
        # Actualizar imports internos si los hay
        $content = $content -replace "import 'package:biux/data/models/", "import 'package:biux/features/members/data/models/"
        
        # Escribir en la nueva ubicación
        Set-Content -Path $model.New -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✅ Migrado: $(Split-Path $model.Old -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  No encontrado: $($model.Old)" -ForegroundColor Yellow
    }
}

# Migrar repositorios
Write-Host ""
Write-Host "🗃️ Migrando repositorios..." -ForegroundColor Green

if (Test-Path "lib\data\repositories\members") {
    # Copiar todos los archivos del directorio members
    $memberRepoFiles = Get-ChildItem "lib\data\repositories\members" -Filter "*.dart"
    
    foreach ($file in $memberRepoFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Actualizar imports para usar la nueva estructura
        $content = $content -replace "import 'package:biux/data/models/member\.dart';", "import 'package:biux/features/members/data/models/member.dart';"
        $content = $content -replace "import 'package:biux/data/models/membership\.dart';", "import 'package:biux/features/members/data/models/membership.dart';"
        $content = $content -replace "import 'package:biux/data/models/user_membership\.dart';", "import 'package:biux/features/members/data/models/user_membership.dart';"
        
        # Actualizar imports relativos si los hay
        $content = $content -replace "import '../../models/", "import '../models/"
        $content = $content -replace "import '../models/member\.dart';", "import '../models/member.dart';"
        $content = $content -replace "import '../models/membership\.dart';", "import '../models/membership.dart';"
        $content = $content -replace "import '../models/user_membership\.dart';", "import '../models/user_membership.dart';"
        
        $newPath = "lib\features\members\data\repositories\$($file.Name)"
        Set-Content -Path $newPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✅ Migrado: $($file.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  No encontrado directorio: lib\data\repositories\members" -ForegroundColor Yellow
}

# Crear entities básicas en domain layer
Write-Host ""
Write-Host "🏗️ Creando entities en domain layer..." -ForegroundColor Green

# Member Entity
$memberEntity = @"
class MemberEntity {
  final String id;
  final String userId;
  final String groupId;
  final String role;
  final DateTime joinedAt;
  final bool isActive;
  
  const MemberEntity({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemberEntity &&
        other.id == id &&
        other.userId == userId &&
        other.groupId == groupId &&
        other.role == role &&
        other.joinedAt == joinedAt &&
        other.isActive == isActive;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        groupId.hashCode ^
        role.hashCode ^
        joinedAt.hashCode ^
        isActive.hashCode;
  }
}
"@

Set-Content -Path "lib\features\members\domain\entities\member_entity.dart" -Value $memberEntity -Encoding UTF8

# Repository interface
$memberRepository = @"
import '../entities/member_entity.dart';

abstract class MembersRepository {
  Future<List<MemberEntity>> getGroupMembers(String groupId);
  Future<MemberEntity?> getMember(String memberId);
  Future<List<MemberEntity>> getUserMemberships(String userId);
  Future<void> addMember(MemberEntity member);
  Future<void> updateMember(MemberEntity member);
  Future<void> removeMember(String memberId);
}
"@

Set-Content -Path "lib\features\members\domain\repositories\members_repository.dart" -Value $memberRepository -Encoding UTF8

# Use cases
$getMembersUseCase = @"
import '../entities/member_entity.dart';
import '../repositories/members_repository.dart';

class GetGroupMembersUseCase {
  final MembersRepository repository;
  
  GetGroupMembersUseCase(this.repository);
  
  Future<List<MemberEntity>> call(String groupId) async {
    return await repository.getGroupMembers(groupId);
  }
}
"@

Set-Content -Path "lib\features\members\domain\usecases\get_group_members_usecase.dart" -Value $getMembersUseCase -Encoding UTF8

Write-Host "  ✅ Creadas entities y use cases básicas" -ForegroundColor Green

# Actualizar todas las importaciones de members en el proyecto
Write-Host ""
Write-Host "🔄 Actualizando importaciones en todo el proyecto..." -ForegroundColor Green

# Buscar todos los archivos .dart que importan members
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\" -and
    $_.FullName -notmatch "lib\\features\\members\\"
}

$updatedFiles = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Actualizar imports de member
    $content = $content -replace "import 'package:biux/data/models/member\.dart';", "import 'package:biux/features/members/data/models/member.dart';"
    $content = $content -replace "import 'package:biux/data/models/membership\.dart';", "import 'package:biux/features/members/data/models/membership.dart';"
    $content = $content -replace "import 'package:biux/data/models/user_membership\.dart';", "import 'package:biux/features/members/data/models/user_membership.dart';"
    
    # Actualizar imports de repositorios
    $content = $content -replace "import 'package:biux/data/repositories/members/([^']+)';", "import 'package:biux/features/members/data/repositories/`$1';"
    
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "  ✅ Actualizado: $relativePath" -ForegroundColor Green
        $updatedFiles++
    }
}

Write-Host ""
Write-Host "📊 RESUMEN DE MIGRACIÓN:" -ForegroundColor Magenta
Write-Host "  • Modelos migrados: 3 (member, membership, user_membership)" -ForegroundColor White
Write-Host "  • Repositorios migrados: $(if (Test-Path "lib\data\repositories\members") { (Get-ChildItem "lib\data\repositories\members" -Filter "*.dart").Count } else { 0 })" -ForegroundColor White  
Write-Host "  • Archivos actualizados: $updatedFiles" -ForegroundColor Green
Write-Host "  • Entities creadas: 1" -ForegroundColor White
Write-Host "  • Use cases creados: 1" -ForegroundColor White

Write-Host ""
Write-Host "🎉 ¡Migración de Members Feature completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "  1. Ejecutar: flutter analyze" -ForegroundColor Yellow
Write-Host "  2. Verificar que no hay errores de compilación" -ForegroundColor Yellow
Write-Host "  3. Ejecutar: flutter test (si hay tests de members)" -ForegroundColor Yellow
Write-Host "  4. Continuar con FASE 2: .\migrate_phase2_accidents.ps1" -ForegroundColor Yellow

Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "  • NO eliminar lib\data\models\ ni lib\data\repositories\ todavía" -ForegroundColor Yellow
Write-Host "  • Esperai a completar todas las fases antes de limpiar" -ForegroundColor Yellow