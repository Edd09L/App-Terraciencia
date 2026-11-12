import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/app_colors.dart';
import 'providers/progress_provider.dart';
import 'providers/user_role_provider.dart';
import 'screens/space_home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
      ],
      child: const TerracienciaApp(),
    ),
  );
}

/// Aplicación educativa espacial inclusiva "Terraciencia Inclusiva".
///
/// Diseñada con pautas de accesibilidad cognitiva (WCAG):
/// - Tipografías sans-serif de formas redondas y legibles (Fredoka).
/// - Paleta de colores institucional oficial fija con base en negro absoluto.
/// - Animaciones suaves y controladas para evitar sobrecarga o fatiga cognitiva.
class TerracienciaApp extends StatelessWidget {
  const TerracienciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terraciencia Inclusiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.azulPetroleo,
          secondary: AppColors.mostazaDorado,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        // Aplicar la tipografía Fredoka redondeada y gruesa para todo el texto
        textTheme: GoogleFonts.fredokaTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const SpaceHomeScreen(),
    );
  }
}
