import 'package:my_moon/services/auth_service.dart';
import 'package:my_moon/services/period_log_service.dart';
import 'package:my_moon/services/period_service.dart';
import 'package:my_moon/services/period_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  final AuthService _authService = AuthService();
  final PeriodLogService _periodLogService = PeriodLogService();
  final PeriodService _periodService = PeriodService();
  final PeriodAnalysisService _analysisService = PeriodAnalysisService();

  /// Mendapatkan data analytics lengkap termasuk data inisialisasi
  Future<AnalyticsData> getAnalyticsData() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Ambil data inisialisasi
      final cycleInfo = await _periodService.getCycleInfo();
      
      // Ambil semua periode yang sudah dikelompokkan
      final periods = await _analysisService.getAllPeriods();
      
      // Cek apakah ada current cycle yang sedang berlangsung
      final currentCycleInfo = await _getCurrentCycleInfo();
      
      // Jika tidak ada periode sama sekali, gunakan data inisialisasi
      if (periods.isEmpty && cycleInfo != null) {
        return _createAnalyticsFromInitialization(cycleInfo, currentCycleInfo);
      }
      
      // Jika ada periode tapi kurang dari 2, gabungkan dengan data inisialisasi
      if (periods.length < 2 && cycleInfo != null) {
        return _createAnalyticsWithInitialization(periods, cycleInfo, currentCycleInfo);
      }
      
      // Jika ada cukup periode, hitung analytics normal
      if (periods.length >= 2) {
        return _createAnalyticsFromPeriods(periods, cycleInfo, currentCycleInfo);
      }

      // Fallback jika tidak ada data sama sekali
      return AnalyticsData(
        hasEnoughData: false,
        averagePeriodLength: 0,
        averageCycleLength: 0,
        cycleHistory: [],
        moodSummary: [],
        symptomSummary: [],
        message: "No data available. Please add your cycle information.",
      );

    } catch (e) {
      print("Error in getAnalyticsData: $e");
      return AnalyticsData(
        hasEnoughData: false,
        averagePeriodLength: 0,
        averageCycleLength: 0,
        cycleHistory: [],
        moodSummary: [],
        symptomSummary: [],
        message: "Error loading analytics data: $e",
      );
    }
  }

  /// Mendapatkan informasi current cycle yang sedang berlangsung
  Future<CurrentCycleInfo?> _getCurrentCycleInfo() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return null;

      // Ambil semua log menstruasi user
      final logs = await _periodLogService.getAllLogsForUser(user.id);
      if (logs.isEmpty) return null;

      // Urutkan berdasarkan tanggal (terbaru dulu)
      logs.sort((a, b) {
        final dateA = DateTime.parse(a.data['date_menstruation']);
        final dateB = DateTime.parse(b.data['date_menstruation']);
        return dateB.compareTo(dateA);
      });

      // Konversi ke list tanggal
      final allDates = logs.map((log) => DateTime.parse(log.data['date_menstruation'])).toList();
      
      // Cari consecutive dates dari tanggal terbaru
      final today = DateTime.now();
      final consecutiveDates = <DateTime>[];
      
      // Mulai dari tanggal terbaru dan cek apakah berurutan
      for (int i = 0; i < allDates.length; i++) {
        final currentDate = allDates[i];
        
        // Jika ini tanggal pertama atau berurutan dengan tanggal sebelumnya
        if (consecutiveDates.isEmpty) {
          consecutiveDates.add(currentDate);
        } else {
          final lastDate = consecutiveDates.last;
          final daysDifference = lastDate.difference(currentDate).inDays;
          
          // Jika berurutan (selisih 1 hari)
          if (daysDifference == 1) {
            consecutiveDates.add(currentDate);
          } else {
            // Jika tidak berurutan, berhenti
            break;
          }
        }
      }

      // Cek apakah consecutive dates ini masih berlangsung (tanggal terakhir adalah kemarin atau hari ini)
      if (consecutiveDates.isNotEmpty) {
        final latestDate = consecutiveDates.first; // Tanggal terbaru
        final daysSinceLatest = today.difference(latestDate).inDays;
        
        // Jika tanggal terakhir adalah hari ini atau kemarin, berarti current cycle
        if (daysSinceLatest <= 1) {
          final startDate = consecutiveDates.last; // Tanggal mulai periode
          final duration = consecutiveDates.length;
          
          return CurrentCycleInfo(
            startDate: startDate,
            currentDuration: duration,
            isOngoing: true,
          );
        }
      }

      return null;
    } catch (e) {
      print("Error getting current cycle info: $e");
      return null;
    }
  }

  /// Membuat analytics dari data inisialisasi saja
  Future<AnalyticsData> _createAnalyticsFromInitialization(Map<String, dynamic> cycleInfo, CurrentCycleInfo? currentCycle) async {
    final lastPeriodDate = DateTime.parse(cycleInfo['last_period_date']);
    final periodLength = (cycleInfo['period_length'] as num).toInt();
    final cycleLength = (cycleInfo['cycle_length'] as num).toInt();
    
    // Buat beberapa siklus simulasi berdasarkan data inisialisasi
    final cycleHistory = <CycleHistoryData>[];
    final now = DateTime.now();
    
    // Hitung berapa siklus yang sudah berlalu sejak inisialisasi
    final daysSinceInit = now.difference(lastPeriodDate).inDays;
    final cyclesPassed = (daysSinceInit / cycleLength).floor();
    
    // Buat maksimal 6 siklus untuk ditampilkan
    final cyclesToShow = cyclesPassed > 6 ? 6 : cyclesPassed;
    
    for (int i = 0; i < cyclesToShow; i++) {
      final cycleStartDate = lastPeriodDate.add(Duration(days: cycleLength * i));
      final monthLabel = DateFormat('MM.dd').format(cycleStartDate);
      
      cycleHistory.add(CycleHistoryData(
        periodStartDate: cycleStartDate,
        cycleLength: cycleLength,
        classification: CycleClassification.onTime,
        color: const Color(0xFFFF6B9D),
        monthLabel: monthLabel,
        averageCycleLength: cycleLength,
        isCurrentCycle: false,
        isFromInitialization: true,
      ));
    }
    
    // Tambahkan current cycle jika ada
    if (currentCycle != null && currentCycle.isOngoing) {
      final daysSinceStart = now.difference(currentCycle.startDate).inDays;
      cycleHistory.add(CycleHistoryData(
        periodStartDate: currentCycle.startDate,
        cycleLength: daysSinceStart,
        classification: CycleClassification.onTime,
        color: Colors.transparent,
        monthLabel: DateFormat('MM.dd').format(currentCycle.startDate),
        averageCycleLength: cycleLength,
        isCurrentCycle: true,
        isFromInitialization: false,
      ));
    }

    // Load mood and symptom summary
    final moodSummary = await _getMoodSummary();
    final symptomSummary = await _getSymptomSummary();

    return AnalyticsData(
      hasEnoughData: true,
      averagePeriodLength: periodLength,
      averageCycleLength: cycleLength,
      cycleHistory: cycleHistory,
      moodSummary: moodSummary,
      symptomSummary: symptomSummary,
      totalPeriods: cyclesToShow,
    );
  }

  /// Membuat analytics dengan kombinasi periode aktual dan data inisialisasi
  Future<AnalyticsData> _createAnalyticsWithInitialization(List<PeriodGroup> periods, Map<String, dynamic> cycleInfo, CurrentCycleInfo? currentCycle) async {
    final lastPeriodDate = DateTime.parse(cycleInfo['last_period_date']);
    final periodLength = (cycleInfo['period_length'] as num).toInt();
    final cycleLength = (cycleInfo['cycle_length'] as num).toInt();
    
    // Urutkan periode dari yang terlama ke terbaru
    periods.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    final cycleHistory = <CycleHistoryData>[];
    
    // Tambahkan data inisialisasi sebagai periode pertama
    cycleHistory.add(CycleHistoryData(
      periodStartDate: lastPeriodDate,
      cycleLength: cycleLength,
      classification: CycleClassification.onTime,
      color: const Color(0xFFFF6B9D),
      monthLabel: DateFormat('MM.dd').format(lastPeriodDate),
      averageCycleLength: cycleLength,
      isCurrentCycle: false,
      isFromInitialization: true,
    ));
    
    // Tambahkan periode aktual
    for (int i = 0; i < periods.length; i++) {
      final period = periods[i];
      final previousDate = i == 0 ? lastPeriodDate : periods[i - 1].startDate;
      final actualCycleLength = period.startDate.difference(previousDate).inDays;
      
      final classification = _classifyCycleWithTolerance(actualCycleLength, cycleLength);
      final color = _getColorForClassification(classification);
      final monthLabel = DateFormat('MM.dd').format(period.startDate);
      
      cycleHistory.add(CycleHistoryData(
        periodStartDate: period.startDate,
        cycleLength: actualCycleLength,
        classification: classification,
        color: color,
        monthLabel: monthLabel,
        averageCycleLength: cycleLength,
        isCurrentCycle: false,
        isFromInitialization: false,
      ));
    }
    
    // Tambahkan current cycle jika ada
    if (currentCycle != null && currentCycle.isOngoing) {
      final now = DateTime.now();
      final daysSinceStart = now.difference(currentCycle.startDate).inDays;
      
      cycleHistory.add(CycleHistoryData(
        periodStartDate: currentCycle.startDate,
        cycleLength: daysSinceStart,
        classification: CycleClassification.onTime,
        color: Colors.transparent,
        monthLabel: DateFormat('MM.dd').format(currentCycle.startDate),
        averageCycleLength: cycleLength,
        isCurrentCycle: true,
        isFromInitialization: false,
      ));
    }

    // Load mood and symptom summary
    final moodSummary = await _getMoodSummary();
    final symptomSummary = await _getSymptomSummary();

    // Hitung rata-rata dari data yang ada
    final averagePeriodLength = _calculateAveragePeriodLength(periods);
    final averageCycleLength = _calculateAverageCycleLength(cycleHistory);

    return AnalyticsData(
      hasEnoughData: true,
      averagePeriodLength: averagePeriodLength > 0 ? averagePeriodLength : periodLength,
      averageCycleLength: averageCycleLength,
      cycleHistory: cycleHistory.length > 6 ? cycleHistory.sublist(cycleHistory.length - 6) : cycleHistory,
      moodSummary: moodSummary,
      symptomSummary: symptomSummary,
      totalPeriods: periods.length + 1, // +1 untuk data inisialisasi
    );
  }

  /// Membuat analytics dari periode aktual saja
  Future<AnalyticsData> _createAnalyticsFromPeriods(List<PeriodGroup> periods, Map<String, dynamic>? cycleInfo, CurrentCycleInfo? currentCycle) async {
    // Urutkan periode dari yang terlama ke terbaru
    periods.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Hitung rata-rata panjang periode
    final averagePeriodLength = _calculateAveragePeriodLength(periods);
    
    // Hitung cycle history dengan klasifikasi
    final cycleHistory = _calculateCycleHistory(periods, currentCycle);
    
    // Hitung rata-rata panjang siklus
    final averageCycleLength = _calculateAverageCycleLength(cycleHistory);

    // Load mood and symptom summary
    final moodSummary = await _getMoodSummary();
    final symptomSummary = await _getSymptomSummary();

    return AnalyticsData(
      hasEnoughData: true,
      averagePeriodLength: averagePeriodLength,
      averageCycleLength: averageCycleLength,
      cycleHistory: cycleHistory,
      moodSummary: moodSummary,
      symptomSummary: symptomSummary,
      totalPeriods: periods.length,
    );
  }

  /// Mendapatkan ringkasan mood dari log menstruasi
  Future<List<MoodSummaryData>> _getMoodSummary() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return [];

      // Ambil semua log menstruasi
      final logs = await _periodLogService.getAllLogsForUser(user.id);
      
      // Ambil data mood dari PocketBase
      final moods = await _periodLogService.getMoods();
      
      // Hitung frekuensi setiap mood
      final moodCounts = <String, int>{};
      final moodData = <String, Map<String, dynamic>>{};
      
      // Buat mapping mood data
      for (var mood in moods) {
        moodData[mood['id']] = mood;
        moodCounts[mood['id']] = 0;
      }
      
      // Hitung frekuensi mood dari logs
      for (var log in logs) {
        final moodId = log.data['mood'];
        if (moodId != null && moodCounts.containsKey(moodId)) {
          moodCounts[moodId] = moodCounts[moodId]! + 1;
        }
      }
      
      // Buat list summary yang diurutkan berdasarkan frekuensi
      final moodSummary = <MoodSummaryData>[];
      moodCounts.entries.where((entry) => entry.value > 0).forEach((entry) {
        final mood = moodData[entry.key]!;
        moodSummary.add(MoodSummaryData(
          name: mood['name'] ?? 'Unknown',
          count: entry.value,
          iconUrl: mood['iconUrl'],
        ));
      });
      
      // Urutkan berdasarkan frekuensi (tertinggi dulu)
      moodSummary.sort((a, b) => b.count.compareTo(a.count));
      
      return moodSummary;
    } catch (e) {
      print("Error getting mood summary: $e");
      return [];
    }
  }

  /// Mendapatkan ringkasan gejala dari log menstruasi
  Future<List<SymptomSummaryData>> _getSymptomSummary() async {
    try {
      final user = _authService.getCurrentUser();
      if (user == null) return [];

      // Ambil semua log menstruasi
      final logs = await _periodLogService.getAllLogsForUser(user.id);
      
      // Ambil data cramps dan body conditions dari PocketBase
      final cramps = await _periodLogService.getCramps();
      final bodyConditions = await _periodLogService.getBodyConditions();
      
      // Gabungkan semua gejala
      final allSymptoms = <Map<String, dynamic>>[];
      allSymptoms.addAll(cramps);
      allSymptoms.addAll(bodyConditions);
      
      // Hitung frekuensi setiap gejala
      final symptomCounts = <String, int>{};
      final symptomData = <String, Map<String, dynamic>>{};
      
      // Buat mapping symptom data
      for (var symptom in allSymptoms) {
        symptomData[symptom['id']] = symptom;
        symptomCounts[symptom['id']] = 0;
      }
      
      // Hitung frekuensi gejala dari logs
      for (var log in logs) {
        // Hitung cramps
        final crampId = log.data['cramp'];
        if (crampId != null && symptomCounts.containsKey(crampId)) {
          symptomCounts[crampId] = symptomCounts[crampId]! + 1;
        }
        
        // Hitung body conditions
        final bodyConditionId = log.data['body_condition'];
        if (bodyConditionId != null && symptomCounts.containsKey(bodyConditionId)) {
          symptomCounts[bodyConditionId] = symptomCounts[bodyConditionId]! + 1;
        }
      }
      
      // Buat list summary yang diurutkan berdasarkan frekuensi
      final symptomSummary = <SymptomSummaryData>[];
      symptomCounts.entries.where((entry) => entry.value > 0).forEach((entry) {
        final symptom = symptomData[entry.key]!;
        symptomSummary.add(SymptomSummaryData(
          name: symptom['name'] ?? 'Unknown',
          count: entry.value,
          iconUrl: symptom['iconUrl'],
        ));
      });
      
      // Urutkan berdasarkan frekuensi (tertinggi dulu)
      symptomSummary.sort((a, b) => b.count.compareTo(a.count));
      
      return symptomSummary;
    } catch (e) {
      print("Error getting symptom summary: $e");
      return [];
    }
  }

  /// Menghitung rata-rata panjang periode
  int _calculateAveragePeriodLength(List<PeriodGroup> periods) {
    if (periods.isEmpty) return 0;
    
    final totalDuration = periods.fold<int>(0, (sum, period) => sum + period.duration);
    final average = totalDuration / periods.length;
    return average.round();
  }

  /// Menghitung cycle history dengan klasifikasi
  List<CycleHistoryData> _calculateCycleHistory(List<PeriodGroup> periods, [CurrentCycleInfo? currentCycle]) {
    if (periods.length < 2) return [];

    List<CycleHistoryData> cycleHistory = [];
    List<int> cycleLengths = [];

    // Urutkan periode dari yang terlama ke terbaru
    periods.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Hitung panjang siklus untuk setiap periode (kecuali yang pertama)
    for (int i = 1; i < periods.length; i++) {
      final currentPeriod = periods[i];
      final previousPeriod = periods[i - 1];
      
      final cycleLength = currentPeriod.startDate.difference(previousPeriod.startDate).inDays;
      cycleLengths.add(cycleLength);
    }

    // Hitung rata-rata siklus untuk klasifikasi
    final averageCycle = cycleLengths.isNotEmpty 
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 28;

    // Buat data cycle history dengan klasifikasi
    for (int i = 1; i < periods.length; i++) {
      final currentPeriod = periods[i];
      final cycleLength = cycleLengths[i - 1];
      
      // Klasifikasi berdasarkan rata-rata dan toleransi 3 hari
      final classification = _classifyCycleWithTolerance(cycleLength, averageCycle);
      final color = _getColorForClassification(classification);
      
      // Format tanggal sebagai MM.DD untuk tanggal mulai menstruasi
      final monthLabel = DateFormat('MM.dd').format(currentPeriod.startDate);
      
      cycleHistory.add(CycleHistoryData(
        periodStartDate: currentPeriod.startDate,
        cycleLength: cycleLength,
        classification: classification,
        color: color,
        monthLabel: monthLabel,
        averageCycleLength: averageCycle,
        isCurrentCycle: false,
        isFromInitialization: false,
      ));
    }

    // Tambahkan current cycle jika ada
    if (currentCycle != null && currentCycle.isOngoing) {
      final now = DateTime.now();
      final daysSinceStart = now.difference(currentCycle.startDate).inDays;
      
      cycleHistory.add(CycleHistoryData(
        periodStartDate: currentCycle.startDate,
        cycleLength: daysSinceStart,
        classification: CycleClassification.onTime,
        color: Colors.transparent,
        monthLabel: DateFormat('MM.dd').format(currentCycle.startDate),
        averageCycleLength: averageCycle,
        isCurrentCycle: true,
        isFromInitialization: false,
      ));
    }

    // Ambil maksimal 6 data terakhir untuk ditampilkan
    if (cycleHistory.length > 6) {
      cycleHistory = cycleHistory.sublist(cycleHistory.length - 6);
    }

    return cycleHistory;
  }

  /// Mengklasifikasikan siklus berdasarkan toleransi 3 hari
  CycleClassification _classifyCycleWithTolerance(int cycleLength, int averageCycleLength) {
    const tolerance = 3; // Toleransi 3 hari
    
    if (cycleLength >= averageCycleLength - tolerance && cycleLength <= averageCycleLength + tolerance) {
      return CycleClassification.onTime;
    } else if (cycleLength > averageCycleLength + tolerance) {
      return CycleClassification.delayed;
    } else {
      return CycleClassification.early;
    }
  }

  /// Mendapatkan warna berdasarkan klasifikasi
  Color _getColorForClassification(CycleClassification classification) {
    switch (classification) {
      case CycleClassification.early:
        return const Color(0xFFB8B5FF); // Light purple for early
      case CycleClassification.onTime:
        return const Color(0xFFFF6B9D); // Pink for on time
      case CycleClassification.delayed:
        return const Color(0xFFB8B5FF); // Light purple for delayed
      case CycleClassification.irregular:
        return Colors.red[300]!;
    }
  }

  /// Menghitung rata-rata panjang siklus
  int _calculateAverageCycleLength(List<CycleHistoryData> cycleHistory) {
    if (cycleHistory.isEmpty) return 28;
    
    final totalCycleLength = cycleHistory.fold<int>(0, (sum, cycle) => sum + cycle.cycleLength);
    final average = totalCycleLength / cycleHistory.length;
    return average.round();
  }

  /// Mendapatkan label untuk klasifikasi
  String getClassificationLabel(CycleClassification classification) {
    switch (classification) {
      case CycleClassification.early:
        return 'Early';
      case CycleClassification.onTime:
        return 'On time';
      case CycleClassification.delayed:
        return 'Delayed';
      case CycleClassification.irregular:
        return 'Irregular';
    }
  }

  /// Menghitung standar deviasi untuk ditampilkan
  String calculateCycleLengthVariation(List<CycleHistoryData> cycleHistory) {
    if (cycleHistory.length < 2) return "± 0 days";
    
    final cycleLengths = cycleHistory.map((c) => c.cycleLength.toDouble()).toList();
    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    
    final variance = cycleLengths.map((length) => 
        (length - average) * (length - average)).reduce((a, b) => a + b) / cycleLengths.length;
    final standardDeviation = variance > 0 ? variance.sqrt() : 0.0;
    
    return "± ${standardDeviation.round()} days";
  }
}

