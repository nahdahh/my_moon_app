import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/services/period_log_service.dart';
import 'package:my_moon/services/period_service.dart';


class PeriodAnalysisService {
  final AuthService _authService = AuthService();
  final PeriodLogService _periodLogService = PeriodLogService();
  final PeriodService _periodService = PeriodService();

  /// Mengelompokkan tanggal menstruasi yang berurutan menjadi periode
  List<PeriodGroup> groupConsecutiveDates(List<DateTime> dates) {
    if (dates.isEmpty) return [];
    
    // Urutkan tanggal dari yang terlama ke terbaru
    dates.sort();
    
    List<PeriodGroup> periods = [];
    List<DateTime> currentGroup = [dates[0]];
    
    for (int i = 1; i < dates.length; i++) {
      DateTime currentDate = dates[i];
      DateTime previousDate = dates[i - 1];
      
      // Jika tanggal berurutan (selisih 1 hari), masukkan ke grup yang sama
      if (currentDate.difference(previousDate).inDays == 1) {
        currentGroup.add(currentDate);
      } else {
        // Jika tidak berurutan, buat grup baru
        periods.add(PeriodGroup(
          startDate: currentGroup.first,
          endDate: currentGroup.last,
          duration: currentGroup.length,
          dates: List.from(currentGroup),
        ));
        currentGroup = [currentDate];
      }
    }
    
    // Tambahkan grup terakhir
    periods.add(PeriodGroup(
      startDate: currentGroup.first,
      endDate: currentGroup.last,
      duration: currentGroup.length,
      dates: List.from(currentGroup),
    ));
    
    return periods;
  }

  /// Mendapatkan analisis periode lengkap untuk user
  Future<PeriodAnalysis> getPeriodAnalysis() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Ambil semua log menstruasi user
      final logs = await _periodLogService.getAllLogsForUser(user.id);
      
