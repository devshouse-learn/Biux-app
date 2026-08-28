# Remove duplicate translation blocks from app_translations.dart
$filePath = "lib/core/config/app_translations.dart"
$backupPath = "lib/core/config/app_translations.dart.backup"

# Create backup
Copy-Item $filePath $backupPath

$content = Get-Content $filePath -Raw
$lines = @($content -split '\n')  # Use \n to preserve line endings

Write-Host "Original file: $($lines.Count) lines"

# Define ranges to remove (inclusive start, inclusive end)
# These are 0-indexed line numbers
$rangesToRemove = @(
    @{ Start = 7247; End = 10055; Name = "English duplicate (Account settings)" },
    @{ Start = 12196; End = 15015; Name = "Portuguese duplicate (Account settings)" },
    @{ Start = 17174; End = 20049; Name = "French duplicate (Account settings)" },
    @{ Start = 23704; End = -1; Name = "Italian duplicate (Privacy & security to end)" }
)

# Sort ranges in reverse order so we can remove from end to start (prevents line number shifting)
$rangesToRemove = $rangesToRemove | Sort-Object { $_.Start } -Descending

foreach ($range in $rangesToRemove) {
    $startLine = $range.Start
    $endLine = $range.End
    
    if ($endLine -eq -1) {
        $endLine = $lines.Count - 1
    }
    
    # Verify we're removing the right content
    Write-Host "Removing $($range.Name): lines $startLine-$endLine"
    Write-Host "  First line: $($lines[$startLine].Substring(0, [Math]::Min(60, $lines[$startLine].Length)))"
    Write-Host "  Last line: $($lines[$endLine].Substring(0, [Math]::Min(60, $lines[$endLine].Length)))"
    
    # Remove the range
    $lines = $lines[0..($startLine-1)] + $lines[($endLine+1)..($lines.Count-1)]
    Write-Host "  After removal: $($lines.Count) lines"
}

# Write back
$content = $lines -join "`n"
Set-Content $filePath $content -NoNewline

Write-Host "File cleaned! New size: $((Get-Content $filePath -Raw).Split("`n").Count) lines"
Write-Host "Backup saved to: $backupPath"
