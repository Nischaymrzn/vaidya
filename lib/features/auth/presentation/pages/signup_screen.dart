import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/divider_with_text.dart';
import 'package:vaidya/core/widgets/google_login_button.dart';
import 'package:vaidya/core/widgets/my_button.dart';
import 'package:vaidya/core/widgets/my_text_form_field.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authViewModelProvider.notifier)
          .register(
            fullName: _nameController.text,
            email: _emailController.text,
            role: "user",
            number: _phoneController.text.isNotEmpty
                ? int.tryParse(_phoneController.text)
                : null,
            password: _passwordController.text,
          );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google Sign In
    SnackbarUtils.showInfo(context, 'Google Sign In coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == previous?.status) return;

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(
          context,
          next.errorMessage ?? 'Registration successful! Please login.',
        );
        ref.read(authViewModelProvider.notifier).resetState();
        Navigator.of(context).pop();
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? "Registration failed!",
        );
        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12),

                Image.asset('assets/images/logo.png', height: 90),

                Text(
                  "Sign up",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4),

                Text(
                  "Set up your Vaidya account now",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Color(0xFF313131)),
                ),

                SizedBox(height: 18),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 3),

                    MyTextFormField(
                      controller: _nameController,
                      text: "Enter your full name",
                      validationMessage: "Full name is required",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 12),

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

                    SizedBox(height: 3),

                    MyTextFormField(
                      controller: _emailController,
                      text: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      validationMessage: "Email is required",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
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
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 3),

                    MyTextFormField(
                      controller: _phoneController,
                      text: "Enter your number",
                      keyboardType: TextInputType.phone,
                      validationMessage: "Phone number is required",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number is required";
                        }

                        if (value.length != 10) {
                          return "Enter 10 digit phone number";
                        }

                        return null;
                      },
                      prefixIcon: Icon(
                        Icons.phone_android,
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

                    SizedBox(height: 3),

                    MyTextFormField(
                      controller: _passwordController,
                      text: "Enter your password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validationMessage: "Password is required",
                      prefixIcon: Icon(
                        Icons.key_rounded,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 3),

                    MyTextFormField(
                      controller: _confirmPasswordController,
                      text: "Re-enter password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validationMessage: "Confirm Password is required",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm your password";
                        }

                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }

                        return null;
                      },
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                MyButton(
                  text: "Create Account",
                  height: 56,
                  radius: 14,
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _handleSignup,
                ),

                SizedBox(height: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: Color(0xFF2D8CFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                DividerWithText(text: "Or"),

                SizedBox(height: 12),

                GoogleLoginButton(onPressed: _handleGoogleSignIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
