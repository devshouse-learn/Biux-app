# Script para corregir importaciones incorrectas en el proyecto Biux
Write-Host "🔍 Iniciando corrección de importaciones..." -ForegroundColor Cyan

# Definir correcciones usando variables simples
$corrections = @()
$corrections += @{Old = "import '../../../../../config/colors.dart';"; New = "import 'package:biux/core/config/colors.dart';"}
$corrections += @{Old = "import '../../../../config/colors.dart';"; New = "import 'package:biux/core/config/colors.dart';"}
$corrections += @{Old = "import '../../../config/colors.dart';"; New = "import 'package:biux/core/config/colors.dart';"}
$corrections += @{Old = "import '../../config/colors.dart';"; New = "import 'package:biux/core/config/colors.dart';"}
$corrections += @{Old = "import '../config/colors.dart';"; New = "import 'package:biux/core/config/colors.dart';"}

$corrections += @{Old = "import '../../../../config/strings.dart';"; New = "import 'package:biux/core/config/strings.dart';"}
$corrections += @{Old = "import '../../../config/strings.dart';"; New = "import 'package:biux/core/config/strings.dart';"}
$corrections += @{Old = "import '../../config/strings.dart';"; New = "import 'package:biux/core/config/strings.dart';"}
$corrections += @{Old = "import '../config/strings.dart';"; New = "import 'package:biux/core/config/strings.dart';"}

$corrections += @{Old = "import '../../../../data/models/group_model.dart';"; New = "import 'package:biux/features/groups/data/models/group_model.dart';"}
$corrections += @{Old = "import '../../../data/models/group_model.dart';"; New = "import 'package:biux/features/groups/data/models/group_model.dart';"}
$corrections += @{Old = "import '../../data/models/group_model.dart';"; New = "import 'package:biux/features/groups/data/models/group_model.dart';"}

$corrections += @{Old = "import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';"; New = "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"}
$corrections += @{Old = "import '../../../../data/repositories/groups/groups_firebase_repository.dart';"; New = "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';"}

$corrections += @{Old = "import '../../../../providers/group_provider.dart';"; New = "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"}
$corrections += @{Old = "import '../../../providers/group_provider.dart';"; New = "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"}
$corrections += @{Old = "import '../../providers/group_provider.dart';"; New = "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"}
$corrections += @{Old = "import '../providers/group_provider.dart';"; New = "import 'package:biux/features/groups/presentation/providers/group_provider.dart';"}

$corrections += @{Old = "import 'package:biux/data/repositories/users/user_firebase_repository.dart';"; New = "import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';"}
$corrections += @{Old = "import 'package:biux/data/repositories/authentication_repository.dart';"; New = "import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';"}
$corrections += @{Old = "import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';"; New = "import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';"}

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
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $fileReplacements = 0
        
        # Aplicar correcciones
        foreach ($correction in $corrections) {
            if ($content.Contains($correction.Old)) {
                $content = $content.Replace($correction.Old, $correction.New)
                $fileReplacements++
                $totalReplacements++
                Write-Host "  ✅ Corregido en: $relativePath" -ForegroundColor Green
            }
        }
        
        # Guardar si hubo cambios
        if ($fileReplacements -gt 0) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $modifiedFiles++
            Write-Host "  📝 Guardado: $fileReplacements cambios" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "❌ Error procesando $relativePath : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 RESUMEN:" -ForegroundColor Magenta
Write-Host "  • Archivos procesados: $totalFiles" -ForegroundColor White
Write-Host "  • Archivos modificados: $modifiedFiles" -ForegroundColor Green
Write-Host "  • Importaciones corregidas: $totalReplacements" -ForegroundColor Yellow

if ($totalReplacements -gt 0) {
    Write-Host ""
    Write-Host "🎉 ¡Corrección completada!" -ForegroundColor Green
    Write-Host "💡 Ejecuta: flutter analyze" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ℹ️  No se encontraron importaciones que corregir." -ForegroundColor Blue
}