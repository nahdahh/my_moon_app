import 'package:flutter/material.dart';
import 'package:my_moon/screens/notification_screen.dart';
import 'package:my_moon/screens/add_log_period_screen.dart';
import 'package:my_moon/widgets/bottom_nav_bar.dart';
import 'package:my_moon/services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  bool _isLoading = true;
  AnalyticsData? _analyticsData;
  
  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }
  
  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = await _analyticsService.getAnalyticsData();
      setState(() {
        _analyticsData = data;
      });
    } catch (e) {
      print("Error loading analytics data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FD),
      appBar: null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF4D6D),
              ),
            )
          : Column(
        children: [
          // Header with 3-column layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  // Left: Empty placeholder
                  const SizedBox(width: 48),
                  
                  // Center: Analytics text
                  Expanded(
                    child: Text(
                      'Analitic',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  // Right: Notification icon
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _analyticsData == null || !_analyticsData!.hasEnoughData
                ? _buildInsufficientDataView()
                : _buildAnalyticsView(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLogPeriodScreen()),
          ).then((_) {
            _loadAnalyticsData();
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInsufficientDataView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Image.asset(
              'assets/images/mascot.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Not Enough Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4D6D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _analyticsData?.message ?? 'Please complete your cycle initialization to see analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddLogPeriodScreen()),
                ).then((_) {
                  _loadAnalyticsData();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Period Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() {
    final data = _analyticsData!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // My Siklus Section with Cards in White Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Siklus Title
                  const Text(
                    'My Siklus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Cards Row
                  Row(
                    children: [
                      // Average Period Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xF3678A).withOpacity(0.56), // #F3678A with 56% transparency
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: const Color(0xFFD91E5B),
                                size: 24,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${data.averagePeriodLength} Days',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'average period',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Average Cycle Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E7FF), // #E7E7FF
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: const Color(0xFF6B6BFF),
                                size: 24,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${data.averageCycleLength} Days',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const Text(
                                'average cycle',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12), // Reduced from 16 to 12
            
            // Cycle History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cycle History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
            
            Text(
              'Average Cycle Length over the Last Six Months',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 4), // Reduced from 8 to 4
            
            Text(
              '${data.averageCycleLength} ${_analyticsService.calculateCycleLengthVariation(data.cycleHistory)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 4), // Reduced from 8 to 4
            
            // Chart
            if (data.cycleHistory.isNotEmpty) _buildCycleChart(data.cycleHistory),
            
            const SizedBox(height: 24),
            
            // Summary
            _buildSummary(data),
            
            const SizedBox(height: 24),
            
            // Mood & Symptom Summary
            if (data.moodSummary.isNotEmpty || data.symptomSummary.isNotEmpty)
              _buildMoodSymptomSummary(data),
              
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCycleChart(List<CycleHistoryData> cycleHistory) {
    final maxCycleLength = cycleHistory.map((e) => e.cycleLength).reduce((a, b) => a > b ? a : b);
    final minCycleLength = cycleHistory.map((e) => e.cycleLength).reduce((a, b) => a < b ? a : b);
    final chartHeight = 200.0;
    
    return Container(
      height: chartHeight + 60, // Reduced from 80 to 60
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: cycleHistory.map((data) {
          // Calculate bar height based on cycle length (proportional)
          double barHeight;
          if (maxCycleLength > minCycleLength) {
            // Normalize height between 60 and chartHeight
            final normalizedHeight = ((data.cycleLength - minCycleLength) / (maxCycleLength - minCycleLength));
            barHeight = 60 + (normalizedHeight * (chartHeight - 60));
          } else {
            barHeight = chartHeight * 0.7; // Default height if all cycles are same length
          }
          
          // Determine bar color based on classification
          Color barColor;
          if (data.classification == CycleClassification.onTime) {
            barColor = const Color(0xFFFF6B9D); // Pink for on time
          } else if (data.classification == CycleClassification.delayed) {
            barColor = const Color(0xFFB8B5FF); // Light purple for delayed
          } else if (data.classification == CycleClassification.early) {
            barColor = const Color(0xFFB8B5FF); // Light purple for early
          } else {
            barColor = Colors.grey[300]!; // Grey for irregular
          }
          
          // Determine if this is the current cycle
          final isCurrentCycle = data.isCurrentCycle;
          
          // Get status text - FIXED: Check current cycle first
          String statusText;
          if (isCurrentCycle) {
            statusText = "Current\ncycle";
          } else if (data.classification == CycleClassification.onTime) {
            statusText = "On time";
          } else if (data.classification == CycleClassification.delayed) {
            final daysDelayed = data.cycleLength - data.averageCycleLength;
            statusText = "Delayed\n${daysDelayed.abs()} days";
          } else if (data.classification == CycleClassification.early) {
            final daysEarly = data.averageCycleLength - data.cycleLength;
            statusText = "Early\n${daysEarly.abs()} days";
          } else {
            statusText = "Irregular";
          }
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Status text above bar
                Container(
                  height: 28, // Reduced from 35 to 28
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9, // Reduced from 10 to 9
                      color: isCurrentCycle ? const Color(0xFFFF1493) : Colors.grey[600],
                      fontWeight: isCurrentCycle ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                
                // No SizedBox here - removed the gap
                
                // Cycle length bar with dashed border for current cycle
                Container(
                  width: 45,
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCurrentCycle ? Colors.transparent : barColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrentCycle 
                      ? Border.all(
                          color: const Color(0xFFFF1493), // Deep pink/magenta for current cycle
                          width: 2,
                          style: BorderStyle.solid,
                        )
                      : null,
                  ),
                  child: isCurrentCycle 
                    ? CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFFFF1493),
                          strokeWidth: 2,
                          dashLength: 5,
                          gapLength: 3,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${data.cycleLength}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFF1493),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'days',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFF1493),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${data.cycleLength}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'days',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
                
                const SizedBox(height: 6), // Reduced from 8 to 6
                
                // Date label (MM.DD format for menstruation start date)
                Text(
                  data.monthLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(AnalyticsData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on ${data.totalPeriods} periods logged:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Average period length: ${data.averagePeriodLength} days',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
          Text(
            '• Average cycle length: ${data.averageCycleLength} days',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
          Text(
            '• Cycle variation: ${_analyticsService.calculateCycleLengthVariation(data.cycleHistory)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSymptomSummary(AnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood & Symptom Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Mood Summary
        if (data.moodSummary.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mood,
                      color: Colors.amber[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Common Moods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: data.moodSummary.take(6).map((mood) => _buildMoodSymptomItem(
                    name: mood.name,
                    count: mood.count,
                    iconUrl: mood.iconUrl,
                    backgroundColor: Colors.amber[100]!,
                    textColor: Colors.amber[700]!,
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Symptom Summary
        if (data.symptomSummary.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.healing,
                      color: Colors.pink[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Most Common Symptoms',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: data.symptomSummary.take(6).map((symptom) => _buildMoodSymptomItem(
                    name: symptom.name,
                    count: symptom.count,
                    iconUrl: symptom.iconUrl,
                    backgroundColor: Colors.pink[100]!,
                    textColor: Colors.pink[700]!,
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodSymptomItem({
    required String name,
    required int count,
    String? iconUrl,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          if (iconUrl != null && iconUrl.isNotEmpty)
            ClipOval(
              child: Image.network(
                iconUrl,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.circle,
                    color: textColor,
                    size: 20,
                  );
                },
              ),
            )
          else
            Icon(
              Icons.circle,
              color: textColor,
              size: 20,
            ),
          const SizedBox(width: 6),
          
          // Name and count
          Text(
            '$name ($count×)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}