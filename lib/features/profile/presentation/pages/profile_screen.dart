import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/app_drawer_toggle_button.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/auth/presentation/pages/login_screen.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_checkout_webview_screen.dart';
import 'package:vaidya/features/profile/presentation/pages/personal_information_screen.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_password_security_screen.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_sensor_demo_screen.dart';
import 'package:vaidya/features/profile/presentation/pages/profile_theme_screen.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';
import 'package:vaidya/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(userSessionServiceProvider);
      final userId = session.getCurrentUserId();
      if (userId != null && userId.trim().isNotEmpty) {
        ref
            .read(profileViewModelProvider.notifier)
            .load(userId, forceLoading: true);
      }
      ref.read(profileViewModelProvider.notifier).loadPaymentStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final data = state.user?.data ?? const <String, dynamic>{};

    final theme = Theme.of(context);
    AppColors.sync(theme.brightness);
    final colorScheme = theme.colorScheme;
    final cardColor = AppColors.card;
    final borderColor = AppColors.border;
    final mutedColor = AppColors.textSecondary;

    final name = (data['name'] ?? session.getCurrentUserFullName() ?? 'User')
        .toString();
    final email = (data['email'] ?? session.getCurrentUserEmail() ?? '')
        .toString();
    final profilePicture =
        (data['profilePicture'] ?? session.getCurrentUserProfilePicture())
            ?.toString();

    final isPremium = state.isPremium || session.getCurrentUserIsPremium();
    final planLabel = isPremium ? 'Premium' : 'Free';

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      final action = next.actionMessage;
      if (action != null && action != previous?.actionMessage) {
        SnackbarUtils.showSuccess(context, action);
      }
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        SnackbarUtils.showError(context, error);
      }
      final paymentMessage = next.paymentMessage;
      if (paymentMessage != null &&
          paymentMessage != previous?.paymentMessage &&
          !next.isCheckingPremium) {
        SnackbarUtils.showWarning(context, paymentMessage);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.profile,
      ),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: AppDrawerToggleButton(color: colorScheme.onSurface),
        title: Text(
          'My Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1.2),
                      image: DecorationImage(
                        image:
                            profilePicture != null && profilePicture.isNotEmpty
                            ? NetworkImage(profilePicture)
                            : const AssetImage(
                                    'assets/images/avatar_placeholder.png',
                                  )
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? Color(0xFFDCFCE7)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Plan: $planLabel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isPremium
                                  ? const Color(0xFF166534)
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!isPremium)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton(
                                onPressed: state.isUpgradingPremium
                                    ? null
                                    : () => _upgradeToPremium(context),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  side: BorderSide(color: borderColor),
                                ),
                                child: Text(
                                  state.isUpgradingPremium
                                      ? 'Redirecting to Stripe...'
                                      : 'Upgrade to Premium',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Premium unlocks disease report PDF downloads.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Premium is active on your account.',
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Account',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedColor: mutedColor,
              children: [
                _ProfileListTile(
                  label: 'Personal Information',
                  leading: Icons.person_outline,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => AppRoutes.push(
                    context,
                    const PersonalInformationScreen(),
                  ),
                ),
                Divider(height: 1, color: borderColor),
                _ProfileListTile(
                  label: 'Password & Security',
                  leading: Icons.lock_outline,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => AppRoutes.push(
                    context,
                    const ProfilePasswordSecurityScreen(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'General',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedColor: mutedColor,
              children: [
                _ProfileListTile(
                  label: 'Notification',
                  leading: Icons.notifications_none_rounded,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => _showStaticMessage(
                    context,
                    'Notification settings coming soon.',
                  ),
                ),
                Divider(height: 1, color: borderColor),
                _ProfileListTile(
                  label: 'Theme',
                  leading: Icons.palette_outlined,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () =>
                      AppRoutes.push(context, const ProfileThemeScreen()),
                ),
                Divider(height: 1, color: borderColor),
                _ProfileListTile(
                  label: 'Health preferences',
                  leading: Icons.favorite_border_rounded,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => _showStaticMessage(
                    context,
                    'Health preferences will be available soon.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Sensor',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedColor: mutedColor,
              children: [
                _ProfileListTile(
                  label: 'Light & Accelerometer',
                  leading: Icons.sensors_outlined,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => AppRoutes.push(
                    context,
                    const ProfileSensorDemoScreen(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Support',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedColor: mutedColor,
              children: [
                _ProfileListTile(
                  label: 'Contact us',
                  leading: Icons.mail_outline_rounded,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => _showStaticMessage(
                    context,
                    'Contact support flow coming soon.',
                  ),
                ),
                Divider(height: 1, color: borderColor),
                _ProfileListTile(
                  label: 'Log out',
                  leading: Icons.logout_rounded,
                  color: colorScheme.onSurface,
                  mutedColor: mutedColor,
                  onTap: () => _showLogoutDialog(context),
                ),
                Divider(height: 1, color: borderColor),
                _ProfileListTile(
                  label: 'Delete account',
                  leading: Icons.delete_outline_rounded,
                  color: const Color(0xFFDC2626),
                  mutedColor: const Color(0xFFDC2626),
                  onTap: () => _showStaticMessage(
                    context,
                    'Delete account flow is not enabled yet.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStaticMessage(BuildContext context, String message) {
    SnackbarUtils.showInfo(context, message);
  }

  Future<void> _upgradeToPremium(BuildContext context) async {
    final checkoutUrl = await ref
        .read(profileViewModelProvider.notifier)
        .startPremiumCheckout();
    if (!context.mounted) return;
    if (checkoutUrl == null || checkoutUrl.trim().isEmpty) return;

    final uri = Uri.tryParse(checkoutUrl.trim());
    if (uri == null) {
      SnackbarUtils.showError(context, 'Invalid checkout URL received.');
      return;
    }
    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            ProfileCheckoutWebviewScreen(checkoutUrl: uri.toString()),
      ),
    );
    if (!context.mounted) return;
    if (success == true) {
      await ref.read(profileViewModelProvider.notifier).loadPaymentStatus();
      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Payment successful. Premium activated.',
        );
      }
    } else if (success == false) {
      SnackbarUtils.showInfo(context, 'Payment was cancelled.');
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => AppRoutes.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: handleLogout,
            child: const Text(
              'Logout',
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Color borderColor;
  final Color mutedColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.cardColor,
    required this.borderColor,
    required this.mutedColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: mutedColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final String label;
  final IconData leading;
  final Color color;
  final Color mutedColor;
  final VoidCallback onTap;

  const _ProfileListTile({
    required this.label,
    required this.leading,
    required this.color,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(leading, color: mutedColor),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14.5,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: mutedColor),
      onTap: onTap,
    );
  }
}
