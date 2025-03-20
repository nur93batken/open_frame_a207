import 'package:flutter/material.dart';
import 'package:open_frame_a207/presentations/main/main_open_frame.dart';
import 'package:open_frame_a207/presentations/main/onboarding_open_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenOpenFrame extends StatefulWidget {
  const SplashScreenOpenFrame({super.key});

  @override
  State<SplashScreenOpenFrame> createState() => _SplashScreenOpenFrameState();
}

class _SplashScreenOpenFrameState extends State<SplashScreenOpenFrame> {
  Future<void> _checkFirstOpenFrame() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                isFirstLaunch
                    ? const OnboardingOpenFrame()
                    : const MainScreenOpenFrame(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _checkFirstOpenFrame);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Image(
        image: AssetImage('assets/images/splash_image.png'),
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
