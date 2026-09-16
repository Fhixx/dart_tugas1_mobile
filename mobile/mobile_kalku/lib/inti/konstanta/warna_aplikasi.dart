import 'package:flutter/material.dart';

/// Central color tokens for NusaFit ("Kalkulator BMI").
///
/// Do NOT hardcode hex colors anywhere else in the app — always
/// reference these tokens. See DESIGN_SYSTEM.md for the source of truth.
class AppColors {
  AppColors._();

  // Brand gradient
  static const Color primaryDark = Color(0xFF114177);
  static const Color primary = Color(0xFF006A9A);
  static const Color primaryTeal = Color(0xFF17A18A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryTeal],
    stops: [0.0, 0.5, 1.0],
  );

  // Surfaces
  static const Color background = Color(0xFFEEEEEE);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // BMI / status states
  static const Color success = Color(0xFF2E7D32); // normal
  static const Color warning = Color(0xFFED6C02); // underweight
  static const Color danger = Color(0xFFD32F2F); // overweight / delete / error
  static const Color dangerDark = Color(0xFFB71C1C); // obesity / critical

  static const Color disabled = Color(0xFFBDBDBD);

  // Bottom navigation
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF9CA3AF);
  static const Color navLogout = danger;
}
