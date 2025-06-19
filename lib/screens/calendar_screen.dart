import 'package:flutter/material.dart';
import 'package:my_moon/screens/add_log_period_screen.dart';
import 'package:my_moon/screens/notification_screen.dart';
import 'package:my_moon/widgets/month_calendar_widget.dart';
import 'package:my_moon/widgets/bottom_nav_bar.dart';
import 'package:my_moon/services/period_service.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/services/period_log_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
const CalendarScreen({Key? key}) : super(key: key);

@override
State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
late DateTime _selectedMonth;
final PeriodService _periodService = PeriodService();
final AuthService _authService = AuthService();
final PeriodLogService _periodLogService = PeriodLogService();

List<DateTime> _periodDays = [];
List<DateTime> _predictedPeriodDays = [];
List<DateTime> _fertileWindowDays = [];

bool _isLoading = true;
// Remove: String _userName = 'User';

DateTime? _selectedDate;
RecordModel? _selectedDateLog;
bool _isLoadingLog = false;
bool _isDeletingLog = false;

// Data untuk menampilkan nama yang sebenarnya
Map<String, String> _flowNames = {};
Map<String, String> _moodNames = {};
Map<String, String> _crampNames = {};
Map<String, String> _bodyConditionNames = {};

@override
void initState() {
  super.initState();
  _selectedMonth = DateTime.now();
  _loadOptionNames();  
  _loadPeriodData();   
  
}



Future<void> _loadOptionNames() async {
  try {
    // Load semua option names untuk mapping ID ke nama
    final flows = await _periodLogService.getFlows();
    final moods = await _periodLogService.getMoods();
    final cramps = await _periodLogService.getCramps();
    final bodyConditions = await _periodLogService.getBodyConditions();
    
    setState(() {
      _flowNames = {for (var item in flows) item['id']: item['name']};
      _moodNames = {for (var item in moods) item['id']: item['name']};
      _crampNames = {for (var item in cramps) item['id']: item['name']};
      _bodyConditionNames = {for (var item in bodyConditions) item['id']: item['name']};
    });
    
    print("Loaded option names:");
    print("Flows: $_flowNames");
    print("Moods: $_moodNames");
    print("Cramps: $_crampNames");
    print("Body Conditions: $_bodyConditionNames");
  } catch (e) {
    print("Error loading option names: $e");
  }
}

Future<void> _loadPeriodData() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final user = _authService.getCurrentUser();
    if (user != null) {
      // Get all logs for the current month
      final allLogs = await _periodLogService.getAllLogsForUser(user.id);
      
      // Filter logs for the current month and convert to period days
      final monthLogs = allLogs.where((log) {
        try {
          final logDate = DateTime.parse(log.data['date_menstruation']);
          return logDate.year == _selectedMonth.year && logDate.month == _selectedMonth.month;
        } catch (e) {
          return false;
        }
      }).toList();
      
      setState(() {
        _periodDays = monthLogs.map((log) => DateTime.parse(log.data['date_menstruation'])).toList();
      });
      
      print("Found ${monthLogs.length} logs for ${DateFormat('MMMM yyyy').format(_selectedMonth)}");
      for (var log in monthLogs) {
        print("- Log date: ${log.data['date_menstruation']}");
      }
    }
    
    // Also load cycle info for predicted days
    final cycleInfo = await _periodService.getCycleInfo()
        .timeout(const Duration(seconds: 5), onTimeout: () {
      print("Timeout getting cycle info");
      return null;
    });
    
    if (cycleInfo != null) {
      final lastPeriodDate = DateTime.parse(cycleInfo['last_period_date']);
      final periodLength = cycleInfo['period_length'];
      final cycleLength = cycleInfo['cycle_length'];
      
      // Calculate predicted period days and fertile window
      final predictedPeriodDays = _periodService.calculatePredictedPeriodDays(
        lastPeriodStartDate: lastPeriodDate,
        periodLength: periodLength,
        cycleLength: cycleLength,
      );
      
      // Filter predicted period days that fall in the selected month
      final filteredPredictedPeriodDays = predictedPeriodDays.where((date) {
        return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
      }).toList();
      
      final fertileWindowDays = _periodService.calculateFertileWindowDays(
        lastPeriodStartDate: lastPeriodDate,
        cycleLength: cycleLength,
      );
      
      // Filter fertile window days that fall in the selected month
      final filteredFertileWindowDays = fertileWindowDays.where((date) {
        return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
      }).toList();
      
      setState(() {
        _predictedPeriodDays = filteredPredictedPeriodDays;
        _fertileWindowDays = filteredFertileWindowDays;
      });
    }
  } catch (e) {
    print("Error loading period data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading period data. Please try again.')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _loadLogForSelectedDate(DateTime date) async {
  setState(() {
    _isLoadingLog = true;
    _selectedDate = date;
    _selectedDateLog = null;
  });
  
  print("=== CALENDAR DEBUG ===");
  print("Loading log for selected date: ${DateFormat('yyyy-MM-dd').format(date)}");
  
  try {
    final user = _authService.getCurrentUser();
    if (user != null) {
      print("User ID: ${user.id}");
      final log = await _periodLogService.getLogForDate(date, user.id);
      print("Log result: ${log != null ? 'Found' : 'Not found'}");
      if (log != null) {
        print("Log data: ${log.data}");
      }
      setState(() {
        _selectedDateLog = log;
      });
    } else {
      print("No user logged in");
    }
  } catch (e) {
    print("Error loading log for selected date: $e");
  } finally {
    setState(() {
      _isLoadingLog = false;
    });
  }
}

Future<void> _deleteLog() async {
  if (_selectedDateLog == null) return;

  // Show confirmation dialog
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Delete Log',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4D6D),
          ),
        ),
        content: Text(
          'Are you sure you want to delete the log for ${DateFormat('MMMM d, yyyy').format(_selectedDate!)}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  setState(() {
    _isDeletingLog = true;
  });

  try {
    final success = await _periodLogService.deleteMenstruationLog(_selectedDateLog!.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear selected date and reload data
      setState(() {
        _selectedDate = null;
        _selectedDateLog = null;
      });
      
      // Reload period data to update calendar
      _loadPeriodData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete log. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("Error deleting log: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isDeletingLog = false;
    });
  }
}

