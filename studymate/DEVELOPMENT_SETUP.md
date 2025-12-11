# StudyMate Development Environment Setup

## 🎯 Purpose

This guide ensures all team members have a consistent, stable development environment to minimize version conflicts and build errors.

---

## 📋 Prerequisites

### Required Versions

- **Flutter**: 3.5.3 or higher
- **Dart SDK**: 3.5.3 (comes with Flutter)
- **Android Studio**: Latest stable version
- **Java/JDK**: 17 or higher
- **Gradle**: 8.11.1 (handled by wrapper)
- **Android Gradle Plugin**: 8.9.1
- **Kotlin**: 2.1.0
- **Git**: Latest version

### Check Your Versions

```bash
flutter --version
java -version
git --version
```

---

## 🚀 Initial Setup (First Time Only)

### 1. Clone and Setup

```bash
git clone https://github.com/Omarashraf-0-0/Simi-Final-Project-.git
cd Simi-Final-Project-/studymate
flutter pub get
```

### 2. Configure Firebase

- Download `google-services.json` from Firebase Console
- Place in `android/app/` directory
- **DO NOT commit this file** (already in .gitignore)

### 3. Run Initial Build

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🔧 Daily Development Workflow

### Before Starting Work

```bash
# Pull latest changes
git pull origin main

# Clean and update dependencies
flutter clean
flutter pub get

# Run the app
flutter run
```

### Before Committing

```bash
# Format code
dart format .

# Run basic checks
flutter analyze

# Test build
flutter build apk --debug
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: "AssetManifest.json not found"

**Solution:**

```bash
flutter clean
flutter pub get
# Stop app completely and run again (not hot reload)
flutter run
```

### Issue 2: Gradle version conflicts

**Solution:**

- Never modify `android/build.gradle`, `android/settings.gradle`, or `android/app/build.gradle` manually
- If you see version errors, run:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue 3: Asset path errors

**Solution:**

- Assets are in `assets/` directory (not `lib/assets/`)
- Use paths like: `'assets/img/image.png'`
- Never use `'lib/assets/img/image.png'`

### Issue 4: Package version conflicts

**Solution:**

```bash
flutter pub upgrade
flutter pub get
```

---

## 📁 File Structure

```
studymate/
├── android/              # Android native code (rarely modified)
├── ios/                  # iOS native code (rarely modified)
├── lib/
│   ├── main.dart         # App entry point
│   ├── router/           # Navigation configuration
│   ├── pages/            # All screens
│   ├── Pop-ups/          # Dialog components
│   ├── util/             # Utilities and helpers
│   └── Classes/          # Data models
├── assets/
│   ├── img/              # Image files
│   ├── animations/       # Lottie animations
│   └── fonts/            # Custom fonts
├── pubspec.yaml          # Dependencies (can modify)
└── .gitignore            # Ignored files
```

---

## 🚫 Files to NEVER Commit

These are already in `.gitignore`, but be aware:

- `pubspec.lock` (each dev generates their own)
- `android/local.properties`
- `android/.gradle/`
- `android/app/*.jks`
- `build/` directories
- `.dart_tool/`
- `google-services.json`
- `firebase_options.dart`
- Any `.iml` files

---

## 🔒 Version Lock Strategy

### pubspec.yaml Philosophy

We use `any` for most packages to allow flexibility, but lock critical ones:

- `syncfusion_flutter_pdfviewer: ^28.1.38` (specific version)
- SDK: `^3.5.3` (minimum version)

### Why This Works

- Flutter resolves compatible versions automatically
- Reduces merge conflicts in `pubspec.lock`
- Team members can have slightly different patch versions
- Critical packages are locked to prevent breaking changes

---

## 🛠️ Team Guidelines

### 1. Before Modifying Dependencies

- Discuss with team
- Test on your machine first
- Document the change

### 2. Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and test
flutter run
flutter analyze

# Commit with clear messages
git add .
git commit -m "feat: add notification feature"

# Push to your branch
git push origin feature/your-feature-name

# Create Pull Request on GitHub
```

### 3. Handling Merge Conflicts

If you get merge conflicts:

```bash
# Pull latest changes
git pull origin main

# If conflicts in build files:
flutter clean
flutter pub get

# If conflicts in code:
# Resolve manually, then:
git add .
git commit -m "chore: resolve merge conflicts"
```

### 4. After Pulling Changes

**Always run:**

```bash
flutter clean
flutter pub get
```

Then **fully restart** the app (not hot reload).

---

## 🐛 Debugging Checklist

When you encounter build errors:

1. ✅ Run `flutter clean && flutter pub get`
2. ✅ Stop app completely (not hot reload)
3. ✅ Check Flutter version: `flutter --version`
4. ✅ Check for Git conflicts: `git status`
5. ✅ Verify assets exist in `assets/` directory
6. ✅ Check Android Studio SDK is updated
7. ✅ Clear Gradle cache: `cd android && ./gradlew clean`
8. ✅ Restart Android Studio/VS Code
9. ✅ If all fails, ask team for help!

---

## 📱 Running on Different Platforms

### Android Emulator

```bash
flutter emulators
flutter emulators --launch <emulator_id>
flutter run
```

### Physical Device

1. Enable USB Debugging on device
2. Connect via USB
3. `flutter devices`
4. `flutter run`

---

## 🔄 Keeping Environment Clean

### Weekly Maintenance

```bash
# Clean Flutter cache
flutter clean

# Update Flutter (if team agrees)
flutter upgrade

# Clean Android cache
cd android && ./gradlew clean && cd ..

# Remove old build artifacts
rm -rf build/
```

### If Everything Breaks

```bash
# Nuclear option - fresh start
flutter clean
rm -rf build/
rm -rf android/.gradle/
rm -rf android/app/build/
rm pubspec.lock
flutter pub get
```

---

## 👥 Team Communication

### Before Changing These Files, Notify Team:

- `pubspec.yaml` (dependencies)
- `android/build.gradle`
- `android/settings.gradle`
- `android/app/build.gradle`
- `gradle-wrapper.properties`
- Asset structure

### Use Git Commit Messages:

- `feat:` - New feature
- `fix:` - Bug fix
- `chore:` - Maintenance (dependencies, cleanup)
- `docs:` - Documentation only
- `refactor:` - Code restructuring
- `style:` - Formatting, no code change

---

## 📞 Getting Help

1. Check this guide first
2. Check error in `error_logs/` directory
3. Search error message online
4. Ask team in group chat
5. Create GitHub issue with:
   - Error message
   - Steps to reproduce
   - Your environment (`flutter doctor -v`)

---

## ✅ Success Checklist

Your environment is stable when:

- [ ] `flutter doctor` shows no errors
- [ ] `flutter run` builds without errors
- [ ] Hot reload works
- [ ] Assets load correctly
- [ ] No Git conflicts on pull
- [ ] Tests pass (when we add them)

---

**Last Updated**: December 11, 2025  
**Maintained By**: Development Team
