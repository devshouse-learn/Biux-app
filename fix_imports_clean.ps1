# Script para corregir importaciones incorrectas en el proyecto Biux
# Este script busca y corrige automáticamente las rutas de importación según la nueva estructura Clean Architecture

Write-Host "🔍 Iniciando corrección de importaciones..." -ForegroundColor Cyan

# Definir las correcciones como arrays separados
$oldImports = @(
    "import '../../../../config/colors.dart';",
    "import '../../../config/colors.dart';",
    "import '../../config/colors.dart';",
    "import '../config/colors.dart';",
    "import '../../../../config/strings.dart';",
    "import '../../../config/strings.dart';",
    "import '../../config/strings.dart';",
    "import '../config/strings.dart';",
    "import '../../../../data/models/group_model.dart';",
    "import '../../../data/models/group_model.dart';",
    "import '../../data/models/group_model.dart';",
    "import '../data/models/group_model.dart';",
    "import 'package:biux/data/repositories/groups/groups_firebase_repository.dart';",
    "import '../../../../data/repositories/groups/groups_firebase_repository.dart';",
    "import '../../../data/repositories/groups/groups_firebase_repository.dart';",
    "import '../../../../providers/group_provider.dart';",
    "import '../../../providers/group_provider.dart';",
    "import '../../providers/group_provider.dart';",
    "import '../providers/group_provider.dart';",
    "import '../../../../data/models/user_model.dart';",
    "import '../../../data/models/user_model.dart';",
    "import '../../data/models/user_model.dart';",
    "import 'package:biux/data/repositories/users/user_firebase_repository.dart';",
    "import '../../../../data/repositories/users/user_firebase_repository.dart';",
    "import '../../../../providers/user_provider.dart';",
    "import '../../../providers/user_provider.dart';",
    "import '../../providers/user_provider.dart';",
    "import 'package:biux/data/repositories/authentication_repository.dart';",
    "import '../../../../data/repositories/authentication_repository.dart';",
    "import '../../../../providers/auth_provider.dart';",
    "import '../../../providers/auth_provider.dart';",
    "import '../../providers/auth_provider.dart';",
    "import 'package:biux/data/repositories/cities/cities_firebase_repository.dart';",
    "import '../../../../data/repositories/cities/cities_firebase_repository.dart';",
    "import '../../../../providers/map_provider.dart';",
    "import '../../../providers/map_provider.dart';",
    "import '../../providers/map_provider.dart';",
    "import '../../../../data/models/ride_model.dart';",
    "import '../../../data/models/ride_model.dart';",
    "import '../../data/models/ride_model.dart';",
    "import '../../../../providers/ride_provider.dart';",
    "import '../../../providers/ride_provider.dart';",
    "import '../../providers/ride_provider.dart';"
)

