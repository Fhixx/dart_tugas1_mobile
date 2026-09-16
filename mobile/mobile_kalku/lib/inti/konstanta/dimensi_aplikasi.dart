/// Central spacing/radius/size tokens for NusaFit.
///
/// 8-point spacing scale + radius scale from DESIGN_SYSTEM.md.
/// Reference these instead of hardcoding EdgeInsets/BorderRadius values.
class AppDimensions {
  AppDimensions._();

  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // Recommended usage
  static const double screenHorizontalPadding = 20;
  static const double cardInternalPadding = 16;
  static const double sectionGap = 24;
  static const double fieldGap = 12;

  // Radius scale
  static const double radiusSmall = 8; // small control
  static const double radiusInput = 12;
  static const double radiusButton = 16;
  static const double radiusCard = 16;
  static const double radiusModal = 20;
  static const double radiusPill = 999;

  // Component sizes
  static const double bottomNavHeight = 76;
  static const double homeMenuCardHeight = 90;
  static const double minTouchTarget = 48;

  // Responsive baseline (logical px) — see DESIGN_SYSTEM.md #8
  static const double minSupportedWidth = 360;
  static const double minSupportedHeight = 640;
}
