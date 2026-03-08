import 'package:flutter/material.dart';
import 'package:vaidya/core/widgets/medication_card.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/family_health/presentation/models/family_health_view_data.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/themes/colors.dart';

class FamilyMemberPanel extends StatelessWidget {
  final FamilySummaryViewData summary;
  final FamilyMemberViewData member;
  final List<MedicalRecordEntity> records;
  final List<DashboardMedicationItemEntity> medications;
  final List<String> allergies;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onMemberChanged;
  final bool memberOnly;

  const FamilyMemberPanel({
    super.key,
    required this.summary,
    required this.member,
    required this.records,
    required this.medications,
    required this.allergies,
    required this.activeTab,
    required this.onTabChanged,
    required this.onMemberChanged,
    this.memberOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MemberHeader(member: member, currentUserId: summary.currentUserId),
          if (summary.isAdmin) ...[
            const SizedBox(height: 12),
            _MemberDropdown(
              summary: summary,
              selectedUserId: member.userId,
              onChanged: onMemberChanged,
            ),
          ],
          const SizedBox(height: 14),
          _TabBar(activeTab: activeTab, onTabChanged: onTabChanged),
          const SizedBox(height: 14),
          _TabContent(
            summary: summary,
            member: member,
            records: records,
            medications: medications,
            allergies: allergies,
            activeTab: activeTab,
            memberOnly: memberOnly,
          ),
        ],
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  final FamilyMemberViewData member;
  final String? currentUserId;

  const _MemberHeader({required this.member, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final status = member.statusStyle;
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primarySoft,
          child: Text(
            member.initials,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${member.relationLabel(currentUserId: currentUserId)} | ${member.age ?? '--'} yrs | Last update ${_formatDate(member.lastUpdated)}',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color(status.backgroundHex),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(status.textHex),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberDropdown extends StatelessWidget {
  final FamilySummaryViewData summary;
  final String selectedUserId;
  final ValueChanged<String> onChanged;

  const _MemberDropdown({
    required this.summary,
    required this.selectedUserId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        color: AppColors.card,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedUserId,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: summary.members.map((m) {
            return DropdownMenuItem(
              value: m.userId,
              child: Text(
                '${m.displayName} (${m.relationLabel(currentUserId: summary.currentUserId)})',
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _TabBar({required this.activeTab, required this.onTabChanged});

  static const _tabs = [
    'Overview',
    'Vitals history',
    'Medical records',
    'Allergies',
    'Medications',
    'AI consults',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = activeTab == i;
          return Padding(
            padding: EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? AppColors.textPrimary : AppColors.border,
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final FamilySummaryViewData summary;
  final FamilyMemberViewData member;
  final List<MedicalRecordEntity> records;
  final List<DashboardMedicationItemEntity> medications;
  final List<String> allergies;
  final int activeTab;
  final bool memberOnly;

  const _TabContent({
    required this.summary,
    required this.member,
    required this.records,
    required this.medications,
    required this.allergies,
    required this.activeTab,
    required this.memberOnly,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = member.userId == summary.currentUserId;
    final canAccessMemberRecords = isSelf || summary.isAdmin;
    switch (activeTab) {
      case 0:
        return _OverviewTab(
          member: member,
          memberOnly: memberOnly,
          summary: summary,
        );
      case 1:
        return _VitalsHistoryTab(member: member);
      case 2:
        return _MedicalRecordsTab(
          records: records,
          canView: canAccessMemberRecords,
        );
      case 3:
        return _AllergiesTab(
          allergies: allergies,
          canView: canAccessMemberRecords,
        );
      case 4:
        return _MedicationsTab(
          medications: medications,
          canView: canAccessMemberRecords,
        );
      default:
        return _PlaceholderCard(
          text: 'AI consultation history will appear after sessions.',
        );
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final FamilyMemberViewData member;
  final FamilySummaryViewData summary;
  final bool memberOnly;

  const _OverviewTab({
    required this.member,
    required this.summary,
    this.memberOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final v = member.latestVitals;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: constraints.maxWidth >= 500
                      ? cardWidth
                      : double.infinity,
                  child: _InfoCard(
                    title: 'LATEST VITALS',
                    children: [
                      _KVRow(
                        label: 'Blood pressure',
                        value: v?.bloodPressure ?? '--',
                      ),
                      _KVRow(label: 'Heart rate', value: _fmt(v?.heartRate)),
                      _KVRow(label: 'Glucose', value: _fmt(v?.glucoseLevel)),
                      _KVRow(label: 'BMI', value: _fmt(v?.bmi)),
                    ],
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth >= 500
                      ? cardWidth
                      : double.infinity,
                  child: _InfoCard(
                    title: 'PROFILE INFO',
                    children: [
                      _KVRow(label: 'Age', value: '${member.age ?? '--'} yrs'),
                      _KVRow(label: 'Gender', value: member.gender ?? '--'),
                      _KVRow(
                        label: 'Health score',
                        value: '${member.healthScore ?? '--'}',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: _AlertCard(status: member.status),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _fmt(num? v) {
    if (v == null) return '--';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;

  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final FamilyMemberStatus status;
  const _AlertCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = switch (status) {
      FamilyMemberStatus.critical => 'Immediate follow-up recommended.',
      FamilyMemberStatus.warning => 'Monitor vitals in next 24 hours.',
      FamilyMemberStatus.stable => 'Stable vitals in the last 7 days.',
    };

    final alertBg = switch (status) {
      FamilyMemberStatus.critical => isDark
          ? AppColors.dangerSurface
          : Color(0xFFFEE2E2),
      FamilyMemberStatus.warning => isDark
          ? AppColors.warningSurface
          : Color(0xFFFFF8E8),
      FamilyMemberStatus.stable => isDark
          ? AppColors.primary.withValues(alpha: 0.16)
          : Color(0xFFEAF3FF),
    };

    final alertFg = switch (status) {
      FamilyMemberStatus.critical => Color(0xFFDC2626),
      FamilyMemberStatus.warning => Color(0xFF9A6700),
      FamilyMemberStatus.stable => AppColors.primary,
    };

    final alertIcon = switch (status) {
      FamilyMemberStatus.critical => Icons.warning_amber_rounded,
      FamilyMemberStatus.warning => Icons.info_outline_rounded,
      FamilyMemberStatus.stable => Icons.check_circle_outline_rounded,
    };

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE ALERTS',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alertBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(alertIcon, size: 18, color: alertFg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: alertFg,
                    ),
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

class _VitalsHistoryTab extends StatelessWidget {
  final FamilyMemberViewData member;
  const _VitalsHistoryTab({required this.member});

  @override
  Widget build(BuildContext context) {
    final items = [...member.recentVitals]
      ..sort(
        (a, b) => (b.recordedAt?.millisecondsSinceEpoch ?? 0).compareTo(
          a.recordedAt?.millisecondsSinceEpoch ?? 0,
        ),
      );

    if (items.isEmpty) {
      return _PlaceholderCard(text: 'No vitals history recorded yet.');
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.surfaceSoft,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'DATE',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'HEART',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'BP',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'GLUCOSE',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'BMI',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          ...items.take(4).map((e) => _VitalsRow(vitals: e)),
        ],
      ),
    );
  }
}

class _VitalsRow extends StatelessWidget {
  final FamilyVitalsViewData vitals;
  const _VitalsRow({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(vitals.recordedAt),
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _fmt(vitals.heartRate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: vitals.heartRate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              vitals.bloodPressure,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: vitals.systolicBp != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _fmt(vitals.glucoseLevel),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: vitals.glucoseLevel != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _fmt(vitals.bmi),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: vitals.bmi != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num? v) {
    if (v == null) return '--';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _MedicalRecordsTab extends StatelessWidget {
  final List<MedicalRecordEntity> records;
  final bool canView;
  const _MedicalRecordsTab({required this.records, required this.canView});

  @override
  Widget build(BuildContext context) {
    if (!canView) {
      return _PlaceholderCard(
        text: 'Medical records are available only to the member.',
      );
    }

    final items = [...records]
      ..sort((a, b) {
        final aDate =
            DateTime.tryParse(a.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        final bDate =
            DateTime.tryParse(b.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        return bDate.compareTo(aDate);
      });
    final visible = items.take(2).toList(growable: false);
    if (visible.isEmpty) {
      return _PlaceholderCard(text: 'No medical records available yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Medical Records',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visible.length,
            separatorBuilder: (context, index) =>
                Divider(color: AppColors.border, thickness: 1.2, height: 2),
            itemBuilder: (context, index) {
              final record = visible[index];
              return MedicationCard(
                iconPath: index.isEven
                    ? 'assets/icons/file_2.svg'
                    : 'assets/icons/file_1.svg',
                title: record.title,
                date: _formatDateFromString(record.effectiveDate),
                hospital: (record.provider?.trim().isNotEmpty ?? false)
                    ? record.provider!.trim()
                    : 'Unspecified',
              );
            },
          ),
        ),
        SizedBox(height: 6),
        TextButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => DashboardScreen(initialIndex: 1),
            ),
            (_) => false,
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Open Health Records'),
        ),
      ],
    );
  }
}

class _AllergiesTab extends StatelessWidget {
  final List<String> allergies;
  final bool canView;
  const _AllergiesTab({required this.allergies, required this.canView});

  @override
  Widget build(BuildContext context) {
    if (!canView) {
      return _PlaceholderCard(
        text:
            'Allergy details are available only to the member or family admin.',
      );
    }

    final visible = allergies
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .take(3)
        .toList(growable: false);

    if (visible.isEmpty) {
      return _PlaceholderCard(text: 'No allergies recorded.');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: visible
            .map(
              (item) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.card,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
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
}

class _MedicationsTab extends StatelessWidget {
  final List<DashboardMedicationItemEntity> medications;
  final bool canView;
  const _MedicationsTab({required this.medications, required this.canView});

  @override
  Widget build(BuildContext context) {
    if (!canView) {
      return _PlaceholderCard(
        text:
            'Medication details are available only to the member or family admin.',
      );
    }
    final visible = medications.take(3).toList(growable: false);
    if (visible.isEmpty) {
      return _PlaceholderCard(text: 'No medications on file.');
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: visible
            .map(
              (item) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.name} - ${item.dose}',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            item.meta ?? 'Medication on file',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Effective',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
}

class _PlaceholderCard extends StatelessWidget {
  final String text;
  const _PlaceholderCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

String _formatDateFromString(String value) {
  final parsed = DateTime.tryParse(value);
  return _formatDate(parsed);
}

String _formatDate(DateTime? d) {
  if (d == null) return '--';
  const months = [
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
  return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
}

