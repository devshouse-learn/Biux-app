# Final cleanup: Remove only the duplicate blocks by line range
$filePath = "lib/core/config/app_translations.dart"
$backupPath = "lib/core/config/app_translations.dart.backup3"

# Create backup
Copy-Item $filePath $backupPath

$lines = @(Get-Content $filePath)
$originalCount = $lines.Count

Write-Host "Original: $originalCount lines"

# Define the exact ranges to remove (these are 1-indexed line numbers from the output)
# Convert to 0-indexed for array operations
$ranges = @(
    @{ Name = "English duplicate block"; StartLine = 7257; EndLine = 10058 },  # 7258-10059 in 1-indexed
    @{ Name = "Portuguese duplicate block"; StartLine = 12196; EndLine = 15000 },  # 12197-15001 in 1-indexed  
    @{ Name = "French duplicate block"; StartLine = 17171; EndLine = 20030 }   # 17172-20031 in 1-indexed
)

# Sort in reverse order to remove from bottom up (to preserve indices)
$ranges = $ranges | Sort-Object { $_.StartLine } -Descending

foreach ($range in $ranges) {
    $startIdx = $range.StartLine - 1  # Convert to 0-indexed
    $endIdx = $range.EndLine - 1      # Convert to 0-indexed
    
    if ($startIdx -ge 0 -and $endIdx -lt $lines.Count -and $startIdx -lt $endIdx) {
        $rangeSize = $endIdx - $startIdx + 1
        Write-Host "Removing $($range.Name): lines $($range.StartLine)-$($range.EndLine) ($rangeSize lines)"
        
        # Remove the range
        if ($startIdx -eq 0) {
            $lines = $lines[($endIdx + 1)..($lines.Count - 1)]
        } elseif ($endIdx -eq $lines.Count - 1) {
            $lines = $lines[0..($startIdx - 1)]
        } else {
            $lines = $lines[0..($startIdx - 1)] + $lines[($endIdx + 1)..($lines.Count - 1)]
        }
        
        Write-Host "  After removal: $($lines.Count) lines"
    } else {
        Write-Host "Warning: Invalid range for $($range.Name): start=$startIdx end=$endIdx count=$($lines.Count)"
    }
}

# Write back
$lines | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline

Write-Host "Final: $($(Get-Content $filePath).Split("`n").Count) lines"
Write-Host "Backup at: $backupPath"
