import 'package:flutter/material.dart';

class NumberSelector extends StatefulWidget {
  final int defaultValue;
  final int minValue;
  final int maxValue;
  final Function(int) onValueChanged;
  final String label;

  const NumberSelector({
    Key? key,
    required this.defaultValue,
    this.minValue = 1,
    this.maxValue = 40,
    required this.onValueChanged,
    this.label = 'Days',
  }) : super(key: key);

  @override
  State<NumberSelector> createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.defaultValue;
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue++;
        widget.onValueChanged(_currentValue);
      });
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue--;
        widget.onValueChanged(_currentValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 400 ? screenWidth * 0.5 : 200.0;
    
    return Container(
      height: 100,
      width: containerWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D6D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF4D6D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _decrement,
            color: const Color(0xFFFF4D6D),
            iconSize: 28,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_currentValue',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4D6D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _increment,
            color: const Color(0xFFFF4D6D),
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
