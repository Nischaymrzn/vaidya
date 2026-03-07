import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/family_health/presentation/pages/family_health_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_care_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_ai_screen.dart';
import 'package:vaidya/features/symptoms/presentation/pages/symptoms_screen.dart';
import 'package:vaidya/features/vitals/presentation/pages/vitals_screen.dart';
import 'package:vaidya/themes/colors.dart';

enum AppDrawerDestination {
  home,
  familyHealth,
  records,
  vitals,
  symptoms,
  analytics,
  riskAnalysis,
  vaidyaCare,
  vaidyaAi,
  profile,
}

class AppSideDrawer extends StatefulWidget {
  final AppDrawerDestination currentDestination;

  const AppSideDrawer({
    super.key,
    this.currentDestination = AppDrawerDestination.home,
  });

  @override
  State<AppSideDrawer> createState() => _AppSideDrawerState();
}

class _AppSideDrawerState extends State<AppSideDrawer> {
  bool _healthOverviewExpanded = true;
  bool _healthIntelligenceExpanded = true;

  void _openDashboardTab(int tabIndex) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialIndex: tabIndex),
      ),
      (_) => false,
    );
  }

  void _openStandalone(Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Material(
        color: selected ? const Color(0xFFE8F1FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subMenuItem({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 12, top: 1, bottom: 1),
      child: Row(
        children: [
          Container(width: 1, height: 34, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: selected ? const Color(0xFFE8F1FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 10,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 14),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vaidya.ai',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.panelLeftClose,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _sectionLabel('GENERAL'),
            _menuItem(
              icon: LucideIcons.layoutDashboard,
              label: 'Home',
              selected: widget.currentDestination == AppDrawerDestination.home,
              onTap: () {
                if (widget.currentDestination == AppDrawerDestination.home) {
                  Navigator.of(context).pop();
                  return;
                }
                _openDashboardTab(0);
              },
            ),
            _menuItem(
              icon: LucideIcons.users,
              label: 'Family Health',
              selected:
                  widget.currentDestination ==
                  AppDrawerDestination.familyHealth,
              onTap: () {
                if (widget.currentDestination ==
                    AppDrawerDestination.familyHealth) {
                  Navigator.of(context).pop();
                  return;
                }
                _openStandalone(const FamilyHealthScreen());
              },
            ),
            _menuItem(
              icon: LucideIcons.folderHeart,
              label: 'Health Records',
              selected:
                  widget.currentDestination == AppDrawerDestination.records,
              onTap: () {
                if (widget.currentDestination == AppDrawerDestination.records) {
                  Navigator.of(context).pop();
                  return;
                }
                _openDashboardTab(1);
              },
            ),
            _menuItem(
              icon: LucideIcons.squareActivity,
              label: 'Health Overview',
              selected: false,
              trailing: Icon(
                _healthOverviewExpanded
                    ? LucideIcons.chevronUp
                    : LucideIcons.chevronDown,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                setState(() {
                  _healthOverviewExpanded = !_healthOverviewExpanded;
                });
              },
            ),
            if (_healthOverviewExpanded) ...[
              _subMenuItem(
                label: 'Vitals',
                selected:
                    widget.currentDestination == AppDrawerDestination.vitals,
                onTap: () {
                  if (widget.currentDestination ==
                      AppDrawerDestination.vitals) {
                    Navigator.of(context).pop();
                    return;
                  }
                  _openStandalone(const VitalsScreen());
                },
              ),
              _subMenuItem(
                label: 'Symptoms',
                selected:
                    widget.currentDestination == AppDrawerDestination.symptoms,
                onTap: () {
                  if (widget.currentDestination ==
                      AppDrawerDestination.symptoms) {
                    Navigator.of(context).pop();
                    return;
                  }
                  _openStandalone(const SymptomsScreen());
                },
              ),
            ],
            _menuItem(
              icon: LucideIcons.chartColumnBig,
              label: 'Analytics',
              selected:
                  widget.currentDestination == AppDrawerDestination.analytics,
              onTap: () {
                if (widget.currentDestination ==
                    AppDrawerDestination.analytics) {
                  Navigator.of(context).pop();
                  return;
                }
                _openDashboardTab(3);
              },
            ),
            _menuItem(
              icon: LucideIcons.brain,
              label: 'Health Intelligence',
              selected: false,
              trailing: Icon(
                _healthIntelligenceExpanded
                    ? LucideIcons.chevronUp
                    : LucideIcons.chevronDown,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                setState(() {
                  _healthIntelligenceExpanded = !_healthIntelligenceExpanded;
                });
              },
            ),
            if (_healthIntelligenceExpanded) ...[
              _subMenuItem(
                label: 'Risk Analysis',
                selected:
                    widget.currentDestination ==
                    AppDrawerDestination.riskAnalysis,
                onTap: () {
                  if (widget.currentDestination ==
                      AppDrawerDestination.riskAnalysis) {
                    Navigator.of(context).pop();
                    return;
                  }
                  _openDashboardTab(2);
                },
              ),
              _subMenuItem(
                label: 'Vaidya Care',
                selected:
                    widget.currentDestination == AppDrawerDestination.vaidyaCare,
                onTap: () {
                  if (widget.currentDestination ==
                      AppDrawerDestination.vaidyaCare) {
                    Navigator.of(context).pop();
                    return;
                  }
                  _openStandalone(const VaidyaCareScreen());
                },
              ),
              _subMenuItem(
                label: 'Vaidya.ai',
                selected:
                    widget.currentDestination == AppDrawerDestination.vaidyaAi,
                onTap: () {
                  if (widget.currentDestination ==
                      AppDrawerDestination.vaidyaAi) {
                    Navigator.of(context).pop();
                    return;
                  }
                  _openStandalone(const VaidyaAiScreen());
                },
              ),
            ],
            const SizedBox(height: 16),
            _sectionLabel('OTHERS'),
            _menuItem(
              icon: LucideIcons.user,
              label: 'Profile',
              selected:
                  widget.currentDestination == AppDrawerDestination.profile,
              onTap: () {
                if (widget.currentDestination == AppDrawerDestination.profile) {
                  Navigator.of(context).pop();
                  return;
                }
                _openDashboardTab(4);
              },
            ),
          ],
        ),
      ),
    );
  }
}
