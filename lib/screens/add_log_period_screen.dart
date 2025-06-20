import 'package:flutter/material.dart';
import 'package:my_moon/widgets/week_calendar_widget.dart';
import 'package:my_moon/services/period_log_service.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:intl/intl.dart';


class AddLogPeriodScreen extends StatefulWidget {
  const AddLogPeriodScreen({Key? key}) : super(key: key);

  @override
  State<AddLogPeriodScreen> createState() => _AddLogPeriodScreenState();
}

class _AddLogPeriodScreenState extends State<AddLogPeriodScreen> {
  final PeriodLogService _periodLogService = PeriodLogService();
  final AuthService _authService = AuthService();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentWeekDate = DateTime.now(); // For week navigation
  String? _selectedFlow;
  String? _selectedMood; // Single mood selection
  String? _selectedCramp;
  String? _selectedBodyCondition; // Single body condition selection
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  // Data dari PocketBase
  List<Map<String, dynamic>> _flowOptions = [];
  List<Map<String, dynamic>> _moodOptions = [];
  List<Map<String, dynamic>> _crampOptions = [];
  List<Map<String, dynamic>> _bodyConditionOptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Muat opsi dari PocketBase
      final flows = await _periodLogService.getFlows();
      final moods = await _periodLogService.getMoods();
      final cramps = await _periodLogService.getCramps();
      final bodyConditions = await _periodLogService.getBodyConditions();
      
      setState(() {
        _flowOptions = flows;
        _moodOptions = moods;
        _crampOptions = cramps;
        _bodyConditionOptions = bodyConditions;
      });
      
      print("Loaded ${flows.length} flows, ${moods.length} moods, ${cramps.length} cramps, ${bodyConditions.length} body conditions");
      
