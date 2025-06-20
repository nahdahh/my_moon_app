import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:my_moon/screens/welcome_screen.dart';
import 'package:my_moon/screens/home_screen.dart';
import 'package:my_moon/screens/calendar_screen.dart';
import 'package:my_moon/screens/profile_screen.dart';
import 'package:my_moon/screens/analytics_screen.dart';
import 'package:my_moon/screens/setting_screen.dart';
import 'package:my_moon/screens/notification_screen.dart';
import 'package:my_moon/screens/cycle_screen.dart';

class NavigationService {
  static const String _lastRouteKey = 'last_route';
  static const String _lastRouteDataKey = 'last_route_data';

  /// Save current route to SharedPreferences
  static Future<void> saveCurrentRoute(String routeName, {Map<String, dynamic>? routeData}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastRouteKey, routeName);
      
      if (routeData != null) {
        await prefs.setString(_lastRouteDataKey, routeData.toString());
      }
      
      print("NavigationService: Saved current route: $routeName");
    } catch (e) {
      print("NavigationService: Error saving current route: $e");
    }
  }

  /// Get last saved route
  static Future<String?> getLastRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRoute = prefs.getString(_lastRouteKey);
      print("NavigationService: Retrieved last route: $lastRoute");
      return lastRoute;
    } catch (e) {
      print("NavigationService: Error getting last route: $e");
      return null;
    }
  }

  /// Clear saved route
  static Future<void> clearSavedRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRouteKey);
      await prefs.remove(_lastRouteDataKey);
      print("NavigationService: Cleared saved route");
    } catch (e) {
      print("NavigationService: Error clearing saved route: $e");
    }
  }

  /// Get widget for route name
  static Widget? getWidgetForRoute(String routeName) {
    print("NavigationService: Getting widget for route: $routeName");
    
    switch (routeName) {
      case '/welcome':
        print("NavigationService: Returning WelcomeScreen");
        return const WelcomeScreen();
      case '/home':
        print("NavigationService: Returning HomeScreen");
        return const HomeScreen();
      case '/calendar':
        print("NavigationService: Returning CalendarScreen");
        return const CalendarScreen();
      case '/profile':
        print("NavigationService: Returning ProfileScreen");
        return const ProfileScreen();
      case '/analytics':
        print("NavigationService: Returning AnalyticsScreen");
        return const AnalyticsScreen();
      case '/settings':
        print("NavigationService: Returning SettingScreen");
        return const SettingScreen();
      case '/notifications':
        print("NavigationService: Returning NotificationScreen");
        return const NotificationScreen();
      case '/cycle':
        print("NavigationService: Returning CycleScreen");
        return const CycleScreen();
      default:
        print("NavigationService: Unknown route: $routeName");
        return null;
    }
  }

  /// Navigate and save route
  static Future<void> navigateAndSave(BuildContext context, Widget destination, String routeName) async {
    print("NavigationService: Navigating to $routeName");
    await saveCurrentRoute(routeName);
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  /// Navigate without replacement and save route
  static Future<void> pushAndSave(BuildContext context, Widget destination, String routeName) async {
    print("NavigationService: Pushing to $routeName");
    await saveCurrentRoute(routeName);
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  /// Debug: Print all saved navigation data
  static Future<void> debugPrintSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRoute = prefs.getString(_lastRouteKey);
      final lastRouteData = prefs.getString(_lastRouteDataKey);
      
      print("NavigationService Debug:");
      print("  - Last Route: $lastRoute");
      print("  - Last Route Data: $lastRouteData");
      print("  - All Keys: ${prefs.getKeys()}");
    } catch (e) {
      print("NavigationService: Error in debug print: $e");
    }
  }
}
