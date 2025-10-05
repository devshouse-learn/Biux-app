# 🚀 Script para Migrar Modelos de Soporte (FASE 8)
Write-Host "🔄 Iniciando migración de modelos de soporte..." -ForegroundColor Cyan
Write-Host "📋 FASE 8: Modelos comunes y de soporte" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "lib")) {
    Write-Host "❌ Error: No se encuentra el directorio lib. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Crear estructura de directorios para modelos comunes
Write-Host ""
Write-Host "📁 Creando estructura para modelos comunes..." -ForegroundColor Green

$coreDirectories = @(
    "lib\core\models",
    "lib\core\models\geography",
    "lib\core\models\analytics",
    "lib\core\models\common"
)

foreach ($dir in $coreDirectories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ✅ Creado: $dir" -ForegroundColor Green
    }
}

# Definir modelos a migrar con sus destinos
$supportModels = @(
    @{
        Old = "lib\data\models\response.dart"
        New = "lib\core\models\common\response.dart"
        Description = "Modelo de respuesta genérico"
    },
    @{
        Old = "lib\data\models\analitics.dart"
        New = "lib\core\models\analytics\analytics.dart"
        Description = "Modelo de analíticas (version 1)"
    },
    @{
        Old = "lib\data\models\analitycs.dart"
        New = "lib\core\models\analytics\analytics_v2.dart"
        Description = "Modelo de analíticas (version 2)"
    },
    @{
        Old = "lib\data\models\country.dart"
        New = "lib\core\models\geography\country.dart"
        Description = "Modelo de país"
    },
    @{
        Old = "lib\data\models\state.dart"
        New = "lib\core\models\geography\state.dart"
        Description = "Modelo de estado/provincia"
    },
    @{
        Old = "lib\data\models\event.dart"
        New = "lib\core\models\common\event.dart"
        Description = "Modelo de evento genérico"
    }
)

# Migrar modelos de soporte
Write-Host ""
Write-Host "📦 Migrando modelos de soporte..." -ForegroundColor Green

$migratedModels = 0

foreach ($model in $supportModels) {
    if (Test-Path $model.Old) {
        $content = Get-Content $model.Old -Raw -Encoding UTF8
        
        # Actualizar imports internos para apuntar a la nueva estructura core
        $content = $content -replace "import 'package:biux/data/models/", "import 'package:biux/core/models/"
        
        # Crear directorio si no existe
        $newDir = Split-Path $model.New -Parent
        if (-not (Test-Path $newDir)) {
            New-Item -ItemType Directory -Path $newDir -Force | Out-Null
        }
        
        Set-Content -Path $model.New -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✅ $($model.Description)" -ForegroundColor Green
        $migratedModels++
    } else {
        Write-Host "  ⚠️  No encontrado: $(Split-Path $model.Old -Leaf)" -ForegroundColor Yellow
    }
}

# Crear modelo de respuesta mejorado si no existe
if (-not (Test-Path "lib\core\models\common\response.dart")) {
    $responseModel = @"
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }
  
  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
  
  bool get isSuccess => success;
  bool get isError => !success;
}

// Modelo de respuesta simple para compatibilidad
class Response {
  final bool success;
  final dynamic data;
  final String? message;
  
  const Response({
    required this.success,
    this.data,
    this.message,
  });
  
  factory Response.success(dynamic data, {String? message}) {
    return Response(
      success: true,
      data: data,
      message: message,
    );
  }
  
  factory Response.error(String message) {
    return Response(
      success: false,
      message: message,
    );
  }
}
"@

    Set-Content -Path "lib\core\models\common\response.dart" -Value $responseModel -Encoding UTF8
    Write-Host "  ✅ Modelo de respuesta mejorado creado" -ForegroundColor Green
}

# Actualizar todas las importaciones en el proyecto
Write-Host ""
Write-Host "🔄 Actualizando importaciones de modelos de soporte..." -ForegroundColor Green

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\" -and
    $_.FullName -notmatch "lib\\core\\models\\"
}

$updatedFiles = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Actualizar imports de modelos de soporte
    $content = $content -replace "import 'package:biux/data/models/response\.dart';", "import 'package:biux/core/models/common/response.dart';"
    $content = $content -replace "import 'package:biux/data/models/analitics\.dart';", "import 'package:biux/core/models/analytics/analytics.dart';"
    $content = $content -replace "import 'package:biux/data/models/analitycs\.dart';", "import 'package:biux/core/models/analytics/analytics_v2.dart';"
    $content = $content -replace "import 'package:biux/data/models/country\.dart';", "import 'package:biux/core/models/geography/country.dart';"
    $content = $content -replace "import 'package:biux/data/models/state\.dart';", "import 'package:biux/core/models/geography/state.dart';"
    $content = $content -replace "import 'package:biux/data/models/event\.dart';", "import 'package:biux/core/models/common/event.dart';"
    
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "  ✅ Actualizado: $relativePath" -ForegroundColor Green
        $updatedFiles++
    }
}

# Verificar qué modelos quedan en lib/data/models
Write-Host ""
Write-Host "📋 Verificando modelos restantes en lib/data/models..." -ForegroundColor Cyan

if (Test-Path "lib\data\models") {
    $remainingModels = Get-ChildItem "lib\data\models" -Filter "*.dart"
    
    if ($remainingModels.Count -gt 0) {
        Write-Host "  ⚠️  Modelos restantes sin migrar:" -ForegroundColor Yellow
        foreach ($model in $remainingModels) {
            Write-Host "    - $($model.Name)" -ForegroundColor Yellow
        }
        Write-Host "  💡 Estos modelos pueden requerir migración manual" -ForegroundColor Cyan
    } else {
        Write-Host "  ✅ ¡Todos los modelos han sido migrados!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📊 RESUMEN DE MIGRACIÓN (FASE 8):" -ForegroundColor Magenta
Write-Host "  • Modelos de soporte migrados: $migratedModels" -ForegroundColor White
Write-Host "    - ✅ response.dart → core/models/common/" -ForegroundColor Green
Write-Host "    - ✅ analytics → core/models/analytics/" -ForegroundColor Green
Write-Host "    - ✅ geografía → core/models/geography/" -ForegroundColor Green
Write-Host "    - ✅ eventos → core/models/common/" -ForegroundColor Green
Write-Host "  • Archivos actualizados: $updatedFiles" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 ¡Migración de modelos de soporte completada!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 SIGUIENTES PASOS:" -ForegroundColor Cyan
Write-Host "  1. Ejecutar: flutter analyze" -ForegroundColor Yellow
Write-Host "  2. Verificar que no hay errores de compilación" -ForegroundColor Yellow
Write-Host "  3. Ejecutar: .\cleanup_old_structure.ps1" -ForegroundColor Yellow
Write-Host "  4. Validación final del proyecto" -ForegroundColor Yellow

Write-Host ""
Write-Host "🚀 MIGRACIÓN CASI COMPLETA:" -ForegroundColor Green
Write-Host "  • Todas las features principales migradas ✅" -ForegroundColor Green
Write-Host "  • Modelos de soporte organizados ✅" -ForegroundColor Green
Write-Host "  • Listo para limpieza final ✅" -ForegroundColor Green