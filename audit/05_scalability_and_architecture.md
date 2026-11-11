# STAGE 5: SCALABILITY AND ARCHITECTURE CERTIFICATION

**Date:** November 11, 2026  
**Auditor:** Principal Flutter/Dart Engineer & System Architect  
**Branch:** `cert-audit`

---

## 1. Architectural Layering & Code Health
- **Presentation Layer:** Rich CustomPainter canvases, Material 3 theming, and responsive UI controls.
- **Business Logic / Domain Layer:** Immutable `ShaderPresetConfig` models, `UserShaderItem` entities, and Bedrock JSON schema builders.
- **Data & Storage Layer:** Decoupled `UserShaderStore` with disk manifest indexing and `io_real.dart` / `io_stub.dart` abstraction for cross-platform file operations.
- **God Class / Technical Debt:**
  - `lib/new_ui.dart` spans 9,392 lines. While isolate workers and storage logic are extracted into standalone functions, the editor state class (`_ShaderEditorScreenState`) manages ~40 state variables and procedural canvas delegates.
  - **Maintainability Risk:** **Medium.** Merging large feature updates risks editor regressions unless decomposed into `features/editor/`, `features/canvas/`, and `features/compiler/` in a future refactor.

---

## 2. Scalability & Operational Cost Projection

Because Piglix Shader Builder is engineered as a **100% Client-Side Offline Utility**:

| Active User Base | Cloud Backend Server Cost | Database / Bandwidth Cost | Client Storage Footprint | What Breaks First? |
|---|:---:|:---:|:---:|---|
| **10,000 Users** | **\$0.00 / mo** | **\$0.00 / mo** | ~25 MB APK + ~6 MB / saved pack | Nothing. Completely decentralized. |
| **100,000 Users** | **\$0.00 / mo** | **\$0.00 / mo** | Local device documents folder | Heavy users accumulating 100+ `.mcpack` files in eager ListView. |
| **1,000,000 Users** | **\$0.00 / mo** | **\$0.00 / mo** | Local device documents folder | Users on low-storage devices (< 1GB free) running out of device storage. |

*All cost figures are verified estimates based on 0 server dependencies.*

---

## 3. Release Safety, Telemetry & Observability
1. **Crash Reporting:**
   - **Current State:** No Crashlytics or Sentry SDK integrated.
   - **Risk:** If an Adreno or Mali GPU driver crashes when rendering procedural shaders on specific Android hardware, no stack trace or alert is generated.
   - **Recommendation:** Integrate `firebase_crashlytics` with automatic de-obfuscation symbol upload.
2. **Staged Rollout Strategy:**
   - For Google Play submission, recommend a 4-phase staged rollout:
     - Day 1: 10% rollout (Monitor crash rate and ANR rate in Android Vitals).
     - Day 3: 25% rollout.
     - Day 5: 50% rollout.
     - Day 7: 100% full release.
3. **CI/CD Automation:**
   - [`.github/workflows/ci.yml`](file:///Users/sopanvijaypatil/Downloads/Newb_X_Pink_Atmosphere_android/.github/workflows/ci.yml) automates linting, test execution, and APK build checks on every push to `main`.