      // Konversi log ke list tanggal
      List<DateTime> menstruationDates = [];
      for (var log in logs) {
        try {
          final dateStr = log.data['date_menstruation'];
          if (dateStr != null) {
            menstruationDates.add(DateTime.parse(dateStr));
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }

      // Ambil data inisialisasi
      final cycleInfo = await _periodService.getCycleInfo();
      
      if (menstruationDates.isEmpty) {
        // Jika belum ada log, gunakan data inisialisasi
        return _getAnalysisFromInitialData(cycleInfo);
      }

      // Kelompokkan tanggal menjadi periode
      final periods = groupConsecutiveDates(menstruationDates);
      
      if (periods.isEmpty) {
        return _getAnalysisFromInitialData(cycleInfo);
      }

      // Analisis berdasarkan periode yang ada
      return _getAnalysisFromPeriods(periods, cycleInfo);
      
    } catch (e) {
      print("Error in getPeriodAnalysis: $e");
      // Return default analysis jika terjadi error
      return PeriodAnalysis(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 7)),
        lastPeriodDuration: 4,
        averageCycleLength: 28,
        daysSinceLastPeriod: 7,
        daysUntilNextPeriod: 21,
        hasActualData: false,
      );
    }
  }

  /// Analisis berdasarkan data inisialisasi saja
  PeriodAnalysis _getAnalysisFromInitialData(Map<String, dynamic>? cycleInfo) {
    if (cycleInfo == null) {
      // Data default jika tidak ada data inisialisasi
      final defaultLastPeriod = DateTime.now().subtract(const Duration(days: 7));
      return PeriodAnalysis(
        lastPeriodStartDate: defaultLastPeriod,
        lastPeriodDuration: 4,
        averageCycleLength: 28,
        daysSinceLastPeriod: 7,
        daysUntilNextPeriod: 21,
        hasActualData: false,
      );
    }

    final lastPeriodDate = DateTime.parse(cycleInfo['last_period_date']);
    final periodLength = cycleInfo['period_length'] ?? 4;
    final cycleLength = cycleInfo['cycle_length'] ?? 28;
    
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodDate).inDays;
    
    // Hitung kapan periode berikutnya
    final nextPeriodDate = lastPeriodDate.add(Duration(days: cycleLength));
    final daysUntilNextPeriod = nextPeriodDate.difference(now).inDays;

    return PeriodAnalysis(
      lastPeriodStartDate: lastPeriodDate,
      lastPeriodDuration: periodLength,
      averageCycleLength: cycleLength,
      daysSinceLastPeriod: daysSinceLastPeriod,
      daysUntilNextPeriod: daysUntilNextPeriod,
      hasActualData: false,
    );
  }

  /// Analisis berdasarkan periode yang sudah dikelompokkan
  PeriodAnalysis _getAnalysisFromPeriods(List<PeriodGroup> periods, Map<String, dynamic>? cycleInfo) {
    // Urutkan periode dari yang terbaru
    periods.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    final lastPeriod = periods.first;
    final now = DateTime.now();
    
    // Hitung cycle length
    int cycleLength;
    if (periods.length >= 2) {
      // Jika ada minimal 2 periode, hitung dari periode sebelumnya
      final secondLastPeriod = periods[1];
      cycleLength = lastPeriod.startDate.difference(secondLastPeriod.startDate).inDays;
    } else if (cycleInfo != null) {
      // Jika hanya ada 1 periode, gunakan data inisialisasi sebagai periode sebelumnya
      final initialLastPeriodDate = DateTime.parse(cycleInfo['last_period_date']);
      cycleLength = lastPeriod.startDate.difference(initialLastPeriodDate).inDays;
    } else {
      // Default cycle length
      cycleLength = 28;
    }

    // Pastikan cycle length masuk akal (21-45 hari)
    if (cycleLength < 21 || cycleLength > 45) {
      cycleLength = cycleInfo?['cycle_length'] ?? 28;
    }

    final daysSinceLastPeriod = now.difference(lastPeriod.startDate).inDays;
    
    // Hitung kapan periode berikutnya
    final nextPeriodDate = lastPeriod.startDate.add(Duration(days: cycleLength));
    final daysUntilNextPeriod = nextPeriodDate.difference(now).inDays;

    return PeriodAnalysis(
      lastPeriodStartDate: lastPeriod.startDate,
      lastPeriodDuration: lastPeriod.duration,
      averageCycleLength: cycleLength,
      daysSinceLastPeriod: daysSinceLastPeriod,
      daysUntilNextPeriod: daysUntilNextPeriod,
      hasActualData: true,
      periods: periods,
    );
  }

  /// Mendapatkan semua periode untuk analisis lebih lanjut
  Future<List<PeriodGroup>> getAllPeriods() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return [];

      final logs = await _periodLogService.getAllLogsForUser(user.id);
      
      List<DateTime> menstruationDates = [];
      for (var log in logs) {
        try {
          final dateStr = log.data['date_menstruation'];
          if (dateStr != null) {
            menstruationDates.add(DateTime.parse(dateStr));
          }
        } catch (e) {
          print("Error parsing date: $e");
        }
      }

      return groupConsecutiveDates(menstruationDates);
    } catch (e) {
      print("Error in getAllPeriods: $e");
      return [];
    }
  }

  /// Menghitung rata-rata panjang siklus dari beberapa periode terakhir
  int calculateAverageCycleLength(List<PeriodGroup> periods, {int maxPeriods = 6}) {
    if (periods.length < 2) return 28; // Default

    // Urutkan dari yang terbaru
    periods.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    // Ambil maksimal periode yang ditentukan
    final periodsToAnalyze = periods.take(maxPeriods).toList();
    
    List<int> cycleLengths = [];
    for (int i = 0; i < periodsToAnalyze.length - 1; i++) {
      final currentPeriod = periodsToAnalyze[i];
      final previousPeriod = periodsToAnalyze[i + 1];
      
      final cycleLength = currentPeriod.startDate.difference(previousPeriod.startDate).inDays;
      
      // Hanya masukkan cycle length yang masuk akal
      if (cycleLength >= 21 && cycleLength <= 45) {
        cycleLengths.add(cycleLength);
      }
    }

    if (cycleLengths.isEmpty) return 28;

    // Hitung rata-rata
    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    return average.round();
  }

  /// Menghitung rata-rata panjang periode
  int calculateAveragePeriodLength(List<PeriodGroup> periods, {int maxPeriods = 6}) {
    if (periods.isEmpty) return 4; // Default

    // Urutkan dari yang terbaru
    periods.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    // Ambil maksimal periode yang ditentukan
    final periodsToAnalyze = periods.take(maxPeriods).toList();
    
    final totalDuration = periodsToAnalyze.fold<int>(0, (sum, period) => sum + period.duration);
    return (totalDuration / periodsToAnalyze.length).round();
  }
}

/// Model untuk menyimpan informasi satu periode menstruasi
class PeriodGroup {
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final List<DateTime> dates;

  PeriodGroup({
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.dates,
  });

  @override
  String toString() {
    return 'PeriodGroup(start: $startDate, end: $endDate, duration: $duration days)';
  }
}

/// Model untuk menyimpan hasil analisis periode
class PeriodAnalysis {
  final DateTime lastPeriodStartDate;
  final int lastPeriodDuration;
  final int averageCycleLength;
  final int daysSinceLastPeriod;
  final int daysUntilNextPeriod;
  final bool hasActualData; // true jika berdasarkan log aktual, false jika dari data inisialisasi
  final List<PeriodGroup>? periods;

  PeriodAnalysis({
    required this.lastPeriodStartDate,
    required this.lastPeriodDuration,
    required this.averageCycleLength,
    required this.daysSinceLastPeriod,
    required this.daysUntilNextPeriod,
    required this.hasActualData,
    this.periods,
  });

  @override
  String toString() {
    return 'PeriodAnalysis(lastStart: $lastPeriodStartDate, duration: $lastPeriodDuration, cycle: $averageCycleLength, daysSince: $daysSinceLastPeriod, daysUntil: $daysUntilNextPeriod, hasData: $hasActualData)';
  }
}