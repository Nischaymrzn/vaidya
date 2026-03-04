import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/app/routes/app_routes.dart';
import 'package:vaidya/core/widgets/loader.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await ref.read(authViewModelProvider.notifier).getCurrentUser();
    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.status == AuthStatus.authenticated) {
      AppRoutes.pushReplacement(context, const DashboardScreen());
    } else {
      AppRoutes.pushReplacement(context, const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),

      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/logo.png", height: 140),

                  const SizedBox(height: 14),

                  const Text(
                    "VAIDYA",
                    style: TextStyle(
                      fontSize: 32,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Loader(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
