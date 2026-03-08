import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vaidya/themes/colors.dart';

class MetricDetailPage extends StatelessWidget {
  final String metricName;
  final String iconPath;
  final String value;
  final String unit;
  final String condition;
  final int scorePercent;
  final List<double> historyPoints;

  const MetricDetailPage({
    super.key,
    required this.metricName,
    required this.iconPath,
    required this.value,
    required this.unit,
    required this.condition,
    required this.scorePercent,
    required this.historyPoints,
  });

  @override
  Widget build(BuildContext context) {
    final displayCondition = _displayCondition(condition);
    final scoreLabel = _scoreLabel(scorePercent);
    final suggestion = _suggestion(
      metricName: metricName,
      conditionLabel: displayCondition,
      score: scorePercent,
      history: historyPoints,
    );
    final historySpots = _historySpots();
    final hasHistoryData = historySpots.length >= 2;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final donutSize = (screenWidth - 110).clamp(236.0, 270.0);
    final conditionBg = Color(0xFFEAF9F0);
    final conditionBorder = Color(0xFFC2E8D0);
    final suggestionBg = Color(0xFFEAF9F0);
    final suggestionBorder = Color(0xFFC2E8D0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: CircleBorder(),
                        side: BorderSide(color: Color(0xFF202020)),
                        padding: EdgeInsets.zero,
                        minimumSize: Size(46, 46),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      metricName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_horiz, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  SvgPicture.asset(iconPath, width: 20, height: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metricName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: conditionBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: conditionBorder),
                    ),
                    child: Text(
                      displayCondition,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E4B3A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: RichText(
                  text: TextSpan(
                    text: _primaryValue(value),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Urbanist',
                    ),
                    children: [
                      if (_secondaryValue(value).isNotEmpty)
                        TextSpan(
                          text: '/${_secondaryValue(value)}',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: donutSize,
                  height: donutSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: donutSize,
                        height: donutSize,
                        child: PieChart(
                          PieChartData(
                            startDegreeOffset: -90,
                            sectionsSpace: 1.6,
                            centerSpaceRadius: donutSize * 0.31,
                            borderData: FlBorderData(show: false),
                            sections: [
                              PieChartSectionData(
                                value: scorePercent.clamp(0, 100).toDouble(),
                                showTitle: false,
                                color: Color(0xFF3387E8),
                                radius: donutSize * 0.19,
                              ),
                              PieChartSectionData(
                                value: (100 - scorePercent.clamp(0, 100))
                                    .toDouble(),
                                showTitle: false,
                                color: Color(0xFFECECEC),
                                radius: donutSize * 0.19,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$scorePercent %',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            scoreLabel,
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: suggestionBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: suggestionBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            suggestion.body,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 76,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7C4DC)),
                ),
                child: LineChart(
                  hasHistoryData
                      ? LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: historySpots.first.x,
                          maxX: historySpots.last.x,
                          minY: 1.8,
                          maxY: 6.2,
                          lineBarsData: [
                            LineChartBarData(
                              spots: historySpots,
                              isCurved: true,
                              curveSmoothness: 0.24,
                              isStrokeCapRound: true,
                              color: Color(0xFF3E94FF),
                              barWidth: 2.3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        )
                      : LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [],
                          betweenBarsData: [],
                        ),
                ),
              ),
              if (!hasHistoryData)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No history data available yet.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _historySpots() {
    if (historyPoints.isEmpty) {
      return const [];
    }

    if (historyPoints.length == 1) {
      return const [FlSpot(0, 4), FlSpot(1, 4)];
    }

    final values = historyPoints;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final spread = (max - min).abs() < 0.0001 ? 1.0 : (max - min);

    final normalized = List<double>.generate(values.length, (index) {
      return 2.1 + ((values[index] - min) / spread) * 3.7;
    });

    final smoothed = List<double>.generate(normalized.length, (index) {
      if (index == 0 || index == normalized.length - 1) {
        return normalized[index];
      }
      return normalized[index - 1] * 0.25 +
          normalized[index] * 0.5 +
          normalized[index + 1] * 0.25;
    });

    return List<FlSpot>.generate(
      smoothed.length,
      (index) => FlSpot(index.toDouble(), smoothed[index]),
    );
  }

  String _displayCondition(String input) {
    switch (input.toLowerCase()) {
      case 'high':
        return 'Slightly High';
      case 'low':
        return 'Slightly Low';
      default:
        return 'Normal';
    }
  }

  String _primaryValue(String text) {
    final clean = text.trim();
    if (clean.contains('/')) {
      return clean.split('/').first;
    }
    return clean;
  }

  String _secondaryValue(String text) {
    final clean = text.trim();
    if (!clean.contains('/')) return '';
    return clean.split('/').last;
  }

  String _scoreLabel(int score) {
    if (score >= 75) return 'OPTIMAL';
    if (score >= 60) return 'STABLE';
    if (score >= 45) return 'WATCH';
    return 'RISK';
  }

  _MetricSuggestion _suggestion({
    required String metricName,
    required String conditionLabel,
    required int score,
    required List<double> history,
  }) {
    final metricKey = metricName.toLowerCase();
    final trend = _trendDirection(history);

    if (score >= 75 && !conditionLabel.contains('High')) {
      return const _MetricSuggestion(
        title: 'Looking stable',
        body:
            'Average readings remain in a healthy range. Continue your routine and keep logging regularly.',
      );
    }

    if (metricKey.contains('blood pressure') &&
        conditionLabel.contains('High')) {
      return const _MetricSuggestion(
        title: 'Slightly elevated',
        body:
            'Consider reducing sodium intake and increasing physical activity. Monitor readings for next few days.',
      );
    }

    if (conditionLabel.contains('High')) {
      return _MetricSuggestion(
        title: 'Slightly elevated',
        body: trend == _TrendDirection.up
            ? 'Average trend is moving up. Improve hydration, sleep, and activity, then re-check soon.'
            : 'Average reading is above range. Keep tracking and adjust routine to stabilize this metric.',
      );
    }

    if (conditionLabel.contains('Low')) {
      return _MetricSuggestion(
        title: 'Slightly low',
        body: trend == _TrendDirection.down
            ? 'Average trend is moving lower. Maintain regular meals, hydration, and rest before next check.'
            : 'Average reading is below range. Re-check over the next few logs and monitor symptoms.',
      );
    }

    return const _MetricSuggestion(
      title: 'Looking stable',
      body:
          'Your latest readings look stable. Continue current routine and keep logging consistently.',
    );
  }

  _TrendDirection _trendDirection(List<double> values) {
    if (values.length < 2) return _TrendDirection.flat;
    final delta = values.last - values.first;
    if (delta > 0.5) return _TrendDirection.up;
    if (delta < -0.5) return _TrendDirection.down;
    return _TrendDirection.flat;
  }
}

class _MetricSuggestion {
  final String title;
  final String body;

  const _MetricSuggestion({required this.title, required this.body});
}

enum _TrendDirection { up, down, flat }
