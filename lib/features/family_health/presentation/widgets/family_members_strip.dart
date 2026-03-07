import 'package:flutter/material.dart';
import 'package:vaidya/features/family_health/presentation/models/family_health_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class FamilyMembersStrip extends StatelessWidget {
  final FamilySummaryViewData summary;
  final String? selectedMemberId;
  final ValueChanged<String> onSelectMember;
  final ValueChanged<String> onViewMember;

  const FamilyMembersStrip({
    super.key,
    required this.summary,
    required this.selectedMemberId,
    required this.onSelectMember,
    required this.onViewMember,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family members',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Select a member to review vitals and care guidance.',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: summary.members.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final member = summary.members[index];
              final isSelected =
                  (selectedMemberId ?? summary.currentUserId) == member.userId;
              return _MemberCard(
                member: member,
                isSelected: isSelected,
                summary: summary,
                onSelect: () => onSelectMember(member.userId),
                onView: () => onViewMember(member.userId),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMemberViewData member;
  final bool isSelected;
  final FamilySummaryViewData summary;
  final VoidCallback onSelect;
  final VoidCallback onView;

  const _MemberCard({
    required this.member,
    required this.isSelected,
    required this.summary,
    required this.onSelect,
    required this.onView,
  });

  String _fmtNum(num? v) {
    if (v == null) return '--';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final status = member.statusStyle;
    final vitals =
        member.latestVitals ??
        (member.recentVitals.isNotEmpty ? member.recentVitals.first : null);
    final bp = vitals?.bloodPressure ?? '--';
    final hr = _fmtNum(vitals?.heartRate);
    final glucose = _fmtNum(vitals?.glucoseLevel);
    final bmi = _fmtNum(vitals?.bmi);
    final relation = member.relationLabel(currentUserId: summary.currentUserId);
    final age = member.age != null ? '${member.age}' : '--';

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE8F1FF),
                  child: Text(
                    member.initials,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '$relation · $age yrs',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (summary.isAdmin) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'EDIT',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(status.backgroundHex),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(status.textHex),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LAST RECORDED VITALS',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'BP $bp | HR $hr | Glucose $glucose',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BMI $bmi',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _CardTextButton(
                  label: 'View',
                  color: AppColors.textSecondary,
                  onTap: onView,
                ),
                const Spacer(),
                _CardTextButton(
                  label: 'Select',
                  color: AppColors.primary,
                  onTap: onSelect,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTextButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CardTextButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
