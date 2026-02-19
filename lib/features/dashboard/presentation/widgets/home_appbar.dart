import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/themes/colors.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String progress;
  final String premiumText;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const HomeAppbar({
    super.key,
    this.userName = 'Nischay',
    this.progress = '--',
    this.premiumText = 'Premium',
    this.unreadCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      leadingWidth: 44,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      elevation: 0,
      leading: const AppDrawerToggleButton(
        color: Colors.white,
        padding: EdgeInsets.zero,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Namaste, ${_firstName(userName)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.health_and_safety_rounded,
                    color: AppColors.background,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    progress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Image.asset('assets/images/line_sep.png', height: 16),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.background),
                  const SizedBox(width: 4),
                  Text(
                    premiumText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onNotificationTap,
              padding: const EdgeInsets.only(right: 16, bottom: 6),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 12,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _firstName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Nischay';
    return trimmed.split(' ').first;
  }

  @override
  Size get preferredSize => const Size.fromHeight(84);
}
