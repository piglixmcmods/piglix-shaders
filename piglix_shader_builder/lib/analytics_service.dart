import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized, production-grade Firebase Analytics service for Piglix Shader Maker.
///
/// Features:
/// - Safe graceful fallback (no crash in unit tests or unsupported environments)
/// - Automatic screen tracking observer
/// - Event tracking: Downloads, Presets, App Opens, Minecraft Launch, Guide Views
class AnalyticsService {
  AnalyticsService._();

  static bool _isInitialized = false;
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  /// Returns true if Firebase Analytics is initialized and ready.
  static bool get isInitialized => _isInitialized;

  /// Observer to pass to MaterialApp for automatic screen transition analytics.
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Safe initialization of Firebase Core and Firebase Analytics.
  static Future<void> init() async {
    try {
      if (kIsWeb) {
        // Firebase for web requires FirebaseOptions; safe fallback for web/demo mode
        debugPrint('[AnalyticsService] Web detected - skipping native Firebase init');
        return;
      }

      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _isInitialized = true;

      // Automatically log initial app open
      await _analytics?.logAppOpen();
      debugPrint('[AnalyticsService] Firebase Analytics initialized successfully');
    } catch (e) {
      // In unit tests or mock runs without native config, gracefully degrade
      _isInitialized = false;
      debugPrint('[AnalyticsService] Firebase init notice: $e');
    }
  }

  /// 1. Track when a Shader Pack is exported / downloaded
  static Future<void> logShaderExport({
    required String packName,
    required String format, // 'mcpack' or 'zip'
    int? byteSize,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      final params = <String, Object>{
        'pack_name': packName,
        'format': format,
      };
      if (byteSize != null) {
        params['byte_size'] = byteSize;
      }
      await _analytics!.logEvent(
        name: 'shader_exported',
        parameters: params,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logShaderExport error: $e');
    }
  }

  /// 2. Track when user taps "Apply Preset"
  static Future<void> logPresetApplied({
    required String presetName,
    String? presetId,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      final params = <String, Object>{
        'preset_name': presetName,
      };
      if (presetId != null) {
        params['preset_id'] = presetId;
      }
      await _analytics!.logEvent(
        name: 'preset_applied',
        parameters: params,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logPresetApplied error: $e');
    }
  }

  /// 3. Track when user opens the Minecraft Guide
  static Future<void> logGuideOpened({String? source}) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      final params = <String, Object>{};
      if (source != null) {
        params['source'] = source;
      }
      await _analytics!.logEvent(
        name: 'guide_opened',
        parameters: params.isEmpty ? null : params,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logGuideOpened error: $e');
    }
  }

  /// 4. Track when user taps "Open in Minecraft"
  static Future<void> logOpenWithMinecraft({required String packName}) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'open_with_minecraft',
        parameters: {
          'pack_name': packName,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logOpenWithMinecraft error: $e');
    }
  }

  /// 5. Generic event logging
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isInitialized || _analytics == null) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('[AnalyticsService] logEvent $name error: $e');
    }
  }
}
