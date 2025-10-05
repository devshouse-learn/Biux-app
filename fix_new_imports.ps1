# Script para corregir imports de features migradas
Write-Host "=== CORRIGIENDO IMPORTS DE FEATURES MIGRADAS ===" -ForegroundColor Green

$filesToFix = @()

# Buscar archivos que pueden necesitar corrección
$searchDirs = @(
    "lib\features\",
    "lib\shared\",
    "lib\ui\",
    "lib\providers\"
)

foreach ($dir in $searchDirs) {
    if (Test-Path $dir) {
        $files = Get-ChildItem -Path $dir -Recurse -Filter "*.dart"
        $filesToFix += $files.FullName
    }
}

$correctionCount = 0

foreach ($file in $filesToFix) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $originalContent = $content
            
            # Correcciones para BIKES
            $content = $content -replace "import 'package:biux/data/models/bike\.dart'", "import 'package:biux/features/bikes/data/models/bike.dart'"
            $content = $content -replace "import 'package:biux/data/models/stole_bikes\.dart'", "import 'package:biux/features/bikes/data/models/stole_bikes.dart'"
            $content = $content -replace "import 'package:biux/data/models/trademark_bike\.dart'", "import 'package:biux/features/bikes/data/models/trademark_bike.dart'"
            $content = $content -replace "import 'package:biux/data/models/type_bike\.dart'", "import 'package:biux/features/bikes/data/models/type_bike.dart'"
            
            $content = $content -replace "import 'package:biux/data/repositories/bikes/bike_firebase_repository\.dart'", "import 'package:biux/features/bikes/data/repositories/bike_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/stoles_bikes/stole_bikes_firebase_repository\.dart'", "import 'package:biux/features/bikes/data/repositories/stole_bikes_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/trademarks_bikes/trademark_bike_firebase_repository\.dart'", "import 'package:biux/features/bikes/data/repositories/trademark_bike_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/types_bikes/types_bike_firebase_repository\.dart'", "import 'package:biux/features/bikes/data/repositories/types_bike_firebase_repository.dart'"
            
            # Correcciones para PAYMENTS
            $content = $content -replace "import 'package:biux/data/repositories/payments/payments_firebase_repository\.dart'", "import 'package:biux/features/payments/data/repositories/payments_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/payments/payments_repository_abstract\.dart'", "import 'package:biux/features/payments/domain/repositories/payments_repository_abstract.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/payments/payments_repository\.dart'", "import 'package:biux/features/payments/data/repositories/payments_repository.dart'"
            
            # Correcciones para SITES
            $content = $content -replace "import 'package:biux/data/models/sites\.dart'", "import 'package:biux/features/sites/data/models/sites.dart'"
            $content = $content -replace "import 'package:biux/data/models/types_sites\.dart'", "import 'package:biux/features/sites/data/models/types_sites.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/sites/sites_firebase_repository\.dart'", "import 'package:biux/features/sites/data/repositories/sites_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/sites/sites_repository\.dart'", "import 'package:biux/features/sites/data/repositories/sites_repository.dart'"
            
            # Correcciones para EPS
            $content = $content -replace "import 'package:biux/data/models/eps\.dart'", "import 'package:biux/features/eps/data/models/eps.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/eps/eps_firebase_repository\.dart'", "import 'package:biux/features/eps/data/repositories/eps_firebase_repository.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/eps/eps_repository\.dart'", "import 'package:biux/features/eps/data/repositories/eps_repository.dart'"
            
            # Correcciones para ADVERTISEMENTS
            $content = $content -replace "import 'package:biux/data/models/advertising\.dart'", "import 'package:biux/features/advertisements/data/models/advertising.dart'"
            $content = $content -replace "import 'package:biux/data/repositories/advertisements/advertising_repository\.dart'", "import 'package:biux/features/advertisements/data/repositories/advertising_repository.dart'"
            
            # Correcciones para CITIES (modelos adicionales)
            $content = $content -replace "import 'package:biux/data/models/country\.dart'", "import 'package:biux/features/cities/data/models/country.dart'"
            $content = $content -replace "import 'package:biux/data/models/state\.dart'", "import 'package:biux/features/cities/data/models/state.dart'"
            
            if ($content -ne $originalContent) {
                Set-Content -Path $file -Value $content -Encoding UTF8
                $correctionCount++
                Write-Host "Corregido: $file" -ForegroundColor Cyan
            }
        }
    }
}

Write-Host "`n=== CORRECCIÓN COMPLETADA ===" -ForegroundColor Green
Write-Host "Archivos corregidos: $correctionCount" -ForegroundColor Yellow