import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VerticalDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const VerticalDateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<VerticalDateSelector> createState() => _VerticalDateSelectorState();
}

class _VerticalDateSelectorState extends State<VerticalDateSelector> {
  @override
  Widget build(BuildContext context) {
    // Create 3 dates: previous month, current, next month
    final List<DateTime> dates = [
      DateTime(widget.selectedDate.year, widget.selectedDate.month - 1, widget.selectedDate.day),
      widget.selectedDate,
      DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, widget.selectedDate.day),
    ];

    return Column(
      children: dates.asMap().entries.map((entry) {
        final index = entry.key;
        final date = entry.value;
        final isSelected = index == 1; // Middle one is selected
        
        return GestureDetector(
          onTap: () {
            widget.onDateChanged(date);
          },
          child: Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8D5FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    date.year.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
