# STAGE 0: ENVIRONMENT AUDIT REPORT

**Date:** November 11, 2026  
**Auditor:** Principal Flutter/Dart Engineer & Release Gatekeeper  
**Branch:** `cert-audit` (Isolated snapshot of applied production fixes)  
**Workspace:** `/Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder`

---

## 1. Toolchain & Runtime Versions
- **Flutter Version:** Flutter 3.44.5 (channel `stable`, git hash `f94f4fc76b`, 2026-07-06)
- **Dart Version:** Dart 3.12.2
- **DevTools Version:** DevTools 2.57.0
- **Android SDK:** Version 37.0.0 (API 35/36/37 toolchains available) at `/Users/sopanvijaypatil/Library/Android/sdk`
- **Host OS:** macOS 27.0.1 darwin-arm64 (Apple Silicon)
- **Pubspec SDK Constraint:** `sdk: ^3.12.2` (Strict null-safety enabled)

### Google Play Toolchain Readiness:
- **PASS (Confidence: High):** Flutter 3.44.5 and Dart 3.12.2 exceed Google Play's baseline Flutter runtime requirements.
- **PASS (Confidence: High):** Android build toolchain configures `compileSdk = 35` and `targetSdk = 35` (Android 15), satisfying Google Play's target API level requirements.

---

## 2. Architecture & Package Stack Detection
- **State Management:** `StatefulWidget` / `setState` combined with `ChangeNotifier` (`ThemeController`) and static persistence controller (`UserShaderStore`).
- **Navigation:** Imperative Flutter Navigator 1.0 (`Navigator.push`, `Navigator.pop`) with modal sheets (`showModalBottomSheet`, `showDialog`) and `PopScope` navigation guards.
- **Backend / Cloud Services:** 100% Client-Side Offline. No Firebase, AWS, Supabase, or REST backends.
- **Local Storage:** Filesystem JSON indexing (`shaders_manifest.json`) and raw `.mcpack` files in `getApplicationDocumentsDirectory()`, plus `shared_preferences: ^2.5.6` for user preferences.
- **Game Engine / Rendering:** Custom Canvas / CustomPainter (`CustomPaint`, `_PixelatedCardPainter`, `_PixelatedBorderPainter`, `_PixelatedClipper`, and procedural Minecraft landscape scene painters). Does not use Flame.
- **Ads / Analytics / Crash Telemetry:** None currently integrated (zero third-party trackers, zero ads).
- **Background Concurrency:** Multi-threaded worker isolates using `compute(_decodeZipBytesWorker)` and `compute(_encodeZipArchiveWorker)`.

---

## 3. Execution Capabilities & Test Environment
- **Available Executables in this Environment:**
  - `flutter analyze` & `dart analyze`: Verified available.
  - `flutter test` & `flutter test --coverage`: Verified available.
  - `flutter build appbundle --release`: Verified available.
  - `flutter build apk --release --analyze-size`: Verified available.
  - `dart format` & `dart fix`: Verified available.
- **Connected Devices / Emulators:**
  - `macOS (desktop)` • macos • darwin-arm64
  - `Chrome (web)` • chrome • web-javascript
  - `Android Emulator / Physical Device`: **NONE AVAILABLE** (`flutter emulators` returned 0 emulators; `adb devices` found 0 connected devices).
- **Execution Limitation Impact:**
  - All real-device / real-emulator measurements (exact 60fps frame drops, cold-start milliseconds, GPU memory allocation under live rendering, system font scale visual clipping) cannot be run on a physical Android handset in this terminal session and are strictly marked **UNVERIFIED**. Exact step-by-step physical test plans are documented in `/audit/MANUAL_TEST_CHECKLIST.md`.