$newImports = @(
    "import 'package:biux/core/config/colors.dart';",
    "import 'package:biux/core/config/colors.dart';",
    "import 'package:biux/core/config/colors.dart';",
    "import 'package:biux/core/config/colors.dart';",
    "import 'package:biux/core/config/strings.dart';",
    "import 'package:biux/core/config/strings.dart';",
    "import 'package:biux/core/config/strings.dart';",
    "import 'package:biux/core/config/strings.dart';",
    "import 'package:biux/features/groups/data/models/group_model.dart';",
    "import 'package:biux/features/groups/data/models/group_model.dart';",
    "import 'package:biux/features/groups/data/models/group_model.dart';",
    "import 'package:biux/features/groups/data/models/group_model.dart';",
    "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';",
    "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';",
    "import 'package:biux/features/groups/data/repositories/groups_firebase_repository.dart';",
    "import 'package:biux/features/groups/presentation/providers/group_provider.dart';",
    "import 'package:biux/features/groups/presentation/providers/group_provider.dart';",
    "import 'package:biux/features/groups/presentation/providers/group_provider.dart';",
    "import 'package:biux/features/groups/presentation/providers/group_provider.dart';",
    "import 'package:biux/features/users/data/models/user_model.dart';",
    "import 'package:biux/features/users/data/models/user_model.dart';",
    "import 'package:biux/features/users/data/models/user_model.dart';",
    "import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';",
    "import 'package:biux/features/users/data/repositories/user_firebase_repository.dart';",
    "import 'package:biux/features/users/presentation/providers/user_provider.dart';",
    "import 'package:biux/features/users/presentation/providers/user_provider.dart';",
    "import 'package:biux/features/users/presentation/providers/user_provider.dart';",
    "import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';",
    "import 'package:biux/features/authentication/data/repositories/authentication_repository.dart';",
    "import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';",
    "import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';",
    "import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';",
    "import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';",
    "import 'package:biux/features/cities/data/repositories/cities_firebase_repository.dart';",
    "import 'package:biux/features/maps/presentation/providers/map_provider.dart';",
    "import 'package:biux/features/maps/presentation/providers/map_provider.dart';",
    "import 'package:biux/features/maps/presentation/providers/map_provider.dart';",
    "import 'package:biux/features/rides/data/models/ride_model.dart';",
    "import 'package:biux/features/rides/data/models/ride_model.dart';",
    "import 'package:biux/features/rides/data/models/ride_model.dart';",
    "import 'package:biux/features/rides/presentation/providers/ride_provider.dart';",
    "import 'package:biux/features/rides/presentation/providers/ride_provider.dart';",
    "import 'package:biux/features/rides/presentation/providers/ride_provider.dart';"
)

# Contadores
$totalFiles = 0
$modifiedFiles = 0
$totalReplacements = 0

# Buscar todos los archivos .dart en el proyecto, excluyendo build y .dart_tool
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\" -and
    $_.FullName -notmatch "\\generated\\"
}

Write-Host "📁 Encontrados $($dartFiles.Count) archivos Dart para procesar" -ForegroundColor Yellow

foreach ($file in $dartFiles) {
    $totalFiles++
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
    
    try {
        # Leer el contenido del archivo
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $fileReplacements = 0
        
        # Aplicar cada corrección
        for ($i = 0; $i -lt $oldImports.Length; $i++) {
            $oldImport = $oldImports[$i]
            $newImport = $newImports[$i]
            
            if ($content.Contains($oldImport)) {
                $content = $content.Replace($oldImport, $newImport)
                $fileReplacements++
                $totalReplacements++
                Write-Host "  ✅ $relativePath" -ForegroundColor Green
                Write-Host "     OLD: $oldImport" -ForegroundColor Red
                Write-Host "     NEW: $newImport" -ForegroundColor Green
            }
        }
        
        # Si hubo cambios, guardar el archivo
        if ($fileReplacements -gt 0) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $modifiedFiles++
            Write-Host "  📝 Guardado: $fileReplacements cambios en $relativePath" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "❌ Error procesando $relativePath : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 RESUMEN DE CORRECCIONES:" -ForegroundColor Magenta
Write-Host "  • Archivos procesados: $totalFiles" -ForegroundColor White
Write-Host "  • Archivos modificados: $modifiedFiles" -ForegroundColor Green
Write-Host "  • Total de importaciones corregidas: $totalReplacements" -ForegroundColor Yellow

if ($totalReplacements -gt 0) {
    Write-Host ""
    Write-Host "🎉 ¡Corrección completada! Se han actualizado las importaciones según la nueva estructura Clean Architecture." -ForegroundColor Green
    Write-Host "💡 Recomendación: Ejecuta 'flutter pub get' y verifica que no haya errores de compilación." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ℹ️  No se encontraron importaciones que corregir. El proyecto ya está actualizado." -ForegroundColor Blue
}

Write-Host ""
Write-Host "🔍 Para verificar errores compilación, ejecuta:" -ForegroundColor Yellow
Write-Host "   flutter analyze" -ForegroundColor White