import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_ui.dart';
import 'theme_controller.dart';
import 'my_shaders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Centralized Framework Error Handling (Prevents uncaught runtime crashes)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Piglix-Error] ${details.exceptionAsString()}');
  };

  // Centralized Platform Asynchronous Error Handling
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[Piglix-AsyncError] $error\n$stack');
    return true; // Handled gracefully
  };

  // Safe Production Fallback for layout errors (Replaces default gray/red screen)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF080D14),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFF22C55E),
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'SHADER ENGINE NOTICE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AppThemeController.init();
  await UserShaderStore.init();
  runApp(const PiglixProApp());
}

class PiglixProApp extends StatelessWidget {
  const PiglixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppThemeController.isDarkMode,
      builder: (context, isDark, _) {
        final palette = AppPalette(isDark);
        return MaterialApp(
          title: 'Shader Generator for MCPE',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: palette.bg,
            colorScheme: ColorScheme.light(
              primary: palette.primary,
              secondary: palette.surface,
              surface: palette.surface,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF080D14),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF22C55E),
              secondary: Color(0xFF0E1722),
              surface: Color(0xFF0E1722),
            ),
            useMaterial3: true,
          ),
          home: const PiglixHomeScreen(),
        );
      },
    );
  }
}
