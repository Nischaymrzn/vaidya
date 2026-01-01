import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/divider_with_text.dart';
import 'package:vaidya/core/widgets/google_login_button.dart';
import 'package:vaidya/core/widgets/my_button.dart';
import 'package:vaidya/core/widgets/my_text_form_field.dart';
import 'package:vaidya/features/auth/presentation/pages/signup_screen.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  void _navigateToSignup() {
    AppRoutes.push(context, SignupScreen());
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password
    SnackbarUtils.showInfo(context, 'Forgot password feature coming soon');
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    SnackbarUtils.showInfo(context, 'Google Sign In coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        AppRoutes.pushReplacement(context, const DashboardScreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Image.asset('assets/images/logo.png', height: 90),

                SizedBox(height: 8),

                Text(
                  "Sign In",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 6),

                Text(
                  "Enter your credentials to continue",
                  style: TextStyle(fontSize: 18, color: Color(0xFF313131)),
                ),

                SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: _emailController,
                      text: "Enter your email",
                      validationMessage: "Email is required",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.mail,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 6),

                    MyTextFormField(
                      controller: _passwordController,
                      text: "Enter your password",
                      validationMessage: "Password is required",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      prefixIcon: Icon(
                        Icons.key_rounded,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    TextButton(
                      onPressed: _handleForgotPassword,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D8CFF),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                MyButton(
                  text: "Login",
                  height: 56,
                  radius: 12,
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleLogin,
                ),

                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    TextButton(
                      onPressed: _navigateToSignup,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF2D8CFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                DividerWithText(text: "Or"),

                SizedBox(height: 16),

                GoogleLoginButton(onPressed: _handleGoogleSignIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
