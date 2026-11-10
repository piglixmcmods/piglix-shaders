import 'package:flutter/material.dart';
import 'new_ui.dart';

void main() {
  runApp(const PiglixProApp());
}

class PiglixProApp extends StatelessWidget {
  const PiglixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Generator for MCPE',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
          secondary: Color(0xFF0E1722),
          surface: Color(0xFF0E1722),
        ),
        fontFamily: 'Minecraft',
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Minecraft',
        ),
        useMaterial3: true,
      ),
      home: const PiglixHomeScreen(),
    );
  }
}
