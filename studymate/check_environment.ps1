#!/usr/bin/env pwsh
# StudyMate Environment Health Check & Auto-Fix Script
# Run this whenever you encounter build issues or after pulling changes

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  StudyMate Environment Health Check" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

$hasIssues = $false

# Check 1: Flutter Installation
Write-Host "[1/8] Checking Flutter installation..." -ForegroundColor Yellow
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version | Select-String "Flutter" | Out-String
    Write-Host "  ✓ Flutter found: $($flutterVersion.Trim())" -ForegroundColor Green
} else {
    Write-Host "  ✗ Flutter not found in PATH!" -ForegroundColor Red
    $hasIssues = $true
}

# Check 2: Verify we're in correct directory
Write-Host "`n[2/8] Checking project directory..." -ForegroundColor Yellow
if (Test-Path "pubspec.yaml") {
    Write-Host "  ✓ Found pubspec.yaml" -ForegroundColor Green
} else {
    Write-Host "  ✗ Not in Flutter project root! Navigate to studymate folder." -ForegroundColor Red
    exit 1
}

# Check 3: Assets directory structure
Write-Host "`n[3/8] Checking assets directory..." -ForegroundColor Yellow
if ((Test-Path "assets/img") -and (Test-Path "assets/animations")) {
    $imgCount = (Get-ChildItem "assets/img" -File -Recurse).Count
    $animCount = (Get-ChildItem "assets/animations" -File).Count
    Write-Host "  ✓ Assets found: $imgCount images, $animCount animations" -ForegroundColor Green
} else {
    Write-Host "  ✗ Assets directory structure incorrect!" -ForegroundColor Red
    $hasIssues = $true
}

# Check 4: Git status
Write-Host "`n[4/8] Checking Git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain 2>&1
if ($LASTEXITCODE -eq 0) {
    $conflicts = git diff --name-only --diff-filter=U 2>&1
    if ($conflicts) {
        Write-Host "  ✗ Merge conflicts detected in:" -ForegroundColor Red
        $conflicts | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
        $hasIssues = $true
    } else {
        Write-Host "  ✓ No merge conflicts" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ Not a git repository or git not installed" -ForegroundColor Yellow
}

# Check 5: Old lib/assets directory (should not exist)
Write-Host "`n[5/8] Checking for legacy assets..." -ForegroundColor Yellow
if (Test-Path "lib/assets") {
    Write-Host "  ✗ Found lib/assets directory (should not exist!)" -ForegroundColor Red
    Write-Host "    This will cause AssetManifest errors." -ForegroundColor Red
    
    $response = Read-Host "  Remove lib/assets now? (y/n)"
    if ($response -eq 'y') {
        Remove-Item "lib/assets" -Recurse -Force
        Write-Host "  ✓ Removed lib/assets" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ No legacy asset directories" -ForegroundColor Green
}

# Check 6: Android configuration
Write-Host "`n[6/8] Checking Android configuration..." -ForegroundColor Yellow
if (Test-Path "android/settings.gradle") {
    $settingsGradle = Get-Content "android/settings.gradle" -Raw
    if ($settingsGradle -match 'version.*8\.9\.1') {
        Write-Host "  ✓ Android Gradle Plugin version is correct (8.9.1)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Android Gradle Plugin version mismatch" -ForegroundColor Red
        $hasIssues = $true
    }
} else {
    Write-Host "  ✗ Android configuration not found!" -ForegroundColor Red
    $hasIssues = $true
}

# Check 7: Tracked files that shouldn't be
Write-Host "`n[7/8] Checking for incorrectly tracked files..." -ForegroundColor Yellow
$badFiles = @(
    "android/.gradle",
    "android/local.properties",
    "android/app/*.jks",
    "build",
    ".dart_tool"
)
$foundBadFiles = @()
foreach ($pattern in $badFiles) {
    $files = git ls-files $pattern 2>$null
    if ($files) {
        $foundBadFiles += $files
    }
}
if ($foundBadFiles.Count -gt 0) {
    Write-Host "  ⚠ Found tracked files that should be ignored:" -ForegroundColor Yellow
    $foundBadFiles | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
    Write-Host "  Run cleanup_git.ps1 to remove them" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ No incorrectly tracked files" -ForegroundColor Green
}

# Check 8: Dependencies status
Write-Host "`n[8/8] Checking dependencies..." -ForegroundColor Yellow
if (Test-Path ".dart_tool/package_config.json") {
    Write-Host "  ✓ Dependencies appear to be installed" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Dependencies may need installation" -ForegroundColor Yellow
    $hasIssues = $true
}

# Summary and Recommendations
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($hasIssues) {
    Write-Host "⚠ Issues detected! Recommended actions:`n" -ForegroundColor Yellow
    
    Write-Host "1. Clean and reinstall dependencies:" -ForegroundColor White
    Write-Host "   flutter clean" -ForegroundColor Gray
    Write-Host "   flutter pub get`n" -ForegroundColor Gray
    
    Write-Host "2. Clean Android build cache:" -ForegroundColor White
    Write-Host "   cd android" -ForegroundColor Gray
    Write-Host "   ./gradlew clean" -ForegroundColor Gray
    Write-Host "   cd ..`n" -ForegroundColor Gray
    
    Write-Host "3. Fully restart your app (not hot reload)`n" -ForegroundColor White
    
    $autoFix = Read-Host "Run auto-fix now? (y/n)"
    if ($autoFix -eq 'y') {
        Write-Host "`nRunning auto-fix..." -ForegroundColor Cyan
        
        flutter clean
        flutter pub get
        
        if (Test-Path "android") {
            Set-Location android
            ./gradlew clean
            Set-Location ..
        }
        
        Write-Host "`n✓ Auto-fix complete! Try running your app now." -ForegroundColor Green
    }
} else {
    Write-Host "✓ All checks passed! Your environment looks healthy." -ForegroundColor Green
    Write-Host "  If you still have issues, try:" -ForegroundColor White
    Write-Host "  1. Stop the app completely" -ForegroundColor Gray
    Write-Host "  2. Run: flutter clean && flutter pub get" -ForegroundColor Gray
    Write-Host "  3. Restart your app (not hot reload)`n" -ForegroundColor Gray
}

Write-Host "============================================`n" -ForegroundColor Cyan
