import 'package:flutter/material.dart';
import 'package:my_moon/screens/initialization_screen_3.dart';
import 'package:my_moon/screens/home_screen.dart';
import 'package:my_moon/widgets/infinite_number_picker.dart';

class InitializationScreen2 extends StatefulWidget {
final int periodLength;

const InitializationScreen2({
  Key? key,
  required this.periodLength,
}) : super(key: key);

@override
State<InitializationScreen2> createState() => _InitializationScreen2State();
}

class _InitializationScreen2State extends State<InitializationScreen2> {
late int _cycleLength;

@override
void initState() {
  super.initState();
  _cycleLength = 28; // Default cycle length
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background color
        Container(
          color: const Color(0xFFFFF7FD),
        ),
      
        // Mascot area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.4,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome sist',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/mascot.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      
        // Content box
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: MediaQuery.of(context).size.height * 0.35,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with navigation - positioned at the top of white container
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        '2/3',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // Navigate directly to Home Screen when X is clicked
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              
                // Question and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Text(
                        'How many days does your menstrual cycle usually last?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF2D55),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The duration between the start dates of two periods is usually 23 to 35 days',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                ),
              
                const SizedBox(height: 30),

                // Number picker - using the working InfiniteNumberPicker
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InfiniteNumberPicker(
                      initialValue: _cycleLength,
                      minValue: 21,
                      maxValue: 45,
                      label: 'Days',
                      onValueChanged: (value) {
                        setState(() {
                          _cycleLength = value;
                        });
                      },
                    ),
                  ),
                ),
              
                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InitializationScreen3(
                                  periodLength: widget.periodLength,
                                  cycleLength: _cycleLength,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2D55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InitializationScreen3(
                                periodLength: widget.periodLength,
                                cycleLength: _cycleLength,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF999999),
                        ),
                        child: const Text(
                          'Not Sure',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
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
      ],
    ),
  );
}
}
