import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:amber_flutter/features/sinh_luc/models/health_inputs.dart';
import 'package:amber_flutter/features/sinh_luc/models/sleep_log.dart';
import 'package:amber_flutter/features/sinh_luc/screens/sinh_luc_screen.dart';
import 'package:amber_flutter/features/sinh_luc/services/health_inputs_api.dart';
import 'package:amber_flutter/features/sinh_luc/services/sleep_api.dart';
import 'package:amber_flutter/shared/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../amber_brain/fake_brain.dart';

class _FakeSleepApi extends SleepApi {
  _FakeSleepApi(this.logs) : super(Dio());

  List<SleepLog> logs;
  final saved = <Map<String, Object?>>[];
  final deleted = <String>[];

  @override
  Future<SleepHistory> history({int days = 14}) async => SleepHistory(today: '2026-11-15', logs: List.of(logs));

  @override
  Future<SleepLog> save({required String date, required int sleepMinutes, int? quality, String? note}) async {
    saved.add({'date': date, 'sleepMinutes': sleepMinutes, 'quality': quality, 'note': note});
    final l = SleepLog(date: date, sleepMinutes: sleepMinutes, quality: quality, note: note);
    logs = [l, ...logs.where((x) => x.date != date)];
    return l;
  }

  @override
  Future<void> delete(String date) async {
    deleted.add(date);
    logs = logs.where((x) => x.date != date).toList();
  }
}

class _FakeHealthApi extends HealthInputsApi {
  _FakeHealthApi({List<CheckIn>? checkIns, List<Debuff>? debuffs})
      : checkInsList = checkIns ?? [],
        debuffList = debuffs ?? [],
        super(Dio());

  List<CheckIn> checkInsList;
  List<Debuff> debuffList;
  final calls = <String, List<Map<String, Object?>>>{};
  Object? failWith;

  void _log(String k, Map<String, Object?> v) => (calls[k] ??= []).add(v);
  void _maybeFail() {
    final f = failWith;
    if (f != null) throw f;
  }

  @override
  Future<CheckInHistory> checkIns({int days = 14}) async => CheckInHistory(today: '2026-11-15', checkIns: List.of(checkInsList));

  CheckIn _store(CheckIn c) {
    checkInsList = [c, ...checkInsList.where((x) => !(x.date == c.date && x.slot == c.slot))];
    return c;
  }

  @override
  Future<CheckIn> saveNoon({required String date, required int staminaSelf}) async {
    _maybeFail();
    _log('noon', {'date': date, 'staminaSelf': staminaSelf});
    return _store(CheckIn(date: date, slot: 'noon', staminaSelf: staminaSelf));
  }

  @override
  Future<CheckIn> saveEvening({required String date, int? exerciseMinutes, int? sportMinutes, required bool restDay}) async {
    _maybeFail();
    _log('evening', {'date': date, 'exerciseMinutes': exerciseMinutes, 'sportMinutes': sportMinutes, 'restDay': restDay});
    return _store(CheckIn(date: date, slot: 'evening', exerciseMinutes: exerciseMinutes, sportMinutes: sportMinutes, restDay: restDay));
  }

  @override
  Future<void> deleteCheckIn(String date, String slot) async {
    _log('deleteCheckIn', {'date': date, 'slot': slot});
    checkInsList = checkInsList.where((x) => !(x.date == date && x.slot == slot)).toList();
  }

  @override
  Future<List<Debuff>> debuffs({int days = 30}) async => List.of(debuffList);

  @override
  Future<Debuff> createDebuff({required String level, String? label, String? startedAt}) async {
    _maybeFail();
    _log('createDebuff', {'level': level, 'label': label, 'startedAt': startedAt});
    final d = Debuff(id: 'd${debuffList.length + 1}', level: level, label: label?.trim().isEmpty ?? true ? null : label!.trim(), startedAt: DateTime.utc(2026, 11, 15, 1), active: true);
    debuffList = [d, ...debuffList];
    return d;
  }

  @override
  Future<Debuff> updateDebuff(String id, {String? level, String? label, bool? ended}) async {
    _log('updateDebuff', {'id': id, 'level': level, 'label': label, 'ended': ended});
    final old = debuffList.firstWhere((d) => d.id == id);
    final endedAt = ended == null ? old.endedAt : (ended ? DateTime.utc(2026, 11, 15, 5) : null);
    final d = Debuff(id: id, level: level ?? old.level, label: label ?? old.label, startedAt: old.startedAt, endedAt: endedAt, active: endedAt == null);
    debuffList = [for (final x in debuffList) x.id == id ? d : x];
    return d;
  }

