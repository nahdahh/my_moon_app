import 'package:flutter/material.dart';
import 'package:my_moon/screens/onboarding_screen.dart';
import 'package:my_moon/screens/welcome_screen.dart';
import 'package:my_moon/services/notification_service.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My MOON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D6D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF4D6D),
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Debug: Print saved navigation data
      await NavigationService.debugPrintSavedData();
      
      // Initialize auth service first
      await _authService.initializeAuth();
      
      // Add a small delay to show splash screen briefly
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if user is logged in from both PocketBase and SharedPreferences
      bool isLoggedInPB = _authService.isLoggedIn();
      bool isLoggedInStorage = await _authService.isLoggedInFromStorage();
      
      print("AuthCheck: PocketBase login status: $isLoggedInPB");
      print("AuthCheck: Storage login status: $isLoggedInStorage");
      
      bool isLoggedIn = isLoggedInPB;
      
      // If PocketBase says not logged in but storage says yes, try to restore
      if (!isLoggedInPB && isLoggedInStorage) {
        // Try to refresh auth token
        bool refreshSuccess = await _authService.refreshAuth();
        if (refreshSuccess) {
          isLoggedIn = _authService.isLoggedIn();
          print("AuthCheck: Session restored successfully: $isLoggedIn");
        } else {
          print("AuthCheck: Failed to restore session");
        }
      }
      
      // If still logged in, try to refresh token to ensure it's valid
      if (isLoggedIn) {
        try {
          bool refreshSuccess = await _authService.refreshAuth();
          if (!refreshSuccess) {
            print("AuthCheck: Token refresh failed, user needs to login again");
            isLoggedIn = false;
          }
        } catch (e) {
          print("AuthCheck: Failed to refresh auth token: $e");
          isLoggedIn = false;
        }
      }
      
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
        
        // Navigate to appropriate screen
        if (isLoggedIn) {
          await _navigateToLastKnownRoute();
        } else {
          print("AuthCheck: User is not logged in, navigating to OnboardingScreen");
          // Clear any saved route since user is not logged in
          await NavigationService.clearSavedRoute();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      print("AuthCheck: Error checking auth status: $e");
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
        
        // On error, go to onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  Future<void> _navigateToLastKnownRoute() async {
    try {
      // Get the last saved route
      final lastRoute = await NavigationService.getLastRoute();
      print("AuthCheck: Last saved route: $lastRoute");
      
      Widget destinationWidget;
      
      if (lastRoute != null && lastRoute.isNotEmpty) {
        // Try to get widget for the saved route
        final savedWidget = NavigationService.getWidgetForRoute(lastRoute);
        
        if (savedWidget != null) {
          destinationWidget = savedWidget;
          print("AuthCheck: Navigating to last saved route: $lastRoute");
        } else {
          // If saved route is invalid, go to welcome screen
          destinationWidget = const WelcomeScreen();
          print("AuthCheck: Invalid saved route ($lastRoute), navigating to WelcomeScreen");
        }
      } else {
        // No saved route, go to welcome screen
        destinationWidget = const WelcomeScreen();
        print("AuthCheck: No saved route, navigating to WelcomeScreen");
      }
      
      // Don't save the route here, let the destination screen save it
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destinationWidget),
        );
      }
    } catch (e) {
      print("AuthCheck: Error navigating to last known route: $e");
      
      // Fallback to welcome screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isChecking 
          ? const CircularProgressIndicator(
              color: Color(0xFFFF4D6D),
              strokeWidth: 3,
            )
          : const SizedBox.shrink(),
      ),
    );
  }
}
