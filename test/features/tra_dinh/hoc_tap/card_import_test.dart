import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/card_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_import_screen.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:amber_flutter/shared/widgets/tag.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn Nhập thẻ từ Claude: dán JSON → Xem trước (không lưu) → Lưu. Dữ liệu xem trước lấy từ JSON thật của backend dev.

const _subject = 'subject-1';
Finder _k(String key) => find.byKey(ValueKey(key));

/// `cards_parse` thật: 2 thẻ hợp lệ, 2 lỗi (thẻ 4), 1 lặp, 1 đã có.
ParsedCards _fixtureParsed({bool errors = true, bool existing = true, bool duplicates = true}) {
  final j = Map<String, dynamic>.from(fixtureMap('cards_parse'));
  if (!errors) j['errors'] = <Object>[];
  if (!existing) j['existing'] = <Object>[];
  if (!duplicates) j['duplicates'] = <Object>[];
  return ParsedCards.fromJson(j);
}

Future<void> _pump(WidgetTester tester, FakeHocTapApi api) => pumpHocTap(tester, const CardImportScreen(subjectId: _subject), api: api);

Future<void> _preview(WidgetTester tester, [String text = '[{"phrase": "x"}]']) async {
  await tester.enterText(_k('import-text'), text);
  await tester.pump();
  await tester.tap(_k('import-preview'));
  await tester.pumpAndSettle();
}

FilledButton _save(WidgetTester tester) => tester.widget<FilledButton>(_k('import-save'));

