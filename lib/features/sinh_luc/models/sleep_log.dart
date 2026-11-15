/// Một đêm ngủ tự ghi (backend: bảng `sleep_logs`, `date` = ngày thức dậy theo lịch VN).
class SleepLog {
  const SleepLog({required this.date, required this.sleepMinutes, this.quality, this.note});

  factory SleepLog.fromJson(Map<String, dynamic> j) => SleepLog(
    date: j['date'] as String? ?? '',
    sleepMinutes: (j['sleepMinutes'] as num?)?.toInt() ?? 0,
    quality: (j['quality'] as num?)?.toInt(),
    note: j['note'] as String?,
  );

  final String date;
  final int sleepMinutes;

  /// 1 (rất tệ) … 5 (rất tốt), null = không chấm.
  final int? quality;
  final String? note;
}

/// GET /api/du-an/sleep: các đêm gần nhất (mới trước) + "hôm nay" theo server.
class SleepHistory {
  const SleepHistory({required this.today, required this.logs});

  factory SleepHistory.fromJson(Map<String, dynamic> j) => SleepHistory(
    today: j['today'] as String? ?? '',
    logs: [
      for (final e in (j['logs'] as List?) ?? const [])
        if (e is Map) SleepLog.fromJson(Map<String, dynamic>.from(e)),
    ],
  );

  final String today;
  final List<SleepLog> logs;
}
