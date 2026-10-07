enum KrMode {
  auto('AUTO'),
  manual('MANUAL');

  const KrMode(this.apiValue);

  final String apiValue;

  static KrMode fromApi(String value) => values.firstWhere((m) => m.apiValue == value, orElse: () => manual);
}

/// Kết quả then chốt của dự án. AUTO: tiến độ đếm từ việc gắn vào (linkedDone / linkedTotal);
/// MANUAL: nhập tay current / target kèm đơn vị.
class KeyResult {
  const KeyResult({
    required this.id,
    required this.name,
    required this.mode,
    this.unit,
    required this.target,
    required this.current,
    required this.linkedTotal,
    required this.linkedDone,
    required this.progress,
  });

  factory KeyResult.fromJson(Map<String, dynamic> json) => KeyResult(
        id: json['id'] as String,
        name: json['name'] as String,
        mode: KrMode.fromApi(json['mode'] as String),
        unit: json['unit'] as String?,
        target: json['target'] as int,
        current: json['current'] as int,
        linkedTotal: json['linkedTotal'] as int,
        linkedDone: json['linkedDone'] as int,
        progress: (json['progress'] as num).toDouble(),
      );

  final String id;
  final String name;
  final KrMode mode;
  final String? unit;
  final int target;
  final int current;
  final int linkedTotal;
  final int linkedDone;

  /// 0..1.
  final double progress;
}
