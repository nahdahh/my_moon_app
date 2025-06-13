import 'package:flutter/material.dart';
import 'package:my_moon/screens/home_screen.dart';
import 'package:my_moon/screens/calendar_screen.dart';
import 'package:my_moon/screens/profile_screen.dart';
import 'package:my_moon/screens/analytics_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              onTap: () => _navigateToScreen(context, const HomeScreen()),
              child: _buildCustomHomeIcon(currentIndex == 0),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              onTap: () => _navigateToScreen(context, const CalendarScreen()),
              child: _buildCustomCalendarIcon(currentIndex == 1),
            ),
            const SizedBox(width: 56), // Space for center FAB
            _buildNavItem(
              context: context,
              index: 2,
              onTap: () => _navigateToScreen(context, const AnalyticsScreen()),
              child: Icon(
                Icons.bar_chart_outlined,
                color: currentIndex == 2 ? const Color(0xFFFF4D6D) : const Color(0xFFC4C4C4),
                size: 24,
              ),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              onTap: () => _navigateToScreen(context, const ProfileScreen()),
              child: Icon(
                Icons.person_outline,
                color: currentIndex == 3 ? const Color(0xFFFF4D6D) : const Color(0xFFC4C4C4),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: currentIndex != index ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }

  Widget _buildCustomHomeIcon(bool isActive) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: HomeIconPainter(
          color: isActive ? const Color(0xFFFF4D6D) : const Color(0xFFC4C4C4),
        ),
      ),
    );
  }

  Widget _buildCustomCalendarIcon(bool isActive) {
    return Icon(
      Icons.calendar_today_outlined,
      color: isActive ? const Color(0xFFFF4D6D) : const Color(0xFFC4C4C4),
      size: 24,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class HomeIconPainter extends CustomPainter {
  final Color color;
  HomeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // House shape - simple dan sedikit tinggi
    // Mulai dari kiri bawah
    path.moveTo(size.width * 0.15, size.height * 0.9);
    // Garis kiri ke atas
    path.lineTo(size.width * 0.15, size.height * 0.45);
    // Atap kiri
    path.lineTo(size.width * 0.5, size.height * 0.15);
    // Atap kanan
    path.lineTo(size.width * 0.85, size.height * 0.45);
    // Garis kanan ke bawah
    path.lineTo(size.width * 0.85, size.height * 0.9);
    // Garis bawah
    path.lineTo(size.width * 0.15, size.height * 0.9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
