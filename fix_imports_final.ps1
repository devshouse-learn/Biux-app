# Script para corregir importaciones incorrectas
Write-Host "🔍 Iniciando corrección de importaciones..." -ForegroundColor Cyan

$totalFiles = 0
$modifiedFiles = 0

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
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Aplicar correcciones usando -replace con cadenas
        $content = $content -replace "import '../../../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
        $content = $content -replace "import '../../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
        $content = $content -replace "import '../../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
        $content = $content -replace "import '../config/colors\.dart';", "import 'package:biux/core/config/colors.dart';"
        
        $content = $content -replace "import '../../../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
        $content = $content -replace "import '../../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
        $content = $content -replace "import '../../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
        $content = $content -replace "import '../config/strings\.dart';", "import 'package:biux/core/config/strings.dart';"
        
        $content = $content -replace "import '../../../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
        $content = $content -replace "import '../../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
        $content = $content -replace "import '../../data/models/group_model\.dart';", "import 'package:biux/features/groups/data/models/group_model.dart';"
        
        $content = $content -replace "import 'package:biux/data/repositories/groups/groups_firebase_repository\.dart';", "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"
        $content = $content -replace "import '../../../../data/repositories/groups/groups_firebase_repository\.dart';", "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"
        
        $content = $content -replace "import '../../../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
        $content = $content -replace "import '../../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
        $content = $content -replace "import '../../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
        $content = $content -replace "import '../providers/group_provider\.dart';", "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"
        
        $content = $content -replace "import 'package:biux/data/repositories/users/user_firebase_repository\.dart';", "import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';"
        $content = $content -replace "import 'package:biux/data/repositories/authentication_repository\.dart';", "import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';"
        $content = $content -replace "import 'package:biux/data/repositories/cities/cities_firebase_repository\.dart';", "import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';"
        
        if ($originalContent -ne $content) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $modifiedFiles++
            Write-Host "  ✅ Corregido: $relativePath" -ForegroundColor Green
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