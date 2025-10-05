# 🚀 Script para Migrar Features Restantes (FASES 3-7)
Write-Host "🔄 Iniciando migración de features restantes..." -ForegroundColor Cyan
Write-Host "📋 FASES 3-7: Bikes, Payments, Sites, EPS, Advertisements" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "lib")) {
    Write-Host "❌ Error: No se encuentra el directorio lib. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Definir features a migrar
$featuresToMigrate = @(
    @{
        Name = "bikes"
        Models = @("bike.dart", "stole_bikes.dart", "trademark_bike.dart", "type_bike.dart", "bike_parking.dart")
        Repositories = @("bikes", "stoles_bikes", "trademarks_bikes", "types_bikes")
        Priority = "Media"
    },
    @{
        Name = "payments"
        Models = @()
        Repositories = @("payments")
        Priority = "Alta"
    },
    @{
        Name = "sites"
        Models = @("sites.dart", "types_sites.dart")
        Repositories = @("sites")
        Priority = "Media"
    },
    @{
        Name = "eps"
        Models = @("eps.dart")
        Repositories = @("eps")
        Priority = "Media"
    },
    @{
        Name = "advertisements"
        Models = @("advertising.dart")
        Repositories = @("advertisements")
        Priority = "Baja"
    }
)

$totalFeatures = $featuresToMigrate.Count
$currentFeature = 0

foreach ($feature in $featuresToMigrate) {
    $currentFeature++
    Write-Host ""
    Write-Host "🚀 [$currentFeature/$totalFeatures] Migrando feature: $($feature.Name.ToUpper())" -ForegroundColor Green
    Write-Host "📊 Prioridad: $($feature.Priority)" -ForegroundColor Yellow
    
    # Crear estructura de directorios
    $featureDirectories = @(
        "lib\features\$($feature.Name)",
        "lib\features\$($feature.Name)\data",
        "lib\features\$($feature.Name)\data\models",
        "lib\features\$($feature.Name)\data\datasources", 
        "lib\features\$($feature.Name)\data\repositories",
        "lib\features\$($feature.Name)\domain",
        "lib\features\$($feature.Name)\domain\entities",
        "lib\features\$($feature.Name)\domain\repositories",
        "lib\features\$($feature.Name)\domain\usecases",
        "lib\features\$($feature.Name)\presentation",
        "lib\features\$($feature.Name)\presentation\providers"
    )

    foreach ($dir in $featureDirectories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    Write-Host "  ✅ Estructura de directorios creada" -ForegroundColor Green

    # Migrar modelos
    $migratedModels = 0
    if ($feature.Models.Count -gt 0) {
        Write-Host "  📦 Migrando modelos..." -ForegroundColor Cyan
        
        foreach ($model in $feature.Models) {
            $oldPath = "lib\data\models\$model"
            $newPath = "lib\features\$($feature.Name)\data\models\$model"
            
            if (Test-Path $oldPath) {
                $content = Get-Content $oldPath -Raw -Encoding UTF8
                
                # Actualizar imports internos
                $content = $content -replace "import 'package:biux/data/models/", "import 'package:biux/features/$($feature.Name)/data/models/"
                
                Set-Content -Path $newPath -Value $content -Encoding UTF8 -NoNewline
                Write-Host "    ✅ $model" -ForegroundColor Green
                $migratedModels++
            }
        }
    }

    # Migrar repositorios
    $migratedRepos = 0
    if ($feature.Repositories.Count -gt 0) {
        Write-Host "  🗃️ Migrando repositorios..." -ForegroundColor Cyan
        
        foreach ($repoDir in $feature.Repositories) {
            $oldRepoPath = "lib\data\repositories\$repoDir"
            
            if (Test-Path $oldRepoPath) {
                $repoFiles = Get-ChildItem $oldRepoPath -Filter "*.dart"
                
                foreach ($file in $repoFiles) {
                    $content = Get-Content $file.FullName -Raw -Encoding UTF8
                    
                    # Actualizar imports básicos para esta feature
                    foreach ($model in $feature.Models) {
                        $modelName = $model -replace "\.dart$", ""
                        $content = $content -replace "import 'package:biux/data/models/$model';", "import 'package:biux/features/$($feature.Name)/data/models/$model';"
                        $content = $content -replace "import '../../models/$model';", "import '../models/$model';"
                    }
                    
                    $newPath = "lib\features\$($feature.Name)\data\repositories\$($file.Name)"
                    Set-Content -Path $newPath -Value $content -Encoding UTF8 -NoNewline
                    $migratedRepos++
                }
                Write-Host "    ✅ $repoDir ($($repoFiles.Count) archivos)" -ForegroundColor Green
            }
        }
    }

    # Crear entity básica
    $entityName = ($feature.Name -replace "s$", "") + "_entity"
    $entityClassName = (Get-Culture).TextInfo.ToTitleCase($feature.Name -replace "s$", "") + "Entity"
    
    $basicEntity = @"
class $entityClassName {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  const $entityClassName({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is $entityClassName &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode;
  }
}
"@

    Set-Content -Path "lib\features\$($feature.Name)\domain\entities\$entityName.dart" -Value $basicEntity -Encoding UTF8

    # Crear repository interface básica
    $repositoryInterface = @"
import '../entities/$entityName.dart';

abstract class $(Get-Culture).TextInfo.ToTitleCase($feature.Name)Repository {
  Future<List<$entityClassName>> getAll();
  Future<$entityClassName?> getById(String id);
  Future<void> create($entityClassName entity);
  Future<void> update($entityClassName entity);
  Future<void> delete(String id);
}
"@

    Set-Content -Path "lib\features\$($feature.Name)\domain\repositories\$($feature.Name)_repository.dart" -Value $repositoryInterface -Encoding UTF8

    Write-Host "  🏗️ Entity y repository interface creados" -ForegroundColor Green
    Write-Host "  📊 Resumen: $migratedModels modelos, $migratedRepos archivos de repositorio" -ForegroundColor White
}

# Actualizar importaciones en todo el proyecto
Write-Host ""
Write-Host "🔄 Actualizando importaciones en todo el proyecto..." -ForegroundColor Green

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\"
}

$totalUpdatedFiles = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Actualizar imports para cada feature migrada
    foreach ($feature in $featuresToMigrate) {
        foreach ($model in $feature.Models) {
            $content = $content -replace "import 'package:biux/data/models/$model';", "import 'package:biux/features/$($feature.Name)/data/models/$model';"
        }
        
        foreach ($repoDir in $feature.Repositories) {
            $content = $content -replace "import 'package:biux/data/repositories/$repoDir/([^']+)';", "import 'package:biux/features/$($feature.Name)/data/repositories/`$1';"
        }
    }
    
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $totalUpdatedFiles++
    }
}

