import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const DatePickerWidget({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  static const int _infiniteOffset = 10000;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month;
    _selectedYear = widget.initialDate.year;
    
    // Initialize controllers
    _dayController = FixedExtentScrollController(
      initialItem: _infiniteOffset + (_selectedDay - 1),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _infiniteOffset + (_selectedMonth - 1),
    );
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - 2020, // Years 2020-2030
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(int month, int year) {
    switch (month) {
      case 2: // February
        return _isLeapYear(year) ? 29 : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int _getDayFromIndex(int index) {
    final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
    final normalizedIndex = (index - _infiniteOffset) % maxDays;
    final adjustedIndex = normalizedIndex < 0 ? normalizedIndex + maxDays : normalizedIndex;
    return adjustedIndex + 1;
  }

  int _getMonthFromIndex(int index) {
    const maxMonths = 12;
    final normalizedIndex = (index - _infiniteOffset) % maxMonths;
    final adjustedIndex = normalizedIndex < 0 ? normalizedIndex + maxMonths : normalizedIndex;
    return adjustedIndex + 1;
  }

  int _getYearFromIndex(int index) {
    const minYear = 2020;
    const maxYear = 2030;
    final range = maxYear - minYear + 1;
    
    if (index < 0) return minYear;
    if (index >= range) return maxYear;
    
    return minYear + index;
  }

  void _updateDate() {
    final newDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    widget.onDateChanged(newDate);
  }

  void _onDayChanged(int index) {
    final newDay = _getDayFromIndex(index);
    final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
    
    if (newDay != _selectedDay) {
      setState(() {
        _selectedDay = newDay > maxDays ? maxDays : newDay;
      });
      _updateDate();
      HapticFeedback.selectionClick();
    }
  }

  void _onMonthChanged(int index) {
    final newMonth = _getMonthFromIndex(index);
    if (newMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = newMonth;
        
        // Validate day for new month
        final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
        if (_selectedDay > maxDays) {
          _selectedDay = maxDays;
          // Update day controller
          _dayController.animateToItem(
            _infiniteOffset + (_selectedDay - 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      _updateDate();
      HapticFeedback.selectionClick();
    }
  }

  void _onYearChanged(int index) {
    final newYear = _getYearFromIndex(index);
    if (newYear != _selectedYear) {
      setState(() {
        _selectedYear = newYear;
        
        // Validate day for new year (leap year check)
        final maxDays = _getDaysInMonth(_selectedMonth, _selectedYear);
        if (_selectedDay > maxDays) {
          _selectedDay = maxDays;
          // Update day controller
          _dayController.animateToItem(
            _infiniteOffset + (_selectedDay - 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      _updateDate();
      HapticFeedback.selectionClick();
    }
  }

  Widget _buildPickerColumn({
    required FixedExtentScrollController controller,
    required Function(int) onSelectedItemChanged,
    required Widget Function(int) itemBuilder,
    bool isInfinite = true,
  }) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Picker
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 60,
            perspective: 0.005,
            diameterRatio: 1.5,
            physics: const BouncingScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => itemBuilder(index),
              childCount: isInfinite ? null : 11, // null for infinite, 11 for years (2020-2030)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Row(
        children: [
          // Day picker
          _buildPickerColumn(
            controller: _dayController,
            onSelectedItemChanged: _onDayChanged,
            itemBuilder: (index) {
              final day = _getDayFromIndex(index);
              final isSelected = day == _selectedDay;
              
              return GestureDetector(
                onTap: () {
                  _dayController.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 24,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black : const Color(0xFFC0C0C0),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Month picker
          _buildPickerColumn(
            controller: _monthController,
            onSelectedItemChanged: _onMonthChanged,
            itemBuilder: (index) {
              final month = _getMonthFromIndex(index);
              final isSelected = month == _selectedMonth;
              
              return GestureDetector(
                onTap: () {
                  _monthController.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    _months[month - 1],
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 24,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black : const Color(0xFFC0C0C0),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Year picker
          _buildPickerColumn(
            controller: _yearController,
            onSelectedItemChanged: _onYearChanged,
            isInfinite: false,
            itemBuilder: (index) {
              final year = _getYearFromIndex(index);
              final isSelected = year == _selectedYear;
              
              return GestureDetector(
                onTap: () {
                  _yearController.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 24,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black : const Color(0xFFC0C0C0),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
