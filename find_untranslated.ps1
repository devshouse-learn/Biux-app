# Script para encontrar todos los textos sin traducir en los archivos de pantalla

$patterns = @(
    # Archivos de pantallas y widgets en features
    "lib/features/*/presentation/screens/*.dart",
    "lib/features/*/presentation/widgets/*.dart"
)

$results = @()

foreach ($pattern in $patterns) {
    $files = Get-ChildItem -Path $pattern -Recurse -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Buscar Text('...') sin l.t() - más preciso
        $matches = [regex]::Matches($content, "Text\(\s*['\"]([^'\"]+)['\"]\s*\)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
        
        foreach ($match in $matches) {
            $text = $match.Groups[1].Value
            # Excluir textos que típicamente no necesitan traducción
            if ($text -notmatch '^\s*\$|^[0-9]+$|^[•-]|^[a-zA-Z0-9_]+$|^\+|^[(){}\[\]]|^[|]' -and $text.Length -gt 1) {
                $results += @{
                    File = $file.Name
                    Text = $text
                    FullPath = $file.FullName
                }
            }
        }
        
        # Buscar showSnackBar con Text hardcodeado
        $snackMatches = [regex]::Matches($content, "SnackBar\(.*?content:\s*Text\(\s*['\"]([^'\"]+)['\"]\s*\)", [System.Text.RegularExpressions.RegexOptions]::Singleline)
        foreach ($match in $snackMatches) {
            $text = $match.Groups[1].Value
            if ($text -notmatch '^\s*\$|^[0-9]+$' -and $text.Length -gt 1) {
                $results += @{
                    File = $file.Name
                    Text = "[SNACKBAR] $text"
                    FullPath = $file.FullName
                }
            }
        }
    }
}

# Mostrar resultados únicos
$unique = $results | Sort-Object -Property Text -Unique

Write-Host "Total textos sin traducir encontrados: $($unique.Count)"
Write-Host ""

$unique | ForEach-Object {
    Write-Host "$($_.File): $($_.Text)"
}

# Exportar a archivo para procesamiento
$unique | Export-Csv -Path "untranslated_texts.csv" -Encoding UTF8 -NoTypeInformation
Write-Host ""
Write-Host "Resultados exportados a untranslated_texts.csv"
