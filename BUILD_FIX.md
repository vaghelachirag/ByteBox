# Fix for Unicode Codepoint Error

## Problem
When building your Flutter app, you're encountering this error:
```
The value '0' (0) could not be parsed as a valid unicode codepoint; aborting.
```

## Root Cause
The `iconsax` package (version 0.0.8) contains an invalid Unicode codepoint (0) in its font configuration. Flutter's font subsetting tool rejects this during the build process.

## Solution

### Option 1: Use the Build Script (Recommended)
Use the provided `build_without_tree_shake.bat` script:

```bash
# For Android APK
build_without_tree_shake.bat apk

# For Android App Bundle
build_without_tree_shake.bat appbundle

# For iOS
build_without_tree_shake.bat ios

# For Web
build_without_tree_shake.bat web
```

### Option 2: Manual Build Command
Add the `--no-tree-shake-icons` flag to your build commands:

```bash
# Android APK
flutter build apk --no-tree-shake-icons

# Android App Bundle
flutter build appbundle --no-tree-shake-icons

# iOS
flutter build ios --no-tree-shake-icons

# Web
flutter build web --no-tree-shake-icons
```

### Option 3: IDE Configuration
If you're using an IDE like Android Studio or VS Code:

1. **Android Studio**: 
   - Go to Run → Edit Configurations
   - Add `--no-tree-shake-icons` to the "Additional run args" field

2. **VS Code**:
   - Edit `.vscode/launch.json` and add the flag to your build configuration

## Trade-offs

**Pros:**
- ✅ Fixes the build error immediately
- ✅ Allows your app to build successfully

**Cons:**
- ⚠️ Increases app size (all icons are included, not just used ones)
- ⚠️ This is a workaround, not a permanent fix

## Long-term Solution

Monitor the `iconsax` package for updates. When a newer version fixes this issue, you can:
1. Update the package: `flutter pub upgrade iconsax`
2. Remove the `--no-tree-shake-icons` flag
3. Rebuild your app

## Alternative: Replace iconsax

If the package size increase is a concern, consider:
- Using Material Icons or Cupertino Icons instead
- Finding an alternative icon package
- Using SVG icons with `flutter_svg`

