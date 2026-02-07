import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/core/widgets/notifications_panel.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:vaidya/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
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
    final summary = dashboardState.summary;
    final hasSummary = summary != const DashboardSummaryEntity.empty();

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
    final notifications = _buildNotifications(summary);

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
        onNotificationTap: () {
          showNotificationsPanel(context, items: notifications);
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

  List<AppNotificationItem> _buildNotifications(
    DashboardSummaryEntity summary,
  ) {
    final fromTimeline = summary.timelineItems
        .take(4)
        .map((item) {
          final heading = item.title.toLowerCase().contains('ai')
              ? 'AI summary ready'
              : 'Record added';

          return AppNotificationItem(
            title: heading,
            subtitle: item.title.isEmpty
                ? 'New health update available.'
                : item.title,
            dateLabel: item.date.isEmpty ? 'Today' : item.date,
          );
        })
        .toList(growable: false);

    if (fromTimeline.isNotEmpty) return fromTimeline;

    return const [
      AppNotificationItem(
        title: 'AI summary ready',
        subtitle: 'Review AI insights for your latest visit.',
        dateLabel: 'Today',
      ),
      AppNotificationItem(
        title: 'Record added',
        subtitle: 'Your recent health record was created successfully.',
        dateLabel: 'Today',
      ),
    ];
  }
}

class _SuggestionData {
  final String title;
  final String desc;

  const _SuggestionData({required this.title, required this.desc});
}
