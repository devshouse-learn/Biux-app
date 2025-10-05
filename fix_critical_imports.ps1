# Script simple para corregir importaciones criticas
Write-Host "Corrigiendo importaciones criticas..." -ForegroundColor Green

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\"
}

$modifiedFiles = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Corregir imports mas criticos
    $content = $content -replace "import 'package:biux/data/models/member\.dart';", "import 'package:biux/features/members/data/models/member.dart';"
    $content = $content -replace "import 'package:biux/data/models/user_membership\.dart';", "import 'package:biux/features/members/data/models/user_membership.dart';"
    $content = $content -replace "import 'package:biux/data/repositories/members/members_firebase_repository\.dart';", "import 'package:biux/features/members/data/repositories/members_firebase_repository.dart';"
    $content = $content -replace "import 'package:biux/data/models/competitor_road\.dart';", "import 'package:biux/features/roads/data/models/competitor_road.dart';"
    $content = $content -replace "import 'package:biux/data/models/situation_accident\.dart';", "import 'package:biux/features/accidents/data/models/situation_accident.dart';"
    $content = $content -replace "import 'package:biux/data/models/response\.dart';", "import 'package:biux/core/models/common/response.dart';"
    
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "  Corregido: $relativePath" -ForegroundColor Green
        $modifiedFiles++
    }
}

Write-Host ""
Write-Host "Archivos modificados: $modifiedFiles" -ForegroundColor Yellow
Write-Host "Correccion completada!" -ForegroundColor Green