import 'package:flutter/material.dart';

class VerticalNumberSelector extends StatefulWidget {
  final int selectedValue;
  final int minValue;
  final int maxValue;
  final Function(int) onValueChanged;

  const VerticalNumberSelector({
    Key? key,
    required this.selectedValue,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<VerticalNumberSelector> createState() => _VerticalNumberSelectorState();
}

class _VerticalNumberSelectorState extends State<VerticalNumberSelector> {
  @override
  Widget build(BuildContext context) {
    // Show 3 values: previous, current, next
    final List<int> values = [];
    
    // Add previous value if exists
    if (widget.selectedValue > widget.minValue) {
      values.add(widget.selectedValue - 1);
    }
    
    // Add current value
    values.add(widget.selectedValue);
    
    // Add next value if exists
    if (widget.selectedValue < widget.maxValue) {
      values.add(widget.selectedValue + 1);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: values.map((value) {
        final isSelected = value == widget.selectedValue;
        
        return GestureDetector(
          onTap: () {
            widget.onValueChanged(value);
          },
          // Add vertical drag support
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Dragged down - decrease value
              if (widget.selectedValue > widget.minValue) {
                widget.onValueChanged(widget.selectedValue - 1);
              }
            } else if (details.primaryVelocity! < 0) {
              // Dragged up - increase value
              if (widget.selectedValue < widget.maxValue) {
                widget.onValueChanged(widget.selectedValue + 1);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: isSelected ? 70 : 50,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8D5FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[400],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
