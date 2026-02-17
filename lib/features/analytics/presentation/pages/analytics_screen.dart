import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/state/analytics_state.dart';
import 'package:vaidya/features/analytics/presentation/view_model/analytics_viewmodel.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_allergy_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_conditions_procedures_cards.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_encounters_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_header_section.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_medication_immunization_cards.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_network_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_summary_grid.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analyticsViewModelProvider.notifier)
          .loadSummary(months: 12, forceLoading: true);
    });
  }

  Future<void> _refresh() {
    return ref
        .read(analyticsViewModelProvider.notifier)
        .loadSummary(months: 12, forceLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsViewModelProvider);
    final viewData = AnalyticsViewData.fromEntity(state.summary);

    ref.listen<AnalyticsState>(analyticsViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _show(next.errorMessage!, error: true);
      }
    });

    final hasAnyData = state.summary.data.isNotEmpty;

    final body = state.status == AnalyticsStatus.loading && !hasAnyData
        ? const Center(
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
                  const AnalyticsHeaderSection(),
                  if (state.status == AnalyticsStatus.loading &&
                      hasAnyData) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: Color(0xFFE6EEF9),
                    ),
                  ],
                  if (state.status == AnalyticsStatus.error && hasAnyData) ...[
                    const SizedBox(height: 10),
                    _ErrorBanner(
                      message:
                          state.errorMessage ??
                          'Failed to refresh analytics summary. Pull to retry.',
                    ),
                  ],
                  const SizedBox(height: 14),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: AnalyticsSummaryGrid(items: viewData.summaryCards),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1080;
                      final encounters = AnalyticsEncountersCard(
                        history: viewData.encounterHistory,
                        totals: viewData.encounterTotals,
                        hasData: viewData.hasEncounterData,
                      );
                      final allergies = AnalyticsAllergyCard(
                        data: viewData.allergySeverity,
                        hasData: viewData.hasAllergyData,
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 8, child: encounters),
                            const SizedBox(width: 12),
                            Expanded(flex: 4, child: allergies),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          encounters,
                          const SizedBox(height: 12),
                          allergies,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final conditions = AnalyticsConditionsCard(
                        data: viewData.topConditions,
                        hasData: viewData.hasConditionsData,
                      );
                      final procedures = AnalyticsProceduresCard(
                        data: viewData.procedureBreakdown,
                        hasData: viewData.hasProcedureData,
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: conditions),
                            const SizedBox(width: 12),
                            Expanded(flex: 7, child: procedures),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          conditions,
                          const SizedBox(height: 12),
                          procedures,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final medications = AnalyticsMedicationHistoryCard(
                        data: viewData.medicationHistory,
                        hasData: viewData.hasMedicationData,
                      );
                      final immunizations = AnalyticsImmunizationHistoryCard(
                        data: viewData.immunizationHistory,
                        hasData: viewData.hasImmunizationData,
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: medications),
                            const SizedBox(width: 12),
                            Expanded(flex: 5, child: immunizations),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          medications,
                          const SizedBox(height: 12),
                          immunizations,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AnalyticsNetworkCard(
                    network: viewData.providerNetwork,
                    hasData: viewData.hasProviderData,
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.analytics,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: AppDrawerToggleButton(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: body,
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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF991B1B),
        ),
      ),
    );
  }
}
