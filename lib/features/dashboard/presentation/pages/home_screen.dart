import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/core/widgets/notifications_panel.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:vaidya/features/dashboard/presentation/state/notifications_state.dart';
import 'package:vaidya/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:vaidya/features/dashboard/presentation/view_model/notifications_viewmodel.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/dashboard_ai_quick_action_card.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/dashboard_medications_allergies_card.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/dashboard_symptom_activity_card.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/health_score_card.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/health_suggestion.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/home_appbar.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/recent_medications.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/smart_health_metrics.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_ai_screen.dart';
import 'package:vaidya/themes/colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider.notifier).getDashboardSummary();
      ref
          .read(notificationsViewModelProvider.notifier)
          .load(forceLoading: true);
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(dashboardViewModelProvider.notifier)
        .getDashboardSummary(forceLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final notificationsState = ref.watch(notificationsViewModelProvider);
    final summary = dashboardState.summary;
    final hasSummary = summary != const DashboardSummaryEntity.empty();
    final unreadCount = notificationsState.items
        .where((item) => !item.isRead)
        .length;

    ref.listen<DashboardState>(dashboardViewModelProvider, (previous, next) {
      final previousMessage = previous?.errorMessage;
      if (next.errorMessage != null && next.errorMessage != previousMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    ref.listen<NotificationsState>(notificationsViewModelProvider, (
      previous,
      next,
    ) {
      final previousError = previous?.errorMessage;
      if (next.errorMessage != null && next.errorMessage != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    if (dashboardState.status == DashboardStatus.loading && !hasSummary) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (dashboardState.status == DashboardStatus.error && !hasSummary) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to load dashboard data.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dashboardState.errorMessage ?? 'Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final suggestion = _resolveSuggestion(summary);
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.home,
      ),
      appBar: HomeAppbar(
        userName: summary.userName,
        progress: summary.vaidyaScore != null
            ? '${summary.vaidyaScore!.round()}%'
            : '--',
        unreadCount: unreadCount,
        onNotificationTap: () async {
          await ref
              .read(notificationsViewModelProvider.notifier)
              .load(forceLoading: true);
          if (!mounted) return;
          final refreshed = ref.read(notificationsViewModelProvider);
          final refreshedItems = _buildNotificationItems(refreshed.items);
          showNotificationsPanel(
            this.context,
            items: refreshedItems,
            isLoading: refreshed.status == NotificationsStatus.loading,
            onMarkRead: (id) async {
              return ref
                  .read(notificationsViewModelProvider.notifier)
                  .markRead(id);
            },
            onMarkAllRead: () async {
              return ref
                  .read(notificationsViewModelProvider.notifier)
                  .markAllRead();
            },
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 20,
            left: 18,
            right: 18,
          ),
          child: Column(
            children: [
              HealthScoreCard(
                desc:
                    'Based on your data, we think your health status is above average',
                score: summary.vaidyaScore?.round().toString() ?? '--',
                trend: summary.healthScoreTrend,
              ),
              const SizedBox(height: 24),
              SmartHealthMetrics(
                vitalStats: summary.vitalStats,
                riskFactors: summary.riskFactors,
                vitalsData: summary.vitalsData,
              ),
              const SizedBox(height: 24),
              RecentMedications(
                medications: summary.medications,
                recentRecords: summary.timelineItems,
              ),
              const SizedBox(height: 24),
              DashboardSymptomActivityCard(
                symptoms: summary.symptomData,
                pattern: summary.symptomPattern,
              ),
              const SizedBox(height: 24),
              DashboardMedicationsAllergiesCard(
                medications: summary.medications,
                allergies: summary.allergies,
              ),
              const SizedBox(height: 24),
              HealthSuggestion(title: suggestion.title, desc: suggestion.desc),
              const SizedBox(height: 24),
              DashboardAiQuickActionCard(
                onTap: () {
                  AppRoutes.push(context, const VaidyaAiScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SuggestionData _resolveSuggestion(DashboardSummaryEntity summary) {
    if (summary.insights.isNotEmpty) {
      return _SuggestionData(
        title: summary.insights.first.title,
        desc: summary.insights.first.body,
      );
    }

    if (summary.symptomPattern.isNotEmpty) {
      return _SuggestionData(
        title: 'Health Insight',
        desc: summary.symptomPattern,
      );
    }

    return const _SuggestionData(
      title: 'Health Suggestion',
      desc: 'Keep tracking your symptoms and vitals to get better insights.',
    );
  }

  List<AppNotificationItem> _buildNotificationItems(
    List<NotificationEntity> notifications,
  ) {
    if (notifications.isEmpty) {
      return const <AppNotificationItem>[];
    }

    return notifications
        .map((item) {
          return AppNotificationItem(
            id: item.id,
            title: item.title.isEmpty ? 'Notification' : item.title,
            subtitle: item.message.isEmpty
                ? 'You have a new health update.'
                : item.message,
            dateLabel: _formatNotificationDate(item.createdAt),
            read: item.isRead,
          );
        })
        .toList(growable: false);
  }

  String _formatNotificationDate(DateTime? date) {
    if (date == null) return 'Today';
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    return '$month $day';
  }
}

class _SuggestionData {
  final String title;
  final String desc;

  const _SuggestionData({required this.title, required this.desc});
}
