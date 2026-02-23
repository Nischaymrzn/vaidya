import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/themes/colors.dart';

enum MainBottomNavItem { home, records, intelligence, analytics, profile }

class AppMainBottomNav extends StatelessWidget {
  final MainBottomNavItem? activeItem;
  final ValueChanged<MainBottomNavItem> onTap;

  const AppMainBottomNav({super.key, required this.onTap, this.activeItem});

  @override
  Widget build(BuildContext context) {
    final items = <({MainBottomNavItem item, IconData icon})>[
      (item: MainBottomNavItem.home, icon: LucideIcons.layoutDashboard),
      (item: MainBottomNavItem.records, icon: LucideIcons.folderHeart),
      (item: MainBottomNavItem.intelligence, icon: LucideIcons.brain),
      (item: MainBottomNavItem.analytics, icon: LucideIcons.chartColumnBig),
      (item: MainBottomNavItem.profile, icon: LucideIcons.user),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: items
                .map((entry) {
                  final selected = activeItem == entry.item;
                  return Expanded(
                    child: IconButton(
                      onPressed: () => onTap(entry.item),
                      splashRadius: 22,
                      icon: Icon(
                        entry.icon,
                        size: 22,
                        color: selected
                            ? AppColors.activeNav
                            : AppColors.isNotActiveNav,
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}
