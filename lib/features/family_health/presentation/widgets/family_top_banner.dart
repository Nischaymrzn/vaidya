import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/features/family_health/presentation/models/family_health_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class FamilyTopBanner extends StatelessWidget {
  final FamilySummaryViewData summary;
  final bool hasCritical;
  final VoidCallback onAddMember;
  final VoidCallback onInviteMember;
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;
  final VoidCallback onEmergencyAlert;

  const FamilyTopBanner({
    super.key,
    required this.summary,
    required this.hasCritical,
    required this.onAddMember,
    required this.onInviteMember,
    required this.onCreateGroup,
    required this.onJoinGroup,
    required this.onEmergencyAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppDrawerToggleButton(
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                summary.title,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _RoleBadge(isAdmin: summary.isAdmin),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Monitor family vitals, health trends, and AI-guided insights in one place.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 13,
                            color: Color(0xFFDCEAFE),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ActionButtonsRow(
                hasGroup: summary.hasGroup,
                isAdmin: summary.isAdmin,
                hasCritical: hasCritical,
                onAddMember: onAddMember,
                onInviteMember: onInviteMember,
                onCreateGroup: onCreateGroup,
                onJoinGroup: onJoinGroup,
                onEmergencyAlert: onEmergencyAlert,
              ),
              const SizedBox(height: 14),
              _StatsGrid(summary: summary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;
  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAdmin ? 'Family Admin' : 'Family Member',
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  final bool hasGroup;
  final bool isAdmin;
  final bool hasCritical;
  final VoidCallback onAddMember;
  final VoidCallback onInviteMember;
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;
  final VoidCallback onEmergencyAlert;

  const _ActionButtonsRow({
    required this.hasGroup,
    required this.isAdmin,
    required this.hasCritical,
    required this.onAddMember,
    required this.onInviteMember,
    required this.onCreateGroup,
    required this.onJoinGroup,
    required this.onEmergencyAlert,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (hasGroup && isAdmin) ...[
            _BannerActionButton(
              label: 'Add member',
              icon: LucideIcons.plus,
              filled: true,
              onTap: onAddMember,
            ),
            const SizedBox(width: 8),
            _BannerActionButton(
              label: 'Invite member',
              icon: LucideIcons.mail,
              onTap: onInviteMember,
            ),
            const SizedBox(width: 8),
          ],
          if (!hasGroup) ...[
            _BannerActionButton(
              label: 'Create group',
              icon: LucideIcons.plus,
              filled: true,
              onTap: onCreateGroup,
            ),
            const SizedBox(width: 8),
            _BannerActionButton(
              label: 'Join group',
              icon: LucideIcons.link,
              onTap: onJoinGroup,
            ),
            const SizedBox(width: 8),
          ],
          _BannerActionButton(
            label: 'Emergency alert',
            icon: LucideIcons.shieldAlert,
            danger: hasCritical,
            onTap: onEmergencyAlert,
          ),
        ],
      ),
    );
  }
}

class _BannerActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool danger;
  final VoidCallback onTap;

  const _BannerActionButton({
    required this.label,
    required this.icon,
    this.filled = false,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = danger
        ? const Color(0xFFDC2626)
        : filled
        ? Colors.white
        : Colors.transparent;
    final fg = danger
        ? Colors.white
        : filled
        ? AppColors.primary
        : Colors.white;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: fg),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide(
          color: danger
              ? const Color(0xFFDC2626)
              : filled
              ? Colors.white
              : Colors.white54,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final FamilySummaryViewData summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Keep cards slightly taller to avoid tiny bottom overflow on devices
        // with higher text scale / font metrics.
        mainAxisExtent: 100,
      ),
      children: [
        _StatCard(
          label: 'TOTAL MEMBERS',
          value: '${summary.totalMembers}',
          detail: 'Active in group',
        ),
        _StatCard(
          label: 'STABLE',
          value: '${summary.stableCount}',
          detail: 'On track',
        ),
        _StatCard(
          label: 'WATCH',
          value: '${summary.watchCount}',
          detail: 'Needs attention',
        ),
        _StatCard(
          label: 'FAMILY SCORE',
          value: '${summary.averageHealthScore}',
          detail: 'Average index',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _StatCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDCEAFE),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFDCEAFE),
            ),
          ),
        ],
      ),
    );
  }
}
