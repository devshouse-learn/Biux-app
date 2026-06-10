# Script para remover imports innecesarios de firebase_core
# Elimina la linea: import 'package:firebase_core/firebase_core.dart';

$projectRoot = "C:\Users\Usuario\Biux-app\Biux-app"

$archivos = @(
    "lib\core\services\notification_service.dart",
    "lib\core\utils\firebase_utils.dart",
    "lib\features\advertisements\data\repositories\advertising_repository_impl.dart",
    "lib\features\age_verification\presentation\screens\identity_verification_screen.dart",
    "lib\features\authentication\data\repositories\authentication_repository.dart",
    "lib\features\emergency\presentation\providers\emergency_provider.dart",
    "lib\features\experiences\presentation\screens\experiences_list_screen.dart",
    "lib\features\payments\data\repositories\payments_firebase_repository_impl.dart",
    "lib\features\stories\data\repositories\stories_firebase_repository.dart",
    "lib\features\users\presentation\providers\edit_username_provider.dart"
)

$contadorEliminados = 0

Write-Host "Iniciando eliminacion de imports de firebase_core..." -ForegroundColor Cyan
Write-Host "Directorio: $projectRoot" -ForegroundColor Gray
Write-Host ""

foreach ($archivo in $archivos) {
    $rutaCompleta = Join-Path -Path $projectRoot -ChildPath $archivo

    if (Test-Path -Path $rutaCompleta) {
        try {
            $lineas = Get-Content -Path $rutaCompleta -Encoding UTF8
            $lineasNuevas = @()
            $encontrado = $false

            foreach ($linea in $lineas) {
                if ($linea -eq "import 'package:firebase_core/firebase_core.dart';") {
                    $encontrado = $true
                } else {
                    $lineasNuevas += $linea
                }
            }

            if ($encontrado) {
                Set-Content -Path $rutaCompleta -Value $lineasNuevas -Encoding UTF8

                Write-Host "OK: $archivo" -ForegroundColor Green
                $contadorEliminados++
            } else {
                Write-Host "SKIP: $archivo (no encontrado)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "ERROR: $archivo ($_)" -ForegroundColor Red
        }
    } else {
        Write-Host "NOT FOUND: $archivo" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Imports eliminados: $contadorEliminados / 10" -ForegroundColor Green
Write-Host ""
Write-Host "Completado." -ForegroundColor Cyan
