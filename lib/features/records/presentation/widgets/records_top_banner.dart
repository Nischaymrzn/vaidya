import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/themes/colors.dart';

class RecordsTopBanner extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const RecordsTopBanner({
    super.key,
    this.unreadCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppDrawerToggleButton(
                color: Colors.white,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Records',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your complete medical record collection',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Color(0xFFDCEAFE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onNotificationTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.5,
                          vertical: 2,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
