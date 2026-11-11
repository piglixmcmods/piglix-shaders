import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_ui.dart';
import 'theme_controller.dart';
import 'my_shaders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            fontFamily: 'PixelifySans',
            textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'PixelifySans',
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
            fontFamily: 'PixelifySans',
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'PixelifySans',
            ),
            useMaterial3: true,
          ),
          home: const PiglixHomeScreen(),
        );
      },
    );
  }
}
