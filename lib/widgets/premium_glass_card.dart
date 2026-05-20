import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool isInnerPill; // 🆕 Toggle for the "pill/button" look inside
  final Color? color; // 🆕 Optional custom background color

  PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
    this.isInnerPill = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              // 🎨 BACKGROUND
              color: color ?? (isInnerPill
                ? Colors.black.withOpacity(0.3) // Darker for inner pills
                : Colors.white.withOpacity(0.08)), // Lighter for main card
              
              borderRadius: BorderRadius.circular(borderRadius),
              
              // 💎 BORDER
              border: Border.all(
                color: Colors.white.withOpacity(isInnerPill ? 0.6 : 0.2), 
                width: isInnerPill ? 1.5 : 1.0, 
              ),
              
              // 🔦 SHADOWS & GLOWS
              boxShadow: [
                 if (!isInnerPill)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20.r,
                    spreadRadius: 0,
                  ),
                  
                // ✨ INNER GLOW SIMULATION (Top-Left Highlight)
                if (isInnerPill)
                   BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    offset: const Offset(-2, -2),
                    blurRadius: 4.r,
                    blurStyle: BlurStyle.inner, // CRITICAL: Makes it look like glass bevel
                  ),
                if (isInnerPill)
                   BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 6.r,
                    blurStyle: BlurStyle.inner, // CRITICAL: Depth
                  ),
              ],
              
              // 🌈 GRADIENT OVERLAY (Subtle reflection)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(isInnerPill ? 0.15 : 0.1),
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(isInnerPill ? 0.05 : 0.02),
                ],
                stops: const [0.0, 0.4, 0.6, 1.0],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
