# 🚀 Script para Migrar Accidents Feature (FASE 2)
Write-Host "🔄 Iniciando migración de Accidents Feature..." -ForegroundColor Cyan
Write-Host "📋 FASE 2: Funcionalidad de seguridad - Accidents" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "lib")) {
    Write-Host "❌ Error: No se encuentra el directorio lib. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Crear estructura de directorios para accidents feature
Write-Host ""
Write-Host "📁 Creando estructura de directorios..." -ForegroundColor Green

$accidentsDirectories = @(
    "lib\features\accidents",
    "lib\features\accidents\data",
    "lib\features\accidents\data\models",
    "lib\features\accidents\data\datasources", 
    "lib\features\accidents\data\repositories",
    "lib\features\accidents\domain",
    "lib\features\accidents\domain\entities",
    "lib\features\accidents\domain\repositories",
    "lib\features\accidents\domain\usecases",
    "lib\features\accidents\presentation",
    "lib\features\accidents\presentation\providers"
)

foreach ($dir in $accidentsDirectories) {
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
    @{Old = "lib\data\models\situation_accident.dart"; New = "lib\features\accidents\data\models\situation_accident.dart"}
)

foreach ($model in $modelsToMigrate) {
    if (Test-Path $model.Old) {
        # Leer contenido del archivo original
        $content = Get-Content $model.Old -Raw -Encoding UTF8
        
        # Actualizar imports internos si los hay
        $content = $content -replace "import 'package:biux/data/models/", "import 'package:biux/features/accidents/data/models/"
        
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

if (Test-Path "lib\data\repositories\accidents") {
    # Copiar todos los archivos del directorio accidents
    $accidentRepoFiles = Get-ChildItem "lib\data\repositories\accidents" -Filter "*.dart"
    
    foreach ($file in $accidentRepoFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Actualizar imports para usar la nueva estructura
        $content = $content -replace "import 'package:biux/data/models/situation_accident\.dart';", "import 'package:biux/features/accidents/data/models/situation_accident.dart';"
        
        # Actualizar imports relativos si los hay
        $content = $content -replace "import '../../models/", "import '../models/"
        $content = $content -replace "import '../models/situation_accident\.dart';", "import '../models/situation_accident.dart';"
        
        $newPath = "lib\features\accidents\data\repositories\$($file.Name)"
        Set-Content -Path $newPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✅ Migrado: $($file.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  No encontrado directorio: lib\data\repositories\accidents" -ForegroundColor Yellow
}

# Crear entities básicas en domain layer
Write-Host ""
Write-Host "🏗️ Creando entities en domain layer..." -ForegroundColor Green

# Accident Entity
$accidentEntity = @"
class AccidentEntity {
  final String id;
  final String userId;
  final String location;
  final DateTime accidentDate;
  final String severity;
  final String description;
  final List<String> involvedParties;
  final bool isReported;
  
  const AccidentEntity({
    required this.id,
    required this.userId,
    required this.location,
    required this.accidentDate,
    required this.severity,
    required this.description,
    required this.involvedParties,
    required this.isReported,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccidentEntity &&
        other.id == id &&
        other.userId == userId &&
        other.location == location &&
        other.accidentDate == accidentDate &&
        other.severity == severity &&
        other.description == description &&
        other.isReported == isReported;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        location.hashCode ^
        accidentDate.hashCode ^
        severity.hashCode ^
        description.hashCode ^
        isReported.hashCode;
  }
}
"@

Set-Content -Path "lib\features\accidents\domain\entities\accident_entity.dart" -Value $accidentEntity -Encoding UTF8

# Repository interface
$accidentRepository = @"
import '../entities/accident_entity.dart';

abstract class AccidentsRepository {
  Future<List<AccidentEntity>> getUserAccidents(String userId);
  Future<AccidentEntity?> getAccident(String accidentId);
  Future<List<AccidentEntity>> getAccidentsByLocation(String location);
  Future<void> reportAccident(AccidentEntity accident);
  Future<void> updateAccident(AccidentEntity accident);
  Future<void> deleteAccident(String accidentId);
}
"@

Set-Content -Path "lib\features\accidents\domain\repositories\accidents_repository.dart" -Value $accidentRepository -Encoding UTF8

# Use cases
$reportAccidentUseCase = @"
import '../entities/accident_entity.dart';
import '../repositories/accidents_repository.dart';

class ReportAccidentUseCase {
  final AccidentsRepository repository;
  
  ReportAccidentUseCase(this.repository);
  
  Future<void> call(AccidentEntity accident) async {
    await repository.reportAccident(accident);
  }
}
"@

Set-Content -Path "lib\features\accidents\domain\usecases\report_accident_usecase.dart" -Value $reportAccidentUseCase -Encoding UTF8

$getUserAccidentsUseCase = @"
import '../entities/accident_entity.dart';
import '../repositories/accidents_repository.dart';

class GetUserAccidentsUseCase {
  final AccidentsRepository repository;
  
  GetUserAccidentsUseCase(this.repository);
  
  Future<List<AccidentEntity>> call(String userId) async {
    return await repository.getUserAccidents(userId);
  }
}
"@

Set-Content -Path "lib\features\accidents\domain\usecases\get_user_accidents_usecase.dart" -Value $getUserAccidentsUseCase -Encoding UTF8

Write-Host "  ✅ Creadas entities y use cases básicas" -ForegroundColor Green

# Actualizar todas las importaciones de accidents en el proyecto
Write-Host ""
Write-Host "🔄 Actualizando importaciones en todo el proyecto..." -ForegroundColor Green

# Buscar todos los archivos .dart que importan accidents
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\" -and
    $_.FullName -notmatch "lib\\features\\accidents\\"
}

$updatedFiles = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Actualizar imports de situation_accident
    $content = $content -replace "import 'package:biux/data/models/situation_accident\.dart';", "import 'package:biux/features/accidents/data/models/situation_accident.dart';"
    
    # Actualizar imports de repositorios de accidents
    $content = $content -replace "import 'package:biux/data/repositories/accidents/([^']+)';", "import 'package:biux/features/accidents/data/repositories/`$1';"
    
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "  ✅ Actualizado: $relativePath" -ForegroundColor Green
        $updatedFiles++
    }
}

Write-Host ""
Write-Host "📊 RESUMEN DE MIGRACIÓN:" -ForegroundColor Magenta
Write-Host "  • Modelos migrados: 1 (situation_accident)" -ForegroundColor White
Write-Host "  • Repositorios migrados: $(if (Test-Path "lib\data\repositories\accidents") { (Get-ChildItem "lib\data\repositories\accidents" -Filter "*.dart").Count } else { 0 })" -ForegroundColor White  
Write-Host "  • Archivos actualizados: $updatedFiles" -ForegroundColor Green
Write-Host "  • Entities creadas: 1" -ForegroundColor White
Write-Host "  • Use cases creados: 2" -ForegroundColor White

Write-Host ""
Write-Host "🎉 ¡Migración de Accidents Feature completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "  1. Ejecutar: flutter analyze" -ForegroundColor Yellow
Write-Host "  2. Verificar que no hay errores de compilación" -ForegroundColor Yellow
Write-Host "  3. Continuar con FASE 3: .\migrate_phase3_bikes.ps1" -ForegroundColor Yellow

Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "  • NO eliminar lib\data\ todavía" -ForegroundColor Yellow
Write-Host "  • Continuar con las siguientes fases" -ForegroundColor Yellow