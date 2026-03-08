import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/intelligence/presentation/models/vaidya_care_doctor_profile.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_ai_screen.dart';
import 'package:vaidya/features/intelligence/presentation/pages/vaidya_care_consult_screen.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/vaidya_care_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class VaidyaCareScreen extends ConsumerStatefulWidget {
  const VaidyaCareScreen({super.key});

  @override
  ConsumerState<VaidyaCareScreen> createState() => _VaidyaCareScreenState();
}

class _VaidyaCareScreenState extends ConsumerState<VaidyaCareScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = ref.read(vaidyaCareViewModelProvider).searchQuery;
      _searchController.text = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openMainTab(MainBottomNavItem item) {
    final targetIndex = switch (item) {
      MainBottomNavItem.home => 0,
      MainBottomNavItem.records => 1,
      MainBottomNavItem.intelligence => 2,
      MainBottomNavItem.analytics => 3,
      MainBottomNavItem.profile => 4,
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialIndex: targetIndex),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(vaidyaCareViewModelProvider);
    final vm = ref.read(vaidyaCareViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppSideDrawer(
        currentDestination: AppDrawerDestination.vaidyaCare,
      ),
      bottomNavigationBar: AppMainBottomNav(
        activeItem: null,
        onTap: _openMainTab,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: AppDrawerToggleButton(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
        title: Text(
          'Vaidya Care',
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F7AE0), Color(0xFF2E84E8)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start a guided health consult',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                  fontSize: 31,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Each doctor focuses on a specialty with tailored prompts and next-step advice.',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Color(0xE6FFFFFF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VaidyaAiScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.card
                                : Colors.white,
                            foregroundColor: isDark
                                ? AppColors.textPrimary
                                : AppColors.primary,
                            minimumSize: const Size(128, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            'Open Vaidya.ai',
                            style: TextStyle(fontFamily: 'Urbanist'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSoft : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 4),
                          Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: vm.updateSearchQuery,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Search a doctor or specialty...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => FocusScope.of(context).unfocus(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(108, 38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Find Doctor',
                              style: TextStyle(fontFamily: 'Urbanist'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width >= 1280) {
                  crossAxisCount = 3;
                } else if (width >= 780) {
                  crossAxisCount = 2;
                }

                final doctors = state.filteredDoctors;
                if (doctors.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      color: AppColors.card,
                    ),
                    child: Center(
                      child: Text(
                        'No doctors found. Try a different search.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: AppColors.textSecondary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                if (crossAxisCount == 1) {
                  return Column(
                    children: doctors
                        .map(
                          (doctor) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: _DoctorCard(
                                doctor: doctor,
                                onStartConsult: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => VaidyaCareConsultScreen(
                                        doctorId: doctor.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: crossAxisCount == 2 ? 282 : 300,
                  ),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return _DoctorCard(
                      doctor: doctor,
                      onStartConsult: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                VaidyaCareConsultScreen(doctorId: doctor.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final VaidyaCareDoctorProfile doctor;
  final VoidCallback onStartConsult;

  const _DoctorCard({required this.doctor, required this.onStartConsult});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Image.asset(
                    doctor.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        ColoredBox(color: AppColors.surfaceMuted),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        doctor.title,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: doctor.tags
                  .map(
                    (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.surfaceSoft,
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStartConsult,
                style: FilledButton.styleFrom(
                  minimumSize: Size(0, 42),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Start consult',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
