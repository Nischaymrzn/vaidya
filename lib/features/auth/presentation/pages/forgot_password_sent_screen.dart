import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/my_button.dart';

class ForgotPasswordSentScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordSentScreen({super.key, required this.email});

  Future<void> _openEmailApp(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email.trim().isEmpty ? null : email.trim(),
    );

    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      SnackbarUtils.showError(context, 'Could not open email app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Link Sent')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 18),
                const Text(
                  'Reset Link Has Been Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  email.trim().isEmpty
                      ? 'Please check your email for the password reset link.'
                      : 'We sent a password reset link to $email.\nPlease check your email.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF525252),
                  ),
                ),
                const SizedBox(height: 22),
                MyButton(
                  text: 'Open Email App',
                  height: 52,
                  radius: 12,
                  onPressed: () => _openEmailApp(context),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => AppRoutes.popToFirst(context),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