Write-Host "  ✅ $totalUpdatedFiles archivos actualizados" -ForegroundColor Green

Write-Host ""
Write-Host "📊 RESUMEN COMPLETO DE MIGRACIÓN (FASES 3-7):" -ForegroundColor Magenta
Write-Host "  • Features migradas: $totalFeatures" -ForegroundColor White
Write-Host "    - ✅ bikes (bicicletas y robos)" -ForegroundColor Green
Write-Host "    - ✅ payments (pagos)" -ForegroundColor Green
Write-Host "    - ✅ sites (sitios/lugares)" -ForegroundColor Green
Write-Host "    - ✅ eps (entidades de salud)" -ForegroundColor Green
Write-Host "    - ✅ advertisements (publicidad)" -ForegroundColor Green
Write-Host "  • Total archivos actualizados: $totalUpdatedFiles" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 ¡Migración de features 3-7 completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "  1. Ejecutar: flutter analyze" -ForegroundColor Yellow
Write-Host "  2. Verificar que no hay errores de compilación" -ForegroundColor Yellow
Write-Host "  3. Continuar con FASE 8: .\migrate_phase8_support_models.ps1" -ForegroundColor Yellow

Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "  • NO eliminar lib\data\ todavía" -ForegroundColor Yellow
Write-Host "  • Falta migrar modelos de soporte (response, analytics, etc.)" -ForegroundColor Yellow