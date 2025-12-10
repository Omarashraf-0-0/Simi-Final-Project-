# Flutter Git Cleanup Script
# This script removes files that should be ignored by git but are already tracked

Write-Host "Cleaning up Git tracked files that should be ignored..." -ForegroundColor Cyan

# Remove build artifacts
Write-Host "`nRemoving build artifacts..." -ForegroundColor Yellow
git rm -r --cached build/ 2>$null
git rm -r --cached android/build/ 2>$null
git rm -r --cached android/.gradle/ 2>$null
git rm -r --cached ios/build/ 2>$null
git rm -r --cached macos/build/ 2>$null
git rm -r --cached windows/build/ 2>$null
git rm -r --cached linux/build/ 2>$null

# Remove .dart_tool
Write-Host "Removing .dart_tool..." -ForegroundColor Yellow
git rm -r --cached .dart_tool/ 2>$null

# Remove Flutter plugins files
Write-Host "Removing Flutter plugin files..." -ForegroundColor Yellow
git rm --cached .flutter-plugins 2>$null
git rm --cached .flutter-plugins-dependencies 2>$null
git rm --cached .packages 2>$null

# Remove IDE files
Write-Host "Removing IDE configuration files..." -ForegroundColor Yellow
git rm -r --cached .idea/ 2>$null
git rm -r --cached .vscode/ 2>$null
git rm --cached *.iml 2>$null
git rm --cached studymate.iml 2>$null

# Remove Android specific files
Write-Host "Removing Android specific files..." -ForegroundColor Yellow
git rm --cached android/gradlew 2>$null
git rm --cached android/gradlew.bat 2>$null
git rm --cached android/local.properties 2>$null

# Remove generated files
Write-Host "Removing generated files..." -ForegroundColor Yellow
git rm --cached lib/generated_plugin_registrant.dart 2>$null
git rm --cached windows/flutter/generated_plugin_registrant.cc 2>$null
git rm --cached windows/flutter/generated_plugin_registrant.h 2>$null
git rm --cached windows/flutter/generated_plugins.cmake 2>$null
git rm --cached linux/flutter/generated_plugin_registrant.cc 2>$null
git rm --cached linux/flutter/generated_plugin_registrant.h 2>$null
git rm --cached linux/flutter/generated_plugins.cmake 2>$null
git rm --cached macos/Flutter/GeneratedPluginRegistrant.swift 2>$null

# Remove backup files
Write-Host "Removing backup files..." -ForegroundColor Yellow
git rm -r --cached "Backup files/" 2>$null

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review the changes: git status"
Write-Host "2. Commit the changes: git commit -m 'Remove ignored files from git tracking'"
Write-Host "3. Push to remote: git push"
Write-Host "`nNote: Files will remain on your local disk, they just will not be tracked by git anymore." -ForegroundColor Yellow