  @override
  Future<void> deleteDebuff(String id) async {
    _log('deleteDebuff', {'id': id});
    debuffList = debuffList.where((d) => d.id != id).toList();
  }
}

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const Authenticated({'id': 'u', 'email': 'me@example.invalid'});
}

const _offline = BrainConnection(link: BrainLink.offline, apiHost: 'localhost:3000');

Future<_FakeSleepApi> _pump(WidgetTester tester, List<SleepLog> logs, {_FakeHealthApi? health}) async {
  final api = _FakeSleepApi(logs);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sleepApiProvider.overrideWithValue(api),
      healthInputsApiProvider.overrideWithValue(health ?? _FakeHealthApi()),
      brainStatusProvider.overrideWith(() => FixedBrainStatus(_offline)),
      authControllerProvider.overrideWith(_Auth.new),
    ],
    child: MaterialApp.router(
      theme: ThemeData.dark(),
      routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SinhLucScreen())]),
    ),
  ));
  await tester.pumpAndSettle();
  return api;
}

void main() {
  testWidgets('chưa có đêm nào: hướng dẫn + nút ghi đêm qua; ghi 7 giờ 30, chất lượng Tốt', (tester) async {
    final api = await _pump(tester, const []);
    expect(find.textContaining('giá trị trung tính'), findsOneWidget);
    expect(find.text('Chưa ghi'), findsOneWidget);
    await tester.tap(find.text('Ghi giấc ngủ đêm qua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập số giờ đã ngủ.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('sleep-hours')), '7');
    await tester.enterText(find.byKey(const ValueKey('sleep-minutes')), '30');
    await tester.tap(find.text('Tốt'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(api.saved.single, {'date': '2026-11-15', 'sleepMinutes': 450, 'quality': 4, 'note': ''});
    expect(find.byKey(const ValueKey('sleep-2026-11-15')), findsOneWidget);
    expect(find.text('7 giờ 30 · Tốt'), findsOneWidget);
  });

  testWidgets('có dữ liệu: trung bình 7 ngày, chạm một đêm để sửa / xoá', (tester) async {
    final api = await _pump(tester, const [
      SleepLog(date: '2026-11-15', sleepMinutes: 480, quality: 5),
      SleepLog(date: '2026-11-14', sleepMinutes: 360),
      SleepLog(date: '2026-11-01', sleepMinutes: 600),
    ]);
    expect(find.text('7 giờ (2 đêm)'), findsOneWidget, reason: 'đêm 01/11 nằm ngoài 7 ngày');
    await tester.tap(find.byKey(const ValueKey('sleep-2026-11-14')));
    await tester.pumpAndSettle();
    expect(find.text('Sửa giấc ngủ'), findsOneWidget);
    await tester.tap(find.text('Xoá đêm này'));
    await tester.pumpAndSettle();
    expect(api.deleted, ['2026-11-14']);
    expect(find.byKey(const ValueKey('sleep-2026-11-14')), findsNothing);
  });

  testWidgets('320 px, chữ ×2,0: không tràn', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() { tester.view.reset(); tester.platformDispatcher.clearTextScaleFactorTestValue(); });
    await _pump(tester, const [SleepLog(date: '2026-11-15', sleepMinutes: 480, quality: 3, note: 'Thức giấc giữa đêm vì mưa to')]);
    expect(tester.takeException(), isNull);
  });

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.byKey(ValueKey('chip-$label')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('chip-$label')));
    await tester.pumpAndSettle();
  }

  testWidgets('check-in trưa: bắt chọn mức, lưu Khoẻ; tổng quan cập nhật', (tester) async {
    final health = _FakeHealthApi();
    await _pump(tester, const [], health: health);
    expect(find.text('Chưa check-in'), findsNWidgets(2));
    await openTab(tester, 'Check-in');
    expect(find.text('Chưa có check-in nào trong 14 ngày.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('checkin-noon')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn mức thể lực.'), findsOneWidget);
    await tester.tap(find.text('Khoẻ'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(health.calls['noon'], [{'date': '2026-11-15', 'staminaSelf': 4}]);
    expect(find.text('Thể lực: Khoẻ'), findsOneWidget);
    expect(find.byKey(const ValueKey('checkin-2026-11-15-noon')), findsOneWidget);
  });

  testWidgets('check-in tối: kiểm phút, lưu hôm qua; ngày nghỉ; sửa rồi xoá', (tester) async {
    final health = _FakeHealthApi();
    await _pump(tester, const [], health: health);
    await openTab(tester, 'Check-in');
    await tester.tap(find.byKey(const ValueKey('checkin-evening')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hôm qua (14/11)'));
    await tester.enterText(find.byKey(const ValueKey('checkin-exercise')), '2000');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Phút tập phải là số phút từ 0 đến 1440.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('checkin-exercise')), '30');
    await tester.enterText(find.byKey(const ValueKey('checkin-sport')), '20');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(health.calls['evening'], [{'date': '2026-11-14', 'exerciseMinutes': 30, 'sportMinutes': 20, 'restDay': false}]);
    final row = find.byKey(const ValueKey('checkin-2026-11-14-evening'));
    expect(find.descendant(of: row, matching: find.text('14/11 · Tối · 30 phút tập · 20 phút thể thao')), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('Sửa check-in tối'), findsOneWidget);
    await tester.tap(find.text('Ngày nghỉ'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(health.calls['evening']!.last['restDay'], true);
    await tester.tap(find.byKey(const ValueKey('checkin-2026-11-14-evening')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xoá check-in tối'));
    await tester.pumpAndSettle();
    expect(health.calls['deleteCheckIn'], [{'date': '2026-11-14', 'slot': 'evening'}]);
    expect(find.byKey(const ValueKey('checkin-2026-11-14-evening')), findsNothing);
  });

  testWidgets('lỗi backend future_date → câu tiếng Việt trong form', (tester) async {
    final health = _FakeHealthApi()
      ..failWith = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 400, data: {'error': 'future_date'}),
      );
    await _pump(tester, const [], health: health);
    await openTab(tester, 'Check-in');
    await tester.tap(find.byKey(const ValueKey('checkin-noon')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mệt'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Không ghi được cho ngày trong tương lai.'), findsOneWidget);
  });

  testWidgets('debuff: thêm (vừa, đầu ngày hôm nay), tổng quan hiện, đã khỏi, mở lại, xoá', (tester) async {
    final health = _FakeHealthApi();
    await _pump(tester, const [], health: health);
    expect(find.text('Không có'), findsOneWidget);
    await openTab(tester, 'Debuff');
    expect(find.text('Không có debuff nào trong 30 ngày.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('debuff-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vừa (−25)'));
    await tester.enterText(find.byKey(const ValueKey('debuff-label')), ' Cảm ');
    await tester.tap(find.text('Đầu ngày hôm nay'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(health.calls['createDebuff'], [{'level': 'medium', 'label': ' Cảm ', 'startedAt': '2026-11-15T00:00:00+07:00'}]);
    expect(find.text('Cảm (vừa)'), findsOneWidget);
    final row = find.byKey(const ValueKey('debuff-d1'));
    expect(find.descendant(of: row, matching: find.textContaining('đang có')), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('debuff-end')));
    await tester.pumpAndSettle();
    expect(health.calls['updateDebuff']!.last, {'id': 'd1', 'level': null, 'label': null, 'ended': true});
    expect(find.text('Không có'), findsOneWidget, reason: 'đã khỏi ⇒ tổng quan không còn debuff');
    expect(find.descendant(of: row, matching: find.textContaining('đến 15/11 12:00')), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('debuff-reopen')));
    await tester.pumpAndSettle();
    expect(health.calls['updateDebuff']!.last['ended'], false);
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xoá (nhập nhầm)'));
    await tester.pumpAndSettle();
    expect(health.calls['deleteDebuff'], [{'id': 'd1'}]);
    expect(row, findsNothing);
  });

  testWidgets('320 px, chữ ×2,0: tab Check-in và Debuff không tràn', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() { tester.view.reset(); tester.platformDispatcher.clearTextScaleFactorTestValue(); });
    await _pump(tester, const [], health: _FakeHealthApi(
      checkIns: const [CheckIn(date: '2026-11-15', slot: 'evening', exerciseMinutes: 45, sportMinutes: 90), CheckIn(date: '2026-11-15', slot: 'noon', staminaSelf: 3)],
      debuffs: [Debuff(id: 'x', level: 'heavy', label: 'Sốt cao kèm đau họng kéo dài', startedAt: DateTime.utc(2026, 11, 14), active: true)],
    ));
    await openTab(tester, 'Check-in');
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('checkin-evening')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('checkin-evening')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('Sửa check-in tối'))).pop();
    await tester.pumpAndSettle();
    await openTab(tester, 'Debuff');
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('debuff-x')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('debuff-x')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
