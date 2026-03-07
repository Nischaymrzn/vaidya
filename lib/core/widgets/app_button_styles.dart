import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class AppButtonStyles {
  const AppButtonStyles._();

  static ButtonStyle pillOutlined({
    Color? foreground,
    Color? border,
    Color? hoverBackground,
    Color? pressedBackground,
    Color? disabledForeground,
    Color? disabledBorder,
    double height = 44,
  }) {
    final resolvedForeground = foreground ?? AppColors.primary;
    final resolvedBorder = border ?? AppColors.border;
    final resolvedHoverBackground = hoverBackground ?? AppColors.primarySoft;
    final resolvedPressedBackground = pressedBackground ?? AppColors.surfaceMuted;
    final resolvedDisabledForeground =
        disabledForeground ?? AppColors.textSecondary;
    final resolvedDisabledBorder = disabledBorder ?? AppColors.borderStrong;

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, height)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.pressed)) {
          return resolvedPressedBackground;
        }
        if (states.contains(WidgetState.hovered)) {
          return resolvedHoverBackground;
        }
        return Colors.transparent;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: resolvedDisabledBorder, width: 1);
        }
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(
            color: resolvedForeground.withValues(alpha: 0.85),
            width: 1.3,
          );
        }
        if (states.contains(WidgetState.hovered)) {
          return BorderSide(
            color: resolvedForeground.withValues(alpha: 0.75),
            width: 1.2,
          );
        }
        return BorderSide(color: resolvedBorder, width: 1);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return resolvedDisabledForeground;
        }
        return resolvedForeground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return resolvedForeground.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return resolvedForeground.withValues(alpha: 0.08);
        }
        return null;
      }),
      animationDuration: const Duration(milliseconds: 170),
      mouseCursor: WidgetStateMouseCursor.clickable,
    );
  }
}
