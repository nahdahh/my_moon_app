import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfiniteNumberPicker extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int) onValueChanged;
  final String label;

  const InfiniteNumberPicker({
    Key? key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
    required this.label,
  }) : super(key: key);

  @override
  State<InfiniteNumberPicker> createState() => _InfiniteNumberPickerState();
}

class _InfiniteNumberPickerState extends State<InfiniteNumberPicker> {
  late FixedExtentScrollController _scrollController;
  late int _currentValue;

  // Large number to simulate infinite scroll
  static const int _infiniteOffset = 10000;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    
    // Start at middle position for infinite scroll effect
    final initialIndex = _infiniteOffset + (widget.initialValue - widget.minValue);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getValueFromIndex(int index) {
    final range = widget.maxValue - widget.minValue + 1;
    final normalizedIndex = (index - _infiniteOffset) % range;
    final adjustedIndex = normalizedIndex < 0 ? normalizedIndex + range : normalizedIndex;
    return widget.minValue + adjustedIndex;
  }

  void _onSelectedItemChanged(int index) {
    final newValue = _getValueFromIndex(index);
    if (newValue != _currentValue) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onValueChanged(newValue);
      
      // Haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Full-width selection highlight
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            
            // Content row with number and label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  // Number picker
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: 60,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const BouncingScrollPhysics(),
                        onSelectedItemChanged: _onSelectedItemChanged,
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final value = _getValueFromIndex(index);
                            final isSelected = value == _currentValue;
                            
                            return GestureDetector(
                              onTap: () {
                                _scrollController.animateToItem(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.black : const Color(0xFFC0C0C0),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: null, // Infinite
                        ),
                      ),
                    ),
                  ),
                  
                  // Days label
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
