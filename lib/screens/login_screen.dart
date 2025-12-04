import 'package:flutter/material.dart';
import 'package:vaidya/common/my_snackbar.dart';
import 'package:vaidya/widgets/divider_with_text.dart';
import 'package:vaidya/widgets/google_login_button.dart';
import 'package:vaidya/widgets/my_button.dart';
import 'package:vaidya/widgets/my_text_form_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Image.asset('assets/images/logo.png', height: 90),

                const SizedBox(height: 8),

                const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Enter your credentials to continue",
                  style: TextStyle(fontSize: 17, color: Color(0xFF313131)),
                ),

                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    MyTextFormField(
                      controller: _emailController,
                      text: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.mail,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    MyTextFormField(
                      controller: _passwordController,
                      text: "*********",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.key_rounded,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D8CFF),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                MyButton(
                  text: "Login",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showMySnackBar(
                        context: context,
                        message: "Login clicked",
                      );
                    }
                  },
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
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

                const SizedBox(height: 4),

                const DividerWithText(text: "Or login with"),

                const SizedBox(height: 16),

                GoogleLoginButton(
                  onPressed: () {
                    showMySnackBar(
                      context: context,
                      message: "Google Login clicked",
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
