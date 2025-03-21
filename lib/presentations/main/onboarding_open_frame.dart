import 'package:flutter/material.dart';
import 'package:open_frame_a207/presentations/main/main_open_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingOpenFrame extends StatefulWidget {
  const OnboardingOpenFrame({super.key});

  @override
  State<OnboardingOpenFrame> createState() => _OnboardingOpenFrameState();
}

class _OnboardingOpenFrameState extends State<OnboardingOpenFrame> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  void _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreenOpenFrame()),
    );
  }

  /// Листаем вперёд
  void _goToNextPage() {
    if (currentPage < 2) {
      setState(() {
        currentPage++;
      });
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Сам "PageView" на заднем плане
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: const [
              // Каждый экран - просто фон/картинка
              OnboardingPageOpenFrame(imagePath: 'assets/images/frame1.png'),
              OnboardingPageOpenFrame(imagePath: 'assets/images/frame2.png'),
              OnboardingPageOpenFrame(imagePath: 'assets/images/frame3.png'),
            ],
          ),

          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: _buildBottomButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    bool isLast = (currentPage == 3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          minimumSize: const Size(343, 56),
          backgroundColor: Color(0xFF4FC3F7),
        ),
        onPressed: _goToNextPage,
        child: Text(
          isLast ? 'Start' : 'Next',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class OnboardingPageOpenFrame extends StatelessWidget {
  final String imagePath;

  const OnboardingPageOpenFrame({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
