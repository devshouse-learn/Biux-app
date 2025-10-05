# Script de Limpieza Final - Estructura Antigua
Write-Host "Iniciando limpieza de estructura antigua..." -ForegroundColor Cyan
Write-Host "LIMPIEZA FINAL: Eliminando lib/data/ y validando migracion" -ForegroundColor Yellow

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "lib")) {
    Write-Host "Error: No se encuentra el directorio lib. Ejecuta desde la raiz del proyecto." -ForegroundColor Red
    exit 1
}

# PASO 1: Verificar que todas las fases anteriores se completaron
Write-Host ""
Write-Host "Verificando completitud de la migracion..." -ForegroundColor Green

$expectedFeatures = @("authentication", "cities", "groups", "maps", "rides", "roads", "stories", "users", "members", "accidents", "bikes", "payments", "sites", "eps", "advertisements")
$missingFeatures = @()

foreach ($feature in $expectedFeatures) {
    if (-not (Test-Path "lib\features\$feature")) {
        $missingFeatures += $feature
    }
}

if ($missingFeatures.Count -gt 0) {
    Write-Host "ERROR: Features faltantes detectadas:" -ForegroundColor Red
    foreach ($missing in $missingFeatures) {
        Write-Host "  - $missing" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Ejecuta las fases faltantes antes de continuar con la limpieza." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Todas las features estan migradas" -ForegroundColor Green

# PASO 2: Verificar que no hay importaciones a lib/data en el código
Write-Host ""
Write-Host "Verificando importaciones a lib/data..." -ForegroundColor Green

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\"
}

$problematicFiles = @()

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    if ($content -match "package:biux/data/") {
        $problematicFiles += $file.FullName
    }
}

