import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class AppNotificationItem {
  final String title;
  final String subtitle;
  final String dateLabel;

  const AppNotificationItem({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
  });
}

Future<void> showNotificationsPanel(
  BuildContext context, {
  required List<AppNotificationItem> items,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Notifications',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) {
      return _NotificationsOverlay(items: items);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _NotificationsOverlay extends StatelessWidget {
  final List<AppNotificationItem> items;

  const _NotificationsOverlay({required this.items});

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 255,
                  margin: const EdgeInsets.fromLTRB(12, 64, 12, 0),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0F172A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notifications',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "You're all caught up.",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Mark all read'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: hasItems
                            ? Scrollbar(
                                thumbVisibility: true,
                                radius: const Radius.circular(999),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        12,
                                        10,
                                        12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFBED0E7),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.subtitle,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.dateLabel,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(18),
                                child: Text(
                                  'No notifications yet.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'View all notifications',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
