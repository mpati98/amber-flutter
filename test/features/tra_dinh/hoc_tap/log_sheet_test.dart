import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/course.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/log_sheet.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/missing_reason_sheet.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

bool _enabled(WidgetTester tester, String key) => tester.widget<FilledButton>(find.byKey(ValueKey(key))).onPressed != null;
Finder _k(String key) => find.byKey(ValueKey(key));

void main() {
  late FakeHocTapApi api;
  String subjectId() => api.subjects.first.id;
  CourseView active() => api.courses.firstWhere((c) => c.status == CourseStatus.active);

  Future<void> open(WidgetTester tester, {String? courseId, StudyLog? editing}) async {
    await pumpHocTap(
      tester,
      Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => showLogSheet(c, subjectId: subjectId(), courseId: courseId, editing: editing), child: const Text('mở')))),
      api: api,
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
  }

  Future<void> minutes(WidgetTester tester, String value) async {
    await tester.enterText(_k('log-minutes'), value);
    await tester.pump();
  }

  StudyLog editingLog({int minutes = 25}) => StudyLog(
    id: 'log-1',
    subjectId: subjectId(),
    courseId: api.detail.course.id,
    courseTitle: 'English Tenses 101',
    logDate: vnToday(),
    minutes: minutes,
    note: 'ghi chú cũ',
    createdAt: DateTime.now(),
    sections: [StudyLogSection(sectionId: api.detail.sections[1].id, title: api.detail.sections[1].title, markedDone: true)],
  );

  setUp(() => api = FakeHocTapApi());

  testWidgets('dòng đầu "Hôm nay · thứ, ngày. Chỉ ghi cho hôm nay."; chip môn khi có > 1 môn; mặc định khóa ACTIVE', (tester) async {
    await open(tester);
    expect(find.textContaining('Hôm nay · '), findsOneWidget);
    expect(find.textContaining('Chỉ ghi cho hôm nay.'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(_k('log-subject-${subjectId()}'), findsOneWidget);
    expect(find.text('English Tenses 101'), findsWidgets); // khóa ACTIVE được chọn sẵn
    // phần kế tiếp được chọn sẵn, công tắc "Xong phần" hiện nhưng tắt
    final next = api.detail.course.nextSection!.id;
    expect(tester.widget<Checkbox>(_k('pick-$next')).value, isTrue);
    expect(tester.widget<Switch>(_k('done-$next')).value, isFalse);
    // phần đã xong không hiện
    expect(_k('pick-${api.detail.sections.first.id}'), findsNothing);
  });

  testWidgets('tổng dự kiến < mục tiêu → hiện công tắc "Hôm nay dừng ở đây" + dòng nhắc', (tester) async {
    await open(tester);
    await minutes(tester, '20');
    expect(_k('stop-switch'), findsOneWidget);
    expect(find.text('Hôm nay: 20 / 60 phút'), findsOneWidget);
    expect(_k('stop-hint'), findsOneWidget);
    expect(find.textContaining('sáng mai app hỏi lý do'), findsOneWidget);
    expect(_enabled(tester, 'log-save'), isTrue, reason: 'chưa bật dừng thì lưu được');
  });

  testWidgets('bật dừng: chưa chọn lý do → Lưu tắt; Khác không văn bản → tắt; có văn bản → bật', (tester) async {
    await open(tester);
    await minutes(tester, '20');
    await tester.tap(_k('stop-switch'));
    await tester.pumpAndSettle();
    expect(_k('reason-BUSY'), findsOneWidget);
    expect(_enabled(tester, 'log-save'), isFalse);

    await tester.tap(_k('reason-BUSY'));
    await tester.pump();
    expect(_enabled(tester, 'log-save'), isTrue);

    await tester.tap(_k('reason-OTHER'));
    await tester.pump();
    expect(_enabled(tester, 'log-save'), isFalse, reason: 'Khác mà trống văn bản');
    await tester.enterText(_k('reason-text'), '   ');
    await tester.pump();
    expect(_enabled(tester, 'log-save'), isFalse, reason: 'chỉ khoảng trắng cũng là trống');
    await tester.enterText(_k('reason-text'), 'Đi khám');
    await tester.pump();
    expect(_enabled(tester, 'log-save'), isTrue);
  });

  testWidgets('đủ mục tiêu → ẩn công tắc dừng và lý do, khối chuyển màu đạt', (tester) async {
    await open(tester);
    await minutes(tester, '60');
    expect(_k('stop-switch'), findsNothing);
    expect(_k('stop-hint'), findsNothing);
    expect(find.text('Hôm nay: 60 / 60 phút · đủ mục tiêu'), findsOneWidget);
    // Đang bật dừng rồi nhập đủ → lý do biến mất và không gửi.
    await minutes(tester, '10');
    await tester.tap(_k('stop-switch'));
    await tester.pumpAndSettle();
    await tester.tap(_k('reason-TIRED'));
    await minutes(tester, '60');
    expect(_k('reason-TIRED'), findsNothing);
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();
    expect(api.logCreates.single.containsKey('stopForToday'), isFalse);
  });

  testWidgets('đã ghi hôm nay được cộng vào tổng dự kiến', (tester) async {
    api.logs = [editingLog(minutes: 40).let((l) => StudyLog(id: 'x', subjectId: l.subjectId, logDate: vnToday(), minutes: 40, createdAt: DateTime.now()))];
    await open(tester);
    await minutes(tester, '20');
    expect(find.text('Hôm nay: 60 / 60 phút · đủ mục tiêu'), findsOneWidget);
    expect(find.text('Đã ghi 40 + đang nhập 20'), findsOneWidget);
    expect(_k('stop-switch'), findsNothing);
  });

  testWidgets('không gắn khóa (ôn tập) → ẩn danh sách phần và không gửi sections', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(ValueKey('log-course-${subjectId()}-${active().id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Không gắn khóa (ôn tập)').last);
    await tester.pumpAndSettle();
    expect(find.text('Phần đã học'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    await minutes(tester, '45');
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();
    final body = api.logCreates.single;
    expect(body.containsKey('courseId'), isFalse);
    expect(body.containsKey('sections'), isFalse);
    expect(body['minutes'], 45);
  });

  testWidgets('lưu: gửi khóa, phút nhanh, phần + Xong phần, ghi chú, lý do dừng; SnackBar "Đã ghi X phút · hôm nay Y/Z"', (tester) async {
    await open(tester);
    await tester.tap(_k('quick-30'));
    await tester.pump();
    final next = api.detail.course.nextSection!.id;
    await tester.tap(_k('done-$next'));
    await tester.enterText(_k('log-note'), 'Học xong phần 2');
    await tester.tap(_k('stop-switch'));
    await tester.pumpAndSettle();
    await tester.tap(_k('reason-BUSY'));
    await tester.pump();
    await tester.ensureVisible(_k('log-save'));
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();

    expect(api.logCreates.single, {
      'subjectId': subjectId(),
      'courseId': active().id,
      'minutes': 30,
      'sections': [{'sectionId': next, 'markDone': true}],
      'note': 'Học xong phần 2',
      'stopForToday': {'code': 'BUSY'},
    });
    expect(find.byType(Dialog), findsNothing, reason: 'đóng sheet');
    expect(find.text('Đã ghi 30 phút · hôm nay 50/60'), findsOneWidget);
  });

  testWidgets('khóa vừa sang DONE → SnackBar thêm "Xong khóa <tên>"', (tester) async {
    final c = active();
    api.logResult = StudyLogResult(
      log: api.logResult.log,
      today: api.logResult.today,
      course: CourseView(id: c.id, subjectId: c.subjectId, title: c.title, status: CourseStatus.done),
    );
    await open(tester);
    await minutes(tester, '30');
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Xong khóa English Tenses 101'), findsOneWidget);
  });

  testWidgets('API lỗi → báo bằng tiếng Việt, sheet còn mở', (tester) async {
    api.logError = apiError(400, {'error': 'reason_text_required'});
    await open(tester);
    await minutes(tester, '30');
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập lý do khi chọn "Khác"'), findsOneWidget);
    expect(_k('log-save'), findsOneWidget);
  });

  testWidgets('mở từ chi tiết khóa: chọn sẵn khóa đó (kể cả khóa Chờ học)', (tester) async {
    final queued = api.courses.firstWhere((c) => c.status == CourseStatus.queued);
    await open(tester, courseId: queued.id);
    await minutes(tester, '30');
    await tester.tap(_k('log-save'));
    await tester.pumpAndSettle();
    expect(api.logCreates.single['courseId'], queued.id);
  });

  group('chế độ sửa', () {
    testWidgets('điền sẵn, có nút Xoá + dòng nhắc, không có chọn môn/khóa', (tester) async {
      await open(tester, editing: editingLog());
      expect(find.text('Sửa buổi học'), findsOneWidget);
      expect(tester.widget<TextField>(_k('log-minutes')).controller!.text, '25');
      expect(tester.widget<TextField>(_k('log-note')).controller!.text, 'ghi chú cũ');
      expect(_k('log-delete'), findsOneWidget);
      expect(_k('edit-section-note'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      final sec = api.detail.sections[1].id;
      expect(tester.widget<Checkbox>(_k('pick-$sec')).value, isTrue);
      expect(tester.widget<Switch>(_k('done-$sec')).value, isTrue);
    });

    testWidgets('lưu gửi PATCH với phút, ghi chú, danh sách phần', (tester) async {
      await open(tester, editing: editingLog());
      await minutes(tester, '35');
      await tester.ensureVisible(_k('log-save'));
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      final patch = api.logPatches.single;
      expect(patch['id'], 'log-1');
      expect(patch['minutes'], 35);
      expect(patch['note'], 'ghi chú cũ');
      expect(patch['sections'], [{'sectionId': api.detail.sections[1].id, 'markDone': true}]);
      expect(find.textContaining('Đã cập nhật buổi học'), findsOneWidget);
    });

    testWidgets('Xoá có xác nhận → deleteLog', (tester) async {
      await open(tester, editing: editingLog());
      await tester.ensureVisible(_k('log-delete'));
      await tester.tap(_k('log-delete'));
      await tester.pumpAndSettle();
      expect(api.logDeletes, isEmpty, reason: 'chưa xác nhận');
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();
      expect(api.logDeletes, ['log-1']);
      expect(find.text('Đã xoá buổi học'), findsOneWidget);
    });

    testWidgets('không tính phút của chính buổi đang sửa vào phần "đã ghi"', (tester) async {
      api.logs = [editingLog(minutes: 25)];
      await open(tester, editing: editingLog(minutes: 25));
      expect(find.text('Đã ghi 0 + đang nhập 25'), findsOneWidget);
    });
  });

  group('sheet lý do thiếu', () {
    Future<void> openReasons(WidgetTester tester, List<String> dates) async {
      api.logs = [
        StudyLog(id: 'a', subjectId: subjectId(), logDate: '2026-10-12', minutes: 30, createdAt: DateTime.now()),
        StudyLog(id: 'b', subjectId: subjectId(), logDate: '2026-10-13', minutes: 45, createdAt: DateTime.now()),
      ];
      await pumpHocTap(
        tester,
        Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => showMissingReasonSheet(c, subjectId: subjectId(), subjectName: 'Tiếng Anh', goalMinutes: 60, dates: dates), child: const Text('mở')))),
        api: api,
      );
      await tester.tap(find.text('mở'));
      await tester.pumpAndSettle();
    }

    testWidgets('đi qua 2 ngày lần lượt, cũ trước; mỗi ngày PUT một lý do', (tester) async {
      await openReasons(tester, ['2026-10-13', '2026-10-12']);
      expect(find.text('12/10 · đã học 30/60 phút'), findsOneWidget);
      expect(find.text('Tiếng Anh · ngày 1/2'), findsOneWidget);
      expect(_enabled(tester, 'reason-save'), isFalse);
      expect(find.text('Lưu và tiếp'), findsOneWidget);

      await tester.tap(_k('reason-TIRED'));
      await tester.pump();
      await tester.tap(_k('reason-save'));
      await tester.pumpAndSettle();
      expect(api.reasonPuts.single, (subjectId: subjectId(), date: '2026-10-12', code: ReasonCode.tired, text: null));

      // ngày thứ hai
      expect(find.text('13/10 · đã học 45/60 phút'), findsOneWidget);
      expect(find.text('Tiếng Anh · ngày 2/2'), findsOneWidget);
      expect(find.text('Lưu'), findsOneWidget, reason: 'ngày cuối: nút "Lưu"');
      expect(_enabled(tester, 'reason-save'), isFalse, reason: 'lý do ngày trước không giữ lại');
      await tester.tap(_k('reason-OTHER'));
      await tester.pump();
      expect(_enabled(tester, 'reason-save'), isFalse);
      await tester.enterText(_k('reason-text'), 'Đi khám');
      await tester.pump();
      await tester.tap(_k('reason-save'));
      await tester.pumpAndSettle();
      expect(api.reasonPuts.last, (subjectId: subjectId(), date: '2026-10-13', code: ReasonCode.other, text: 'Đi khám'));
      expect(find.byType(Dialog), findsNothing, reason: 'xong hết thì đóng');
    });

    testWidgets('goal_met → báo, không sang ngày sau; "Bỏ qua ngày này" sang ngày tiếp', (tester) async {
      api.reasonError = apiError(400, {'error': 'goal_met'});
      await openReasons(tester, ['2026-10-12', '2026-10-13']);
      await tester.tap(_k('reason-BUSY'));
      await tester.pump();
      await tester.tap(_k('reason-save'));
      await tester.pumpAndSettle();
      expect(find.text('Ngày đó đã đủ mục tiêu, không cần lý do'), findsOneWidget);
      expect(find.text('12/10 · đã học 30/60 phút'), findsOneWidget);
      await tester.tap(_k('reason-skip'));
      await tester.pumpAndSettle();
      expect(find.text('13/10 · đã học 45/60 phút'), findsOneWidget);
    });
  });
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
