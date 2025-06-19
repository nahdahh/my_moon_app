import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_moon/screens/add_log_period_screen.dart';
import 'package:my_moon/screens/notification_screen.dart';
import 'package:my_moon/widgets/bottom_nav_bar.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/services/period_service.dart';
import 'package:my_moon/services/period_log_service.dart';
import 'package:my_moon/services/period_analysis_service.dart';
import 'package:my_moon/widgets/week_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final PeriodService _periodService = PeriodService();
  final PeriodLogService _periodLogService = PeriodLogService();
  final PeriodAnalysisService _analysisService = PeriodAnalysisService();
  
  String _userName = 'User';
  DateTime _now = DateTime.now();
  
  // Data yang akan ditampilkan
  DateTime? _lastPeriodStartDate;
  int _lastPeriodDuration = 4;
  int _averageCycleLength = 28;
  int _daysSinceLastPeriod = 0;
  int _daysUntilNextPeriod = 0;
  bool _hasActualData = false;
  
  List<DateTime> _periodDays = [];
  List<DateTime> _predictedPeriodDays = [];
  List<DateTime> _fertileWindowDays = [];
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPeriodAnalysis();
  }
  
  Future<void> _loadUserData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.data['name'] ?? 'User';
      });
    }
  }
  
  Future<void> _loadPeriodAnalysis() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print("=== LOADING PERIOD ANALYSIS ===");
      
      // Gunakan service analisis baru
      final analysis = await _analysisService.getPeriodAnalysis();
      
      print("Analysis result: $analysis");
      
      setState(() {
        _lastPeriodStartDate = analysis.lastPeriodStartDate;
        _lastPeriodDuration = analysis.lastPeriodDuration;
        _averageCycleLength = analysis.averageCycleLength;
        _daysSinceLastPeriod = analysis.daysSinceLastPeriod;
        _daysUntilNextPeriod = analysis.daysUntilNextPeriod;
        _hasActualData = analysis.hasActualData;
      });
      
      // Load period days untuk kalender
      await _loadPeriodDaysForCalendar();
      
      // Calculate predicted period days dan fertile window
      if (_lastPeriodStartDate != null) {
        _calculatePredictedDays();
      }
      
    } catch (e) {
      print("Error loading period analysis: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading period data: $e')),
      );
      
      // Gunakan nilai default jika terjadi error
      setState(() {
        _lastPeriodStartDate = _now.subtract(const Duration(days: 14));
        _daysSinceLastPeriod = 14;
        _daysUntilNextPeriod = 14;
        _hasActualData = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadPeriodDaysForCalendar() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        // Ambil semua log untuk bulan ini
        final logs = await _periodLogService.getAllLogsForUser(user.id);
        
        // Filter logs untuk bulan ini dan konversi ke DateTime
        final monthLogs = logs.where((log) {
          try {
            final logDate = DateTime.parse(log.data['date_menstruation']);
            return logDate.year == _now.year && logDate.month == _now.month;
          } catch (e) {
            return false;
          }
        }).toList();
        
        setState(() {
          _periodDays = monthLogs.map((log) => DateTime.parse(log.data['date_menstruation'])).toList();
        });
        
        print("Loaded ${_periodDays.length} period days for calendar");
      }
    } catch (e) {
      print("Error loading period days for calendar: $e");
    }
  }
  
  void _calculatePredictedDays() {
    if (_lastPeriodStartDate == null) return;
    
    // Calculate predicted period days
    final predictedPeriodDays = _periodService.calculatePredictedPeriodDays(
      lastPeriodStartDate: _lastPeriodStartDate!,
      periodLength: _lastPeriodDuration,
      cycleLength: _averageCycleLength,
    );
    
    // Filter predicted period days untuk bulan ini
    final filteredPredictedPeriodDays = predictedPeriodDays.where((date) {
      return date.year == _now.year && date.month == _now.month;
    }).toList();
    
    // Calculate fertile window days
    final fertileWindowDays = _periodService.calculateFertileWindowDays(
      lastPeriodStartDate: _lastPeriodStartDate!,
      cycleLength: _averageCycleLength,
    );
    
    // Filter fertile window days untuk bulan ini
    final filteredFertileWindowDays = fertileWindowDays.where((date) {
      return date.year == _now.year && date.month == _now.month;
    }).toList();
    
    setState(() {
      _predictedPeriodDays = filteredPredictedPeriodDays;
      _fertileWindowDays = filteredFertileWindowDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Format the last period date for display
    final lastPeriodDateFormatted = _lastPeriodStartDate != null 
        ? DateFormat('MMMM d').format(_lastPeriodStartDate!) 
        : 'Not set';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7FD), 
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF38CA6),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Header with 3-column layout
                      Row(
                        children: [
                          // Left: Empty placeholder
                          const SizedBox(width: 48), // Same width as IconButton to balance
                          
                          // Center: Hello text
                          Expanded(
                            child: Text(
                              'Hello, $_userName',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 23, // Same as Calendar
                                fontWeight: FontWeight.w600, // semi-bold
                                color: Colors.black,
                              ),
                            ),
                          ),
                          
                          // Right: Notification icon (bukan profile icon)
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
                      
                      const SizedBox(height: 24),
                      
                      // Month display
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined, 
                            size: 20,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM yyyy').format(_now),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16, // H2: 16px
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Period notification card with mascot
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF38CA6), Color(0xFFFFB6C1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Text container
                            Positioned(
                              left: 20,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20, 
                                    vertical: 12
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    _daysUntilNextPeriod > 0
                                        ? 'Period Start in $_daysUntilNextPeriod Day'
                                        : _daysUntilNextPeriod == 0
                                            ? 'Period Starts Today'
                                            : 'Period Started ${-_daysUntilNextPeriod} Days Ago',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Mascot
                            Positioned(
                              right: 20,
                              top: 10,
                              bottom: 10,
                              child: Image.asset(
                                'assets/images/mascot.png',
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Week calendar
                      _buildWeekCalendar(),
                      
                      const SizedBox(height: 32),
                      
                      // Last menstrual period section
                      const Text(
                        'Last Menstrual Period',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20, // Sesuai spesifikasi
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Period info cards
                      _buildInfoCard(
                        icon: Icons.access_time_outlined,
                        iconColor: const Color(0xFFFF2D55), // Icon color sesuai spesifikasi
                        title: 'Started $lastPeriodDateFormatted',
                        subtitle: '$_daysSinceLastPeriod days ago',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildInfoCard(
                        icon: Icons.water_drop_outlined,
                        iconColor: const Color(0xFFFF2D55),
                        title: 'Period Length: $_lastPeriodDuration days',
                        subtitle: 'Normal',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildInfoCard(
                        icon: Icons.refresh_outlined,
                        iconColor: const Color(0xFFFF2D55),
                        title: 'Cycle Length: $_averageCycleLength days',
                        subtitle: 'Normal',
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom navigation
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLogPeriodScreen()),
          ).then((_) {
            // Refresh data when returning from add log screen
            _loadPeriodAnalysis();
          });
        },
        backgroundColor: const Color(0xFFFF4D6D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  Widget _buildWeekCalendar() {
  return WeekCalendarWidget(
    currentDate: _now,
    selectedDate: null, // No specific selected date for home screen
    periodDays: _periodDays,
    predictedPeriodDays: _predictedPeriodDays,
    fertileWindowDays: _fertileWindowDays,
    onDaySelected: (date) {
      // Optional: Handle day selection if needed
      print('Day selected: ${DateFormat('yyyy-MM-dd').format(date)}');
    },
  );
}
  
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Rounded style
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16, // H2: 16px
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14, // Body text: 14px
                    fontWeight: FontWeight.w400, // regular
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
