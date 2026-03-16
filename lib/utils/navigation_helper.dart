import 'package:flutter/material.dart';

/// Navigation Helper
/// 
/// Provides consistent navigation methods across the app with:
/// - Standardized transitions
/// - Proper error handling
/// - Sound effects integration
/// - Back button handling
class NavigationHelper {
  // Transition duration constants
  static const Duration _fadeDuration = Duration(milliseconds: 400);
  static const Duration _slideDuration = Duration(milliseconds: 350);

  /// Push a new screen with fade transition
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen, {
    Duration? duration,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration ?? _fadeDuration,
      ),
    );
  }

  /// Push a new screen with slide transition (from right)
  static Future<T?> pushSlide<T>(
    BuildContext context,
    Widget screen, {
    Duration? duration,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: duration ?? _slideDuration,
      ),
    );
  }

  /// Push and replace current screen with fade transition
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget screen, {
    Duration? duration,
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration ?? _fadeDuration,
      ),
      result: result,
    );
  }

  /// Push and remove all previous screens
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget screen, {
    Duration? duration,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration ?? _fadeDuration,
      ),
      predicate ?? (route) => false,
    );
  }

  /// Pop current screen
  static void pop<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, bool Function(Route<dynamic>) predicate) {
    Navigator.popUntil(context, predicate);
  }

  /// Pop to root (first screen)
  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Show modal bottom sheet with consistent styling
  static Future<T?> showBottomSheet<T>(
    BuildContext context,
    Widget child, {
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  /// Show dialog with consistent styling
  static Future<T?> showDialogBox<T>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  /// Material page route (for compatibility)
  static MaterialPageRoute<T> materialRoute<T>(Widget screen) {
    return MaterialPageRoute<T>(builder: (_) => screen);
  }
}
