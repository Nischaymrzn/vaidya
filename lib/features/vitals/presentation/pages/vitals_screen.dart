import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/features/vitals/presentation/pages/metric_detail_page.dart';
import 'package:vaidya/features/vitals/presentation/state/vitals_state.dart';
import 'package:vaidya/features/vitals/presentation/view_model/vitals_viewmodel.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vital_entry_sheet.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vitals_heart_statistic_card.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vitals_log_card.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vitals_metric_cards_section.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vitals_overview_header.dart';
import 'package:vaidya/features/vitals/presentation/widgets/vitals_trend_overview_card.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vitalsViewModelProvider.notifier).load(forceLoading: true);
    });
  }

  Future<void> _onRefresh() {
    return ref.read(vitalsViewModelProvider.notifier).load(forceLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    final state = ref.watch(vitalsViewModelProvider);

    final viewData = VitalsOverviewViewData.fromSources(
      summary: state.summary,
      items: state.items,
    );

    final hasData =
        viewData.cards.isNotEmpty ||
        viewData.trend.isNotEmpty ||
        viewData.records.isNotEmpty;

    ref.listen<VitalsState>(vitalsViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _show(next.errorMessage!, error: true);
      }
      if (next.actionMessage != null &&
          next.actionMessage != previous?.actionMessage) {
        _show(next.actionMessage!);
        ref.read(vitalsViewModelProvider.notifier).clearMessages();
      }
    });

    final body = state.status == VitalsStatus.loading && !hasData
        ? Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VitalsOverviewHeader(onAddReading: () => _openEntrySheet()),
                  if (state.status == VitalsStatus.loading && hasData) ...[
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primarySoft,
                    ),
                  ],
                  if (state.status == VitalsStatus.error && hasData) ...[
                    const SizedBox(height: 12),
                    _ErrorBanner(
                      message:
                          state.errorMessage ??
                          'Failed to refresh vitals. Pull to retry.',
                    ),
                  ],
                  const SizedBox(height: 14),
                  VitalsMetricCardsSection(
                    cards: viewData.topCards,
                    onCardTap: (card) => _openMetricDetail(viewData, card),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1080;
                      final trendCard = VitalsTrendOverviewCard(
                        trend: viewData.trend,
                        stats: viewData.topCards,
                      );
                      final heartCard = VitalsHeartStatisticCard(
                        heartCard: viewData.cardByKey('heartRate'),
                        bloodPressureCard: viewData.cardByKey('bloodPressure'),
                        glucoseCard: viewData.cardByKey('glucose'),
                        heartStats: viewData.heartRateStats,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: trendCard),
                            const SizedBox(width: 12),
                            Expanded(flex: 3, child: heartCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          trendCard,
                          SizedBox(height: 12),
                          heartCard,
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  VitalsLogCard(
                    records: viewData.records,
                    onAddEntry: () => _openEntrySheet(),
                    onView: _viewRecord,
                    onEdit: (record) => _openEntrySheet(initial: record),
                    onDelete: _deleteRecord,
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppSideDrawer(
        currentDestination: AppDrawerDestination.vitals,
      ),
      bottomNavigationBar: AppMainBottomNav(
        activeItem: null,
        onTap: _openMainTab,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: AppDrawerToggleButton(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: Text(
          'Vitals',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: body,
    );
  }

  Future<void> _openEntrySheet({VitalRecordViewData? initial}) async {
    final vm = ref.read(vitalsViewModelProvider.notifier);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => VitalEntrySheet(
        title: initial == null
            ? 'Add a new vitals reading'
            : 'Edit vitals entry',
        initialRecord: initial,
        onSubmit: (payload) {
          if (initial == null) {
            return vm.create(payload);
          }
          if (initial.id.isEmpty) {
            _show('Invalid entry id.', error: true);
            return Future.value(false);
          }
          return vm.update(initial.id, payload);
        },
      ),
    );
  }

  Future<void> _viewRecord(VitalRecordViewData record) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _RecordDetailsSheet(record: record),
    );
  }

  Future<void> _deleteRecord(VitalRecordViewData record) async {
    if (record.id.isEmpty) {
      _show('Cannot delete this entry.', error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete this entry?',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'This will remove the vitals reading permanently.',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Urbanist'),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Urbanist'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await ref.read(vitalsViewModelProvider.notifier).remove(record.id);
  }

  void _openMetricDetail(
    VitalsOverviewViewData viewData,
    VitalsSummaryCardViewData card,
  ) {
    final icon = switch (card.key) {
      'bloodPressure' => 'assets/icons/blood_pressure.svg',
      'glucose' => 'assets/icons/blood_sugar.svg',
      'bmi' => 'assets/icons/bmi.svg',
      _ => 'assets/icons/heart_rate.svg',
    };

    final history = viewData.historyByKey(card.key);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MetricDetailPage(
          metricName: card.label,
          iconPath: icon,
          value: card.value,
          unit: card.unit,
          condition: card.detailCondition,
          scorePercent: card.detailScorePercent,
          historyPoints: history,
        ),
      ),
    );
  }

  void _show(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFDC2626) : null,
        ),
      );
  }

  void _openMainTab(MainBottomNavItem item) {
    final targetIndex = switch (item) {
      MainBottomNavItem.home => 0,
      MainBottomNavItem.records => 1,
      MainBottomNavItem.intelligence => 2,
      MainBottomNavItem.analytics => 3,
      MainBottomNavItem.profile => 4,
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialIndex: targetIndex),
      ),
      (_) => false,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.dangerSurface : const Color(0xFFFEF2F2),
        border: Border.all(
          color: isDark
              ? AppColors.error.withValues(alpha: 0.35)
              : const Color(0xFFFCA5A5),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.error : Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _RecordDetailsSheet extends StatelessWidget {
  final VitalRecordViewData record;

  const _RecordDetailsSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vitals details',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Date', value: _formatDate(record.displayDate)),
            _InfoRow(
              label: 'Heart Rate',
              value: '${displayNum(record.heartRate)} bpm',
            ),
            _InfoRow(
              label: 'Blood Pressure',
              value: '${record.bloodPressureValue} mmHg',
            ),
            _InfoRow(
              label: 'Glucose',
              value: '${displayNum(record.glucoseLevel)} mg/dL',
            ),
            _InfoRow(label: 'Weight', value: '${displayNum(record.weight)} kg'),
            _InfoRow(label: 'Height', value: '${displayNum(record.height)} cm'),
            _InfoRow(
              label: 'BMI',
              value: displayNum(record.bmi, fractionDigits: 2),
            ),
            _InfoRow(
              label: 'Notes',
              value: record.notes.isEmpty ? '--' : record.notes,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';
  }

  String _month(int month) {
    const names = [
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
    return names[month - 1];
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 122,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
