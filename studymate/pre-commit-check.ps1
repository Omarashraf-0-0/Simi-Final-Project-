#!/usr/bin/env pwsh
# Pre-commit hook to prevent committing sensitive or generated files
# To install: Copy to .git/hooks/pre-commit and make executable

Write-Host "Running pre-commit checks..." -ForegroundColor Yellow

# Files that should never be committed
$blockedPatterns = @(
    "android/local.properties",
    "android/.gradle",
    "android/app/.cxx",
    "google-services.json",
    "firebase_options.dart",
    "*.jks",
    "*.keystore",
    ".env",
    "*.db"
)

$stagedFiles = git diff --cached --name-only

$blocked = @()
foreach ($file in $stagedFiles) {
    foreach ($pattern in $blockedPatterns) {
        if ($file -like $pattern) {
            $blocked += $file
        }
    }
}

if ($blocked.Count -gt 0) {
    Write-Host "`n✗ ERROR: Attempting to commit sensitive/generated files:" -ForegroundColor Red
    $blocked | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`nThese files should not be committed." -ForegroundColor Red
    Write-Host "Add them to .gitignore or unstage them.`n" -ForegroundColor Yellow
    exit 1
}

# Check if pubspec.yaml was modified
$pubspecChanged = $stagedFiles | Where-Object { $_ -eq "pubspec.yaml" }
if ($pubspecChanged) {
    Write-Host "⚠ pubspec.yaml modified - notify team!" -ForegroundColor Yellow
}

# Check if Android Gradle files were modified
$gradleChanged = $stagedFiles | Where-Object { $_ -match "\.gradle$|gradle-wrapper\.properties$" }
if ($gradleChanged) {
    Write-Host "⚠ Gradle configuration modified:" -ForegroundColor Yellow
    $gradleChanged | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "Make sure team is aware of these changes!`n" -ForegroundColor Yellow
}

Write-Host "✓ Pre-commit checks passed`n" -ForegroundColor Green
exit 0
