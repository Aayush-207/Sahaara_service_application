import 'package:flutter/material.dart';

/// Sahara Pet Care Color Palette - Modern & Vibrant
/// Professional pet care brand with warm, trustworthy colors
/// 
/// Primary: Navy - Professional, trustworthy, stable
/// Secondary: Orange - Energetic, friendly, warm
/// Accent: Sky Blue - Calm, fresh, caring
/// 
/// This palette follows Material Design 3 principles with proper contrast ratios
/// for accessibility (WCAG AA compliance)

class AppColors {
  // ============================================================================
  // PRIMARY COLORS - Navy (Professional & Trustworthy)
  // ============================================================================
  
  /// Main brand color - Navy
  static const Color primary = Color(0xFF1A2332);
  static const Color primaryLight = Color(0xFF2D3A4D);
  static const Color primaryDark = Color(0xFF0F1419);
  static const Color primaryContainer = Color(0xFFE8EAED);
  
  // ============================================================================
  // SECONDARY COLORS - Orange (Energetic & Friendly)
  // ============================================================================
  
  /// Secondary brand color - Orange
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFF8A5C);
  static const Color secondaryDark = Color(0xFFE55420);
  static const Color secondaryContainer = Color(0xFFFFE8E0);
  
  // ============================================================================
  // ACCENT COLORS - Sky Blue (Calm & Fresh)
  // ============================================================================
  
  /// Accent color - Sky Blue
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF72D9D1);
  static const Color accentDark = Color(0xFF3AB5AD);
  static const Color accentContainer = Color(0xFFE0F7F6);
  
  // ============================================================================
  // TERTIARY COLOR - Warm Peach (Soft & Welcoming)
  // ============================================================================
  
  /// Tertiary color - Warm Peach
  static const Color tertiary = Color(0xFFFFD4B8);
  static const Color tertiaryLight = Color(0xFFFFE5D4);
  static const Color tertiaryDark = Color(0xFFFFC299);
  
  // ============================================================================
  // NEUTRAL COLORS - Cool Grays
  // ============================================================================
  
  /// Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  /// Text colors with proper contrast
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  
  /// Border colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);
  
  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Success - Emerald Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successContainer = Color(0xFFD1FAE5);
  
  /// Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningContainer = Color(0xFFFEF3C7);
  
  /// Error - Rose Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorContainer = Color(0xFFFEE2E2);
  
  /// Info - Sky Blue
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFF38BDF8);
  static const Color infoContainer = Color(0xFFE0F2FE);
  
  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================
  
  /// Primary gradient - Navy shades
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A2332), Color(0xFF2D3A4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Secondary gradient - Orange shades
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Accent gradient - Sky Blue shades
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF72D9D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Vibrant gradient - Navy to Orange to Sky Blue
  static const LinearGradient vibrantGradient = LinearGradient(
    colors: [Color(0xFF1A2332), Color(0xFFFF6B35), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Neutral gradient - White to light background
  static const LinearGradient neutralGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Soft shadows for elevation
  static Color shadow = const Color(0xFF1A2332).withValues(alpha: 0.12);
  static Color shadowLight = const Color(0xFF1A2332).withValues(alpha: 0.06);
  static Color shadowDark = const Color(0xFF1A2332).withValues(alpha: 0.18);
  
  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  
  /// Overlay for modals and dialogs
  static Color overlay = const Color(0xFF000000).withValues(alpha: 0.5);
  static Color overlayLight = const Color(0xFF000000).withValues(alpha: 0.3);
  
  // ============================================================================
  // SPECIAL COLORS
  // ============================================================================
  
  /// Shimmer effect colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
  
  /// Rating star color
  static const Color star = Color(0xFFFFB74D);
  
  /// Online status indicator
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Get lighter shade of color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Get darker shade of color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
