import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppDrawerToggleButton extends StatelessWidget {
  final Color color;
  final double size;
  final EdgeInsetsGeometry? padding;

  const AppDrawerToggleButton({
    super.key,
    required this.color,
    this.size = 21,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          splashRadius: 20,
          padding: padding ?? EdgeInsets.zero,
          icon: Icon(LucideIcons.panelLeftOpen, color: color, size: size),
        );
      },
    );
  }
}