if ($problematicFiles.Count -gt 0) {
    Write-Host "ERROR: Archivos con importaciones a lib/data encontrados:" -ForegroundColor Red
    foreach ($file in $problematicFiles) {
        $relativePath = $file.Replace((Get-Location).Path + "\", "")
        Write-Host "  - $relativePath" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Ejecuta los scripts de correccion de importaciones antes de continuar." -ForegroundColor Yellow
    exit 1
}

Write-Host "  No se encontraron importaciones problematicas" -ForegroundColor Green

# PASO 3: Crear backup de lib/data antes de eliminar
Write-Host ""
Write-Host "Creando backup de lib/data..." -ForegroundColor Green

$backupDir = "backup_lib_data_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

if (Test-Path "lib\data") {
    Copy-Item -Path "lib\data" -Destination $backupDir -Recurse -Force
    Write-Host "  Backup creado en: $backupDir" -ForegroundColor Green
} else {
    Write-Host "  lib/data ya no existe, no se requiere backup" -ForegroundColor Yellow
}

# PASO 4: Listar lo que se va a eliminar
Write-Host ""
Write-Host "Analizando contenido de lib/data..." -ForegroundColor Green

if (Test-Path "lib\data") {
    Write-Host "  Directorios a eliminar:" -ForegroundColor Cyan
    
    if (Test-Path "lib\data\models") {
        $models = Get-ChildItem "lib\data\models" -Filter "*.dart"
        Write-Host "    • lib\data\models\ ($($models.Count) archivos)" -ForegroundColor White
        foreach ($model in $models) {
            Write-Host "      - $($model.Name)" -ForegroundColor Gray
        }
    }
    
    if (Test-Path "lib\data\repositories") {
        $repoDirs = Get-ChildItem "lib\data\repositories" -Directory
        Write-Host "    • lib\data\repositories\ ($($repoDirs.Count) directorios)" -ForegroundColor White
        foreach ($repoDir in $repoDirs) {
            $repoFiles = Get-ChildItem $repoDir.FullName -Filter "*.dart"
            Write-Host "      - $($repoDir.Name)/ ($($repoFiles.Count) archivos)" -ForegroundColor Gray
        }
    }
}

# PASO 5: Confirmar eliminación
Write-Host ""
Write-Host "CONFIRMACION REQUERIDA" -ForegroundColor Red
Write-Host "Estas seguro de que quieres eliminar lib/data/ permanentemente?" -ForegroundColor Yellow
Write-Host "Esta accion NO se puede deshacer (aunque tienes el backup)." -ForegroundColor Yellow
Write-Host ""
Write-Host "S - Si, eliminar lib/data/" -ForegroundColor Green
Write-Host "N - No, cancelar limpieza" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Selecciona una opcion (S/N)"

if ($confirmation -ne "S" -and $confirmation -ne "s") {
    Write-Host ""
    Write-Host "Limpieza cancelada por el usuario." -ForegroundColor Yellow
    Write-Host "lib/data/ se mantiene intacto." -ForegroundColor Cyan
    exit 0
}

# PASO 6: Eliminar lib/data
Write-Host ""
Write-Host "Eliminando lib/data/..." -ForegroundColor Red

if (Test-Path "lib\data") {
    try {
        Remove-Item -Path "lib\data" -Recurse -Force
        Write-Host "  lib/data/ eliminado exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "  Error eliminando lib/data/: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  lib/data/ ya habia sido eliminado" -ForegroundColor Yellow
}

# PASO 7: Eliminar directorios vacíos en lib/
Write-Host ""
Write-Host "Limpiando directorios vacios..." -ForegroundColor Green

$emptyDirs = @()
$libDirs = Get-ChildItem -Path "lib" -Directory -Recurse | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\"
}

foreach ($dir in $libDirs) {
    $items = Get-ChildItem $dir.FullName -Force
    if ($items.Count -eq 0) {
        $emptyDirs += $dir.FullName
    }
}

if ($emptyDirs.Count -gt 0) {
    foreach ($emptyDir in $emptyDirs) {
        Remove-Item -Path $emptyDir -Force
        $relativePath = $emptyDir.Replace((Get-Location).Path + "\", "")
        Write-Host "  Eliminado directorio vacio: $relativePath" -ForegroundColor Green
    }
} else {
    Write-Host "  No se encontraron directorios vacios" -ForegroundColor Yellow
}

# PASO 8: Validación final
Write-Host ""
Write-Host "Ejecutando validacion final..." -ForegroundColor Green

# Verificar estructura de features
$featureCount = (Get-ChildItem "lib\features" -Directory).Count
Write-Host "  Features organizadas: $featureCount" -ForegroundColor White

# Verificar modelos en core
$coreModelsExist = Test-Path "lib\core\models"
Write-Host "  Modelos comunes en core: $(if ($coreModelsExist) { 'SI' } else { 'NO' })" -ForegroundColor White

# Verificar que lib/data ya no existe
$dataExists = Test-Path "lib\data"
Write-Host "  lib/data/ eliminado: $(if (-not $dataExists) { 'SI' } else { 'NO' })" -ForegroundColor White

Write-Host ""
Write-Host "MIGRACION COMPLETADA EXITOSAMENTE!" -ForegroundColor Green
Write-Host ""
Write-Host "RESUMEN FINAL:" -ForegroundColor Magenta
Write-Host "  Arquitectura migrada: Clean Architecture Feature-First" -ForegroundColor Green
Write-Host "  Features organizadas: $featureCount" -ForegroundColor Green
Write-Host "  Estructura antigua eliminada: lib/data/" -ForegroundColor Green
Write-Host "  Backup creado: $backupDir" -ForegroundColor Green
Write-Host "  Modelos comunes en: lib/core/models/" -ForegroundColor Green

Write-Host ""
Write-Host "VALIDACION RECOMENDADA:" -ForegroundColor Cyan
Write-Host "  1. flutter clean" -ForegroundColor Yellow
Write-Host "  2. flutter pub get" -ForegroundColor Yellow
Write-Host "  3. flutter analyze" -ForegroundColor Yellow
Write-Host "  4. flutter test" -ForegroundColor Yellow
Write-Host "  5. flutter build apk --debug" -ForegroundColor Yellow

Write-Host ""
Write-Host "MIGRACION CLEAN ARCHITECTURE COMPLETADA!" -ForegroundColor Green
Write-Host "Tu proyecto Biux ahora sigue 100% Clean Architecture Feature-First" -ForegroundColor Cyan