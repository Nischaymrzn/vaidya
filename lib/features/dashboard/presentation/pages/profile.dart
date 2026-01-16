import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/features/auth/presentation/pages/login_screen.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';

final currentUserNameProvider = Provider<String?>((ref) {
  final session = ref.read(userSessionServiceProvider);
  return session.getCurrentUserFullName();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentUserNameProvider);

    return SizedBox.expand(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name != null ? "Hello, $name" : "Hello Nischay Maharjan",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: 120,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 22),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showLogoutDialog(context, ref),
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
