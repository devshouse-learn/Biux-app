# Script para continuar con las migraciones restantes
# Features pendientes: bikes, payments, sites, eps, advertisements, cities, stoles_bikes, trademarks_bikes, types_bikes

Write-Host "=== CONTINUANDO MIGRACIÓN CLEAN ARCHITECTURE ===" -ForegroundColor Green

# Function to create directories safely
function Create-DirectoryIfNotExists {
    param($path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Creado directorio: $path" -ForegroundColor Yellow
    }
}

# Function to copy files safely
function Copy-FileIfExists {
    param($source, $destination)
    if (Test-Path $source) {
        $destDir = Split-Path $destination -Parent
        Create-DirectoryIfNotExists $destDir
        Copy-Item $source $destination -Force
        Write-Host "Copiado: $source -> $destination" -ForegroundColor Cyan
        return $true
    }
    return $false
}

# FASE 1: MIGRAR FEATURE BIKES
Write-Host "`n--- MIGRANDO FEATURE BIKES ---" -ForegroundColor Magenta

# Crear estructura bikes
Create-DirectoryIfNotExists "lib\features\bikes\data\models"
Create-DirectoryIfNotExists "lib\features\bikes\data\repositories"
Create-DirectoryIfNotExists "lib\features\bikes\data\datasources"
Create-DirectoryIfNotExists "lib\features\bikes\domain\entities"
Create-DirectoryIfNotExists "lib\features\bikes\domain\repositories"
Create-DirectoryIfNotExists "lib\features\bikes\domain\usecases"

# Migrar modelos de bikes
$bikeModels = @(
    "lib\data\models\bike.dart",
    "lib\data\models\stole_bike.dart",
    "lib\data\models\trademark_bike.dart",
    "lib\data\models\type_bike.dart"
)

foreach ($model in $bikeModels) {
    $filename = Split-Path $model -Leaf
    Copy-FileIfExists $model "lib\features\bikes\data\models\$filename"
}

# Migrar repositorios de bikes
$bikeRepos = @(
    "lib\data\repositories\bikes\bike_firebase_repository.dart",
    "lib\data\repositories\stoles_bikes\stole_bikes_firebase_repository.dart",
    "lib\data\repositories\trademarks_bikes\trademark_bike_firebase_repository.dart",
    "lib\data\repositories\types_bikes\type_bike_firebase_repository.dart"
)

foreach ($repo in $bikeRepos) {
    $filename = Split-Path $repo -Leaf
    Copy-FileIfExists $repo "lib\features\bikes\data\repositories\$filename"
}

# FASE 2: MIGRAR FEATURE PAYMENTS
Write-Host "`n--- MIGRANDO FEATURE PAYMENTS ---" -ForegroundColor Magenta

Create-DirectoryIfNotExists "lib\features\payments\data\models"
Create-DirectoryIfNotExists "lib\features\payments\data\repositories"
Create-DirectoryIfNotExists "lib\features\payments\data\datasources"
Create-DirectoryIfNotExists "lib\features\payments\domain\entities"
Create-DirectoryIfNotExists "lib\features\payments\domain\repositories"
Create-DirectoryIfNotExists "lib\features\payments\domain\usecases"

# Migrar modelos de payments
Copy-FileIfExists "lib\data\models\payment.dart" "lib\features\payments\data\models\payment.dart"

# Migrar repositorios de payments
Copy-FileIfExists "lib\data\repositories\payments\payment_firebase_repository.dart" "lib\features\payments\data\repositories\payment_firebase_repository.dart"

# FASE 3: MIGRAR FEATURE SITES
Write-Host "`n--- MIGRANDO FEATURE SITES ---" -ForegroundColor Magenta

Create-DirectoryIfNotExists "lib\features\sites\data\models"
Create-DirectoryIfNotExists "lib\features\sites\data\repositories"
Create-DirectoryIfNotExists "lib\features\sites\data\datasources"
Create-DirectoryIfNotExists "lib\features\sites\domain\entities"
Create-DirectoryIfNotExists "lib\features\sites\domain\repositories"
Create-DirectoryIfNotExists "lib\features\sites\domain\usecases"

