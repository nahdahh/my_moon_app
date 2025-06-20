import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthCalendarWidget extends StatefulWidget {
  final DateTime initialMonth;
  final List<DateTime> periodDays;
  final List<DateTime> predictedPeriodDays;
  final List<DateTime> fertileWindowDays;
  final Function(DateTime)? onDaySelected;
  final Function(DateTime)? onMonthChanged;

  const MonthCalendarWidget({
    Key? key,
    required this.initialMonth,
    this.periodDays = const [],
    this.predictedPeriodDays = const [],
    this.fertileWindowDays = const [],
    this.onDaySelected,
    this.onMonthChanged,
  }) : super(key: key);

  @override
  State<MonthCalendarWidget> createState() => _MonthCalendarWidgetState();
}

class _MonthCalendarWidgetState extends State<MonthCalendarWidget> {
  late DateTime _selectedMonth;
  late List<DateTime> _calendarDays;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _generateCalendarDays();
  }

  @override
  void didUpdateWidget(MonthCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMonth != widget.initialMonth) {
      _selectedMonth = widget.initialMonth;
      _generateCalendarDays();
    }
  }

  void _generateCalendarDays() {
    // Dapatkan hari pertama dari bulan yang dipilih
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    
    // Dapatkan hari terakhir dari bulan yang dipilih
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // Dapatkan hari pertama yang akan ditampilkan (mungkin dari bulan sebelumnya)
    final firstDayToDisplay = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    // Dapatkan hari terakhir yang akan ditampilkan (mungkin dari bulan berikutnya)
    final daysAfterLastDay = 7 - lastDayOfMonth.weekday % 7;
    final lastDayToDisplay = lastDayOfMonth.add(Duration(days: daysAfterLastDay == 7 ? 0 : daysAfterLastDay));
    
    // Generate semua hari yang akan ditampilkan
    _calendarDays = List.generate(
      lastDayToDisplay.difference(firstDayToDisplay).inDays + 1,
      (index) => firstDayToDisplay.add(Duration(days: index)),
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      _generateCalendarDays();
      if (widget.onMonthChanged != null) {
        widget.onMonthChanged!(_selectedMonth);
      }
    });
  }
  
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      _generateCalendarDays();
      if (widget.onMonthChanged != null) {
        widget.onMonthChanged!(_selectedMonth);
      }
    });
  }

  void _showMonthYearPicker(BuildContext context) async {
    // Tahun saat ini dan rentang tahun yang tersedia
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(11, (i) => currentYear - 5 + i);
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    int selectedYear = _selectedMonth.year;
    int selectedMonth = _selectedMonth.month - 1; // indeks 0-based untuk bulan
    
    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih Bulan & Tahun'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pemilih tahun
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        underline: Container(),
                        items: years.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              selectedYear = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Grid bulan
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedMonth;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedMonth = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF4D6D) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              months[index].substring(0, 3),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      DateTime(selectedYear, selectedMonth + 1, 1),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D6D),
                  ),
                  child: const Text('Pilih'),
                ),
              ],
            );
          },
        );
      },
    );
    
    if (result != null && result != _selectedMonth) {
      setState(() {
        _selectedMonth = result;
        _generateCalendarDays();
      });
      if (widget.onMonthChanged != null) {
        widget.onMonthChanged!(_selectedMonth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pemilih bulan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showMonthYearPicker(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Kalender
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Header hari dalam minggu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('M', style: TextStyle(color: Colors.grey)),
                  Text('S', style: TextStyle(color: Colors.grey)),
                  Text('S', style: TextStyle(color: Colors.grey)),
                  Text('R', style: TextStyle(color: Colors.grey)),
                  Text('K', style: TextStyle(color: Colors.grey)),
                  Text('J', style: TextStyle(color: Colors.grey)),
                  Text('S', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              
              // Grid kalender
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: _calendarDays.length,
                itemBuilder: (context, index) {
                  final day = _calendarDays[index];
                  final isCurrentMonth = day.month == _selectedMonth.month;
                  
                  // Periksa apakah hari ini adalah hari periode, prediksi periode, atau masa subur
                  final isPeriodDay = widget.periodDays.any((d) => 
                      d.day == day.day && d.month == day.month && d.year == day.year);
                  
                  final isPredictedPeriodDay = widget.predictedPeriodDays.any((d) => 
                      d.day == day.day && d.month == day.month && d.year == day.year);
                  
                  final isFertileWindowDay = widget.fertileWindowDays.any((d) => 
                      d.day == day.day && d.month == day.month && d.year == day.year);
                  
                  // Hari ini
                  final now = DateTime.now();
                  final isToday = day.day == now.day && 
                                 day.month == now.month && 
                                 day.year == now.year;
                  
                  Color? backgroundColor;
                  Color textColor = isCurrentMonth ? Colors.black : Colors.grey;
                  BoxBorder? border;
                  
                  if (isPeriodDay) {
                    backgroundColor = const Color(0xFFFFB6C1);
                    textColor = Colors.white;
                  } else if (isPredictedPeriodDay) {
                    border = Border.all(color: const Color(0xFFFFB6C1), width: 1, style: BorderStyle.solid);
                    backgroundColor = Colors.transparent;
                  } else if (isFertileWindowDay) {
                    backgroundColor = const Color(0xFFE6E6FA);
                  }
                  
                  if (isToday) {
                    border = Border.all(color: Colors.blue, width: 2);
                  }
                  
                  return GestureDetector(
                    onTap: () {
                      if (widget.onDaySelected != null) {
                        widget.onDaySelected!(day);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                        border: border,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Legenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: const Color(0xFFFFB6C1),
                label: 'Periode',
              ),
              _buildLegendItem(
                color: Colors.transparent,
                label: 'Prediksi Periode',
                hasBorder: true,
              ),
              _buildLegendItem(
                color: const Color(0xFFE6E6FA),
                label: 'Masa Subur',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool hasBorder = false,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(color: const Color(0xFFFFB6C1), width: 1, style: BorderStyle.solid)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}