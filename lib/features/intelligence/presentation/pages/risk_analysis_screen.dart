import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/intelligence/presentation/models/risk_analysis_view_data.dart';
import 'package:vaidya/features/intelligence/presentation/pages/brain_tumor_prediction_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/diabetes_prediction_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/heart_disease_prediction_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/tuberculosis_prediction_screen.dart';
import 'package:vaidya/features/intelligence/presentation/services/intelligence_report_service.dart';
import 'package:vaidya/features/intelligence/presentation/state/health_insights_state.dart';
import 'package:vaidya/features/intelligence/presentation/state/risk_assessments_state.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/health_insights_viewmodel.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/risk_assessments_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class RiskAnalysisScreen extends ConsumerStatefulWidget {
  const RiskAnalysisScreen({super.key});

  @override
  ConsumerState<RiskAnalysisScreen> createState() => _RiskAnalysisScreenState();
}

class _RiskAnalysisScreenState extends ConsumerState<RiskAnalysisScreen> {
  static const _modules =
      <
        ({
          String key,
          String title,
          String status,
          String desc,
          List<String> points,
          IconData icon,
        })
      >[
        (
          key: 'diabetes',
          title: 'Diabetes',
          status: 'Vitals + history',
          desc: 'Glucose and BMI history combined with vitals trends.',
          points: ['Glucose trends', 'BMI changes', 'Vitals continuity'],
          icon: Icons.water_drop_outlined,
        ),
        (
          key: 'heart',
          title: 'Heart Disease',
          status: 'Vitals + records',
          desc: 'Blood pressure, glucose, and history signals over time.',
          points: ['BP variability', 'Glucose trends', 'Vitals log'],
          icon: Icons.favorite_border,
        ),
        (
          key: 'tb',
          title: 'Tuberculosis',
          status: 'Symptoms + imaging',
          desc: 'Symptom cadence paired with scan review inputs.',
          points: ['Symptom cadence', 'Exposure flags', 'Scan upload'],
          icon: Icons.shield_outlined,
        ),
        (
          key: 'brain',
          title: 'Brain Tumor',
          status: 'Symptoms + imaging',
          desc: 'Neurological signals assessed with MRI uploads.',
          points: ['Neuro symptoms', 'Scan upload', 'Clinical notes'],
          icon: Icons.psychology_alt_outlined,
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadAll(forceLoading: true),
    );
  }

  Future<void> _loadAll({bool forceLoading = false}) async {
    await ref
        .read(riskAssessmentsViewModelProvider.notifier)
        .load(forceLoading: forceLoading);
    await _loadInsightsForLatest(forceLoading: forceLoading);
  }

  Future<void> _loadInsightsForLatest({bool forceLoading = false}) async {
    final state = ref.read(riskAssessmentsViewModelProvider);
    final riskId = RiskAnalysisViewData.resolveLatestAssessmentId(state.items);
    if (riskId == null || riskId.isEmpty) {
      return;
    }
    await ref
        .read(healthInsightsViewModelProvider.notifier)
        .load(riskId: riskId, forceLoading: forceLoading);
  }

  Future<void> _runAnalysis() async {
    final ok = await ref
        .read(riskAssessmentsViewModelProvider.notifier)
        .generate(
          payload: const {
            'includeAi': true,
            'includeAnalysis': true,
            'useLatest': true,
            'maxInsights': 6,
          },
        );
    if (!ok || !mounted) {
      return;
    }
    await _loadAll(forceLoading: false);
  }

  Future<void> _generateReport(
    RiskAssessmentsState riskState,
    HealthInsightsState insightState,
  ) async {
    final latestAssessmentId = RiskAnalysisViewData.resolveLatestAssessmentId(
      riskState.items,
    );
    final allAssessments = riskState.items
        .map((e) => e.data)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    Map<String, dynamic>? matchById;
    if (latestAssessmentId != null && latestAssessmentId.isNotEmpty) {
      for (final assessment in allAssessments) {
        final id = (assessment['_id'] ?? assessment['id'] ?? '').toString();
        if (id == latestAssessmentId) {
          matchById = assessment;
          break;
        }
      }
    }

    Map<String, dynamic>? fallbackWithAnalysis;
    for (final assessment in allAssessments) {
      if (assessment['analysis'] is Map) {
        fallbackWithAnalysis = assessment;
        break;
      }
    }

    final assessment = matchById ?? fallbackWithAnalysis;
    if (assessment == null) {
      _show('No generated analysis available for report.', true);
      return;
    }

    try {
      final insights = insightState.items
          .map((e) => e.data)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final path = await IntelligenceReportService.downloadRiskAnalysisReport(
        assessment: assessment,
        insights: insights,
      );
      _show('Report downloaded to: $path', false);
    } catch (e) {
      _show('Unable to generate report: $e', true);
    }
  }

