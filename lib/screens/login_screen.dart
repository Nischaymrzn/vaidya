import 'package:flutter/material.dart';
import 'package:vaidya/common/my_snackbar.dart';
import 'package:vaidya/screens/home_screen.dart';
import 'package:vaidya/screens/signup_screen.dart';
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
                      onPressed: () {},
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  },
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
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
