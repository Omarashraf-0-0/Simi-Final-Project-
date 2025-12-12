# Modern Popup System - Usage Guide

## Overview
نظام Pop-ups محسّن ومتناسق مع ثيم التطبيق. يدعم:
- ✅ Success Popups
- ❌ Error Popups
- ⚠️ Warning Popups
- ℹ️ Info Popups
- ❓ Confirmation Popups
- ⏳ Loading Popups

## Import
```dart
import 'package:studymate/Pop-ups/ModernPopup.dart';
```

## Usage Examples

### 1. Success Popup
```dart
ModernPopup.showSuccess(
  context: context,
  title: 'Success!',
  message: 'Your CV has been generated successfully.',
  buttonText: 'Great!', // Optional
  onConfirm: () {
    // Do something after user clicks button
    print('User confirmed success');
  },
);
```

### 2. Error Popup
```dart
ModernPopup.showError(
  context: context,
  title: 'Error!',
  message: 'Failed to load data. Please try again.',
  buttonText: 'OK', // Optional
  onConfirm: () {
    // Handle error confirmation
  },
);
```

### 3. Warning Popup
```dart
ModernPopup.showWarning(
  context: context,
  title: 'Warning!',
  message: 'This action cannot be undone.',
  buttonText: 'Understood', // Optional
);
```

### 4. Info Popup
```dart
ModernPopup.showInfo(
  context: context,
  title: 'Information',
  message: 'Your quiz will expire in 30 minutes.',
  buttonText: 'Got it', // Optional
);
```

### 5. Confirmation Popup (with Yes/No)
```dart
final bool? confirmed = await ModernPopup.showConfirmation(
  context: context,
  title: 'Delete Item?',
  message: 'Are you sure you want to delete this item? This action cannot be undone.',
  confirmText: 'Delete', // Optional
  cancelText: 'Cancel', // Optional
  isDangerous: true, // Makes button red for dangerous actions
);

if (confirmed == true) {
  // User clicked confirm
  print('Item deleted');
} else {
  // User clicked cancel or dismissed
  print('Deletion cancelled');
}
```

### 6. Loading Popup
```dart
// Show loading
ModernPopup.showLoading(
  context: context,
  message: 'Generating PDF...', // Optional
);

// Do async work
await generatePDF();

// Close loading
Navigator.of(context).pop();
```

## Replace Old Popups

### Old Code (SuccessPopUp):
```dart
showDialog(
  context: context,
  builder: (context) => DonePopUp(
    title: 'Success',
    description: 'Done successfully',
    color: Color(0xff3BBD5E),
  ),
);
```

### New Code:
```dart
ModernPopup.showSuccess(
  context: context,
  title: 'Success',
  message: 'Done successfully',
);
```

### Old Code (AlertDialog):
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Error'),
    content: Text('Something went wrong'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);
```

### New Code:
```dart
ModernPopup.showError(
  context: context,
  title: 'Error',
  message: 'Something went wrong',
);
```

## Features
- 🎨 **Themed**: Automatically adapts to light/dark theme
- 🎭 **Consistent**: Same design across the entire app
- 🌈 **Gradient Backgrounds**: Beautiful gradient headers
- 🎬 **Animations**: Smooth animations (Lottie support for success)
- 📱 **Responsive**: Works on all screen sizes
- ♿ **Accessible**: Supports screen readers and accessibility

## Color Scheme
- **Primary**: `#1c74bb` (Bright Blue)
- **Secondary**: `#165d96` (Medium Blue)
- **Accent**: `#18bebc` (Turquoise)
- **Success**: `#10B981` (Green)
- **Error**: `#EF4444` (Red)
- **Warning**: `#F59E0B` (Orange)
- **Info**: `#3B82F6` (Blue)

## Migration Guide

تحتاج لاستبدال جميع استخدامات:
1. `DonePopUp` → `ModernPopup.showSuccess()`
2. `AlertDialog` البسيطة → `ModernPopup.showError()` أو غيرها
3. Confirmation dialogs → `ModernPopup.showConfirmation()`
4. Loading indicators → `ModernPopup.showLoading()`

## Notes
- كل الـ Popups تدعم الـ dismissible بالضغط خارج الـ Dialog
- الـ Confirmation popup تعيد `bool?` (true/false/null)
- Loading popup يحتاج `Navigator.pop()` يدوي بعد انتهاء العملية
