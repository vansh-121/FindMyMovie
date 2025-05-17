import 'package:flutter/material.dart';

/// A service class to provide theme-related utilities
class ThemeService {
  /// Get a color that adapts to the current theme brightness
  static Color adaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  /// Get an adaptive text color based on theme brightness
  static Color adaptiveTextColor(BuildContext context) {
    return adaptiveColor(
      context,
      lightColor: Colors.black,
      darkColor: Colors.white,
    );
  }

  /// Get an adaptive secondary text color based on theme brightness
  static Color adaptiveSecondaryTextColor(BuildContext context) {
    return adaptiveColor(
      context,
      lightColor: Colors.grey.shade700,
      darkColor: Colors.grey.shade300,
    );
  }

  /// Get an adaptive background color based on theme brightness
  static Color adaptiveBackgroundColor(BuildContext context) {
    return adaptiveColor(
      context,
      lightColor: Colors.white,
      darkColor: Colors.black,
    );
  }

  /// Get an adaptive card color based on theme brightness
  static Color adaptiveCardColor(BuildContext context) {
    return adaptiveColor(
      context,
      lightColor: Colors.white,
      darkColor: Colors.grey.shade900,
    );
  }

  /// Get adaptive gradient colors based on theme brightness
  static List<Color> adaptiveGradientColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode
        ? [
            Colors.black,
            const Color(0xFF101010),
            const Color(0xFF101010),
          ]
        : [
            Colors.white,
            const Color(0xFFF5F5F5),
            const Color(0xFFF5F5F5),
          ];
  }

  /// Check if the current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
