import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/features/profile/presentation/state/profile_state.dart';
import 'package:vaidya/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class ProfilePasswordSecurityScreen extends ConsumerStatefulWidget {
  const ProfilePasswordSecurityScreen({super.key});

  @override
  ConsumerState<ProfilePasswordSecurityScreen> createState() =>
      _ProfilePasswordSecurityScreenState();
}

class _ProfilePasswordSecurityScreenState
    extends ConsumerState<ProfilePasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _isPasswordReady {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (newPassword.isEmpty || confirmPassword.isEmpty) return false;
    if (newPassword.length < 8 || confirmPassword.length < 8) return false;
    return newPassword == confirmPassword;
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = AppColors.card;
    final borderColor = AppColors.border;
    final mutedColor = AppColors.textSecondary;

    final profileState = ref.watch(profileViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final isBusy =
        profileState.isSubmitting || authState.status == AuthStatus.loading;
    final canSubmitPassword = !isBusy && _isPasswordReady;

    ref.listen<ProfileState>(profileViewModelProvider, (prev, next) {
      final action = next.actionMessage;
      if (action != null && action != prev?.actionMessage) {
        SnackbarUtils.showSuccess(context, action);
      }
      final error = next.errorMessage;
      if (error != null && error != prev?.errorMessage) {
        SnackbarUtils.showError(context, error);
      }
    });

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      final success = next.successMessage;
      if (success != null && success != prev?.successMessage) {
        SnackbarUtils.showSuccess(context, success);
        ref.read(authViewModelProvider.notifier).clearSuccessMessage();
      }
      final error = next.errorMessage;
      if (error != null && error != prev?.errorMessage) {
        SnackbarUtils.showError(context, error);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Password & Security',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change password',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set a strong password for your account.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _passwordField(
                          controller: _newPasswordController,
                          label: 'New password',
                          borderColor: borderColor,
                          textColor: colorScheme.onSurface,
                          mutedColor: mutedColor,
                        ),
                        const SizedBox(height: 12),
                        _passwordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm new password',
                          borderColor: borderColor,
                          textColor: colorScheme.onSurface,
                          mutedColor: mutedColor,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canSubmitPassword
                                ? _updatePassword
                                : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              elevation: 0,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: colorScheme.primary
                                  .withValues(
                                    alpha: theme.brightness == Brightness.dark
                                        ? 0.45
                                        : 0.35,
                                  ),
                              disabledForegroundColor: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  canSubmitPassword
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_rounded,
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isBusy ? 'Updating...' : 'Update password',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!canSubmitPassword && !isBusy) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Enter matching passwords (min 8 characters) to unlock update.',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Send a password reset link to your registered email.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isBusy ? null : _sendResetEmail,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text(
                        authState.status == AuthStatus.loading
                            ? 'Sending...'
                            : 'Send reset link',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: (value) {
        final input = value?.trim() ?? '';
        if (input.isEmpty) return '$label is required';
        if (input.length < 8) return 'Password must be at least 8 characters';
        return null;
      },
      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mutedColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        isDense: true,
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      SnackbarUtils.showError(context, 'Passwords do not match.');
      return;
    }

    final userId = ref.read(userSessionServiceProvider).getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Unable to determine current user.');
      return;
    }

    final ok = await ref
        .read(profileViewModelProvider.notifier)
        .updatePassword(userId, _newPasswordController.text.trim());
    if (!ok) return;
    if (!mounted) return;
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _sendResetEmail() async {
    final email = ref.read(userSessionServiceProvider).getCurrentUserEmail();
    if (email == null || email.trim().isEmpty) {
      SnackbarUtils.showError(
        context,
        'No email found for this account. Update your profile first.',
      );
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .requestPasswordReset(email: email.trim());
  }
}
