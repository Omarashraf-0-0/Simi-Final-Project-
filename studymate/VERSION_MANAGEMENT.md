# ⚙️ Version Management Strategy

## 🎯 Problem Statement
After each push, team members encounter:
- Asset loading errors (AssetManifest.json)
- Gradle version conflicts
- Build failures
- Merge conflicts in generated files

## ✅ Solution: Lock Critical Versions

### Versioning Philosophy

We use a **hybrid approach**:
- **Flexible**: Most packages use `any` to avoid conflicts
- **Locked**: Critical infrastructure is version-pinned
- **Documented**: All changes are tracked

---

## 📌 Pinned Versions (DO NOT CHANGE without team approval)

### Flutter/Dart SDK
```yaml
environment:
  sdk: ^3.5.3  # Minimum 3.5.3, allows newer patches
```

### Android Build System
```gradle
# android/settings.gradle
Android Gradle Plugin: 8.9.1
Kotlin: 2.1.0

# android/gradle/wrapper/gradle-wrapper.properties
Gradle: 8.11.1

# android/app/build.gradle
desugar_jdk_libs: 2.1.4
```

### Critical Flutter Packages
```yaml
syncfusion_flutter_pdfviewer: ^28.1.38  # Locked for stability
```

---

## 🔓 Flexible Packages (use `any`)

All other packages use `any` because:
1. **Reduced Conflicts**: No pubspec.lock merge conflicts
2. **Auto-Resolution**: Flutter resolves compatible versions
3. **Team Flexibility**: Everyone can use latest patches
4. **Faster Development**: No version hunting

---

## 🚫 Files to NEVER Manually Edit

### Generated Files (tracked but auto-generated)
- `android/app/.cxx/` - NDK build cache
- `ios/Flutter/Generated.xcconfig`
- `windows/flutter/generated_*`
- `linux/flutter/generated_*`

### Configuration Files (tracked but team-coordinated)
- `android/build.gradle` - Only update via team discussion
- `android/settings.gradle` - Only update via team discussion  
- `android/app/build.gradle` - Only update via team discussion
- `pubspec.yaml` - Coordinate in team chat first

### Never Track These
- `pubspec.lock` - Each developer generates their own
- `android/local.properties` - Machine-specific paths
- `android/.gradle/` - Build cache
- `build/` - Compiled output
- `.dart_tool/` - Dart tooling cache

---

## 📝 Making Dependency Changes

### Adding a New Package

1. **Discuss with team** in group chat
2. **Research compatibility** with Flutter 3.5.3
3. **Add to pubspec.yaml**:
   ```yaml
   new_package: any  # Use 'any' unless specific version needed
   ```
4. **Test locally**:
   ```bash
   flutter pub get
   flutter run
   ```
5. **Commit with clear message**:
   ```bash
   git add pubspec.yaml
   git commit -m "feat: add new_package for feature X"
   ```
6. **Notify team** to run `flutter pub get`

### Updating Existing Package

1. **Check current usage**: Search codebase for package usage
2. **Read changelog**: Check for breaking changes
3. **Update locally and test**:
   ```bash
   flutter pub upgrade package_name
   flutter run
   ```
4. **If it works**, update pubspec.yaml if needed
5. **Commit and notify team**

### Changing Android/Gradle Versions

⚠️ **CRITICAL**: Only do this for important reasons

1. **Create backup**: Copy current working versions
2. **Update version numbers** in:
   - `android/settings.gradle`
   - `android/build.gradle`
   - `android/app/build.gradle`
   - `android/gradle/wrapper/gradle-wrapper.properties`
3. **Test thoroughly**:
   ```bash
   flutter clean
   cd android && ./gradlew clean && cd ..
   flutter pub get
   flutter run
   ```
4. **Document the change** in commit message
5. **Notify team BEFORE pushing**

---

## 🔄 After Someone Pushes Changes

### Standard Update Process
```bash
# 1. Pull changes
git pull origin main

# 2. Check for conflicts
git status

# 3. If no conflicts, update dependencies
flutter clean
flutter pub get

# 4. Run the app (full restart, not hot reload)
flutter run
```

### If You Get Errors
```bash
# Run the environment checker
./check_environment.ps1

# Or manually:
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get

# Fully restart your app (not hot reload!)
```

---

## 🛡️ Prevention Strategies

### Use the Health Check Script
Before starting work each day:
```bash
./check_environment.ps1
```

### Use Pre-Commit Checks
Before committing:
```bash
./pre-commit-check.ps1
```

### Branch Strategy
```bash
# Work on feature branches
git checkout -b feature/your-feature

# Test thoroughly before merging
flutter run
flutter analyze

# Create PR for team review
```

---

## 🔍 Understanding Version Files

### pubspec.yaml
- **Purpose**: Declares dependencies
- **Tracked**: Yes (shared with team)
- **Strategy**: Use `any` for flexibility, lock critical packages

### pubspec.lock
- **Purpose**: Exact resolved versions
- **Tracked**: No (in .gitignore)
- **Strategy**: Each developer generates their own
- **Why**: Prevents merge conflicts, allows patch updates

### android/build.gradle
- **Purpose**: Android build configuration
- **Tracked**: Yes (must be consistent across team)
- **Strategy**: Only update with team coordination

### android/settings.gradle
- **Purpose**: Gradle plugin versions
- **Tracked**: Yes (critical for build consistency)
- **Strategy**: Never change without testing

---

## 📊 Version Compatibility Matrix

| Component | Version | Why |
|-----------|---------|-----|
| Flutter SDK | 3.5.3+ | Latest stable with Dart 3.5.3 |
| Android AGP | 8.9.1 | Required by AndroidX libraries |
| Kotlin | 2.1.0 | Required by Flutter 3.5.3+ |
| Gradle | 8.11.1 | Compatible with AGP 8.9.1 |
| Java/JDK | 17+ | Required by AGP 8.x |
| desugar_jdk_libs | 2.1.4 | Required by notifications package |

---

## 🆘 Emergency Rollback

If a version update breaks everything:

```bash
# 1. Revert the commit
git revert <commit-hash>

# 2. Clean everything
flutter clean
rm -rf android/.gradle
rm -rf android/app/build
rm pubspec.lock

# 3. Reinstall
flutter pub get

# 4. Rebuild
flutter run
```

---

## ✅ Success Indicators

Your version management is working when:
- ✅ Team members can `git pull` without errors
- ✅ `flutter pub get` completes without conflicts
- ✅ App builds on first try after pull
- ✅ No "version mismatch" errors
- ✅ Assets load correctly
- ✅ Hot reload works consistently

---

## 📞 Questions?

- Check `DEVELOPMENT_SETUP.md` first
- Run `./check_environment.ps1` to diagnose
- Ask in team chat with error details
- Include output of `flutter doctor -v`

---

**Remember**: When in doubt, clean and rebuild!
```bash
flutter clean && flutter pub get
```