# Migrar modelos de sites
Copy-FileIfExists "lib\data\models\site.dart" "lib\features\sites\data\models\site.dart"

# Migrar repositorios de sites
Copy-FileIfExists "lib\data\repositories\sites\site_firebase_repository.dart" "lib\features\sites\data\repositories\site_firebase_repository.dart"

# FASE 4: MIGRAR FEATURE EPS
Write-Host "`n--- MIGRANDO FEATURE EPS ---" -ForegroundColor Magenta

Create-DirectoryIfNotExists "lib\features\eps\data\models"
Create-DirectoryIfNotExists "lib\features\eps\data\repositories"
Create-DirectoryIfNotExists "lib\features\eps\data\datasources"
Create-DirectoryIfNotExists "lib\features\eps\domain\entities"
Create-DirectoryIfNotExists "lib\features\eps\domain\repositories"
Create-DirectoryIfNotExists "lib\features\eps\domain\usecases"

# Migrar modelos de eps
Copy-FileIfExists "lib\data\models\eps.dart" "lib\features\eps\data\models\eps.dart"

# Migrar repositorios de eps
Copy-FileIfExists "lib\data\repositories\eps\eps_firebase_repository.dart" "lib\features\eps\data\repositories\eps_firebase_repository.dart"

# FASE 5: MIGRAR FEATURE ADVERTISEMENTS
Write-Host "`n--- MIGRANDO FEATURE ADVERTISEMENTS ---" -ForegroundColor Magenta

Create-DirectoryIfNotExists "lib\features\advertisements\data\models"
Create-DirectoryIfNotExists "lib\features\advertisements\data\repositories"
Create-DirectoryIfNotExists "lib\features\advertisements\data\datasources"
Create-DirectoryIfNotExists "lib\features\advertisements\domain\entities"
Create-DirectoryIfNotExists "lib\features\advertisements\domain\repositories"
Create-DirectoryIfNotExists "lib\features\advertisements\domain\usecases"

# Migrar modelos de advertisements
Copy-FileIfExists "lib\data\models\advertising.dart" "lib\features\advertisements\data\models\advertising.dart"

# Migrar repositorios de advertisements
Copy-FileIfExists "lib\data\repositories\advertisements\advertising_repository.dart" "lib\features\advertisements\data\repositories\advertising_repository.dart"

# FASE 6: MIGRAR FEATURE CITIES
Write-Host "`n--- MIGRANDO FEATURE CITIES ---" -ForegroundColor Magenta

Create-DirectoryIfNotExists "lib\features\cities\data\models"
Create-DirectoryIfNotExists "lib\features\cities\data\repositories"
Create-DirectoryIfNotExists "lib\features\cities\data\datasources"
Create-DirectoryIfNotExists "lib\features\cities\domain\entities"
Create-DirectoryIfNotExists "lib\features\cities\domain\repositories"
Create-DirectoryIfNotExists "lib\features\cities\domain\usecases"

# Migrar modelos de cities
$cityModels = @(
    "lib\data\models\cities.dart",
    "lib\data\models\city.dart"
)

foreach ($model in $cityModels) {
    if (Test-Path $model) {
        $filename = Split-Path $model -Leaf
        Copy-FileIfExists $model "lib\features\cities\data\models\$filename"
    }
}

# Migrar repositorios de cities
Copy-FileIfExists "lib\data\repositories\cities\cities_firebase_repository.dart" "lib\features\cities\data\repositories\cities_firebase_repository.dart"

Write-Host "`n=== MIGRACIÓN COMPLETADA ===" -ForegroundColor Green
Write-Host "Se han migrado las siguientes features:" -ForegroundColor Yellow
Write-Host "- Bikes (incluyendo stoles_bikes, trademarks_bikes, types_bikes)" -ForegroundColor Cyan
Write-Host "- Payments" -ForegroundColor Cyan
Write-Host "- Sites" -ForegroundColor Cyan
Write-Host "- EPS" -ForegroundColor Cyan
Write-Host "- Advertisements" -ForegroundColor Cyan
Write-Host "- Cities" -ForegroundColor Cyan

Write-Host "`nEjecutando análisis post-migración..." -ForegroundColor Yellow