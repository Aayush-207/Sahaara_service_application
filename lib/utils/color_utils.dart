import 'dart:ui';

/// Utility extension for Color to provide opacity functionality
extension ColorOpacity on Color {
  /// Returns a new color with the specified opacity (0.0 to 1.0)
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    final int alpha = (opacity * 255).round();
    final int argb = toARGB32();
    return Color.fromARGB(
      alpha,
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
    );
  }
}
