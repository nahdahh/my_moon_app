import 'package:my_moon/services/auth_service.dart';
import 'package:pocketbase/pocketbase.dart';

class PeriodService {
  final AuthService _authService = AuthService();
  
  /// Log a period day with symptoms
  Future<bool> logPeriodDay({
    required DateTime date,
    String? flow, // spotting, light, medium, heavy
    List<String>? moods, // happy, sad, tired, etc.
    String? crampSeverity, // none, mild, moderate, severe, extreme
    List<String>? symptoms, // headache, backache, etc.
    String? notes,
  }) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot log period: User not logged in");
        return false;
      }
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        print("Auth store is not valid, attempting to refresh");
        try {
          await pb.collection('users').authRefresh();
        } catch (e) {
          print("Failed to refresh auth: $e");
          return false;
        }
      }
      
      final body = {
        "user": user.id,
        "date": date.toIso8601String().split('T')[0], // YYYY-MM-DD
        "flow": flow,
        "moods": moods,
        "cramp_severity": crampSeverity,
        "symptoms": symptoms,
        "notes": notes,
      };
      
      print("Logging period day with data: $body");
      
      final result = await pb.collection('period_logs').create(body: body);
      print("Period log created with ID: ${result.id}");
      return true;
    } catch (e) {
      print("Log period error: $e");
      return false;
    }
  }
  
  /// Get period logs for a specific month
  Future<List<RecordModel>> getPeriodLogsForMonth(DateTime month) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return [];
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        try {
          await pb.collection('users').authRefresh();
        } catch (e) {
          print("Failed to refresh auth: $e");
          return [];
        }
      }
      
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      
      final firstDayStr = "${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}";
      final lastDayStr = "${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}";
      
      print("Getting period logs from $firstDayStr to $lastDayStr");
      
      final records = await pb.collection('period_logs').getList(
        filter: 'user = "${user.id}" && date >= "$firstDayStr" && date <= "$lastDayStr"',
        sort: '+date',
      );
      
      print("Found ${records.items.length} period logs");
      return records.items;
    } catch (e) {
      print("Get period logs error: $e");
      return [];
    }
  }
  
  /// Get all period logs for the user
  Future<List<RecordModel>> getAllPeriodLogs() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return [];
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        try {
          await pb.collection('users').authRefresh();
        } catch (e) {
          print("Failed to refresh auth: $e");
          return [];
        }
      }
      
      print("Getting all period logs for user ${user.id}");
      
      final records = await pb.collection('period_logs').getList(
        filter: 'user = "${user.id}"',
        sort: '+date',
      );
      
      print("Found ${records.items.length} period logs");
      return records.items;
    } catch (e) {
      print("Get all period logs error: $e");
      return [];
    }
  }
  
  /// Save user's cycle information
  Future<bool> saveCycleInfo({
    required int periodLength,
    required int cycleLength,
    required DateTime lastPeriodStartDate,
  }) async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot save cycle info: User not logged in");
        return false;
      }
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        print("Auth store is not valid, attempting to refresh");
        try {
          await pb.collection('users').authRefresh();
        } catch (e) {
          print("Failed to refresh auth: $e");
          return false;
        }
      }
      
      // Format the date as YYYY-MM-DD
      final formattedDate = "${lastPeriodStartDate.year}-${lastPeriodStartDate.month.toString().padLeft(2, '0')}-${lastPeriodStartDate.day.toString().padLeft(2, '0')}";
      
      print("Saving to user_initial_data:");
      print("id_user: ${user.id}");
      print("period_length: $periodLength");
      print("cycle_length: $cycleLength");
      print("last_period_date: $formattedDate");
      
      // Create the request body
      final Map<String, dynamic> body = {
        "id_user": user.id,
        "period_length": periodLength,
        "cycle_length": cycleLength,
        "last_period_date": formattedDate,
      };
      
      // Check if cycle info already exists
      print("Checking if cycle info already exists");
      final records = await pb.collection('user_initial_data').getList(
        filter: 'id_user = "${user.id}"',
      );
      
      if (records.items.isNotEmpty) {
        print("Updating existing record: ${records.items[0].id}");
        final result = await pb.collection('user_initial_data').update(records.items[0].id, body: body);
        print("Update result: ${result.id}");
      } else {
        print("Creating new record");
        final result = await pb.collection('user_initial_data').create(body: body);
        print("Create result: ${result.id}");
      }
      
      print("Cycle info saved successfully");
      return true;
    } catch (e) {
      print("Save cycle info error: $e");
      return false;
    }
  }
  
  /// Get user's cycle information
  Future<Map<String, dynamic>?> getCycleInfo() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return null;
      
      // Ensure PocketBase is authenticated
      if (!pb.authStore.isValid) {
        try {
          await pb.collection('users').authRefresh();
        } catch (e) {
          print("Failed to refresh auth: $e");
          return null;
        }
      }
      
      print("Getting cycle info for user ${user.id}");
      
      final records = await pb.collection('user_initial_data').getList(
        filter: 'id_user = "${user.id}"',
      );
      
      if (records.items.isEmpty) {
        print("No cycle info found");
        return null;
      }
      
      print("Found cycle info: ${records.items[0].data}");
      return records.items[0].data;
    } catch (e) {
      print("Get cycle info error: $e");
      return null;
    }
  }
  
  /// Calculate predicted period days based on cycle info
  List<DateTime> calculatePredictedPeriodDays({
    required DateTime lastPeriodStartDate,
    required int periodLength,
    required int cycleLength,
    int numberOfCycles = 3, // Calculate for the next 3 cycles
  }) {
    final List<DateTime> predictedDays = [];
    
    for (int cycle = 1; cycle <= numberOfCycles; cycle++) {
      final nextPeriodStart = DateTime(
        lastPeriodStartDate.year,
        lastPeriodStartDate.month,
        lastPeriodStartDate.day + (cycleLength * cycle),
      );
      
      for (int day = 0; day < periodLength; day++) {
        predictedDays.add(
          DateTime(nextPeriodStart.year, nextPeriodStart.month, nextPeriodStart.day + day),
        );
      }
    }
    
    return predictedDays;
  }
  
  /// Calculate fertile window days based on cycle info
  List<DateTime> calculateFertileWindowDays({
    required DateTime lastPeriodStartDate,
    required int cycleLength,
    int numberOfCycles = 3, // Calculate for the next 3 cycles
  }) {
    final List<DateTime> fertileWindowDays = [];
    
    for (int cycle = 1; cycle <= numberOfCycles; cycle++) {
      // Fertile window is typically from day 11 to day 17 of the cycle
      // (counting from the first day of the period)
      final cycleStartDate = DateTime(
        lastPeriodStartDate.year,
        lastPeriodStartDate.month,
        lastPeriodStartDate.day + (cycleLength * (cycle - 1)),
      );
      
      for (int day = 11; day <= 17; day++) {
        fertileWindowDays.add(
          DateTime(cycleStartDate.year, cycleStartDate.month, cycleStartDate.day + day),
        );
      }
    }
    
    return fertileWindowDays;
  }
}
