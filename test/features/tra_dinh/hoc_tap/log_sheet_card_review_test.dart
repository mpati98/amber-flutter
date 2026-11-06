import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/log_sheet.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Buổi ôn thẻ (CARD_REVIEW) trong sheet ghi buổi học: form sửa chỉ có phút + ghi chú; công tắc "Loại" khi thêm tay.

Finder _k(String key) => find.byKey(ValueKey(key));
bool _enabled(WidgetTester tester, String key) => tester.widget<FilledButton>(_k(key)).onPressed != null;

void main() {
  late FakeHocTapApi api;
  String subjectId() => api.subjects.first.id;

  StudyLog cardLog({int minutes = 15, String? note = 'ôn 10 thẻ'}) =>
      StudyLog(id: 'card-1', subjectId: subjectId(), logDate: vnToday(), minutes: minutes, note: note, createdAt: DateTime.now(), activity: LogActivity.cardReview);

  Future<void> open(WidgetTester tester, {StudyLog? editing}) async {
    await pumpHocTap(
      tester,
      Scaffold(body: Builder(builder: (c) => TextButton(onPressed: () => showLogSheet(c, subjectId: subjectId(), editing: editing), child: const Text('mở')))),
      api: api,
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
  }

  Future<void> minutes(WidgetTester tester, String value) async {
    await tester.enterText(_k('log-minutes'), value);
    await tester.pump();
  }

  setUp(() => api = FakeHocTapApi());

  group('sửa một buổi ôn thẻ', () {
    testWidgets('tiêu đề "Ôn thẻ"; chỉ có số phút và ghi chú (điền sẵn), không có khóa / phần / mục tiêu / dừng', (tester) async {
      await open(tester, editing: cardLog());
      expect(find.text('Ôn thẻ'), findsWidgets);
      expect(find.byType(CloseButton), findsOneWidget);
      expect(tester.widget<TextField>(_k('log-minutes')).controller!.text, '15');
      expect(tester.widget<TextField>(_k('log-note')).controller!.text, 'ôn 10 thẻ');
      expect(find.textContaining('Khóa học'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String?>), findsNothing, reason: 'không có ô chọn khóa');
      expect(find.text('Phần đã học'), findsNothing);
      expect(find.byType(Checkbox), findsNothing, reason: 'không có phần để chọn');
      expect(_k('total-block'), findsNothing);
      expect(_k('stop-switch'), findsNothing);
      expect(_k('log-activity'), findsNothing, reason: 'không đổi loại của buổi có sẵn');
      expect(_k('log-delete'), findsOneWidget);
    });

    testWidgets('lưu bằng PATCH chỉ gồm minutes và note — KHÔNG gửi courseId, sections, stopForToday', (tester) async {
      await open(tester, editing: cardLog());
      await minutes(tester, '25');
      await tester.enterText(_k('log-note'), 'sửa lại');
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      final patch = api.logPatches.single;
      expect(patch, {'id': 'card-1', 'minutes': 25, 'note': 'sửa lại'});
      for (final k in ['courseId', 'sections', 'stopForToday', 'activity', 'subjectId']) {
        expect(patch.containsKey(k), isFalse, reason: k);
      }
      expect(api.logCreates, isEmpty);
      expect(find.textContaining('Đã cập nhật buổi ôn thẻ'), findsOneWidget);
    });

    testWidgets('xoá ghi chú → note null', (tester) async {
      await open(tester, editing: cardLog());
      await tester.enterText(_k('log-note'), '   ');
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      expect(api.logPatches.single['note'], isNull);
    });

    testWidgets('số phút phải từ 1 đến 1440', (tester) async {
      await open(tester, editing: cardLog());
      for (final (v, ok) in [('0', false), ('1441', false), ('', false), ('1', true), ('1440', true)]) {
        await minutes(tester, v);
        expect(_enabled(tester, 'log-save'), ok, reason: v);
      }
    });

    testWidgets('xoá có hỏi lại (nội dung riêng cho buổi ôn thẻ), xoá xong báo "Đã xoá buổi ôn thẻ"', (tester) async {
      await open(tester, editing: cardLog());
      await tester.tap(_k('log-delete'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá buổi ôn thẻ?'), findsOneWidget);
      expect(find.textContaining('Phần đã đánh dấu xong'), findsNothing);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.logDeletes, isEmpty);
      await tester.tap(_k('log-delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();
      expect(api.logDeletes, ['card-1']);
      expect(find.text('Đã xoá buổi ôn thẻ'), findsOneWidget);
    });

    testWidgets('lỗi server (không phải hôm nay) báo tiếng Việt, sheet vẫn mở', (tester) async {
      api.logError = apiError(400, {'error': 'not_today'});
      await open(tester, editing: cardLog());
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      expect(find.text('Chỉ sửa hoặc xoá được buổi học của hôm nay'), findsOneWidget);
      expect(_k('log-save'), findsOneWidget);
    });

    testWidgets('sửa buổi HỌC BÀI vẫn như cũ: tiêu đề "Sửa buổi học", không có công tắc Loại', (tester) async {
      await open(
        tester,
        editing: StudyLog(id: 'l1', subjectId: subjectId(), courseId: api.detail.course.id, courseTitle: 'English Tenses 101', logDate: vnToday(), minutes: 25, createdAt: DateTime.now()),
      );
      expect(find.text('Sửa buổi học'), findsOneWidget);
      expect(_k('log-activity'), findsNothing);
      expect(_k('total-block'), findsOneWidget);
    });
  });

  group('thêm tay: công tắc "Loại"', () {
    testWidgets('mặc định "Học bài" (đủ ô khóa, phần, mục tiêu); đổi sang "Ôn thẻ" chỉ còn phút + ghi chú', (tester) async {
      await open(tester);
      expect(_k('log-activity'), findsOneWidget);
      expect(find.text('Loại'), findsOneWidget);
      expect(find.text('Học bài'), findsOneWidget);
      expect(find.text('Ôn thẻ'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String?>), findsOneWidget, reason: 'mặc định là form học bài');
      expect(_k('total-block'), findsOneWidget);

      await tester.tap(find.text('Ôn thẻ'));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
      expect(find.text('Phần đã học'), findsNothing);
      expect(_k('total-block'), findsNothing);
      expect(_k('stop-switch'), findsNothing);
      expect(_k('log-minutes'), findsOneWidget);
      expect(_k('log-note'), findsOneWidget);
      expect(find.text('Ghi phút ôn thẻ'), findsOneWidget);
      expect(_k('log-activity'), findsOneWidget, reason: 'công tắc vẫn còn để đổi lại');
    });

    testWidgets('"Ôn thẻ": tạo buổi CARD_REVIEW chỉ với subjectId, activity, minutes, note — không courseId, sections, stopForToday', (tester) async {
      await open(tester);
      await tester.tap(find.text('Ôn thẻ'));
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'log-save'), isFalse);
      await tester.tap(_k('quick-15'));
      await tester.pump();
      expect(tester.widget<TextField>(_k('log-minutes')).controller!.text, '15');
      await tester.enterText(_k('log-note'), 'bù buổi hôm qua bỏ qua');
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      final body = api.logCreates.single;
      expect(body, {'subjectId': subjectId(), 'activity': 'CARD_REVIEW', 'minutes': 15, 'note': 'bù buổi hôm qua bỏ qua'});
      for (final k in ['courseId', 'sections', 'stopForToday']) {
        expect(body.containsKey(k), isFalse, reason: k);
      }
      expect(find.textContaining('Đã ghi 15 phút ôn thẻ'), findsOneWidget);
    });

    testWidgets('không ghi chú thì không gửi note; số phút ngoài 1–1440 thì khoá nút', (tester) async {
      await open(tester);
      await tester.tap(find.text('Ôn thẻ'));
      await tester.pumpAndSettle();
      for (final (v, ok) in [('0', false), ('1441', false), ('20', true)]) {
        await minutes(tester, v);
        expect(_enabled(tester, 'log-save'), ok, reason: v);
      }
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      expect(api.logCreates.single.containsKey('note'), isFalse);
    });

    testWidgets('đổi qua lại: về "Học bài" thì ghi buổi học bài như cũ (không gửi activity, server mặc định LESSON)', (tester) async {
      await open(tester);
      await tester.tap(find.text('Ôn thẻ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Học bài'));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String?>), findsOneWidget);
      await minutes(tester, '30');
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      final body = api.logCreates.single;
      expect(body['minutes'], 30);
      expect(body.containsKey('activity'), isFalse, reason: 'buổi học bài giữ nguyên dạng gửi cũ');
    });

    testWidgets('lỗi tạo: báo, ở lại sheet', (tester) async {
      api.logError = apiError(404, {'error': 'subject_not_found'});
      await open(tester);
      await tester.tap(find.text('Ôn thẻ'));
      await tester.pumpAndSettle();
      await minutes(tester, '15');
      await tester.tap(_k('log-save'));
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy môn học'), findsOneWidget);
      expect(_k('log-save'), findsOneWidget);
    });
  });
}