/// Model untuk informasi current cycle
class CurrentCycleInfo {
  final DateTime startDate;
  final int currentDuration;
  final bool isOngoing;

  CurrentCycleInfo({
    required this.startDate,
    required this.currentDuration,
    required this.isOngoing,
  });
}

/// Model untuk data analytics
class AnalyticsData {
  final bool hasEnoughData;
  final int averagePeriodLength;
  final int averageCycleLength;
  final List<CycleHistoryData> cycleHistory;
  final List<MoodSummaryData> moodSummary;
  final List<SymptomSummaryData> symptomSummary;
  final int totalPeriods;
  final String? message;

  AnalyticsData({
    required this.hasEnoughData,
    required this.averagePeriodLength,
    required this.averageCycleLength,
    required this.cycleHistory,
    required this.moodSummary,
    required this.symptomSummary,
    this.totalPeriods = 0,
    this.message,
  });
}

/// Model untuk data cycle history
class CycleHistoryData {
  final DateTime periodStartDate;
  final int cycleLength;
  final CycleClassification classification;
  final Color color;
  final String monthLabel;
  final int averageCycleLength;
  final bool isCurrentCycle;
  final bool isFromInitialization;

  CycleHistoryData({
    required this.periodStartDate,
    required this.cycleLength,
    required this.classification,
    required this.color,
    required this.monthLabel,
    required this.averageCycleLength,
    this.isCurrentCycle = false,
    this.isFromInitialization = false,
  });
}

/// Model untuk ringkasan mood
class MoodSummaryData {
  final String name;
  final int count;
  final String? iconUrl;

  MoodSummaryData({
    required this.name,
    required this.count,
    this.iconUrl,
  });
}

/// Model untuk ringkasan gejala
class SymptomSummaryData {
  final String name;
  final int count;
  final String? iconUrl;

  SymptomSummaryData({
    required this.name,
    required this.count,
    this.iconUrl,
  });
}

/// Enum untuk klasifikasi siklus
enum CycleClassification {
  early,
  onTime,
  delayed,
  irregular,
}

/// Extension untuk sqrt function
extension DoubleExtension on double {
  double sqrt() {
    if (this < 0) return 0;
    double x = this;
    double prev = 0;
    while ((x - prev).abs() > 0.01) {
      prev = x;
      x = (x + this / x) / 2;
    }
    return x;
  }
}
