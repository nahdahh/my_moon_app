import 'package:flutter/material.dart';

class WeekCalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final DateTime? selectedDate;
  final List<DateTime> periodDays;
  final List<DateTime> predictedPeriodDays;
  final List<DateTime> fertileWindowDays;
  final Function(DateTime)? onDaySelected;

  const WeekCalendarWidget({
    Key? key,
    required this.currentDate,
    this.selectedDate,
    this.periodDays = const [],
    this.predictedPeriodDays = const [],
    this.fertileWindowDays = const [],
    this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the dates for the current week (Sunday to Saturday)
    final today = DateTime.now();
    final weekday = currentDate.weekday % 7; // Convert to Sunday = 0
    final startOfWeek = currentDate.subtract(Duration(days: weekday));
    
    final weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
    
    // Pastikan semua tanggal valid
    final validPeriodDays = periodDays.where((date) => date != null).toList();
    final validPredictedPeriodDays = predictedPeriodDays.where((date) => date != null).toList();
    final validFertileWindowDays = fertileWindowDays.where((date) => date != null).toList();
    
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels.map((day) => 
              Text(
                day,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              )
            ).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Week dates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDates.map((date) {
              final isSelected = selectedDate != null &&
                                date.year == selectedDate!.year &&
                                date.month == selectedDate!.month &&
                                date.day == selectedDate!.day;
                           
              final isPeriodDay = validPeriodDays.any((d) => 
                  d.day == date.day && d.month == date.month && d.year == date.year);
                
              final isPredictedPeriodDay = validPredictedPeriodDays.any((d) => 
                  d.day == date.day && d.month == date.month && d.year == date.year);
                
              final isFertileWindowDay = validFertileWindowDays.any((d) => 
                  d.day == date.day && d.month == date.month && d.year == date.year);
            
            // Check if the date is today
            final isToday = date.year == today.year && 
                           date.month == today.month && 
                           date.day == today.day;
            
            // Check if the date is in the future
            final isInFuture = date.isAfter(DateTime.now());
            
            Color backgroundColor;
            Color textColor;
            Border? border;
            
            // Apply color rules based on priority
            if (isPeriodDay) {
              backgroundColor = const Color(0xFFF38CA6); // Period days
              textColor = Colors.white;
            } else if (isFertileWindowDay) {
              backgroundColor = const Color(0xFFE7E7FF); // Fertile window days
              textColor = Colors.black;
            } else if (isPredictedPeriodDay) {
              backgroundColor = const Color(0xFFE8E4F3); // Light background for predicted
              textColor = Colors.black;
              border = Border.all(color: const Color(0xFFFF2D55), width: 2); // Red stroke for predicted period
            } else {
              backgroundColor = const Color(0xFFE8E4F3); // Light purple for other days
              textColor = Colors.black54;
            }
            
            // Add blue stroke for today or selected date
            if (isToday || isSelected) {
              border = Border.all(color: Colors.blue, width: 2);
            }
            
            // Gray out future dates
            if (isInFuture && !isToday) {
              backgroundColor = Colors.grey[100]!;
              textColor = Colors.grey[300]!;
              border = null;
            }
            
            return GestureDetector(
              onTap: () {
                if (!isInFuture && onDaySelected != null) {
                  onDaySelected!(date);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: border,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
}
