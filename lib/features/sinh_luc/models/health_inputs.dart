/// Check-in trưa / tối (backend: bảng `check_ins`, 1 dòng / ngày / mốc). Trưa: tự chấm thể lực; tối: phút tập, thể thao, ngày nghỉ.
class CheckIn {
  const CheckIn({required this.date, required this.slot, this.staminaSelf, this.exerciseMinutes, this.sportMinutes, this.restDay = false});

  factory CheckIn.fromJson(Map<String, dynamic> j) => CheckIn(
    date: j['date'] as String? ?? '',
    slot: j['slot'] as String? ?? 'evening',
    staminaSelf: (j['staminaSelf'] as num?)?.toInt(),
    exerciseMinutes: (j['exerciseMinutes'] as num?)?.toInt(),
    sportMinutes: (j['sportMinutes'] as num?)?.toInt(),
    restDay: j['restDay'] == true,
  );

  final String date;

  /// `noon` | `evening`.
  final String slot;

  /// 1 (kiệt sức) … 5 (rất khoẻ); chỉ mốc trưa.
  final int? staminaSelf;
  final int? exerciseMinutes;
  final int? sportMinutes;
  final bool restDay;

  bool get isNoon => slot == 'noon';
}

/// GET /api/du-an/check-ins: check-in gần nhất (mới trước) + "hôm nay" theo server.
class CheckInHistory {
  const CheckInHistory({required this.today, required this.checkIns});

  factory CheckInHistory.fromJson(Map<String, dynamic> j) => CheckInHistory(
    today: j['today'] as String? ?? '',
    checkIns: [
      for (final e in (j['checkIns'] as List?) ?? const [])
        if (e is Map) CheckIn.fromJson(Map<String, dynamic>.from(e)),
    ],
  );

  final String today;
  final List<CheckIn> checkIns;

  CheckIn? find(String date, String slot) => checkIns.where((c) => c.date == date && c.slot == slot).firstOrNull;
}

/// Debuff (bệnh / trạng thái xấu): trừ thẳng Sức khoẻ, miễn phạt trễ hạn khi còn hiệu lực.
class Debuff {
  const Debuff({required this.id, required this.level, this.label, required this.startedAt, this.endedAt, required this.active});

  factory Debuff.fromJson(Map<String, dynamic> j) => Debuff(
    id: j['id'] as String? ?? '',
    level: j['level'] as String? ?? 'light',
    label: j['label'] as String?,
    startedAt: DateTime.tryParse(j['startedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    endedAt: DateTime.tryParse(j['endedAt'] as String? ?? ''),
    active: j['active'] == true,
  );

  final String id;

  /// `light` | `medium` | `heavy`.
  final String level;
  final String? label;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool active;
}
