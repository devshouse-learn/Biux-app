# Improved cleanup script with better file handling
$filePath = "lib/core/config/app_translations.dart"

# Read the entire file as a single string to preserve exact formatting
$content = Get-Content $filePath -Raw

# Find and mark ranges to remove using regex or line-by-line
$lines = $content -split '\r?\n'
$totalLines = $lines.Count

Write-Host "Starting with $totalLines lines"

# Helper function to find a string in lines and get its index
function Find-LineIndex {
    param($pattern, $startFrom = 0)
    for ($i = $startFrom; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $pattern) {
            return $i
        }
    }
    return -1
}

# Find section boundaries
$enStart = Find-LineIndex "static const Map<String, String> _en = \{"
$ptStart = Find-LineIndex "static const Map<String, String> _pt = \{" $enStart
$frStart = Find-LineIndex "static const Map<String, String> _fr = \{" $ptStart
$itStart = Find-LineIndex "static const Map<String, String> _it = \{" $frStart

Write-Host "Language sections:"
Write-Host "  EN starts at line $($enStart + 1)"
Write-Host "  PT starts at line $($ptStart + 1)"
Write-Host "  FR starts at line $($frStart + 1)"
Write-Host "  IT starts at line $($itStart + 1)"

# Find the duplicate marker (first occurrence of 'whatsapp_number' after the first legitimate one)
# In English section, find second occurrence of 'whatsapp_number'
$whatsappIdx = $enStart
$whatsappCount = 0
$dupStart_en = -1
for ($i = $enStart; $i -lt $ptStart; $i++) {
    if ($lines[$i] -match "'whatsapp_number':") {
        $whatsappCount++
        if ($whatsappCount -eq 2) {
            # Found the duplicate
            # Go back to find the start of this section (look for comment)
            for ($j = $i - 50; $j -le $i; $j++) {
                if ($lines[$j] -match "// (Account|Profile|Report)") {
                    $dupStart_en = $j
                    break
                }
            }
            break
        }
    }
}

if ($dupStart_en -eq -1) {
    Write-Host "Could not find English duplicate block start"
} else {
    Write-Host "English duplicate block starts at line $($dupStart_en + 1)"
    
    # Remove English duplicates
    $linesToRemove = @()
    for ($i = $dupStart_en; $i -lt $ptStart; $i++) {
        $linesToRemove += $i
    }
    
    Write-Host "Removing English duplicates: $($linesToRemove.Count) lines"
    
    # Remove in reverse order
    [array]::Reverse($linesToRemove)
    foreach ($idx in $linesToRemove) {
        $lines = $lines[0..($idx-1)] + $lines[($idx+1)..($lines.Count-1)]
    }
}

$newContent = $lines -join "`n"
Set-Content $filePath $newContent -Encoding UTF8 -NoNewline

Write-Host "Final size: $((Get-Content $filePath -Raw).Split("`n").Count) lines"
