import 'package:flutter/material.dart';
import 'package:vaidya/common/my_snackbar.dart';
import 'package:vaidya/widgets/divider_with_text.dart';
import 'package:vaidya/widgets/google_login_button.dart';
import 'package:vaidya/widgets/my_button.dart';
import 'package:vaidya/widgets/my_text_form_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Image.asset('assets/images/logo.png', height: 100),

              const SizedBox(height: 4),

              const Text(
                "Sign in",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 2),

              const Text(
                "Enter your credentials to continue",
                style: TextStyle(fontSize: 18, color: Color(0xFF313131)),
              ),

              const SizedBox(height: 18),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 5),

              MyTextFormField(
                text: "Enter your email",
                controller: _emailController,
              ),

              const SizedBox(height: 14),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 5),

              MyTextFormField(
                text: "********",
                controller: _passwordController,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF2D8CFF),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: MyButton(
                  text: "Login",
                  onPressed: () {
                    showMySnackBar(context: context, message: "Login clicked");
                  },
                ),
              ),

              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color(0xFF2D8CFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              DividerWithText(text: "Or login with"),

              const SizedBox(height: 16),

              GoogleLoginButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
