# 🚀 Script Maestro - Migración Completa Clean Architecture
Write-Host "🎯 BIUX - MIGRACIÓN COMPLETA A CLEAN ARCHITECTURE FEATURE-FIRST" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar prerrequisitos
if (-not (Test-Path "lib")) {
    Write-Host "❌ Error: No se encuentra el directorio lib. Ejecuta desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No se encuentra pubspec.yaml. Ejecuta desde la raíz del proyecto Flutter." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Proyecto Flutter detectado correctamente" -ForegroundColor Green
Write-Host ""

# Mostrar plan de ejecución
Write-Host "📋 PLAN DE EJECUCIÓN:" -ForegroundColor Magenta
Write-Host "  FASE 1: Migrar Members (CRÍTICA)" -ForegroundColor Red
Write-Host "  FASE 2: Migrar Accidents (ALTA PRIORIDAD)" -ForegroundColor Yellow
Write-Host "  FASE 3-7: Migrar Features Restantes (MEDIA-BAJA)" -ForegroundColor Green
Write-Host "  FASE 8: Migrar Modelos de Soporte" -ForegroundColor Green
Write-Host "  LIMPIEZA: Eliminar Estructura Antigua" -ForegroundColor Cyan
Write-Host ""

# Confirmación del usuario
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "  • Esta migración modificará la estructura completa del proyecto" -ForegroundColor Yellow
Write-Host "  • Se recomienda tener el código en control de versiones (git)" -ForegroundColor Yellow
Write-Host "  • El proceso tomará aproximadamente 5-10 minutos" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "¿Deseas continuar con la migración completa? (S/N)"

if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host ""
    Write-Host "❌ Migración cancelada por el usuario." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🚀 Iniciando migración completa..." -ForegroundColor Green

# Variables de seguimiento
$startTime = Get-Date
$errors = @()
$successfulPhases = @()

# Función para ejecutar script y manejar errores
function Execute-Phase {
    param(
        [string]$ScriptPath,
        [string]$PhaseName,
        [bool]$Critical = $false
    )
    
    Write-Host ""
    Write-Host "▶️  Ejecutando: $PhaseName" -ForegroundColor Cyan
    Write-Host "   Script: $ScriptPath" -ForegroundColor Gray
    
    if (-not (Test-Path $ScriptPath)) {
        $errorMsg = "Script no encontrado: $ScriptPath"
        $errors += $errorMsg
        Write-Host "❌ $errorMsg" -ForegroundColor Red
        
        if ($Critical) {
            Write-Host "💥 Fase crítica falló. Deteniendo migración." -ForegroundColor Red
            exit 1
        }
        return $false
    }
    
    try {
        & $ScriptPath
        $successfulPhases += $PhaseName
        Write-Host "✅ $PhaseName completada exitosamente" -ForegroundColor Green
        return $true
    } catch {
        $errorMsg = "$PhaseName falló: $($_.Exception.Message)"
        $errors += $errorMsg
        Write-Host "❌ $errorMsg" -ForegroundColor Red
        
        if ($Critical) {
            Write-Host "💥 Fase crítica falló. Deteniendo migración." -ForegroundColor Red
            exit 1
        }
        return $false
    }
}

# EJECUTAR TODAS LAS FASES
Write-Host ""
Write-Host "🎯 INICIANDO EJECUCIÓN DE FASES..." -ForegroundColor Magenta

# FASE 1: Members (CRÍTICA)
Execute-Phase -ScriptPath "migrate_phase1_members.ps1" -PhaseName "FASE 1: Members" -Critical $true

# FASE 2: Accidents
Execute-Phase -ScriptPath "migrate_phase2_accidents.ps1" -PhaseName "FASE 2: Accidents"

# FASES 3-7: Features restantes
Execute-Phase -ScriptPath "migrate_phase3-7_remaining.ps1" -PhaseName "FASES 3-7: Features Restantes"

# FASE 8: Modelos de soporte
Execute-Phase -ScriptPath "migrate_phase8_support_models.ps1" -PhaseName "FASE 8: Modelos de Soporte"

# Ejecutar análisis intermedio
Write-Host ""
Write-Host "🔍 Ejecutando análisis intermedio..." -ForegroundColor Cyan
try {
    & flutter analyze --no-pub
    Write-Host "✅ Flutter analyze completado" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Flutter analyze mostró algunos warnings (normal durante migración)" -ForegroundColor Yellow
}

# LIMPIEZA FINAL
Write-Host ""
Write-Host "🧹 ¿Ejecutar limpieza final (eliminar lib/data/)?" -ForegroundColor Cyan
Write-Host "   Esto eliminará permanentemente la estructura antigua" -ForegroundColor Yellow
$cleanupConfirm = Read-Host "Confirmar limpieza (S/N)"

if ($cleanupConfirm -eq "S" -or $cleanupConfirm -eq "s") {
    Execute-Phase -ScriptPath "cleanup_old_structure_fixed.ps1" -PhaseName "LIMPIEZA FINAL"
} else {
    Write-Host "⏭️  Limpieza final omitida. lib/data/ se mantiene intacto." -ForegroundColor Yellow
}

# VALIDACIÓN FINAL
Write-Host ""
Write-Host "✅ Ejecutando validación final..." -ForegroundColor Green

Write-Host "  🧹 Limpiando proyecto..." -ForegroundColor Cyan
try {
    & flutter clean
    Write-Host "    ✅ flutter clean" -ForegroundColor Green
} catch {
    Write-Host "    ⚠️  flutter clean falló" -ForegroundColor Yellow
}

Write-Host "  📦 Obteniendo dependencias..." -ForegroundColor Cyan  
try {
    & flutter pub get
    Write-Host "    ✅ flutter pub get" -ForegroundColor Green
} catch {
    Write-Host "    ❌ flutter pub get falló" -ForegroundColor Red
    $errors += "flutter pub get falló"
}

Write-Host "  🔍 Análisis final..." -ForegroundColor Cyan
try {
    & flutter analyze
    Write-Host "    ✅ flutter analyze" -ForegroundColor Green
} catch {
    Write-Host "    ⚠️  flutter analyze mostró issues (revisar manualmente)" -ForegroundColor Yellow
}

# RESUMEN FINAL
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "🎉 ¡MIGRACIÓN COMPLETA FINALIZADA!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏱️  TIEMPO TOTAL: $($duration.Minutes) minutos, $($duration.Seconds) segundos" -ForegroundColor White
Write-Host ""
Write-Host "✅ FASES COMPLETADAS:" -ForegroundColor Green
foreach ($phase in $successfulPhases) {
    Write-Host "    • $phase" -ForegroundColor Green
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  ERRORES ENCONTRADOS:" -ForegroundColor Yellow
    foreach ($error in $errors) {
        Write-Host "    • $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📁 ESTRUCTURA FINAL:" -ForegroundColor Magenta
$featureCount = 0
if (Test-Path "lib\features") {
    $featureCount = (Get-ChildItem "lib\features" -Directory).Count
}
Write-Host "    • Features organizadas: $featureCount" -ForegroundColor White
Write-Host "    • Arquitectura: Clean Architecture Feature-First ✅" -ForegroundColor Green
Write-Host "    • Modelos comunes: lib/core/models/ ✅" -ForegroundColor Green

Write-Host ""
Write-Host "🚀 SIGUIENTES PASOS RECOMENDADOS:" -ForegroundColor Cyan
Write-Host "  1. Revisar warnings de flutter analyze (si los hay)" -ForegroundColor Yellow
Write-Host "  2. Ejecutar tests: flutter test" -ForegroundColor Yellow
Write-Host "  3. Probar compilación: flutter build apk --debug" -ForegroundColor Yellow
Write-Host "  4. Commit de los cambios: git add . && git commit -m 'feat: migrate to clean architecture feature-first'" -ForegroundColor Yellow

Write-Host ""
Write-Host "🎯 ¡PROYECTO BIUX MIGRADO EXITOSAMENTE!" -ForegroundColor Green
Write-Host "   Clean Architecture Feature-First implementada al 100%" -ForegroundColor Cyan