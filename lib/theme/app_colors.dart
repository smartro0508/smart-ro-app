import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0077B6); // Strong Ocean Blue
  static const Color primaryLight = Color(0xFF00B4D8); // Bright Aqua
  static const Color primaryDark = Color(0xFF03045E); // Deep Navy
  static const Color accent = Color(0xFF90E0EF); // Soft Water Blue
  
  static const Color background = Color(0xFFF8FAFC); // Very light slate
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient waterGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
