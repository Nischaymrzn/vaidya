import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/themes/colors.dart';

class AnalyticsNetworkCard extends StatelessWidget {
  final AnalyticsProviderNetworkViewData network;
  final bool hasData;

  const AnalyticsNetworkCard({
    super.key,
    required this.network,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Care network',
      subtitle: 'Connected providers and recent touchpoints.',
      child: !hasData
          ? const AnalyticsEmptyState(
              label: 'Add providers to populate the care network.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final graph = _ProviderGraph(
                  topProviders: network.topProviders,
                );
                final stats = _ProviderStats(network: network);

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 65, child: graph),
                      const SizedBox(width: 12),
                      Expanded(flex: 35, child: stats),
                    ],
                  );
                }
                return Column(
                  children: [graph, const SizedBox(height: 12), stats],
                );
              },
            ),
    );
  }
}

class _ProviderGraph extends StatelessWidget {
  final List<AnalyticsTopProviderViewData> topProviders;

  const _ProviderGraph({required this.topProviders});

  @override
  Widget build(BuildContext context) {
    final providers = topProviders.take(6).toList(growable: false);
    return Container(
      height: 320,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          const labelSpace = 26.0;
          const edgePadding = 22.0;
          final center = Offset(size.width / 2, size.height / 2);
          const nodeRadius = 16.0;
          final availableWidth = size.width - (edgePadding * 2);
          final availableHeight = size.height - (edgePadding * 2) - labelSpace;
          final radius = math.min(availableWidth, availableHeight) * 0.36;

          final points = _buildPoints(center, radius, providers.length)
              .map(
                (p) => Offset(
                  p.dx.clamp(
                    edgePadding + nodeRadius,
                    size.width - edgePadding - nodeRadius,
                  ),
                  p.dy.clamp(
                    edgePadding + nodeRadius,
                    size.height - edgePadding - labelSpace - nodeRadius,
                  ),
                ),
              )
              .toList(growable: false);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _NetworkLinesPainter(center: center, points: points),
                ),
              ),
              Positioned(
                left: center.dx - 34,
                top: center.dy - 34,
                child: Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .75),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Patient',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              ...List.generate(points.length, (index) {
                final point = points[index];
                return Positioned(
                  left: point.dx - nodeRadius,
                  top: point.dy - nodeRadius,
                  child: Container(
                    width: nodeRadius * 2,
                    height: nodeRadius * 2,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .75),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              ...List.generate(points.length, (index) {
                final point = points[index];
                final provider = providers[index];
                final isBottom = point.dy > center.dy + 8;
                const labelWidth = 104.0;
                final labelLeft = (point.dx - (labelWidth / 2))
                    .clamp(4.0, size.width - labelWidth - 4.0)
                    .toDouble();
                final labelTop = isBottom
                    ? (point.dy - nodeRadius - 20)
                    : (point.dy + nodeRadius + 6);

                return Positioned(
                  left: labelLeft,
                  top: labelTop,
                  child: SizedBox(
                    width: labelWidth,
                    child: Text(
                      provider.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  List<Offset> _buildPoints(Offset center, double radius, int count) {
    if (count <= 0) return const [];
    if (count == 1) {
      return <Offset>[Offset(center.dx, center.dy - radius)];
    }
    if (count == 2) {
      return <Offset>[
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
      ];
    }
    if (count == 3) {
      return <Offset>[
        Offset(center.dx, center.dy - radius),
        Offset(center.dx - radius, center.dy + 6),
        Offset(center.dx + radius, center.dy + 6),
      ];
    }
    if (count == 4) {
      return <Offset>[
        Offset(center.dx, center.dy - radius),
        Offset(center.dx + radius, center.dy),
        Offset(center.dx, center.dy + radius),
        Offset(center.dx - radius, center.dy),
      ];
    }

    final step = (2 * math.pi) / count;
    return List<Offset>.generate(count, (index) {
      final angle = -math.pi / 2 + (index * step);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }, growable: false);
  }
}

class _ProviderStats extends StatelessWidget {
  final AnalyticsProviderNetworkViewData network;

  const _ProviderStats({required this.network});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatTile(label: 'ACTIVE PROVIDERS', value: network.activeProviders),
        const SizedBox(height: 10),
        _StatTile(label: 'REFERRALS YTD', value: network.referralsYtd),
        const SizedBox(height: 10),
        _StatTile(label: 'CARE TOUCHPOINTS', value: network.careTouchpoints),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOP PROVIDERS',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...network.topProviders.map((provider) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${provider.count}',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 36 / 1.6,
              height: 1,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkLinesPainter extends CustomPainter {
  final Offset center;
  final List<Offset> points;

  const _NetworkLinesPainter({required this.center, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x6694A3B8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      _drawDashedLine(canvas, center, point, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;

    final stepX = dx / distance;
    final stepY = dy / distance;
    double covered = 0;

    while (covered < distance) {
      final start = Offset(
        from.dx + stepX * covered,
        from.dy + stepY * covered,
      );
      final endCovered = math.min(covered + dash, distance);
      final end = Offset(
        from.dx + stepX * endCovered,
        from.dy + stepY * endCovered,
      );
      canvas.drawLine(start, end, paint);
      covered = endCovered + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkLinesPainter oldDelegate) {
    if (oldDelegate.center != center ||
        oldDelegate.points.length != points.length) {
      return true;
    }
    for (var i = 0; i < points.length; i++) {
      if (oldDelegate.points[i] != points[i]) return true;
    }
    return false;
  }
}

