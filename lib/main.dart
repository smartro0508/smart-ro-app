import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/router.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart RO App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          scrolledUnderElevation: 8,
          shadowColor: AppColors.primaryDark.withAlpha(20),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
