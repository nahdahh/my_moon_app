import 'package:flutter/material.dart';
import 'package:my_moon/screens/initialization_screen_1.dart';
import 'package:my_moon/services/navigation_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Save current route when this screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.saveCurrentRoute('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFF7FD),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to My MOON',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/mascot.png',
                    height: 200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Let\'s set up your period tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We\'ll need some information about your cycle to provide accurate predictions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the first initialization screen
                        NavigationService.pushAndSave(
                          context, 
                          const InitializationScreen1(), 
                          '/initialization1'
                        );
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
