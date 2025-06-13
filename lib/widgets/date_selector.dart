import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const DateSelector({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _selectedDate;
  late List<int> _days;
  late List<String> _months;
  late List<int> _years;
  
  late int _selectedDayIndex;
  late int _selectedMonthIndex;
  late int _selectedYearIndex;
  
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  
  final List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    
    // Initialize the lists
    _initializeLists();
    
    // Set initial selected indices
    _selectedDayIndex = _days.indexOf(_selectedDate.day);
    if (_selectedDayIndex < 0) _selectedDayIndex = 0;
    
    _selectedMonthIndex = _selectedDate.month - 1; // Month is 1-based
    if (_selectedMonthIndex < 0) _selectedMonthIndex = 0;
    
    _selectedYearIndex = _years.indexOf(_selectedDate.year);
    if (_selectedYearIndex < 0) _selectedYearIndex = _years.length - 1; // Default to current year
    
    // Initialize controllers
    _dayController = FixedExtentScrollController(initialItem: _selectedDayIndex);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonthIndex);
    _yearController = FixedExtentScrollController(initialItem: _selectedYearIndex);
    
    print("DateSelector initialized:");
    print("- Initial date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
    print("- Day index: $_selectedDayIndex");
    print("- Month index: $_selectedMonthIndex");
    print("- Year index: $_selectedYearIndex");
    
    // Call onDateChanged with the initial date to ensure parent has the correct date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged(_selectedDate);
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _initializeLists() {
    // Generate days 1-31
    _days = List.generate(31, (index) => index + 1);
    
    // Generate months
    _months = _monthNames;
    
    // Generate years (current year - 2 to current year)
    final currentYear = DateTime.now().year;
    _years = List.generate(3, (index) => currentYear - 2 + index);
  }

  void _updateSelectedDate() {
    try {
      // Make sure we don't create an invalid date
      final year = _years[_selectedYearIndex];
      final month = _selectedMonthIndex + 1; // Convert back to 1-based
      
      // Get the last day of the selected month
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      
      // Ensure day is valid for the month
      final day = _days[_selectedDayIndex] > lastDayOfMonth 
          ? lastDayOfMonth 
          : _days[_selectedDayIndex];
      
      final newDate = DateTime(year, month, day);
      
      if (_selectedDate != newDate) {
        setState(() {
          _selectedDate = newDate;
        });
        
        // Notify parent of the date change
        widget.onDateChanged(_selectedDate);
        print('Date updated: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');
      }
    } catch (e) {
      print('Error updating date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // Reduced height
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF4D6D), width: 1),
      ),
      child: Row(
        children: [
          // Day picker
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D6D),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListWheelScrollView(
                    controller: _dayController,
                    itemExtent: 30,
                    diameterRatio: 1.5,
                    perspective: 0.005,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                      _updateSelectedDate();
                    },
                    children: _days.map((day) {
                      final isSelected = day == _days[_selectedDayIndex];
                      return Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFFF4D6D) : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Month picker
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D6D),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListWheelScrollView(
                    controller: _monthController,
                    itemExtent: 30,
                    diameterRatio: 1.5,
                    perspective: 0.005,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMonthIndex = index;
                      });
                      _updateSelectedDate();
                    },
                    children: _months.map((month) {
                      final isSelected = month == _months[_selectedMonthIndex];
                      return Center(
                        child: Text(
                          month,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFFF4D6D) : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Year picker
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Year',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D6D),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListWheelScrollView(
                    controller: _yearController,
                    itemExtent: 30,
                    diameterRatio: 1.5,
                    perspective: 0.005,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYearIndex = index;
                      });
                      _updateSelectedDate();
                    },
                    children: _years.map((year) {
                      final isSelected = year == _years[_selectedYearIndex];
                      return Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFFF4D6D) : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
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
