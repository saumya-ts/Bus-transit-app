import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bushopper/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required LoginPage child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: _controller.drive(
              Tween<double>(begin: 0.5, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'lib/assets/animation.json',
              ),
            ),
          ),
          Positioned(
            bottom: 120, // Reduced spacing 
            child: ScaleTransition(
              scale: _controller.drive(
                Tween<double>(begin: 0.8, end: 1.0).chain(
                  CurveTween(curve: Curves.easeInOut),
                ),
              ),
              child: FadeTransition(
                opacity: _controller,
                child: const Text(
                  "BUS HOPPER",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      nextScreen: LoginPage(),
      duration: 3500,
      backgroundColor: Colors.white,
      splashIconSize: 500,
    );
  }
}