void _onMonthChanged(DateTime month) {
  setState(() {
    _selectedMonth = month;
  });
  _loadPeriodData();
}

void _onDaySelected(DateTime day) {
  print("Day selected in calendar: ${DateFormat('yyyy-MM-dd').format(day)}");
  _loadLogForSelectedDate(day);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFFFF7FD), // Updated background color
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Left: Empty space for centering
          const SizedBox(width: 48), // Same width as notification icon
          
          // Center: Calendar title
          Expanded(
            child: Text(
              'Calendar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
          ),
          
          // Right: Notification icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
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
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF4D6D),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                MonthCalendarWidget(
                  initialMonth: _selectedMonth,
                  periodDays: _periodDays,
                  predictedPeriodDays: _predictedPeriodDays,
                  fertileWindowDays: _fertileWindowDays,
                  onDaySelected: _onDaySelected,
                  onMonthChanged: _onMonthChanged,
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 20),
                  _buildSelectedDateLog(),
                ],
              ],
            ),
          ),
    bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddLogPeriodScreen()),
        ).then((_) {
          // Refresh data when returning from add log screen
          _loadPeriodData();
          if (_selectedDate != null) {
            _loadLogForSelectedDate(_selectedDate!);
          }
        });
      },
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  );
}

Widget _buildSelectedDateLog() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
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
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.pink[300],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4D6D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoadingLog)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFFFF4D6D),
              ),
            ),
          )
        else if (_selectedDateLog == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No log entry for this date',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLogPeriodScreen(),
                      ),
                    ).then((_) {
                      _loadPeriodData();
                      if (_selectedDate != null) {
                        _loadLogForSelectedDate(_selectedDate!);
                      }
                    });
                  },
                  child: const Text(
                    'Add Log',
                    style: TextStyle(
                      color: Color(0xFFFF4D6D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _buildLogDetails(_selectedDateLog!),
      ],
    ),
  );
}

Widget _buildLogDetails(RecordModel log) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Flow
      if (log.data['flow'] != null) ...[
        _buildLogItem(
          icon: Icons.water_drop,
          iconColor: Colors.pink[300]!,
          title: 'Flow',
          value: _flowNames[log.data['flow']] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
      ],
      
      // Mood
      if (log.data['mood'] != null) ...[
        _buildLogItem(
          icon: Icons.mood,
          iconColor: Colors.amber[300]!,
          title: 'Mood',
          value: _moodNames[log.data['mood']] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
      ],
      
      // Cramp
      if (log.data['cramp'] != null) ...[
        _buildLogItem(
          icon: Icons.healing,
          iconColor: Colors.red[300]!,
          title: 'Cramps',
          value: _crampNames[log.data['cramp']] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
      ],
      
      // Body Condition
      if (log.data['body_condition'] != null) ...[
        _buildLogItem(
          icon: Icons.accessibility,
          iconColor: Colors.purple[300]!,
          title: 'Body Condition',
          value: _bodyConditionNames[log.data['body_condition']] ?? 'Unknown',
        ),
        const SizedBox(height: 8),
      ],
      
      // Note
      if (log.data['note'] != null && log.data['note'].toString().isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.pink[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.note,
                    color: Colors.pink[300],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                log.data['note'].toString(),
                style: TextStyle(
                  color: Colors.pink[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
      
      const SizedBox(height: 16),
      
      // Action buttons
      Row(
        children: [
          // Edit button
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddLogPeriodScreen(),
                  ),
                ).then((_) {
                  _loadPeriodData();
                  if (_selectedDate != null) {
                    _loadLogForSelectedDate(_selectedDate!);
                  }
                });
              },
              icon: const Icon(
                Icons.edit,
                color: Color(0xFFFF4D6D),
                size: 16,
              ),
              label: const Text(
                'Edit Log',
                style: TextStyle(
                  color: Color(0xFFFF4D6D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.pink[200]!),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Delete button
          Expanded(
            child: TextButton.icon(
              onPressed: _isDeletingLog ? null : _deleteLog,
              icon: _isDeletingLog
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 16,
                    ),
              label: Text(
                _isDeletingLog ? 'Deleting...' : 'Delete Log',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.red[200]!),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildLogItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: iconColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
}
