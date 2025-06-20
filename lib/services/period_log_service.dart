import 'package:pocketbase/pocketbase.dart';
import 'package:my_moon/services/auth_service.dart';

class PeriodLogService {
  final AuthService _authService = AuthService();
  
  // Ambil semua data flow dari koleksi flows
  Future<List<Map<String, dynamic>>> getFlows() async {
    try {
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch flows: User not logged in");
        return [];
      }
      
      print("Fetching flows from PocketBase...");
      
      // Coba ambil data flows langsung dari PocketBase
      final records = await pb.collection('flows').getFullList();
      print("Successfully fetched ${records.length} flows");
      
      // Jika tidak ada data, cek apakah koleksi ada
      if (records.isEmpty) {
        try {
          // Coba ambil info koleksi untuk cek keberadaan
          await pb.collections.getOne('flows');
          print("Flows collection exists but is empty");
        } catch (e) {
          print("Error checking flows collection: $e");
          // Return data default jika koleksi tidak ada atau bermasalah
          return [
            {'id': 'default1', 'name': 'Light', 'iconUrl': null},
            {'id': 'default2', 'name': 'Medium', 'iconUrl': null},
            {'id': 'default3', 'name': 'Heavy', 'iconUrl': null},
          ];
        }
      }
      
      // Konversi objek RecordModel ke Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Tambahkan ID ke map
        
        // Tambahkan URL gambar jika icon ada
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          // Buat URL lengkap untuk gambar icon
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'flows';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for flow ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // Jika tidak ada data ditemukan, return data default
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
      // Return data default jika error
      return [
        {'id': 'default1', 'name': 'Light', 'iconUrl': null},
        {'id': 'default2', 'name': 'Medium', 'iconUrl': null},
        {'id': 'default3', 'name': 'Heavy', 'iconUrl': null},
      ];
    }
  }

  // Ambil semua data mood dari koleksi moods
  Future<List<Map<String, dynamic>>> getMoods() async {
    try {
      // Pastikan user sudah login
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
      
      // Konversi objek RecordModel ke Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Tambahkan ID ke map
        
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
      
      // Jika tidak ada data ditemukan, return data default
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
      // Return data default jika error
      return [
        {'id': 'default1', 'name': 'Happy', 'iconUrl': null},
        {'id': 'default2', 'name': 'Sad', 'iconUrl': null},
        {'id': 'default3', 'name': 'Angry', 'iconUrl': null},
        {'id': 'default4', 'name': 'Tired', 'iconUrl': null},
      ];
    }
  }

  // Ambil semua data cramps dari koleksi cramps
  Future<List<Map<String, dynamic>>> getCramps() async {
    try {
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch cramps: User not logged in");
        return [];
      }
      
      print("Fetching cramps from PocketBase...");
      
      // Try to get the cramps directly from PocketBase
      final records = await pb.collection('cramps').getFullList();
      print("Successfully fetched ${records.length} cramps");
      
      // Jika tidak ada data, cek apakah koleksi ada
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
      
      // Konversi objek RecordModel ke Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Tambahkan ID ke map
        
        // Tambahkan URL gambar jika icon ada
        if (map['icon'] != null && map['icon'].toString().isNotEmpty) {
          // Buat URL lengkap untuk gambar icon
          final String baseUrl = 'http://127.0.0.1:8090';
          final String collectionId = 'cramps';
          final String recordId = record.id;
          final String fileName = map['icon'].toString();
          map['iconUrl'] = '$baseUrl/api/files/$collectionId/$recordId/$fileName';
          print("Added icon URL for cramp ${map['name']}: ${map['iconUrl']}");
        }
        
        result.add(map);
      }
      
      // Jika tidak ada data ditemukan, return data default
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
      // Return data default jika error
      return [
        {'id': 'default1', 'name': 'None', 'iconUrl': null},
        {'id': 'default2', 'name': 'Mild', 'iconUrl': null},
        {'id': 'default3', 'name': 'Moderate', 'iconUrl': null},
        {'id': 'default4', 'name': 'Severe', 'iconUrl': null},
      ];
    }
  }

  // Ambil semua data kondisi tubuh dari koleksi body_conditions
  Future<List<Map<String, dynamic>>> getBodyConditions() async {
    try {
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot fetch body conditions: User not logged in");
        return [];
      }
      
      print("Fetching body conditions from PocketBase...");
      
      // Try to get the body conditions directly from PocketBase
      final records = await pb.collection('body_conditions').getFullList();
      print("Successfully fetched ${records.length} body conditions");
      
      // Jika tidak ada data, cek apakah koleksi ada
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
      
      // Konversi objek RecordModel ke Maps
      final List<Map<String, dynamic>> result = [];
      for (var record in records) {
        final map = Map<String, dynamic>.from(record.data);
        map['id'] = record.id; // Tambahkan ID ke map
        
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
      
      // Jika tidak ada data ditemukan, return data default
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
      // Return data default jika error
      return [
        {'id': 'default1', 'name': 'Headache', 'iconUrl': null},
        {'id': 'default2', 'name': 'Backache', 'iconUrl': null},
        {'id': 'default3', 'name': 'Bloating', 'iconUrl': null},
        {'id': 'default4', 'name': 'Fatigue', 'iconUrl': null},
      ];
    }
  }

  // Catat periode menstruasi
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
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot log menstruation: User not logged in");
        return false;
      }
      
      // Format tanggal sebagai YYYY-MM-DD
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Buat entri log
      final data = {
        "date_menstruation": formattedDate,
        "id_user": userId,
      };
      
      // Tambahkan field opsional hanya jika ada nilainya
      if (flow != null && flow.isNotEmpty) data["flow"] = flow;
      if (cramp != null && cramp.isNotEmpty) data["cramp"] = cramp;
      if (mood != null && mood.isNotEmpty) data["mood"] = mood;
      if (bodyCondition != null && bodyCondition.isNotEmpty) data["body_condition"] = bodyCondition;
      if (note != null && note.isNotEmpty) data["note"] = note;

      print("Creating log entry with data: $data");
      
      // Cek apakah log sudah ada untuk tanggal dan user ini
      try {
        final existingLog = await getLogForDate(date, userId);
        
        if (existingLog != null) {
          // Update log yang sudah ada
          print("Updating existing log: ${existingLog.id}");
          await pb.collection('log_menstruation').update(existingLog.id, body: data);
          print("Successfully updated log");
          return true;
        } else {
          // Buat log baru
          print("Creating new log");
          final result = await pb.collection('log_menstruation').create(body: data);
          print("Successfully created log with ID: ${result.id}");
          return true;
        }
      } catch (e) {
        print("Error checking for existing log: $e");
        
        // Coba buat log baru saja
        try {
          print("Attempting to create log directly");
          final result = await pb.collection('log_menstruation').create(body: data);
          print("Successfully created log with ID: ${result.id}");
          return true;
        } catch (createError) {
          print("Error creating log: $createError");
          
          // Coba debug masalahnya
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

  // Hapus log menstruasi
  Future<bool> deleteMenstruationLog(String logId) async {
    try {
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot delete log: User not logged in");
        return false;
      }
      
      print("Deleting log with ID: $logId");
      
      // Hapus log dari PocketBase
      await pb.collection('log_menstruation').delete(logId);
      
      print("Successfully deleted log");
      return true;
    } catch (e) {
      print("Error deleting log: $e");
      return false;
    }
  }

  // Ambil log untuk tanggal tertentu - VERSI DIPERBAIKI
  Future<RecordModel?> getLogForDate(DateTime date, String userId) async {
    try {
      // Pastikan user sudah login
      final user = _authService.getCurrentUser();
      if (user == null) {
        print("Cannot get log for date: User not logged in");
        return null;
      }
      
      // Format tanggal sebagai YYYY-MM-DD
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      print("=== DEBUG: Searching for log ===");
      print("Formatted date: $formattedDate");
      print("User ID: $userId");
      
      // Pertama, ambil semua log user ini untuk lihat apa yang ada di database
      final allLogs = await pb.collection('log_menstruation').getFullList(
        filter: 'id_user = "$userId"',
      );
      
      print("Found ${allLogs.length} total logs for user:");
      for (var log in allLogs) {
        print("- Log ID: ${log.id}, Date: ${log.data['date_menstruation']}, User: ${log.data['id_user']}");
      }
      
      // Sekarang cari tanggal spesifik
      final records = await pb.collection('log_menstruation').getList(
        filter: 'date_menstruation = "$formattedDate" && id_user = "$userId"',
        perPage: 1,
      );
      
      print("Search result for date $formattedDate: ${records.items.length} records found");
      
      if (records.items.isEmpty) {
        print("No log found for date: $formattedDate");
        
        // Coba metode pencarian alternatif
        print("Trying alternative search...");
        
        // Cari dengan bagian tanggal saja
        final alternativeRecords = await pb.collection('log_menstruation').getFullList(
          filter: 'id_user = "$userId"',
        );
        
        // Filter manual untuk cari tanggal yang cocok
        for (var record in alternativeRecords) {
          final recordDate = record.data['date_menstruation'];
          print("Comparing: '$recordDate' with '$formattedDate'");
          
          if (recordDate == formattedDate) {
            print("Found matching log with manual search!");
            return record;
          }
          
          // Coba juga parsing tanggal dan bandingkan
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

  // Ambil semua log untuk seorang user
  Future<List<RecordModel>> getAllLogsForUser(String userId) async {
    try {
      // Pastikan user sudah login
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
