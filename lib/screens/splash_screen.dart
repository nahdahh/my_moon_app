import 'package:flutter/material.dart';
import 'package:my_moon/screens/onboarding_screen.dart';
import 'package:my_moon/screens/home_screen.dart';
import 'package:my_moon/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      print("Checking authentication status...");
      
      // Add a small delay for splash screen effect
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if user is already logged in
      final isLoggedIn = await _authService.isLoggedIn();
      print("User logged in status: $isLoggedIn");
      
      if (mounted) {
        if (isLoggedIn) {
          // User is logged in, navigate to home screen
          print("User is logged in, navigating to home screen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // User is not logged in, navigate to onboarding
          print("User is not logged in, navigating to onboarding");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      print("Error checking authentication status: $e");
      
      // On error, navigate to onboarding screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FD), // Light pink background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Mascot
            Image.asset(
              'assets/images/mascot.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 30),
            
            // App Name
            const Text(
              'My Moon',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4D6D),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            
            // Tagline
            const Text(
              'Track your cycle with care',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 50),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Color(0xFFFF4D6D),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            
            // Loading text
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