void main() {
  testWidgets('màn đầu: ô dán JSON, nút Xem trước bị khoá khi trống, chưa có nút Lưu, có nút quay lại', (tester) async {
    await _pump(tester, FakeHocTapApi());
    expect(find.text('Nhập thẻ từ Claude'), findsOneWidget);
    expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    expect(tester.widget<FilledButton>(_k('import-preview')).onPressed, isNull);
    expect(_k('import-save'), findsNothing);
    expect(find.text('Sao chép lời nhắc cho Claude'), findsOneWidget);
    await tester.enterText(_k('import-text'), '[]');
    await tester.pump();
    expect(tester.widget<FilledButton>(_k('import-preview')).onPressed, isNotNull);
  });

  group('xem trước', () {
    testWidgets('chỉ gọi parse, không lưu gì; thẻ hợp lệ hiện cụm, nghĩa, ví dụ, loại viền vàng, chủ đề xám', (tester) async {
      final api = FakeHocTapApi()..parsedResult = _fixtureParsed(errors: false, existing: false, duplicates: false);
      await _pump(tester, api);
      await _preview(tester, '[{"a": 1}]');
      expect(api.cardParseTexts, ['[{"a": 1}]']);
      expect(api.cardImports, isEmpty, reason: 'xem trước không lưu');
      expect(api.cardCreates, isEmpty);
      expect(tester.widget<Text>(_k('preview-summary')).data, '2 thẻ hợp lệ');
      expect(find.text('pick up on'), findsOneWidget);
      expect(find.text('to notice'), findsOneWidget);
      expect(find.text('She picked up on his mood.'), findsOneWidget);
      expect(find.text('inseparable'), findsOneWidget); // ghi chú
      final card = _k('preview-card-1');
      final kind = tester.widget<Tag>(find.descendant(of: card, matching: find.byType(Tag)).first);
      expect(kind.label, 'Cụm động từ');
      expect(kind.variant, TagVariant.outlined, reason: 'loại: viền vàng');
      expect(kind.color, ThemeData.dark().colorScheme.primary, reason: 'màu lấy từ theme');
      final topic = tester.widget<Tag>(find.descendant(of: card, matching: find.byType(Tag)).at(1));
      expect(topic.label, 'daily life');
      expect(topic.variant, TagVariant.tonal, reason: 'chủ đề: xám');
      expect(find.byType(Wrap), findsNothing, reason: 'nhãn nằm trong hàng cuộn ngang');
      expect(_k('preview-errors'), findsNothing);
      expect(_save(tester).onPressed, isNotNull);
      expect(find.text('Lưu 2 thẻ'), findsOneWidget);
    });

    testWidgets('thẻ đã có trong kho: mờ + "đã có trong kho, sẽ không được lưu"; thẻ lặp được ghi chú', (tester) async {
      final api = FakeHocTapApi()..parsedResult = _fixtureParsed(errors: false);
      await _pump(tester, api);
      await _preview(tester);
      expect(tester.widget<Text>(_k('preview-summary')).data, '2 thẻ hợp lệ · 1 đã có · 1 lặp');
      final existing = _k('preview-existing-0');
      expect(existing, findsOneWidget);
      expect(tester.widget<Opacity>(existing).opacity, lessThan(1));
      expect(find.descendant(of: existing, matching: find.text('Break the ice')), findsOneWidget);
      expect(find.descendant(of: existing, matching: find.text('đã có trong kho, sẽ không được lưu')), findsOneWidget);
      expect(find.text('Thẻ 3 "PICK  UP on" lặp với thẻ 2, chỉ giữ một thẻ.'), findsOneWidget);
      expect(_save(tester).onPressed, isNotNull, reason: 'đã có / lặp không chặn việc lưu');
      expect(find.text('Lưu 2 thẻ'), findsOneWidget, reason: 'chỉ đếm thẻ sẽ được tạo');
    });

    testWidgets('còn lỗi: liệt kê vị trí + lý do tiếng Việt và KHÓA nút Lưu', (tester) async {
      final api = FakeHocTapApi()..parsedResult = _fixtureParsed();
      await _pump(tester, api);
      await _preview(tester);
      expect(tester.widget<Text>(_k('preview-summary')).data, '2 thẻ hợp lệ · 1 đã có · 1 lặp · 2 lỗi');
      expect(find.text('Cần sửa trước khi lưu'), findsOneWidget);
      expect(find.text('Thẻ 4 · Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)'), findsOneWidget);
      expect(find.textContaining('Thẻ 4 · Loại không hợp lệ'), findsOneWidget);
      expect(_save(tester).onPressed, isNull, reason: 'phải sửa lỗi trước khi lưu');
      await tester.tap(_k('import-save'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(api.cardImports, isEmpty);
    });

    testWidgets('JSON hỏng: lỗi của cả đầu vào (không có "Thẻ N"), không lưu được', (tester) async {
      final api = FakeHocTapApi()..parsedResult = ParsedCards.fromJson(fixtureMap('cards_parse_invalid_json'));
      await _pump(tester, api);
      await _preview(tester, '[{');
      expect(find.text('Không đọc được JSON, kiểm tra dấu ngoặc và dấu phẩy'), findsOneWidget);
      expect(_save(tester).onPressed, isNull);
      expect(find.text('Lưu 0 thẻ'), findsOneWidget);
    });

    testWidgets('không có thẻ hợp lệ nào (toàn thẻ đã có) → không có gì để lưu', (tester) async {
      final api = FakeHocTapApi()..parsedResult = const ParsedCards(existing: [ExistingCard(index: 0, phrase: 'break the ice')]);
      await _pump(tester, api);
      await _preview(tester);
      expect(_save(tester).onPressed, isNull);
    });

    testWidgets('gõ lại sau khi xem trước: kết quả cũ biến mất, phải xem trước lại', (tester) async {
      final api = FakeHocTapApi()..parsedResult = _fixtureParsed(errors: false);
      await _pump(tester, api);
      await _preview(tester);
      expect(_k('preview-summary'), findsOneWidget);
      await tester.enterText(_k('import-text'), '[{"phrase": "changed"}]');
      await tester.pump();
      expect(_k('preview-summary'), findsNothing);
      expect(_k('import-save'), findsNothing);
    });

    testWidgets('lỗi mạng khi xem trước: báo lỗi, không có kết quả cũ', (tester) async {
      final api = FakeHocTapApi()..cardParseError = apiError(404, {'error': 'subject_not_found'});
      await _pump(tester, api);
      await _preview(tester);
      expect(find.text('Không tìm thấy môn học'), findsOneWidget);
      expect(_k('preview-summary'), findsNothing);
    });
  });

  group('lưu', () {
    testWidgets('gửi đúng các thẻ hợp lệ, báo "Đã lưu X thẻ, bỏ qua Y thẻ" (Y gồm thẻ đã có và lặp), rồi về kho thẻ', (tester) async {
      final api = FakeHocTapApi()
        ..parsedResult = _fixtureParsed(errors: false)
        ..importResult = const ImportResult(created: 2, skipped: 0);
      await _pump(tester, api);
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(api.cardImports.single.map((c) => c['phrase']), ['pick up on', 'come across']);
      expect(api.cardImports.single.first, {'phrase': 'pick up on', 'meaning': 'to notice', 'example': 'She picked up on his mood.', 'note': null, 'kind': 'PHRASAL_VERB', 'topics': ['daily life']});
      expect(find.text('Đã lưu 2 thẻ, bỏ qua 2 thẻ'), findsOneWidget);
      expect(visited.last, '/tra-dinh/hoc-tap/the?subjectId=$_subject', reason: 'quay về kho thẻ');
    });

    testWidgets('server bỏ qua thêm thẻ (đua với lần nhập khác): cộng vào số bỏ qua', (tester) async {
      final api = FakeHocTapApi()
        ..parsedResult = _fixtureParsed(errors: false, existing: false, duplicates: false)
        ..importResult = const ImportResult(created: 1, skipped: 1);
      await _pump(tester, api);
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(find.text('Đã lưu 1 thẻ, bỏ qua 1 thẻ'), findsOneWidget);
    });

    testWidgets('lưu lỗi: báo tiếng Việt, ở lại màn, nút Lưu dùng lại được', (tester) async {
      final api = FakeHocTapApi()
        ..parsedResult = _fixtureParsed(errors: false)
        ..cardImportError = apiError(400, {'error': 'invalid_cards', 'errors': []});
      await _pump(tester, api);
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(find.text('Có thẻ chưa hợp lệ, sửa các lỗi rồi thử lại'), findsOneWidget);
      expect(_k('import-save'), findsOneWidget);
      expect(_save(tester).onPressed, isNotNull);
      expect(visited, isEmpty);
    });
  });

  group('sao chép lời nhắc cho Claude', () {
    Future<String?> copy(WidgetTester tester, FakeHocTapApi api) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await _pump(tester, api);
      await tester.tap(_k('import-copy-prompt'));
      await tester.pumpAndSettle();
      expect(find.text('Đã sao chép lời nhắc cho Claude'), findsOneWidget);
      return copied;
    }

    testWidgets('thay [LIST OF MY TOPICS] bằng các chủ đề đang có của môn', (tester) async {
      final text = await copy(tester, FakeHocTapApi());
      expect(text, contains('topics when they fit: work, daily life.'));
      expect(text, isNot(contains('[LIST OF MY TOPICS]')));
      expect(text, startsWith('Here is the transcript of my English lesson.'));
    });

    testWidgets('môn chưa có chủ đề → "none yet"', (tester) async {
      final text = await copy(tester, FakeHocTapApi()..topics = const []);
      expect(text, contains('topics when they fit: none yet.'));
    });

    testWidgets('tải chủ đề lỗi → vẫn chép được, ghi "none yet"', (tester) async {
      final text = await copy(tester, FakeHocTapApi()..topicsError = apiError(500, {'error': 'x'}));
      expect(text, contains('none yet'));
    });
  });

  group('"Gắn vào buổi học"', () {
    String ago(int days) => vnToday(DateTime.now().subtract(Duration(days: days)));
    StudyLog log(String id, int daysAgo, int minutes, {String? course, LogActivity activity = LogActivity.lesson, int hour = 8}) => StudyLog(
      id: id,
      subjectId: _subject,
      courseId: course == null ? null : 'c-$course',
      courseTitle: course,
      logDate: ago(daysAgo),
      minutes: minutes,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)).copyWith(hour: hour),
      activity: activity,
    );

    FakeHocTapApi withLogs() => FakeHocTapApi()
      ..parsedResult = _fixtureParsed(errors: false, existing: false, duplicates: false)
      ..logs = [
        log('old', 3, 45, course: 'English Tenses 101'),
        log('today', 0, 30),
        log('card', 1, 15, activity: LogActivity.cardReview),
        log('ancient', 20, 60, course: 'Quá cũ'),
        log('mid', 3, 20, hour: 21),
      ];

    Future<void> pickLesson(WidgetTester tester, String label) async {
      await tester.ensureVisible(_k('import-lesson-null'));
      await tester.tap(_k('import-lesson-null'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    testWidgets('provider: chỉ buổi HỌC BÀI trong 14 ngày, mới nhất trước (bỏ buổi ôn thẻ và buổi quá cũ)', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      final container = ProviderScope.containerOf(tester.element(find.byType(CardImportScreen)));
      final list = await container.read(recentLessonLogsProvider(_subject).future);
      expect(list.map((l) => l.id), ['today', 'mid', 'old'], reason: 'cùng ngày thì buổi muộn hơn trước');
    });

    testWidgets('mặc định không gắn buổi nào; ô chọn có dòng "dd/MM · khóa · N phút"', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      expect(find.text('Gắn vào buổi học (không bắt buộc)'), findsOneWidget);
      expect(find.text('Không gắn buổi học'), findsOneWidget);
      await tester.tap(_k('import-lesson-null'));
      await tester.pumpAndSettle();
      expect(find.text('${formatDM(ago(3))} · English Tenses 101 · 45 phút'), findsOneWidget);
      expect(find.text('${formatDM(ago(0))} · Ôn tập · 30 phút'), findsOneWidget, reason: 'buổi không khóa ghi "Ôn tập"');
      expect(find.textContaining('Quá cũ'), findsNothing);
      expect(find.textContaining('15 phút'), findsNothing, reason: 'buổi ôn thẻ không có trong danh sách');
    });

    testWidgets('chọn một buổi: lưu gửi đúng logId kèm các thẻ', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      await pickLesson(tester, '${formatDM(ago(3))} · English Tenses 101 · 45 phút');
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(api.cardImportLogIds, ['old']);
      expect(api.cardImports.single.map((c) => c['phrase']), ['pick up on', 'come across']);
    });

    testWidgets('không chọn: logId null', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(api.cardImportLogIds, [null]);
    });

    testWidgets('chọn rồi quay về "Không gắn buổi học": logId null', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      await pickLesson(tester, '${formatDM(ago(0))} · Ôn tập · 30 phút');
      await tester.ensureVisible(_k('import-lesson-today'));
      await tester.tap(_k('import-lesson-today'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Không gắn buổi học').last);
      await tester.pumpAndSettle();
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(api.cardImportLogIds, [null]);
    });

    testWidgets('chọn buổi không làm mất kết quả xem trước', (tester) async {
      final api = withLogs();
      await _pump(tester, api);
      await _preview(tester);
      await pickLesson(tester, '${formatDM(ago(3))} · English Tenses 101 · 45 phút');
      expect(_k('preview-summary'), findsOneWidget);
      expect(_save(tester).onPressed, isNotNull);
    });

    testWidgets('tải danh sách buổi học lỗi: ẩn ô chọn, vẫn nhập thẻ được (logId null)', (tester) async {
      final api = withLogs()..logsError = apiError(500, {'error': 'x'});
      await _pump(tester, api);
      expect(find.text('Gắn vào buổi học (không bắt buộc)'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
      await _preview(tester);
      await tester.tap(_k('import-save'));
      await tester.pumpAndSettle();
      expect(api.cardImportLogIds, [null]);
      expect(find.textContaining('Đã lưu 2 thẻ'), findsOneWidget);
    });

    testWidgets('không có buổi học nào trong 14 ngày: ẩn ô chọn', (tester) async {
      await _pump(tester, FakeHocTapApi()..logs = [log('ancient', 20, 60, course: 'Quá cũ')]);
      expect(find.text('Gắn vào buổi học (không bắt buộc)'), findsNothing);
    });
  });
}

/// "2026-11-03" → "03/11" (như nhãn trong ô chọn buổi học).
String formatDM(String iso) => '${iso.substring(8, 10)}/${iso.substring(5, 7)}';
