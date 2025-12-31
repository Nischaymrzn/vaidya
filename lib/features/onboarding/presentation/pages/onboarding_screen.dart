import 'package:flutter/material.dart';
import 'package:vaidya/features/auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding1.webp",
      "title": "All Your Health in One Place",
      "desc":
          "Securely store your vitals, lab reports, prescriptions, and medical history anytime, anywhere.",
    },
    {
      "image": "assets/images/onboarding2.webp",
      "title": "Health Guidance",
      "desc": "Smart symptom analysis and personalized insights.",
    },
    {
      "image": "assets/images/onboarding3.webp",
      "title": "Visual Analytics",
      "desc":
          "Understand trends and patterns with interactive charts and progress dashboards.",
    },
  ];

  void goNext() {
    if (_currentPage == pages.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: skip,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF2D8CFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },

                  itemBuilder: (_, index) {
                    final data = pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(data["image"]!, height: 320),

                        SizedBox(height: 32),

                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 12),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Text(
                            data["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == i ? 22 : 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _currentPage == i
                          ? Color(0xFF2D8CFF)
                          : Colors.black26,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D8CFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  onPressed: goNext,

                  child: Text(
                    _currentPage == pages.length - 1 ? "Get Started" : "Next",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
