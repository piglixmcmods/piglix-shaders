import 'dart:ui';
import 'package:flutter/material.dart';
import 'piglix_logo_data.dart';
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141312),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD49B6A),
          secondary: Color(0xFF423C37),
          surface: Color(0xFF1F1E1C),
        ),
        fontFamily: 'Minecraft',
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Minecraft',
        ),
        useMaterial3: true,
      ),
      home: const PiglixSplashScreen(),
    );
  }
}

class PiglixSplashScreen extends StatefulWidget {
  const PiglixSplashScreen({super.key});

  @override
  State<PiglixSplashScreen> createState() => _PiglixSplashScreenState();
}

class _PiglixSplashScreenState extends State<PiglixSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PiglixHomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1511),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD49B6A).withOpacity(0.28),
                        blurRadius: 65,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.memory(
                    kPiglixLogoBytes,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: 'Created by ',
                        style: TextStyle(color: Color(0xFF8E9590)),
                      ),
                        TextSpan(
                          text: 'Piglix Labs',
                          style: TextStyle(
                            color: Color(0xFFD49B6A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD49B6A)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
