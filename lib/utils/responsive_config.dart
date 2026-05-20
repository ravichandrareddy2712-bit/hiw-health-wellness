import 'package:flutter/material.dart';

/// Responsive configuration for consistent UI across different screen sizes
/// 
/// Base design reference: 392x850 (Medium phone like Pixel 5)
/// This ensures all devices render UI elements at consistent relative sizes
class ResponsiveConfig {
  // Base design dimensions (reference device)
  static const double _baseWidth = 392.0;
  static const double _baseHeight = 850.0;

  final double screenWidth;
  final double screenHeight;
  final double scaleFactorWidth;
  final double scaleFactorHeight;
  final double textScaleFactor;

  ResponsiveConfig(BuildContext context)
      : screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height,
        scaleFactorWidth = MediaQuery.of(context).size.width / _baseWidth,
        scaleFactorHeight = MediaQuery.of(context).size.height / _baseHeight,
        textScaleFactor = (MediaQuery.of(context).size.width / _baseWidth).clamp(0.85, 1.15);

  /// Scale width value based on screen size
  double scaleWidth(double width) => width * scaleFactorWidth;

  /// Scale height value based on screen size
  double scaleHeight(double height) => height * scaleFactorHeight;

  /// Scale font size based on screen size (clamped to prevent extreme sizes)
  double scaleFontSize(double fontSize) => fontSize * textScaleFactor;

  /// Scale padding/margin values uniformly
  EdgeInsets scalePadding(EdgeInsets padding) {
    return EdgeInsets.only(
      left: scaleWidth(padding.left),
      top: scaleHeight(padding.top),
      right: scaleWidth(padding.right),
      bottom: scaleHeight(padding.bottom),
    );
  }

  /// Scale symmetric padding
  EdgeInsets scaleSymmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: scaleWidth(horizontal),
      vertical: scaleHeight(vertical),
    );
  }

  /// Scale all-around padding
  EdgeInsets scaleAll(double value) {
    return EdgeInsets.all(scaleWidth(value));
  }

  /// Get responsive border radius
  BorderRadius scaleBorderRadius(double radius) {
    return BorderRadius.circular(scaleWidth(radius));
  }

  /// Check if device is small (< 360dp width)
  bool get isSmallDevice => screenWidth < 360;

  /// Check if device is large (> 450dp width)
  bool get isLargeDevice => screenWidth > 450;

  /// Check if device is medium (between small and large)
  bool get isMediumDevice => !isSmallDevice && !isLargeDevice;
}

/// Global extension for easy access to responsive values
extension ResponsiveExtension on BuildContext {
  ResponsiveConfig get responsive => ResponsiveConfig(this);
}
