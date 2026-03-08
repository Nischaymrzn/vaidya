import 'package:flutter/material.dart';
import 'package:vaidya/themes/colors.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String dateLabel;
  final bool read;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.read,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? dateLabel,
    bool? read,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dateLabel: dateLabel ?? this.dateLabel,
      read: read ?? this.read,
    );
  }
}

Future<void> showNotificationsPanel(
  BuildContext context, {
  required List<AppNotificationItem> items,
  bool isLoading = false,
  Future<bool> Function(String id)? onMarkRead,
  Future<bool> Function()? onMarkAllRead,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Notifications',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) {
      return _NotificationsOverlay(
        initialItems: items,
        isLoading: isLoading,
        onMarkRead: onMarkRead,
        onMarkAllRead: onMarkAllRead,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _NotificationsOverlay extends StatefulWidget {
  final List<AppNotificationItem> initialItems;
  final bool isLoading;
  final Future<bool> Function(String id)? onMarkRead;
  final Future<bool> Function()? onMarkAllRead;

  const _NotificationsOverlay({
    required this.initialItems,
    required this.isLoading,
    required this.onMarkRead,
    required this.onMarkAllRead,
  });

  @override
  State<_NotificationsOverlay> createState() => _NotificationsOverlayState();
}

class _NotificationsOverlayState extends State<_NotificationsOverlay> {
  late List<AppNotificationItem> _items;
  bool _markAllPending = false;
  final Set<String> _markingReadIds = <String>{};

  @override
  void initState() {
    super.initState();
    _items = List<AppNotificationItem>.from(widget.initialItems);
  }

  int get _unreadCount => _items.where((item) => !item.read).length;

  Future<void> _handleMarkRead(AppNotificationItem item) async {
    if (item.read || widget.onMarkRead == null) return;
    if (_markingReadIds.contains(item.id)) return;

    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;

    setState(() {
      _items[index] = _items[index].copyWith(read: true);
      _markingReadIds.add(item.id);
    });

    final ok = await widget.onMarkRead!(item.id);

    if (!mounted) return;
    if (!ok) {
      final rollbackIndex = _items.indexWhere((entry) => entry.id == item.id);
      if (rollbackIndex != -1) {
        setState(() {
          _items[rollbackIndex] = _items[rollbackIndex].copyWith(read: false);
        });
      }
    }

    setState(() {
      _markingReadIds.remove(item.id);
    });
  }

  Future<void> _handleMarkAllRead() async {
    if (_unreadCount == 0 || widget.onMarkAllRead == null || _markAllPending) {
      return;
    }

    final previous = List<AppNotificationItem>.from(_items);
    setState(() {
      _items = _items.map((item) => item.copyWith(read: true)).toList();
      _markAllPending = true;
    });

    final ok = await widget.onMarkAllRead!();

    if (!mounted) return;
    setState(() {
      if (!ok) {
        _items = previous;
      }
      _markAllPending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _items.isNotEmpty;

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
                  margin: EdgeInsets.fromLTRB(12, 64, 12, 0),
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
                            Expanded(
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
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.isLoading
                                        ? 'Loading updates...'
                                        : _unreadCount > 0
                                        ? '$_unreadCount unread'
                                        : "You're all caught up.",
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
                              onPressed: widget.isLoading || _markAllPending
                                  ? null
                                  : _handleMarkAllRead,
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
                              child: _markAllPending
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Mark all read'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: widget.isLoading
                            ? Padding(
                                padding: EdgeInsets.all(18),
                                child: Text(
                                  'Loading notifications...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : hasItems
                            ? Scrollbar(
                                thumbVisibility: true,
                                radius: const Radius.circular(999),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _items.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    final isPending = _markingReadIds.contains(
                                      item.id,
                                    );
                                    return InkWell(
                                      onTap: () => _handleMarkRead(item),
                                      child: Padding(
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
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: item.read
                                                    ? const Color(0xFFD1DBEA)
                                                    : const Color(0xFFBED0E7),
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
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight: item.read
                                                          ? FontWeight.w500
                                                          : FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    item.subtitle,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isPending)
                                              const SizedBox(
                                                width: 11,
                                                height: 11,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            else
                                              Text(
                                                item.dateLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Padding(
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
                            Expanded(
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
