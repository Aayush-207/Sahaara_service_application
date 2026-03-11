import 'package:flutter/material.dart';

/// UI Helper Utilities
/// 
/// Provides reusable widgets and utilities to prevent common UI issues:
/// - Text overflow
/// - Row/Column overflow
/// - Responsive sizing
/// - Safe spacing

class UIHelpers {
  /// Safe Text widget that prevents overflow
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    bool softWrap = true,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  /// Safe Row that prevents overflow with Flexible children
  static Widget safeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) {
        // Wrap Text widgets in Flexible to prevent overflow
        if (child is Text) {
          return Flexible(child: child);
        }
        return child;
      }).toList(),
    );
  }

  /// Safe Column that prevents overflow with scrolling
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool scrollable = false,
  }) {
    final column = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(child: column);
    }
    return column;
  }

  /// Responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return EdgeInsets.all(mobile);
    } else if (width < 1200) {
      return EdgeInsets.all(tablet);
    }
    return EdgeInsets.all(desktop);
  }

  /// Responsive font size
  static double responsiveFontSize(BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return mobile;
    } else if (width < 1200) {
      return tablet;
    }
    return desktop;
  }

  /// Safe spacing that adapts to screen size
  static SizedBox responsiveSpacing(BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    double spacing;
    if (width < 600) {
      spacing = mobile;
    } else if (width < 1200) {
      spacing = tablet;
    } else {
      spacing = desktop;
    }
    return SizedBox(height: spacing, width: spacing);
  }

  /// Constrained box to prevent overflow
  static Widget constrainedChild(
    Widget child, {
    double? maxWidth,
    double? maxHeight,
    double? minWidth,
    double? minHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
        minWidth: minWidth ?? 0,
        minHeight: minHeight ?? 0,
      ),
      child: child,
    );
  }

  /// Flexible text that adapts to available space
  static Widget flexibleText(
    String text, {
    TextStyle? style,
    int? maxLines = 1,
    TextAlign? textAlign,
  }) {
    return Flexible(
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  /// Expanded text that takes all available space
  static Widget expandedText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
  }) {
    return Expanded(
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  /// Safe ListView builder with proper constraints
  static Widget safeListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding,
      shrinkWrap: shrinkWrap,
    );
  }

  /// Wrap text in a container with max width to prevent overflow
  static Widget boundedText(
    String text, {
    TextStyle? style,
    double maxWidth = double.infinity,
    int? maxLines,
    TextAlign? textAlign,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  /// Create a safe card with proper constraints
  static Widget safeCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return Card(
      elevation: elevation ?? 0,
      color: color,
      margin: margin ?? const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Prevent keyboard overflow
  static Widget keyboardSafeArea({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return SafeArea(
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.mobile;
    } else if (width < 1200) {
      return ScreenSize.tablet;
    }
    return ScreenSize.desktop;
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}

enum ScreenSize {
  mobile,
  tablet,
  desktop,
}
