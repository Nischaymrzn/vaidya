import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/symptoms/presentation/models/symptom_view_data.dart';
import 'package:vaidya/features/symptoms/presentation/pages/symptom_anomalies_page.dart';
import 'package:vaidya/features/symptoms/presentation/state/symptoms_state.dart';
import 'package:vaidya/features/symptoms/presentation/view_model/symptoms_viewmodel.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptom_form_sheet.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_anomalies_card.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_frequency_chart_card.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_header_section.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_history_card.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_snapshot_card.dart';
import 'package:vaidya/features/symptoms/presentation/widgets/symptoms_support_card.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomsScreen extends ConsumerStatefulWidget {
  const SymptomsScreen({super.key});

  @override
  ConsumerState<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends ConsumerState<SymptomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomsViewModelProvider.notifier).load(forceLoading: true);
    });
  }

  Future<void> _refresh() {
    return ref
        .read(symptomsViewModelProvider.notifier)
        .load(forceLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    final state = ref.watch(symptomsViewModelProvider);
    final vm = ref.read(symptomsViewModelProvider.notifier);

    final items =
        state.items.map(SymptomViewData.fromEntity).toList(growable: false)
          ..sort((a, b) {
            final aMillis = a.relevantDate?.millisecondsSinceEpoch ?? 0;
            final bMillis = b.relevantDate?.millisecondsSinceEpoch ?? 0;
            return bMillis.compareTo(aMillis);
          });
    final stats = SymptomsOverviewStats.fromItems(items);
    final topSymptoms = topSymptomFrequencies(items);
    final ongoingAlert = _buildOngoingAlert(items);
    final hasData = items.isNotEmpty;

    ref.listen<SymptomsState>(symptomsViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _show(next.errorMessage!, error: true);
      }
      if (next.actionMessage != null &&
          next.actionMessage != prev?.actionMessage) {
        _show(next.actionMessage!);
        vm.clearMessages();
      }
    });

    final body = state.status == SymptomsStatus.loading && !hasData
        ? Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SymptomsHeaderSection(onLogSymptom: _openCreateSheet),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 960;
                      final left = Column(
                        children: [
                          SymptomsSnapshotCard(stats: stats, hasData: hasData),
                          const SizedBox(height: 12),
                          SymptomsHistoryCard(
                            items: items,
                            loading: state.status == SymptomsStatus.loading,
                            onEdit: _openEditSheet,
                            onDelete: (item) async {
                              await vm.remove(item.id);
                            },
                          ),
                        ],
                      );
                      final right = Column(
                        children: [
                          SymptomsAnomaliesCard(
                            onOpenTracker: _openAnomaliesPage,
                          ),
                          const SizedBox(height: 12),
                          SymptomsSupportCard(
                            advisoryText: ongoingAlert,
                            onTalkToAi: () =>
                                _openMainTab(MainBottomNavItem.intelligence),
                          ),
                          const SizedBox(height: 12),
                          SymptomsFrequencyChartCard(data: topSymptoms),
                        ],
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 65, child: left),
                            const SizedBox(width: 12),
                            Expanded(flex: 35, child: right),
                          ],
                        );
                      }

                      return Column(
                        children: [left, const SizedBox(height: 12), right],
                      );
                    },
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.symptoms,
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
          'Symptoms',
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

  String _buildOngoingAlert(List<SymptomViewData> items) {
    final ongoing = items
        .where((item) => item.status == 'ongoing')
        .toList(growable: false);
    if (ongoing.isEmpty) {
      return 'No ongoing symptoms flagged right now. Keep logging for clarity.';
    }
    final sorted = [...ongoing]
      ..sort((a, b) {
        final aTime = a.relevantDate?.millisecondsSinceEpoch ?? 0;
        final bTime = b.relevantDate?.millisecondsSinceEpoch ?? 0;
        return aTime.compareTo(bTime);
      });
    final target = sorted.first;
    final date = target.relevantDate;
    if (date == null) {
      return 'You have ongoing symptoms. Update their status to keep recovery tracking accurate.';
    }
    final days = DateTime.now().difference(date).inDays;
    final safeDays = days <= 0 ? 1 : days;
    return 'You logged ${target.primarySymptom} $safeDays day${safeDays == 1 ? '' : 's'} ago and it is still marked ongoing. Update the status to keep recovery tracking accurate.';
  }

  Future<void> _openCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SymptomFormSheet(
        title: 'Log New Symptom',
        submitLabel: 'Save Symptom',
        onSubmit: (payload) =>
            ref.read(symptomsViewModelProvider.notifier).create(payload),
      ),
    );
  }

  Future<void> _openEditSheet(SymptomViewData item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SymptomFormSheet(
        title: 'Edit Symptom',
        submitLabel: 'Save Changes',
        initialValue: item,
        onSubmit: (payload) => ref
            .read(symptomsViewModelProvider.notifier)
            .update(item.id, payload),
      ),
    );
  }

  void _openAnomaliesPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SymptomAnomaliesPage()));
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
}