      // Cek apakah sudah ada log untuk tanggal ini
      await _checkExistingLog();
    } catch (e) {
      print("Error loading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkExistingLog() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;
    
    try {
      final existingLog = await _periodLogService.getLogForDate(_selectedDate, user.id);
      setState(() {
        if (existingLog != null) {
          _selectedFlow = existingLog.data['flow'];
          _selectedMood = existingLog.data['mood'];
          _selectedCramp = existingLog.data['cramp'];
          _selectedBodyCondition = existingLog.data['body_condition'];
          _noteController.text = existingLog.data['note'] ?? '';
        } else {
          // Reset form jika tidak ada log
          _selectedFlow = null;
          _selectedMood = null;
          _selectedCramp = null;
          _selectedBodyCondition = null;
          _noteController.text = '';
        }
      });
    } catch (e) {
      print("Error checking existing log: $e");
      // Reset form jika ada error
      setState(() {
        _selectedFlow = null;
        _selectedMood = null;
        _selectedCramp = null;
        _selectedBodyCondition = null;
        _noteController.text = '';
      });
    }
  }

  Future<void> _savePeriodLog() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a period log')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      print("Saving period log...");
      print("Selected flow: $_selectedFlow");
      print("Selected mood: $_selectedMood");
      print("Selected cramp: $_selectedCramp");
      print("Selected body condition: $_selectedBodyCondition");
      print("Note: ${_noteController.text}");
      
      final success = await _periodLogService.logMenstruation(
        date: _selectedDate,
        userId: user.id,
        flow: _selectedFlow,
        cramp: _selectedCramp,
        mood: _selectedMood,
        bodyCondition: _selectedBodyCondition,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Period log saved successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save period log. Please try again.')),
        );
      }
    } catch (e) {
      print("Error saving period log: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)), // Allow selecting today and yesterday
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF4D6D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentWeekDate = picked; // Update current week to show the selected date
      });
      _checkExistingLog();
    }
  }

  void _previousWeek() {
    setState(() {
      _currentWeekDate = _currentWeekDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    final nextWeek = _currentWeekDate.add(const Duration(days: 7));
    // Jangan izinkan ke minggu mendatang
    if (nextWeek.isBefore(DateTime.now().add(const Duration(days: 7)))) {
      setState(() {
        _currentWeekDate = nextWeek;
      });
    }
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
    _checkExistingLog();
  }

  @override
  Widget build(BuildContext context) {
  // Contoh data periode untuk kalender
  final List<DateTime> periodDays = [_selectedDate];
  final List<DateTime> predictedPeriodDays = <DateTime>[];
  final List<DateTime> fertileWindowDays = <DateTime>[];

  return Scaffold(
    body: Container(
      color: const Color(0xFFF7FD), // Warna background yang diperbarui
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and centered title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Baris atas dengan tombol kembali dan judul tengah
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Add Log',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Placeholder untuk menyeimbangkan tombol kembali
                    ],
                  ),
                  const SizedBox(height: 12), // Jarak antara judul dan tombol kalender
                  // Baris tombol kalender
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFFFF4D6D),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF4D6D),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Navigasi Minggu dan Kalender - Tanpa container background
                            Column(
                              children: [
                                // Header Navigasi Minggu
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left, size: 28),
                                        onPressed: _previousWeek,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Text(
                                        _getWeekRangeText(_currentWeekDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right, size: 28),
                                        onPressed: _nextWeek,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Kalender Minggu - background transparan
                                WeekCalendarWidget(
                                  currentDate: _currentWeekDate,
                                  selectedDate: _selectedDate,
                                  periodDays: periodDays,
                                  predictedPeriodDays: predictedPeriodDays,
                                  fertileWindowDays: fertileWindowDays,
                                  onDaySelected: _onDaySelected,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Flow Section
                            const Text(
                              'Flow',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _flowOptions.map((flow) {
                                  final String flowId = flow['id'];
                                  final String flowName = flow['name'] ?? 'Unknown';
                                  final String? iconUrl = flow['iconUrl'];
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SymptomOption(
                                      imageUrl: iconUrl,
                                      label: flowName,
                                      color: Colors.pink[300]!,
                                      isSelected: _selectedFlow == flowId,
                                      onToggle: (selected) {
                                        setState(() {
                                          _selectedFlow = selected ? flowId : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Mood Section
                            const Text(
                              'Mood',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _moodOptions.map((mood) {
                                final String moodId = mood['id'];
                                final String moodName = mood['name'] ?? 'Unknown';
                                final String? iconUrl = mood['iconUrl'];
                                
                                return SymptomOption(
                                  imageUrl: iconUrl,
                                  label: moodName,
                                  color: Colors.amber[100]!,
                                  isSelected: _selectedMood == moodId,
                                  onToggle: (selected) {
                                    setState(() {
                                      // Karena mood adalah relasi tunggal, kita hanya set atau hapus
                                      _selectedMood = selected ? moodId : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            
                            // Cramps Section
                            const Text(
                              'Cramps',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _crampOptions.map((cramp) {
                                  final String crampId = cramp['id'];
                                  final String crampName = cramp['name'] ?? 'Unknown';
                                  final String? iconUrl = cramp['iconUrl'];
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SymptomOption(
                                      imageUrl: iconUrl,
                                      label: crampName,
                                      color: Colors.pink[300]!,
                                      small: true,
                                      isSelected: _selectedCramp == crampId,
                                      onToggle: (selected) {
                                        setState(() {
                                          _selectedCramp = selected ? crampId : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Body Section
                            const Text(
                              'Body',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _bodyConditionOptions.map((condition) {
                                final String conditionId = condition['id'];
                                final String conditionName = condition['name'] ?? 'Unknown';
                                final String? iconUrl = condition['iconUrl'];
                                
                                return SymptomOption(
                                  imageUrl: iconUrl,
                                  label: conditionName,
                                  color: Colors.pink[100]!,
                                  isSelected: _selectedBodyCondition == conditionId,
                                  onToggle: (selected) {
                                    setState(() {
                                      // Karena body_condition adalah relasi tunggal, kita hanya set atau hapus
                                      _selectedBodyCondition = selected ? conditionId : null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            
                            // Notes Section
                            const Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Add any notes about your day...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Done Button
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _savePeriodLog,
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Done'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 80), // Ruang untuk navigasi bawah
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getWeekRangeText(DateTime date) {
    DateTime start = date.subtract(Duration(days: date.weekday - 1));
    DateTime end = start.add(const Duration(days: 6));

    String startDay = DateFormat('d').format(start);
    String endDay = DateFormat('d').format(end);
    String month = DateFormat('MMM').format(start);

    if (start.month != end.month) {
      month = '${DateFormat('MMM').format(start)} - ${DateFormat('MMM').format(end)}';
    }

    return '$startDay - $endDay $month';
  }
}

class SymptomOption extends StatefulWidget {
  final String? imageUrl;
  final String label;
  final Color color;
  final bool isSelected;
  final Function(bool) onToggle;
  final bool small;

  const SymptomOption({
    Key? key,
    this.imageUrl,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onToggle,
    this.small = false,
  }) : super(key: key);

  @override
  State<SymptomOption> createState() => _SymptomOptionState();
}

class _SymptomOptionState extends State<SymptomOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onToggle(!widget.isSelected);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, // Ukuran seragam
            height: 60, // Ukuran seragam
            decoration: BoxDecoration(
              color: widget.isSelected ? widget.color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color,
                width: 2,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: _buildContent(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
  if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
    return ClipOval(
      child: Image.network(
        widget.imageUrl!,
        width: 40, 
        height: 40, 
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            color: widget.isSelected ? Colors.white : widget.color,
            strokeWidth: 2,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: ${widget.imageUrl} - $error");
          return Icon(
            Icons.image_not_supported_outlined,
            color: widget.isSelected ? Colors.white : widget.color,
            size: 24,
          );
        },
      ),
    );
  }
  
  // Default: lingkaran kosong dengan ikon
  return Icon(
    Icons.circle_outlined,
    color: widget.isSelected ? Colors.white : widget.color,
    size: 30,
  );
}
}
