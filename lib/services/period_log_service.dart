import 'package:pocketbase/pocketbase.dart';
import 'package:my_moon/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PeriodLogService {
  final AuthService _authService = AuthService();
  
  // Get all flows from the flows collection
  Future<List<Map<String, dynamic>>> getFlows() async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch flows: User not logged in");
        return [];
      }
      
      print("Fetching flows from PocketBase...");
      
      // Try to get the flows directly from PocketBase
      final records = await pb.collection('flows').getFullList();
      print("Successfully fetched ${records.length} flows");
      
      // If no records found, check if the collection exists
      if (records.isEmpty) {
        try {
          // Try to get collection info to check if it exists
          await pb.collections.getOne('flows');
          print("Flows collection exists but is empty");
        } catch (e) {
          print("Error checking flows collection: $e");
          // Return some default data if collection doesn't exist or has issues
          return [
            {'id': 'default1', 'name': 'Light', 'iconUrl': null},
            {'id': 'default2', 'name': 'Medium', 'iconUrl': null},
            {'id': 'default3', 'name': 'Heavy', 'iconUrl': null},
          ];
        }
      }
      
      // Convert RecordModel objects to Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Add the ID to the map
        
        // Add image URL if icon exists
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          // Construct the full URL to the icon image
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'flows';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for flow ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // If no records were found, return default data
      if (result.isEmpty) {
        return [
          {'id': 'default1', 'name': 'Light', 'iconUrl': null},
          {'id': 'default2', 'name': 'Medium', 'iconUrl': null},
          {'id': 'default3', 'name': 'Heavy', 'iconUrl': null},
        ];
      }
      
      return result;
    } catch (e) {
      print("Error fetching flows: $e");
      // Return default data on error
      return [
        {'id': 'default1', 'name': 'Light', 'iconUrl': null},
        {'id': 'default2', 'name': 'Medium', 'iconUrl': null},
        {'id': 'default3', 'name': 'Heavy', 'iconUrl': null},
      ];
    }
  }

  // Get all moods from the moods collection
  Future<List<Map<String, dynamic>>> getMoods() async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch moods: User not logged in");
        return [];
      }
      
      print("Fetching moods from PocketBase...");
      
      // Try to get the moods directly from PocketBase
      final records = await pb.collection('moods').getFullList();
      print("Successfully fetched ${records.length} moods");
      
      // If no records found, check if the collection exists
      if (records.isEmpty) {
        try {
          // Try to get collection info to check if it exists
          await pb.collections.getOne('moods');
          print("Moods collection exists but is empty");
        } catch (e) {
          print("Error checking moods collection: $e");
          // Return some default data if collection doesn't exist or has issues
          return [
            {'id': 'default1', 'name': 'Happy', 'iconUrl': null},
            {'id': 'default2', 'name': 'Sad', 'iconUrl': null},
            {'id': 'default3', 'name': 'Angry', 'iconUrl': null},
            {'id': 'default4', 'name': 'Tired', 'iconUrl': null},
          ];
        }
      }
      
      // Convert RecordModel objects to Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Add the ID to the map
        
        // Handle icon field (should be a single string based on schema)
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'moods';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for mood ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // If no records were found, return default data
      if (result.isEmpty) {
        return [
          {'id': 'default1', 'name': 'Happy', 'iconUrl': null},
          {'id': 'default2', 'name': 'Sad', 'iconUrl': null},
          {'id': 'default3', 'name': 'Angry', 'iconUrl': null},
          {'id': 'default4', 'name': 'Tired', 'iconUrl': null},
        ];
      }
      
      return result;
    } catch (e) {
      print("Error fetching moods: $e");
      // Return default data on error
      return [
        {'id': 'default1', 'name': 'Happy', 'iconUrl': null},
        {'id': 'default2', 'name': 'Sad', 'iconUrl': null},
        {'id': 'default3', 'name': 'Angry', 'iconUrl': null},
        {'id': 'default4', 'name': 'Tired', 'iconUrl': null},
      ];
    }
  }

  // Get all cramps from the cramps collection
  Future<List<Map<String, dynamic>>> getCramps() async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch cramps: User not logged in");
        return [];
      }
      
      print("Fetching cramps from PocketBase...");
      
      // Try to get the cramps directly from PocketBase
      final records = await pb.collection('cramps').getFullList();
      print("Successfully fetched ${records.length} cramps");
      
      // If no records found, check if the collection exists
      if (records.isEmpty) {
        try {
          // Try to get collection info to check if it exists
          await pb.collections.getOne('cramps');
          print("Cramps collection exists but is empty");
        } catch (e) {
          print("Error checking cramps collection: $e");
          // Return some default data if collection doesn't exist or has issues
          return [
            {'id': 'default1', 'name': 'None', 'iconUrl': null},
            {'id': 'default2', 'name': 'Mild', 'iconUrl': null},
            {'id': 'default3', 'name': 'Moderate', 'iconUrl': null},
            {'id': 'default4', 'name': 'Severe', 'iconUrl': null},
          ];
        }
      }
      
      // Convert RecordModel objects to Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Add the ID to the map
        
        // Add image URL if icon exists
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          // Construct the full URL to the icon image
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'cramps';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for cramp ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // If no records were found, return default data
      if (result.isEmpty) {
        return [
          {'id': 'default1', 'name': 'None', 'iconUrl': null},
          {'id': 'default2', 'name': 'Mild', 'iconUrl': null},
          {'id': 'default3', 'name': 'Moderate', 'iconUrl': null},
          {'id': 'default4', 'name': 'Severe', 'iconUrl': null},
        ];
      }
      
      return result;
    } catch (e) {
      print("Error fetching cramps: $e");
      // Return default data on error
      return [
        {'id': 'default1', 'name': 'None', 'iconUrl': null},
        {'id': 'default2', 'name': 'Mild', 'iconUrl': null},
        {'id': 'default3', 'name': 'Moderate', 'iconUrl': null},
        {'id': 'default4', 'name': 'Severe', 'iconUrl': null},
      ];
    }
  }

  // Get all body conditions from the body_conditions collection
  Future<List<Map<String, dynamic>>> getBodyConditions() async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch body conditions: User not logged in");
        return [];
      }
      
      print("Fetching body conditions from PocketBase...");
      
      // Try to get the body conditions directly from PocketBase
      final records = await pb.collection('body_conditions').getFullList();
      print("Successfully fetched ${records.length} body conditions");
      
      // If no records found, check if the collection exists
      if (records.isEmpty) {
        try {
          // Try to get collection info to check if it exists
          await pb.collections.getOne('body_conditions');
          print("Body conditions collection exists but is empty");
        } catch (e) {
          print("Error checking body_conditions collection: $e");
          // Return some default data if collection doesn't exist or has issues
          return [
            {'id': 'default1', 'name': 'Headache', 'iconUrl': null},
            {'id': 'default2', 'name': 'Backache', 'iconUrl': null},
            {'id': 'default3', 'name': 'Bloating', 'iconUrl': null},
            {'id': 'default4', 'name': 'Fatigue', 'iconUrl': null},
          ];
        }
      }
      
      // Convert RecordModel objects to Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Add the ID to the map
        
        // Handle icon field (should be a single string based on schema)
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'body_conditions';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for body condition ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // If no records were found, return default data
      if (result.isEmpty) {
        return [
          {'id': 'default1', 'name': 'Headache', 'iconUrl': null},
          {'id': 'default2', 'name': 'Backache', 'iconUrl': null},
          {'id': 'default3', 'name': 'Bloating', 'iconUrl': null},
          {'id': 'default4', 'name': 'Fatigue', 'iconUrl': null},
        ];
      }
      
      return result;
    } catch (e) {
      print("Error fetching body conditions: $e");
      // Return default data on error
      return [
        {'id': 'default1', 'name': 'Headache', 'iconUrl': null},
        {'id': 'default2', 'name': 'Backache', 'iconUrl': null},
        {'id': 'default3', 'name': 'Bloating', 'iconUrl': null},
        {'id': 'default4', 'name': 'Fatigue', 'iconUrl': null},
      ];
    }
  }

  // Log a menstruation period
  Future<bool> logMenstruation({
    required DateTime date,
    required String userId,
    String? flow,
    String? cramp,
    String? mood,
    String? bodyCondition,
    String? note,
  }) async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot log menstruation: User not logged in");
        return false;
      }
      
      // Format date as YYYY-MM-DD
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Create the log entry
      final data = {
        "date_menstruation": formattedDate,
        "id_user": userId,
      };
      
      // Add optional fields only if they have values
      if (flow != null && flow.isNotEmpty) data["flow"] = flow;
      if (cramp != null && cramp.isNotEmpty) data["cramp"] = cramp;
      if (mood != null && mood.isNotEmpty) data["mood"] = mood;
      if (bodyCondition != null && bodyCondition.isNotEmpty) data["body_condition"] = bodyCondition;
      if (note != null && note.isNotEmpty) data["note"] = note;

      print("Creating log entry with data: $data");
      
      // Check if a log already exists for this date and user
      try {
        final existingLog = await getLogForDate(date, userId);
        
        if (existingLog != null) {
          // Update existing log
          print("Updating existing log: ${existingLog.id}");
          await pb.collection('log_menstruation').update(existingLog.id, body: data);
          print("Successfully updated log");
          return true;
        } else {
          // Create new log
          print("Creating new log");
          final result = await pb.collection('log_menstruation').create(body: data);
          print("Successfully created log with ID: ${result.id}");
          return true;
        }
      } catch (e) {
        print("Error checking for existing log: $e");
        
        // Try to create a new log anyway
        try {
          print("Attempting to create log directly");
          final result = await pb.collection('log_menstruation').create(body: data);
          print("Successfully created log with ID: ${result.id}");
          return true;
        } catch (createError) {
          print("Error creating log: $createError");
          
          // Try to debug the issue
          if (createError.toString().contains("400")) {
            print("Bad request error. Here's the data being sent:");
            data.forEach((key, value) {
              print("$key: $value (${value.runtimeType})");
            });
          }
          
          return false;
        }
      }
    } catch (e) {
      print("Error logging menstruation: $e");
      return false;
    }
  }

  // Delete a menstruation log
  Future<bool> deleteMenstruationLog(String logId) async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot delete log: User not logged in");
        return false;
      }
      
      print("Deleting log with ID: $logId");
      
      // Delete the log from PocketBase
      await pb.collection('log_menstruation').delete(logId);
      
      print("Successfully deleted log");
      return true;
    } catch (e) {
      print("Error deleting log: $e");
      return false;
    }
  }

  // Get logs for a specific date - IMPROVED VERSION
  Future<RecordModel?> getLogForDate(DateTime date, String userId) async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot get log for date: User not logged in");
        return null;
      }
      
      // Format date as YYYY-MM-DD
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      print("=== DEBUG: Searching for log ===");
      print("Formatted date: $formattedDate");
      print("User ID: $userId");
      
      // First, let's get all logs for this user to see what's in the database
      final allLogs = await pb.collection('log_menstruation').getFullList(
        filter: 'id_user = "$userId"',
      );
      
      print("Found ${allLogs.length} total logs for user:");
      for (var log in allLogs) {
        print("- Log ID: ${log.id}, Date: ${log.data['date_menstruation']}, User: ${log.data['id_user']}");
      }
      
      // Now search for the specific date
      final records = await pb.collection('log_menstruation').getList(
        filter: 'date_menstruation = "$formattedDate" && id_user = "$userId"',
        perPage: 1,
      );
      
      print("Search result for date $formattedDate: ${records.items.length} records found");
      
      if (records.items.isEmpty) {
        print("No log found for date: $formattedDate");
        
        // Try alternative search methods
        print("Trying alternative search...");
        
        // Search with just the date part
        final alternativeRecords = await pb.collection('log_menstruation').getFullList(
          filter: 'id_user = "$userId"',
        );
        
        // Filter manually to find matching date
        for (var record in alternativeRecords) {
          final recordDate = record.data['date_menstruation'];
          print("Comparing: '$recordDate' with '$formattedDate'");
          
          if (recordDate == formattedDate) {
            print("Found matching log with manual search!");
            return record;
          }
          
          // Also try parsing the date and comparing
          try {
            final parsedRecordDate = DateTime.parse(recordDate);
            if (parsedRecordDate.year == date.year && 
                parsedRecordDate.month == date.month && 
                parsedRecordDate.day == date.day) {
              print("Found matching log with date parsing!");
              return record;
            }
          } catch (e) {
            print("Error parsing date $recordDate: $e");
          }
        }
        
        return null;
      }
      
      print("Found log for date: $formattedDate");
      return records.items.first;
    } catch (e) {
      print("Error fetching log for date: $e");
      return null;
    }
  }

  // Get all logs for a user
  Future<List<RecordModel>> getAllLogsForUser(String userId) async {
    try {
      // Make sure we're authenticated
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot get logs for user: User not logged in");
        return [];
      }
      
      final records = await pb.collection('log_menstruation').getFullList(
        filter: 'id_user = "$userId"',
        sort: '-date_menstruation',
      );
      
      return records;
    } catch (e) {
      print("Error fetching logs for user: $e");
      return [];
    }
  }
}
