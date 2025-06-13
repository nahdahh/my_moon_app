import 'package:flutter/material.dart';
import 'package:my_moon/screens/home_screen.dart';
import 'package:my_moon/widgets/date_picker_widget.dart';
import 'package:intl/intl.dart';
import 'package:my_moon/services/period_service.dart';

class InitializationScreen3 extends StatefulWidget {
final int periodLength;
final int cycleLength;

const InitializationScreen3({
  Key? key,
  required this.periodLength,
  required this.cycleLength,
}) : super(key: key);

@override
State<InitializationScreen3> createState() => _InitializationScreen3State();
}

class _InitializationScreen3State extends State<InitializationScreen3> {
late DateTime _lastPeriodDate;
final PeriodService _periodService = PeriodService();
bool _isSaving = false;
String? _errorMessage;

@override
void initState() {
  super.initState();
  // Default to 7 days ago
  _lastPeriodDate = DateTime.now().subtract(const Duration(days: 7));
}

Future<void> _saveCycleInfo() async {
  setState(() {
    _isSaving = true;
    _errorMessage = null;
  });
  
  try {
    print('Saving cycle info:');
    print('Period Length: ${widget.periodLength}');
    print('Cycle Length: ${widget.cycleLength}');
    print('Last Period Date: ${DateFormat('yyyy-MM-dd').format(_lastPeriodDate)}');
    
    final success = await _periodService.saveCycleInfo(
      periodLength: widget.periodLength,
      cycleLength: widget.cycleLength,
      lastPeriodStartDate: _lastPeriodDate,
    );
    
    if (success) {
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to save cycle information. Please try again.';
      });
    }
  } catch (e) {
    print('Error saving cycle info: $e');
    setState(() {
      _errorMessage = 'Error: $e';
    });
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
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
                // Header with navigation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                        '3/3',
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
                
                // Question
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: const Text(
                    'When was the first day of your last menstrual period?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF2D55),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // Date picker
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: DatePickerWidget(
                      initialDate: _lastPeriodDate,
                      onDateChanged: (date) {
                        setState(() {
                          _lastPeriodDate = date;
                          print('Date updated: ${DateFormat('yyyy-MM-dd').format(_lastPeriodDate)}');
                        });
                      },
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
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
                          onPressed: _isSaving ? null : _saveCycleInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2D55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Done',
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
                        onPressed: _isSaving ? null : () {
                          _saveCycleInfo();
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
