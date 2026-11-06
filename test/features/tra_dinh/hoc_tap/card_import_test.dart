import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_import_screen.dart';
import 'package:amber_flutter/shared/widgets/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    expect(find.byType(BackButton), findsOneWidget);
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
}
