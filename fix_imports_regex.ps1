# Script para corregir importaciones incorrectas
Write-Host "🔍 Iniciando corrección de importaciones..." -ForegroundColor Cyan

# Función para aplicar correcciones
function Fix-ImportPaths {
    param([string]$content)
    
    # Corregir config/colors.dart
    $content = $content -replace "import\s+'../../../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
    $content = $content -replace "import\s+'../../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
    $content = $content -replace "import\s+'../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
    $content = $content -replace "import\s+'../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
    
    # Corregir config/strings.dart
    $content = $content -replace "import\s+'../../../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
    $content = $content -replace "import\s+'../../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
    $content = $content -replace "import\s+'../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
    $content = $content -replace "import\s+'../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
    
    # Corregir group_model.dart
    $content = $content -replace "import\s+'../../../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
    $content = $content -replace "import\s+'../../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
    $content = $content -replace "import\s+'../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
    
    # Corregir repositorios de grupos
    $content = $content -replace "import\s+'package:biux/data/repositories/groups/groups_firebase_repository\.dart';", "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"
    $content = $content -replace "import\s+'../../../../data/repositories/groups/groups_firebase_repository\.dart';", "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"
    
    # Corregir group_provider.dart
    $content = $content -replace "import\s+'../../../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
    $content = $content -replace "import\s+'../../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
    $content = $content -replace "import\s+'../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
    $content = $content -replace "import\s+'../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
    
    # Corregir repositorios de usuarios
    $content = $content -replace "import\s+'package:biux/data/repositories/users/user_firebase_repository\.dart';", "import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';"
    
    # Corregir repositorio de autenticación
    $content = $content -replace "import\s+'package:biux/data/repositories/authentication_repository\.dart';", "import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';"
    
    # Corregir repositorio de ciudades
    $content = $content -replace "import\s+'package:biux/data/repositories/cities/cities_firebase_repository\.dart';", "import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';"
    
    return $content
}

# Contadores
$totalFiles = 0
$modifiedFiles = 0
$totalReplacements = 0

# Buscar archivos .dart
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\"
}

Write-Host "📁 Encontrados $($dartFiles.Count) archivos Dart para procesar" -ForegroundColor Yellow

foreach ($file in $dartFiles) {
    $totalFiles++
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
    
    try {
        $originalContent = Get-Content $file.FullName -Raw -Encoding UTF8
        $newContent = Fix-ImportPaths -content $originalContent
        
        if ($originalContent -ne $newContent) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $modifiedFiles++
            Write-Host "  ✅ Corregido: $relativePath" -ForegroundColor Green
            
            # Contar las diferencias
            $changes = ($originalContent -split "`n") | ForEach-Object { $i = 0 } { 
                $newLines = $newContent -split "`n"
                if ($i -lt $newLines.Length -and $_ -ne $newLines[$i]) { 1 } else { 0 }
                $i++
            } | Measure-Object -Sum
            $totalReplacements += $changes.Sum
        }
        
    } catch {
        Write-Host "❌ Error procesando $relativePath : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 RESUMEN:" -ForegroundColor Magenta
Write-Host "  • Archivos procesados: $totalFiles" -ForegroundColor White
Write-Host "  • Archivos modificados: $modifiedFiles" -ForegroundColor Green

if ($modifiedFiles -gt 0) {
    Write-Host ""
    Write-Host "🎉 ¡Corrección completada!" -ForegroundColor Green
    Write-Host "💡 Ejecuta: flutter analyze" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ℹ️  No se encontraron importaciones que corregir." -ForegroundColor Blue
}