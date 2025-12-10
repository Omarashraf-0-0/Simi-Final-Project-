# 🚀 StudyMate Quick Reference

## Daily Commands

```bash
# Start of day
git pull origin main
flutter clean && flutter pub get
flutter run

# Before committing
flutter analyze
./pre-commit-check.ps1
git add .
git commit -m "feat: your message"
git push

# When errors occur
./check_environment.ps1

# Nuclear option (if everything breaks)
flutter clean
rm -rf android/.gradle
flutter pub get
```

## Common Errors & Instant Fixes

| Error | Fix |
|-------|-----|
| AssetManifest.json not found | `flutter clean && flutter pub get`, then **full restart** |
| Gradle version mismatch | `cd android && ./gradlew clean && cd ..` |
| Asset path errors | Use `assets/img/file.png` not `lib/assets/` |
| Package conflicts | `flutter pub upgrade` |
| Build fails after pull | `flutter clean && flutter pub get` |
| Hot reload not working | **Stop and restart** (don't hot reload) |

## File Reference

| File | Edit? | Why |
|------|-------|-----|
| `lib/**/*.dart` | ✅ Yes | Your code |
| `assets/**` | ✅ Yes | Your assets |
| `pubspec.yaml` | ⚠️ Discuss first | Dependencies |
| `android/settings.gradle` | ❌ No | Version locked |
| `android/build.gradle` | ❌ No | Version locked |
| `pubspec.lock` | ❌ Never | Auto-generated |

## Asset Paths (IMPORTANT!)

```dart
// ✅ CORRECT
Image.asset('assets/img/logo.png')
Lottie.asset('assets/animations/success.json')

// ❌ WRONG
Image.asset('lib/assets/img/logo.png')  // Will fail!
```

## Version Numbers (DO NOT CHANGE)

- Flutter SDK: `^3.5.3`
- Android Gradle Plugin: `8.9.1`
- Kotlin: `2.1.0`
- Gradle: `8.11.1`

## Scripts

- `./check_environment.ps1` - Health check
- `./cleanup_git.ps1` - Remove ignored files from Git
- `./pre-commit-check.ps1` - Pre-commit validation

## Help Resources

1. Check `DEVELOPMENT_SETUP.md`
2. Check `VERSION_MANAGEMENT.md`
3. Run `./check_environment.ps1`
4. Ask in team chat
