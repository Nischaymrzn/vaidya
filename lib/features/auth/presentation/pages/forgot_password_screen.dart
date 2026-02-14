import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/my_button.dart';
import 'package:vaidya/core/widgets/my_text_form_field.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authViewModelProvider.notifier)
        .requestPasswordReset(email: _emailController.text.trim());
  }

  Future<void> _openEmailApp() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      SnackbarUtils.showError(context, 'Could not open email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.passwordResetEmailSent) {
        setState(() => _resetLinkSent = true);
        SnackbarUtils.showSuccess(
          context,
          next.successMessage ?? 'Reset link sent. Please check your email.',
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Enter your email and we will send a password reset link.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: _emailController,
                  text: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validationMessage: 'Email is required',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Send Reset Link',
                  height: 52,
                  radius: 12,
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleSendResetLink,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _openEmailApp,
                  child: const Text('Open Email App'),
                ),
                if (_resetLinkSent) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Reset link sent. Please open your email and continue there.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
