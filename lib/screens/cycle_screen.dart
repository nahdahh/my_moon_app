import 'package:flutter/material.dart';
import 'package:my_moon/services/period_service.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

class CycleScreen extends StatefulWidget {
  const CycleScreen({Key? key}) : super(key: key);

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  final PeriodService _periodService = PeriodService();
  
  int _averageCycleLength = 0;
  int _averagePeriodLength = 0;
  DateTime? _lastPeriodDate;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCycleData();
  }
  
  Future<void> _loadCycleData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get cycle info from PeriodService
      final cycleInfo = await _periodService.getCycleInfo();
      
      if (cycleInfo != null) {
        // Get cycle length and period length from the cycle info
        final cycleLength = cycleInfo['cycle_length'] as int;
        final periodLength = cycleInfo['period_length'] as int;
        
        // Parse the last period date
        final lastPeriodDateStr = cycleInfo['last_period_date'] as String;
        final lastPeriodDate = DateTime.parse(lastPeriodDateStr);
        
        setState(() {
          _averageCycleLength = cycleLength;
          _averagePeriodLength = periodLength;
          _lastPeriodDate = lastPeriodDate;
        });
      } else {
        // If no cycle info is available, try to get period logs
        final periodLogs = await _periodService.getAllPeriodLogs();
        
        if (periodLogs.isNotEmpty) {
          // Calculate average cycle length (default to 28 if not enough data)
          _averageCycleLength = 28;
          
          // Calculate average period length (default to 5 if not enough data)
          _averagePeriodLength = 5;
          
          // Find the most recent period log
          RecordModel? mostRecentLog;
          DateTime mostRecentDate = DateTime(1900);
          
          for (var log in periodLogs) {
            final dateStr = log.data['date'] as String;
            final date = DateTime.parse(dateStr);
            
            if (date.isAfter(mostRecentDate)) {
              mostRecentDate = date;
              mostRecentLog = log;
            }
          }
          
          if (mostRecentLog != null) {
            setState(() {
              _lastPeriodDate = mostRecentDate;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading cycle data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF000000),
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'My Cycle',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF2D55),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCycleData,
                        color: const Color(0xFFFF2D55),
                        child: ListView(
                          children: [
                            const SizedBox(height: 20),
                            
                            // Cycle Length Card
                            _buildInfoCard(
                              title: 'Average Cycle Length',
                              value: '$_averageCycleLength days',
                              icon: Icons.loop,
                              color: const Color(0xFFFF9AA2),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Period Length Card
                            _buildInfoCard(
                              title: 'Average Period Length',
                              value: '$_averagePeriodLength days',
                              icon: Icons.calendar_today_outlined,
                              color: const Color(0xFFFFB7B2),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Last Period Card
                            _buildInfoCard(
                              title: 'Last Period',
                              value: _formatDate(_lastPeriodDate),
                              icon: Icons.event_note,
                              color: const Color(0xFFFFDAC1),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Cycle Information
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'About Your Cycle',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Your menstrual cycle is the time from the first day of your period to the day before your next period starts. The average cycle is 28 days, but it can range from 21 to 35 days.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Understanding your cycle can help you:',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildBulletPoint('Predict your next period'),
                                  _buildBulletPoint('Track your fertility window'),
                                  _buildBulletPoint('Understand mood changes'),
                                  _buildBulletPoint('Monitor your health'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF2D55),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