  void _openPrediction(String moduleKey) {
    final page = switch (moduleKey) {
      'diabetes' => const DiabetesPredictionScreen(),
      'heart' => const HeartDiseasePredictionScreen(),
      'tb' => const TuberculosisPredictionScreen(),
      'brain' => const BrainTumorPredictionScreen(),
      _ => null,
    };
    if (page == null) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final riskState = ref.watch(riskAssessmentsViewModelProvider);
    final insightState = ref.watch(healthInsightsViewModelProvider);
    final data = RiskAnalysisViewData.fromSources(
      assessments: riskState.items,
      insights: insightState.items,
    );

    ref.listen<RiskAssessmentsState>(riskAssessmentsViewModelProvider, (p, n) {
      if (n.errorMessage != null && n.errorMessage != p?.errorMessage) {
        _show(n.errorMessage!, true);
      }
      if (n.actionMessage != null && n.actionMessage != p?.actionMessage) {
        _show(n.actionMessage!, false);
      }
    });
    ref.listen<HealthInsightsState>(healthInsightsViewModelProvider, (p, n) {
      if (n.errorMessage != null && n.errorMessage != p?.errorMessage) {
        _show(n.errorMessage!, true);
      }
    });

    final loading =
        riskState.status == RiskAssessmentsStatus.loading &&
        riskState.items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.riskAnalysis,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: AppDrawerToggleButton(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: const Text(
          'Risk Analysis',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 21,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () => _loadAll(forceLoading: true),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hero(data, riskState, insightState),
                    const SizedBox(height: 14),
                    _sectionTitle(
                      'Disease modules',
                      'Open a prediction module to run disease-specific analysis.',
                    ),
                    const SizedBox(height: 8),
                    _modulesGrid(),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, c) {
                        final wide = c.maxWidth >= 980;
                        final left = Column(
                          children: [
                            _riskTrajectory(data),
                            const SizedBox(height: 12),
                            _signalContribution(data),
                          ],
                        );
                        final right = Column(
                          children: [
                            _keySignals(data),
                            const SizedBox(height: 12),
                            _aiInsights(data),
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
                    const SizedBox(height: 12),
                    _fullAnalysis(data),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _hero(
    RiskAnalysisViewData data,
    RiskAssessmentsState riskState,
    HealthInsightsState insightState,
  ) {
    final submitting = riskState.isSubmitting;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F7AE0), Color(0xFF185FB0)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Full Risk Analysis',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 26,
                    height: 1.1,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Comprehensive review of vitals, symptoms, records, medications, and history.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13.5,
                    color: Color(0xD9FFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Run the analysis to refresh scores and unlock your report.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13.5,
                    color: Color(0xD9FFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitting ? null : _runAnalysis,
                        style: ButtonStyle(
                          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.disabled)) {
                              return const Color(0xFF124C92);
                            }
                            return Colors.white;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.white;
                            }
                            return AppColors.primary;
                          }),
                        ),
                        child: Text(
                          submitting ? 'Running...' : 'Run full analysis',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: data.analysisReady
                            ? () => _generateReport(riskState, insightState)
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Download report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.summaryTiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.9,
              ),
              itemBuilder: (_, i) {
                final t = data.summaryTiles[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.label,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        t.value,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12.5,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modulesGrid() {
    return LayoutBuilder(
      builder: (context, c) {
        final cross = c.maxWidth >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: cross == 1 ? 1.58 : 1.46,
          ),
          itemBuilder: (_, i) {
            final m = _modules[i];
            return _moduleCard(m);
          },
        );
      },
    );
  }

  Widget _moduleCard(
    ({
      String key,
      String title,
      String status,
      String desc,
      List<String> points,
      IconData icon,
    })
    m,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2937),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(m.icon, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 21 / 1.3,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      m.status,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            m.desc,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13.2,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          ...m.points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 6),
                    child: Icon(
                      Icons.circle,
                      size: 4.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openPrediction(m.key),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Open prediction'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskTrajectory(RiskAnalysisViewData data) {
    final pts = data.riskTrend;
    final spots = pts
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
        .toList();
    final maxY = math
        .max(
          100,
          spots.isEmpty ? 100 : (spots.map((e) => e.y).reduce(math.max) + 10),
        )
        .toDouble();
    return _card(
      'Risk trajectory',
      'Composite risk over the last six months.',
      SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.round();
                    if (i < 0 || i >= pts.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        pts[i].month,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2.3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signalContribution(RiskAnalysisViewData data) {
    final pts = data.contributions;
    final maxY = pts.isEmpty
        ? 40.0
        : pts.map((e) => e.value.toDouble()).reduce(math.max) + 10;
    return _card(
      'Signal contribution',
      'Weighted influence of each data group in the model.',
      SizedBox(
        height: 210,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.round();
                    if (i < 0 || i >= pts.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        pts[i].label,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(
              pts.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: pts[i].value.toDouble(),
                    width: 32,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _keySignals(RiskAnalysisViewData data) {
    return _card(
      'Key signals',
      'Signals used in the current analysis.',
      Column(
        children: data.keySignals
            .map(
              (e) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.label.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 11,
                        letterSpacing: 0.7,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _aiInsights(RiskAnalysisViewData data) {
    Widget list(List<RiskInsightItemViewData> items, String empty, Color dot) {
      if (items.isEmpty) {
        return Text(
          empty,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        );
      }
      return Column(
        children: items
            .take(3)
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            e.description,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    return _card(
      'AI insights',
      'Alerts and improvement opportunities.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tinyPill(
                'Alerts ${data.alertInsights.length}',
                const Color(0xFFB91C1C),
                const Color(0xFFFEF2F2),
              ),
              _tinyPill(
                'Improve ${data.improveInsights.length}',
                const Color(0xFF047857),
                const Color(0xFFECFDF5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ALERTS',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              letterSpacing: 0.7,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          list(
            data.alertInsights,
            'No critical alerts detected.',
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 10),
          const Text(
            'IMPROVING HEALTH',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              letterSpacing: 0.7,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          list(
            data.improveInsights,
            'No improvement insights yet.',
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _fullAnalysis(RiskAnalysisViewData data) {
    Color badgeBg;
    Color badgeText;
    switch (data.riskLevel.toLowerCase()) {
      case 'high':
        badgeBg = const Color(0xFFFEF2F2);
        badgeText = const Color(0xFFB91C1C);
        break;
      case 'medium':
        badgeBg = const Color(0xFFFFFBEB);
        badgeText = const Color(0xFFB45309);
        break;
      default:
        badgeBg = const Color(0xFFECFDF5);
        badgeText = const Color(0xFF047857);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Full analysis',
          'Detailed interpretation across vitals, symptoms, records, and history.',
        ),
        const SizedBox(height: 8),
        _card(
          'Overall summary',
          null,
          Text(
            data.fullSummary,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: badgeText.withValues(alpha: 0.25)),
            ),
            child: Text(
              '${data.riskLevel} risk',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: badgeText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 620) {
              return Column(
                children: data.fullSections
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _fullAnalysisSectionCard(section),
                      ),
                    )
                    .toList(growable: false),
              );
            }

            final leftSections = <RiskSectionViewData>[];
            final rightSections = <RiskSectionViewData>[];
            for (int i = 0; i < data.fullSections.length; i++) {
              if (i.isEven) {
                leftSections.add(data.fullSections[i]);
              } else {
                rightSections.add(data.fullSections[i]);
              }
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: leftSections
                        .map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _fullAnalysisSectionCard(section),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: rightSections
                        .map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _fullAnalysisSectionCard(section),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _fullAnalysisSectionCard(RiskSectionViewData section) {
    return _card(
      section.title,
      null,
      Text(
        section.content,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _card(
    String title,
    String? subtitle,
    Widget child, {
    Widget? trailing,
    Widget? leading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2937),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 8)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18 / 1.12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 22,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _tinyPill(String text, Color textColor, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _show(String message, bool error) {
    if (!mounted) {
      return;
    }
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
