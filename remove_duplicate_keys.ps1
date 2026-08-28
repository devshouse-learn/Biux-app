# Surgical script to remove only duplicate entries, not entire blocks
$filePath = "lib/core/config/app_translations.dart"

# Read file
$content = Get-Content $filePath -Raw
$lines = $content -split '\r?\n'

Write-Host "Starting with $($lines.Count) lines"

# Strategy: Find entries that appear twice and keep only the first occurrence
# Build a map of keys we've seen per language section
$keysBySection = @{}
$linesToRemove = @()

# Identify section boundaries
$sectionStarts = @{}
$currentSection = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'static const Map<String, String> _(\w+) = \{') {
        $currentSection = $matches[1]
        $sectionStarts[$currentSection] = $i
        $keysBySection[$currentSection] = @{}
        continue
    }
    
    # Extract key from line
    if ($lines[$i] -match "^\s*'([^']+)':\s") {
        $key = $matches[1]
        
        if ($currentSection) {
            if ($keysBySection[$currentSection].ContainsKey($key)) {
                # This is a duplicate!
                # Mark this line for removal
                $linesToRemove += $i
                if ($linesToRemove.Count -le 5) {
                    Write-Host "Found duplicate key '$key' at line $($i+1) in section $currentSection"
                }
            } else {
                $keysBySection[$currentSection][$key] = $i
            }
        }
    }
}

Write-Host "Found $($linesToRemove.Count) lines to remove"

# Remove lines in reverse order to preserve indices
[array]::Reverse($linesToRemove)
foreach ($lineNum in $linesToRemove) {
    $lines = $lines[0..($lineNum-1)] + $lines[($lineNum+1)..($lines.Count-1)]
}

# Join and write back
$newContent = $lines -join "`n"
Set-Content $filePath $newContent -NoNewline

Write-Host "File cleaned! New size: $((Get-Content $filePath -Raw).Split("`n").Count) lines"
