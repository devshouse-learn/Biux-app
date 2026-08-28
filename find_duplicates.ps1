# PowerShell script to remove duplicate translation blocks
$filePath = "lib/core/config/app_translations.dart"
$content = Get-Content $filePath -Raw
$lines = $content -split '\r?\n'

Write-Host "File has $($lines.Count) lines"

# Find duplicate sections by looking for specific markers
$duplicates = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    
    # Look for duplicate block markers
    if ($line -like "*// Profile image picker*") {
        # Check if this is part of a duplicate (preceded by 'deactivated': 'Disabled')
        if ($i -gt 0 -and $lines[$i-2] -like "*'deactivated': 'Disabled'*") {
            Write-Host "Found possible English duplicate at line $($i+1)"
            $duplicates += @{Type="English"; StartLine=$i}
        }
    }
}

Write-Host "Found $($duplicates.Count) potential duplicate sections"
foreach ($dup in $duplicates) {
    Write-Host "  - $($dup.Type) starts at line $($dup.StartLine + 1)"
}
