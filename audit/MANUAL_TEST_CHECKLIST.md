# MANUAL REAL-DEVICE TEST CHECKLIST (FINAL RELEASE VERIFICATION)

**Application:** Piglix Shader Builder (`com.piglixlabs.shadermakerformcpe`)  
**Purpose:** Independent physical device verification of all items marked **UNVERIFIED** during static certification (framerate, memory soak, touch latency, hardware interruptions, and cold-start timings).

---

## TEST 1: Low-End Android Device Verification (Budget Phone: 2 GB RAM, Android 8–10)
- **Target Device Profile:** e.g., Samsung Galaxy A03/A10, Xiaomi Redmi 9A/Go, or Motorola E-series (Android 8.1–10.0, 2 GB RAM, eMMC 5.1 storage).
- **Execution Steps:**
  1. Install `app-release.apk` directly via `adb install app-release.apk`.
  2. Launch the app from the app drawer while timing with a stopwatch.
  3. Verify that the welcome onboarding bottom sheet appears smoothly.
  4. Tap "START CREATING SHADERS".
  5. Drag the Atmosphere time-of-day slider, Fog Density slider, and Sun Size slider back and forth rapidly for 20 seconds.
  6. Tap "GENERATE SHADER" and observe the compilation modal dialog.
  7. When complete, tap "OPEN WITH MINECRAFT".
- **What to Look For:**
  - First-frame cold start should occur within 2.5–3.5 seconds.
  - No ANR ("Application Not Responding") popups during zip compression.
  - Slider scrubbing should remain responsive without visual stutter.
- **Pass Criteria:**
  - [ ] App launches without black screen hang.
  - [ ] Pack compilation takes < 1.5 seconds.
  - [ ] Android OS intent chooser opens with Minecraft or file manager.

---

## TEST 2: High-End Android Device Verification (Flagship: 90/120 Hz Display, Android 14–15)
- **Target Device Profile:** e.g., Google Pixel 7/8/9, Samsung Galaxy S23/S24, OnePlus 11/12 (120 Hz refresh rate, Android 14 or 15).
- **Execution Steps:**
  1. Install `app-release.apk`.
  2. Open Developer Options on device → Enable "Show refresh rate".
  3. Launch the app and observe the refresh rate counter in the top-left corner.
  4. Scroll through the Home screen presets grid.
  5. Open "Shader Editor" and switch across all 4 tabs (Atmosphere, Lighting, World, Weather).
  6. Observe edge-to-edge rendering: verify bottom bar floats cleanly above Android gesture navigation bar.
- **What to Look For:**
  - UI renders at full 90 Hz / 120 Hz display rate.
  - No clipping or collision with punch-hole cameras, camera notches, or curved screen edges.
- **Pass Criteria:**
  - [ ] Steady 90/120 Hz refresh rate during scrolling and tab transitions.
  - [ ] Bottom action bar clears the home gesture bar with zero overlap.

---

## TEST 3: Hardware & System Interruption Tests
- **Execution Steps:**
  1. While in the Shader Editor modifying parameters, place an incoming phone call to the device.
  2. Answer the call, talk for 10 seconds, then return to Piglix Shader Builder.
  3. Lock the phone screen using the physical power button while compilation is active.
  4. Unlock the phone after 15 seconds.
  5. Swipe the app to the recent apps overview, open a heavy app (e.g. YouTube or Camera), then return.
- **What to Look For:**
  - No crash upon returning to the foreground.
  - Ticker animation resumes without CPU runaways.
  - Parameter values remain exactly where the user set them.
- **Pass Criteria:**
  - [ ] Zero crash logs.
  - [ ] Editor state completely preserved after incoming call and screen lock.

---

## TEST 4: Gesture Navigation & Predictive Back Test (`PopScope`)
- **Execution Steps:**
  1. Open Shader Editor and change the Morning Sun Size slider to a custom value.
  2. Perform Android's system edge back-swipe gesture (or press the hardware back button).
  3. Observe the "Discard unsaved changes?" confirmation dialog.
  4. Tap "Cancel" / "Keep Editing" → verify you remain on the editor screen with edits intact.
  5. Trigger the back gesture again and tap "Discard" → verify clean return to Home screen.
- **Pass Criteria:**
  - [ ] Back swipe is caught 100% of the time.
  - [ ] Unsaved changes are never lost inadvertently.

---

## TEST 5: Corrupt Data Recovery Test
- **Execution Steps:**
  1. Open Android Studio Device File Explorer or run:
     `adb shell "echo '{corrupt_json: true' > /data/data/com.piglixlabs.shadermakerformcpe/app_flutter/piglix_saved_shaders/shaders_manifest.json"`
  2. Force stop the app (`adb shell am force-stop com.piglixlabs.shadermakerformcpe`).
  3. Re-launch Piglix Shader Builder.
  4. Navigate to "My Shaders" library.
- **What to Look For:**
  - App does not crash with `FormatException`.
  - Store automatically repairs the manifest and re-seeds the default template.
- **Pass Criteria:**
  - [ ] App launches smoothly.
  - [ ] "My Shaders" shows valid, usable shader packs.

---

## TEST 6: 30-Minute Stability Soak Test
- **Execution Steps:**
  1. Keep the application open in the foreground for 30 minutes.
  2. Alternate between creating a shader pack, saving it, switching to the library, and toggling dark/light mode every 5 minutes.
  3. Monitor memory consumption via `adb shell dumpsys meminfo com.piglixlabs.shadermakerformcpe`.
- **Pass Criteria:**
  - [ ] Native heap and Dalvik heap remain stable (< 120 MB total PSS).
  - [ ] No memory growth or leaks over 30 minutes.

---

## TEST 7: Profile Mode DevTools Performance Recording
- **Execution Steps:**
  1. Run `flutter run --profile` on a connected Android device.
  2. Open Flutter DevTools → **Performance** tab.
  3. Click "Record" and scrub the water wave speed slider for 10 seconds.
  4. Click "Stop".
- **What to Look For:**
  - UI thread frame build time < 8.0 ms.
  - Raster thread frame rasterize time < 8.0 ms.
  - Janky frames < 1.0% of total frames recorded.
- **Pass Criteria:**
  - [ ] Zero frames exceeding 16.6 ms (60 fps threshold).

