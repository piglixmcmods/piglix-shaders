# STAGE 1: VERIFICATION OF PREVIOUS FIXES AND REGRESSION AUDIT

**Date:** November 11, 2026  
**Auditor:** Principal Flutter/Dart Engineer & Release Gatekeeper  
**Branch:** `cert-audit` compared against `main` (commit `845fa3ed91d30909b46f7898838215e15014be8b`)

---

## 1. Previous Fixes Verification Matrix

Every finding previously documented in `AUDIT_REPORT.md` has been independently checked against the codebase on branch `cert-audit`:

| ID | Category | Previous Issue | Status | Evidence & Verification Detail |
|---|---|---|:---:|---|
| **AUD-01** | Stability | No `PopScope` / unsaved edits dialog in `ShaderEditorScreen`. | **FIXED** (High Confidence) | [`lib/new_ui.dart:8006`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L8006): `PopScope(canPop: false, onPopInvokedWithResult: ...)` intercepts system gestures and back buttons with `_confirmDiscardEdits()`. |
| **AUD-02** | Compliance | Unverified `Minecraft.otf` font bundled in assets. | **FIXED** (High Confidence) | `git diff main..cert-audit`: File `assets/fonts/Minecraft.otf` deleted. Removed from `pubspec.yaml`. App standardized on SIL OFL-licensed `PixelifySans`. |
| **AUD-03** | Security | Plaintext passwords in `key.properties`. | **FIXED** (High Confidence) | [`android/app/build.gradle.kts:8-45`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/android/app/build.gradle.kts#L8-L45): Prioritizes `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, etc., via `System.getenv()`. `key.properties` ignored in `.gitignore`. |
| **AUD-04** | Telemetry | Zero crash telemetry SDKs integrated. | **NOT FIXED (DEFERRED)** (High Confidence) | No Firebase Crashlytics or Sentry SDK present in `pubspec.yaml`. Operational prerequisite for user to connect Firebase Console. |
| **AUD-05** | UX | Missing Minecraft Deferred Technical Preview activation guide. | **FIXED** (High Confidence) | [`lib/new_ui.dart:7839`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L7839): `_showActivationGuide()` bottom sheet details 3-step setup and is wired to `AppBar.actions` help icon (`Icons.help_outline_rounded`). |
| **AUD-06** | Architecture | Monolithic 9,239-line file (`lib/new_ui.dart`). | **PARTIALLY FIXED** (Medium Confidence) | Background zip compression offloaded to isolates; persistent storage extracted to `UserShaderStore`. Core editor UI still resides in single monolithic file. |
| **AUD-07** | Performance | Unconstrained infinite pulse animation on home screen. | **FIXED** (High Confidence) | [`lib/new_ui.dart:188-197`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L188-L197): `WidgetsBindingObserver` stops `_pulseCtrl` on `AppLifecycleState.paused/inactive` and resumes on `resumed`. |
| **AUD-08** | Build | `file_saver: ^0.4.0` legacy Kotlin Gradle Plugin warning. | **FIXED** (High Confidence) | [`pubspec.yaml:40`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/pubspec.yaml#L40): Upgraded to `file_saver: ^0.7.0` with `meta: 1.18.0` dependency override. Compiles cleanly. |
| **AUD-09** | Stability | Storage full exception handling during pack export. | **FIXED** (High Confidence) | [`lib/new_ui.dart:9157-9173`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L9157-L9173): `try/catch` fallbacks to native storage directory with user-facing error snackbars. |
| **AUD-101** | Store | Missing publicly hosted Privacy Policy URL. | **PARTIALLY FIXED** (High Confidence) | `docs/index.html` and `privacy_policy_web/index.html` created locally with full COPPA/Families compliance. Awaiting user publishing to GitHub Pages or custom domain. |
| **AUD-102** | Store | Missing Google Play Store marketing graphics (512x512 icon, 1024x500 banner, screenshots). | **NOT FIXED (USER ACTION)** | Must be uploaded directly to Google Play Console by the publisher. |
| **AUD-105** | Stability | Corrupted `shaders_manifest.json` recovery gap. | **FIXED** (High Confidence) | [`lib/my_shaders_screen.dart:104-145`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/my_shaders_screen.dart#L104-L145): `_repairManifestFromDisk()` catches `FormatException`, scans disk via `listNativePacks()`, recovers `.mcpack` files, and re-seeds default template. |
| **AUD-106** | Code Quality | 26 silent empty catch blocks (`catch (_) {}`). | **FIXED** (High Confidence) | Replaced silent catches in filesystem, manifest, and store operations with `debugPrint('[Piglix] ...')` diagnostics. |
| **AUD-107** | Performance | Synchronous disk reading on UI thread during tile rendering. | **FIXED** (High Confidence) | [`lib/my_shaders_screen.dart:40-49`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/my_shaders_screen.dart#L40-L49): Added non-blocking `loadBytes() async` with cached in-memory buffer. |
| **AUD-108** | UX | Missing first-run onboarding walkthrough. | **FIXED** (High Confidence) | [`lib/new_ui.dart:175-265`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L175-L265): `_showWelcomeOnboardingSheet()` bottom sheet triggers on initial launch using `SharedPreferences`. |
| **AUD-110** | CI/CD | Missing automated CI/CD pipeline. | **FIXED** (High Confidence) | [`.github/workflows/ci.yml`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/.github/workflows/ci.yml): Automated workflow runs analyzer, test suites, and APK builds on push/PR. |
| **AUD-111** | Memory | Undisposed modal dialog text controllers. | **FIXED** (High Confidence) | [`lib/new_ui.dart:5471`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L5471) & [`line 6038`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/piglix_shader_builder/lib/new_ui.dart#L6038): Controllers `renameCtrl` and `hexCtrl` disposed via `.then((_) => ctrl.dispose())`. |

---

## 2. Regression Hunt (Review of All Git Diffs)
- **Null Safety:** Verified all newly added methods (`listNativePacks`, `loadBytes`, `_repairManifestFromDisk`) check for null returns and empty lists before iteration.
- **Removed Code:** Deletion of unused backup assets (`base_shader_6mb_backup.zip`, 12 unused JPG backgrounds) and byte data files (`sunset_banner_data.dart`, `water_lake_banner_data.dart`) verified to have ZERO references in Dart code.
- **UI Isolate Concurrency:** Both zip decoding and encoding remain strictly isolated in top-level functions `_decodeZipBytesWorker` and `_encodeZipArchiveWorker`.
- **Verdict for Stage 1:** **PASS (Confidence: High).** No code regressions, logic breakages, or unhandled exceptions introduced by recent remediation batches.

