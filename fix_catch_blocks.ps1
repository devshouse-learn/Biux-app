#!/usr/bin/env pwsh

param(
    [string]$RootPath = ".",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Continue"

# Function to fix catch blocks in a file
function Fix-CatchBlocks {
    param(
        [string]$FilePath
    )

    try {
        $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
        $originalContent = $content

        # Pattern 1: catch (e) { rethrow; } - remove entire block
        $content = [System.Text.RegularExpressions.Regex]::Replace(
            $content,
            "}\s*catch\s*\(\s*e\s*\)\s*\{\s*rethrow\s*;\s*\}",
            "}"
        )

        # Pattern 2: catch (e) { } - remove empty blocks
        $content = [System.Text.RegularExpressions.Regex]::Replace(
            $content,
            "}\s*catch\s*\(\s*e\s*\)\s*\{\s*\}",
            "}"
        )

        # Pattern 3: catch (e) { ...any logic without using e... } -> on Exception {
        # Match: catch (e) { ... } where ... doesn't contain 'e' or only contains comments/whitespace
        $catchPattern = "catch\s*\(\s*e\s*\)\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}"
        $matches = [System.Text.RegularExpressions.Regex]::Matches($content, $catchPattern)

        foreach ($match in $matches) {
            $blockContent = $match.Groups[1].Value

            # Check if 'e' is used in the block (not in comments/strings)
            $eUsed = $false

            # Simple heuristic: if 'e' appears outside of strings and comments
            $lines = $blockContent -split "`n"
            foreach ($line in $lines) {
                # Remove comments
                $lineWithoutComments = $line -replace "//.*$", ""
                # Remove strings
                $lineWithoutStrings = $lineWithoutComments -replace "'[^']*'", "" -replace '"[^"]*"', ""

                if ($lineWithoutStrings -match "\be\b") {
                    $eUsed = $true
                    break
                }
            }

            # If 'e' not used and block has logic, replace with on Exception
            if (-not $eUsed -and $blockContent.Trim() -notmatch "^\s*$") {
                $replacement = "on Exception {$($match.Groups[1].Value)}"
                $content = $content.Replace($match.Value, $replacement)
            }
        }

        # Write back if changed
        if ($content -ne $originalContent) {
            if (-not $DryRun) {
                [System.IO.File]::WriteAllText($FilePath, $content, [System.Text.Encoding]::UTF8)
            }
            return $true
        }

        return $false
    }
    catch {
        Write-Host "Error processing $FilePath : $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "Starting catch block cleanup..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "Running in DRY-RUN mode (no changes will be made)" -ForegroundColor Yellow
}

$dartFiles = Get-ChildItem -Path $RootPath -Filter "*.dart" -Recurse -ErrorAction SilentlyContinue
$filesModified = 0
$filesProcessed = 0

foreach ($file in $dartFiles) {
    $filesProcessed++

    # Skip .dart_tool and build directories
    if ($file.FullName -match "\.dart_tool|build[/\\]") {
        continue
    }

    if (Fix-CatchBlocks -FilePath $file.FullName) {
        $filesModified++
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor White
Write-Host "Files modified: $filesModified" -ForegroundColor Green

if ($DryRun) {
    Write-Host "`nTo apply changes, run: .\fix_catch_blocks.ps1 -RootPath '.' -DryRun `$false" -ForegroundColor Yellow
}
