import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsHeartStatisticCard extends StatelessWidget {
  final VitalsSummaryCardViewData? heartCard;
  final VitalsSummaryCardViewData? bloodPressureCard;
  final VitalsSummaryCardViewData? glucoseCard;
  final HeartRateStatsViewData heartStats;

  const VitalsHeartStatisticCard({
    super.key,
    required this.heartCard,
    required this.bloodPressureCard,
    required this.glucoseCard,
    required this.heartStats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1A1C22),
                  Color(0xFF17191E),
                  Color(0xFF13151A),
                ]
              : const [Color(0xFFF0F7FF), Colors.white, Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Heart Statistic',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Snapshot of your latest heart-related vitals.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz_rounded),
                  color: AppColors.textSecondary,
                  splashRadius: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 264,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark
                    ? AppColors.surfaceSoft.withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                      child: Image.asset(
                        'assets/images/heart.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: CustomPaint(painter: _ConnectorPainter()),
                  ),
                  _CalloutTag(
                    label: 'Glucose Level',
                    value: glucoseCard?.value ?? '--',
                    unit: glucoseCard?.unit.isEmpty ?? true
                        ? 'mg/dL'
                        : glucoseCard!.unit,
                    left: 14,
                    top: 24,
                  ),
                  _CalloutTag(
                    label: 'Heart Rate',
                    value: heartCard?.value ?? '--',
                    unit: heartCard?.unit.isEmpty ?? true
                        ? 'bpm'
                        : heartCard!.unit,
                    left: 14,
                    bottom: 24,
                  ),
                  _CalloutTag(
                    label: 'Blood Count',
                    value: '79',
                    unit: '%',
                    right: 14,
                    top: 24,
                    textAlignRight: true,
                  ),
                  _CalloutTag(
                    label: 'Blood Pressure',
                    value: bloodPressureCard?.value ?? '--',
                    unit: bloodPressureCard?.unit.isEmpty ?? true
                        ? 'mmHg'
                        : bloodPressureCard!.unit,
                    right: 14,
                    bottom: 24,
                    textAlignRight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatsTile(
                    label: 'Average',
                    value: heartStats.avg == null ? '--' : '${heartStats.avg}',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatsTile(
                    label: 'Minimum',
                    value: heartStats.min == null ? '--' : '${heartStats.min}',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatsTile(
                    label: 'Maximum',
                    value: heartStats.max == null ? '--' : '${heartStats.max}',
                  ),
                ),
              ],
            ),
            if (heartCard?.updatedAt != null) ...[
              SizedBox(height: 8),
              Text(
                'Updated ${_relativeTime(heartCard!.updatedAt!)}',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays <= 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(timestamp);
  }
}

class _CalloutTag extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final bool textAlignRight;

  const _CalloutTag({
    required this.label,
    required this.value,
    required this.unit,
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.textAlignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: SizedBox(
        width: 96,
        child: Container(
          padding: EdgeInsets.fromLTRB(6, 5, 6, 5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.card.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: textAlignRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: textAlignRight ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 1),
              RichText(
                textAlign: textAlignRight ? TextAlign.right : TextAlign.left,
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cardLeft = 14.0;
    const cardTop = 24.0;
    const cardWidth = 96.0;
    const cardHeight = 44.0;
    const cardRight = cardLeft + cardWidth;
    final rightCardLeft = size.width - cardLeft - cardWidth;
    final bottomCardTop = size.height - cardTop - cardHeight;

    final stroke = Paint()
      ..color = const Color(0xFF6B7280)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftTopStart = Offset(cardRight, cardTop + cardHeight * 0.55);
    final leftBottomStart = Offset(
      cardRight,
      bottomCardTop + cardHeight * 0.42,
    );
    final rightTopStart = Offset(rightCardLeft, cardTop + cardHeight * 0.55);
    final rightBottomStart = Offset(
      rightCardLeft,
      bottomCardTop + cardHeight * 0.42,
    );

    final leftTopEnd = Offset(size.width * 0.43, size.height * 0.50);
    final leftBottomEnd = Offset(size.width * 0.47, size.height * 0.62);
    final rightTopEnd = Offset(size.width * 0.58, size.height * 0.46);
    final rightBottomEnd = Offset(size.width * 0.57, size.height * 0.63);

    _drawSegment(
      canvas,
      stroke,
      leftTopStart,
      Offset(size.width * 0.32, leftTopStart.dy + 18),
      leftTopEnd,
    );
    _drawSegment(
      canvas,
      stroke,
      leftBottomStart,
      Offset(size.width * 0.34, leftBottomStart.dy - 14),
      leftBottomEnd,
    );
    _drawSegment(
      canvas,
      stroke,
      rightTopStart,
      Offset(size.width * 0.68, rightTopStart.dy + 16),
      rightTopEnd,
    );
    _drawSegment(
      canvas,
      stroke,
      rightBottomStart,
      Offset(size.width * 0.68, rightBottomStart.dy - 8),
      rightBottomEnd,
    );
  }

  void _drawSegment(
    Canvas canvas,
    Paint stroke,
    Offset start,
    Offset middle,
    Offset end,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(middle.dx, middle.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) => false;
}

class _StatsTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatsTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        color: AppColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 3),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: ' bpm',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
