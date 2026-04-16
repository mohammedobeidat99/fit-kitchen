import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withAlpha((opacity * 255).toInt()),
            borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withAlpha(30),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
