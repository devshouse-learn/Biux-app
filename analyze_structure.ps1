# Improved script to remove duplicate translation blocks
$filePath = "lib/core/config/app_translations.dart"
$backupPath = "lib/core/config/app_translations.dart.backup2"

# Create second backup
Copy-Item $filePath $backupPath

# Read all content
$content = Get-Content $filePath -Raw
$lines = $content -split '\r?\n'

Write-Host "Original file: $($lines.Count) lines"

# Find each language section start
$sectionStarts = @{}
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match 'static const Map<String, String> _(\w+) = \{') {
        $lang = $matches[1]
        $sectionStarts[$lang] = $i
        Write-Host "Found $lang section at line $($i+1)"
    }
}

# Define duplicate ranges to remove (these are 0-indexed)
# Based on the error output, we know duplicates start around line 7258 in _en section
$toRemove = @()

# Find where duplicates are by looking for content that appears multiple times
# For now, use specific line ranges based on previous analysis

# Check English section
$enStart = $sectionStarts['en']  # Around line 5118
$ptStart = $sectionStarts['pt']  # Around line 10058

# The duplicate likely starts somewhere between these
# Look for "    // Account settings screen" or "    // Profile" patterns
for ($i = $enStart; $i -lt $ptStart; $i++) {
    $line = $lines[$i]
    
    # Look for second occurrence of comments that mark new blocks
    if ($line -match "^\s*//\s*(Account|Profile|whatsapp)" -and $i -gt ($enStart + 2000)) {
        Write-Host "Possible duplicate block marker at line $($i+1): $line"
    }
}

# Strategy: Look for repeated patterns within English section
# Count how many times 'not_linked' appears in English section (should be 1, will be 2 if there's a duplicate)
$notLinkedCount = 0
$notLinkedLines = @()
for ($i = $enStart; $i -lt $ptStart; $i++) {
    if ($lines[$i] -like "*'not_linked'*") {
        $notLinkedCount++
        $notLinkedLines += $i
        Write-Host "Found 'not_linked' at line $($i+1)"
    }
}

if ($notLinkedCount -gt 1) {
    # There are duplicates in English section
    Write-Host "Found $notLinkedCount occurrences of 'not_linked' in English section"
    Write-Host "Duplicate block appears to start at line $($notLinkedLines[1]+1)"
}
