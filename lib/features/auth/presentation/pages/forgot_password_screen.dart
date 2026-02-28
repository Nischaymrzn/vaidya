import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/my_button.dart';
import 'package:vaidya/core/widgets/my_text_form_field.dart';
import 'package:vaidya/features/auth/presentation/pages/forgot_password_sent_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.passwordResetEmailSent) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ForgotPasswordSentScreen(
              email: _emailController.text.trim(),
            ),
          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
