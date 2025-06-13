/// Model untuk menyimpan informasi satu periode menstruasi
class PeriodInfo {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  
  PeriodInfo({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
  });
  
  @override
  String toString() {
    return 'PeriodInfo(startDate: $startDate, endDate: $endDate, durationDays: $durationDays)';
  }
}

/// Model untuk menyimpan informasi siklus menstruasi
class CycleInfo {
  final DateTime lastPeriodEndDate;
  final int lastPeriodDuration;
  final int cycleLength;
  final List<PeriodInfo> periodHistory;
  
  CycleInfo({
    required this.lastPeriodEndDate,
    required this.lastPeriodDuration,
    required this.cycleLength,
    required this.periodHistory,
  });
  
  @override
  String toString() {
    return 'CycleInfo(lastPeriodEndDate: $lastPeriodEndDate, lastPeriodDuration: $lastPeriodDuration, cycleLength: $cycleLength, periodHistory: ${periodHistory.length} periods)';
  }
}
