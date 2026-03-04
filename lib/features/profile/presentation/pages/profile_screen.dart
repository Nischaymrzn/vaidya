import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/features/auth/presentation/pages/login_screen.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/features/profile/presentation/pages/personal_information_screen.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/themes/colors.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';

final currentUserNameProvider = Provider<String?>((ref) {
  final session = ref.read(userSessionServiceProvider);
  return session.getCurrentUserFullName();
});

final currentUserEmailProvider = Provider<String?>((ref) {
  final session = ref.read(userSessionServiceProvider);
  try {
    return session.getCurrentUserEmail();
  } catch (_) {
    return null;
  }
});

final currentUserProfileProvider = Provider<String?>((ref) {
  final session = ref.read(userSessionServiceProvider);
  try {
    return session.getCurrentUserProfilePicture();
  } catch (_) {
    return null;
  }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.read(userSessionServiceProvider);
    final name = session.getCurrentUserFullName() ?? 'User';
    final email = ref.watch(currentUserEmailProvider) ?? '';
    final profile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.profile,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const AppDrawerToggleButton(color: AppColors.textPrimary),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.2),
                      image: DecorationImage(
                        // you can replace with NetworkImage from session if available
                        image: profile != null && profile.isNotEmpty
                            ? NetworkImage(profile) // Cloudinary URL
                            : const AssetImage(
                                    'assets/images/avatar_placeholder.png',
                                  )
                                  as ImageProvider, // fallback
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: Account
            _SectionCard(
              title: 'Account',
              children: [
                _ProfileListTile(
                  label: 'Personal Information',
                  leading: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _ProfileListTile(
                  label: 'Password & Security',
                  leading: Icons.lock_outline,
                  onTap: () {
                    // TODO: navigate to password & security page
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Section: General
            _SectionCard(
              title: 'General',
              children: [
                _ProfileListTile(
                  label: 'Notification',
                  leading: Icons.notifications_none,
                  onTap: () {
                    // TODO: navigate to notification settings
                  },
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _ProfileListTile(
                  label: 'Theme',
                  leading: Icons.palette_outlined,
                  onTap: () {
                    // TODO: navigate to theme settings
                  },
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _ProfileListTile(
                  label: 'Health Preferences',
                  leading: Icons.monitor_heart_outlined,
                  onTap: () {
                    // TODO: navigate to health preferences
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Section: Support
            _SectionCard(
              title: 'Support',
              children: [
                _ProfileListTile(
                  label: 'Health Centre',
                  leading: Icons.headset_mic_outlined,
                  onTap: () {
                    // TODO: navigate to health centre
                  },
                ),

                const Divider(height: 1, thickness: 1, color: AppColors.border),
                _ProfileListTile(
                  label: 'Contact Us',
                  leading: Icons.call_outlined,
                  onTap: () {
                    // TODO: open contact us
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Logout button row (separate)
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    Future<void> handleLogout() async {
      AppRoutes.pop(context);

      await ref.read(authViewModelProvider.notifier).logout();

      if (context.mounted) {
        AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => AppRoutes.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: handleLogout,
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small reusable widget for the section cards
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Reusable list tile used inside section cards
class _ProfileListTile extends StatelessWidget {
  final String label;
  final IconData leading;
  final VoidCallback? onTap;

  const _ProfileListTile({
    required this.label,
    required this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(leading, color: AppColors.textSecondary),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ],
    );
  }
}
