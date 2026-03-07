import 'package:flutter/material.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsMetricCardsSection extends StatelessWidget {
  final List<VitalsSummaryCardViewData> cards;
  final void Function(VitalsSummaryCardViewData card) onCardTap;

  const VitalsMetricCardsSection({
    super.key,
    required this.cards,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final topCards = cards.take(3).toList(growable: false);
    if (topCards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;

        if (wide) {
          return Row(
            children: List.generate(topCards.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
                  child: _VitalMetricCard(
                    card: topCards[index],
                    onTap: () => onCardTap(topCards[index]),
                  ),
                ),
              );
            }),
          );
        }

        return Column(
          children: List.generate(topCards.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == topCards.length - 1 ? 0 : 10,
              ),
              child: _VitalMetricCard(
                card: topCards[index],
                onTap: () => onCardTap(topCards[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

class _VitalMetricCard extends StatelessWidget {
  final VitalsSummaryCardViewData card;
  final VoidCallback onTap;

  const _VitalMetricCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A1F2937),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.label.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.displayValue,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 20,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                card.delta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
