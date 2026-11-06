import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn Kho thẻ: tải, danh sách, trống, lọc / tìm, cuộn vô hạn, sửa - tạm dừng - xoá, lỗi. API giả có dữ liệu thật (fixture).

const _subject = 'subject-1';
Finder _k(String key) => find.byKey(ValueKey(key));

/// Chip nằm trong hàng cuộn ngang có thể ở ngoài màn hình: cuộn tới rồi mới chạm (người dùng cũng làm vậy).
Future<void> _tapScrolled(WidgetTester tester, String key) async {
  await tester.ensureVisible(_k(key));
  await tester.pump();
  await tester.tap(_k(key));
}

DateTime _vnDay(int plusDays) => DateTime.now().toUtc().add(Duration(days: plusDays));

StudyCard _card(String id, String phrase, {CardStage stage = CardStage.weekly, DateTime? dueAt, bool suspended = false, CardKind kind = CardKind.idiom, List<String> topics = const []}) =>
    StudyCard(id: id, subjectId: _subject, phrase: phrase, meaning: 'nghĩa của $phrase', example: 'ví dụ $phrase', kind: kind, topics: topics, stage: stage, dueAt: dueAt, suspended: suspended);

FakeHocTapApi _api({List<StudyCard>? cards}) => FakeHocTapApi()..cards = cards ?? [_card('a', 'break the ice', dueAt: _vnDay(0)), _card('b', 'look forward to', stage: CardStage.newCard, kind: CardKind.phrasalVerb)];

Future<void> _pump(WidgetTester tester, FakeHocTapApi api, {String? subjectId = _subject, bool settle = true, double height = 2600}) =>
    pumpHocTap(tester, CardLibraryScreen(subjectId: subjectId), api: api, settle: settle, height: height);

void main() {
  group('trạng thái tải', () {
    testWidgets('đang tải → vòng quay; xong → danh sách', (tester) async {
      final api = _api();
      final gate = Completer<void>();
      api.cardsGate = gate;
      await _pump(tester, api, settle: false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_k('card-a'), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(_k('card-a'), findsOneWidget);
    });

    testWidgets('lỗi tải → thông báo + Thử lại, bấm lại thì tải được', (tester) async {
      final api = _api()..cardsError = apiError(500, {'error': 'x'});
      await _pump(tester, api);
      expect(find.textContaining('Không tải được kho thẻ'), findsOneWidget);
      api.cardsError = null;
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(_k('card-a'), findsOneWidget);
    });

    testWidgets('không có subjectId → dùng môn đầu tiên của Tổng quan', (tester) async {
      final api = _api();
      await _pump(tester, api, subjectId: null);
      expect(api.cardQueries.first.subjectId, api.overview.subjects.first.subjectId);
      expect(_k('card-a'), findsOneWidget);
    });
  });

  group('danh sách', () {
    testWidgets('dòng thẻ: cụm, nghĩa, loại, nhãn hạn; tổng số ở tiêu đề; chip giai đoạn có số đếm', (tester) async {
      final api = _api(cards: [
        _card('a', 'break the ice', dueAt: _vnDay(0)),
        _card('b', 'look forward to', stage: CardStage.newCard, kind: CardKind.phrasalVerb),
        _card('c', 'make a decision', dueAt: _vnDay(1), kind: CardKind.collocation),
        _card('d', 'pick up on', dueAt: _vnDay(9), kind: CardKind.phrasalVerb),
        _card('e', 'paused one', suspended: true, dueAt: _vnDay(0)),
      ]);
      await _pump(tester, api);
      expect(find.text('Kho thẻ'), findsOneWidget);
      expect(_k('library-total'), findsOneWidget);
      expect(find.textContaining('5 thẻ'), findsOneWidget);
      expect(find.text('break the ice'), findsOneWidget);
      expect(find.text('nghĩa của break the ice'), findsOneWidget);
      expect(tester.widget<Text>(_k('due-a')).data, 'Hôm nay');
      expect(tester.widget<Text>(_k('due-b')).data, 'Mới');
      expect(tester.widget<Text>(_k('due-c')).data, 'Mai');
      expect(tester.widget<Text>(_k('due-d')).data, matches(RegExp(r'^\d{2}/\d{2}$')));
      expect(tester.widget<Text>(_k('due-e')).data, 'Tạm dừng');
      expect(find.text('Thành ngữ'), findsWidgets); // nhãn loại
      expect(find.text('Tất cả 5'), findsOneWidget);
      expect(find.text('Mới 1'), findsOneWidget);
      expect(find.text('Hàng tuần 4'), findsOneWidget);
      expect(find.text('Đang học 0'), findsOneWidget);
    });

    testWidgets('hàng chip giai đoạn cuộn ngang, không xuống dòng (máy hẹp)', (tester) async {
      await pumpHocTap(tester, const CardLibraryScreen(subjectId: _subject), api: _api(), width: 320);
      final row = find.ancestor(of: _k('stage-chip-all'), matching: find.byType(SingleChildScrollView)).first;
      expect(tester.widget<SingleChildScrollView>(row).scrollDirection, Axis.horizontal);
      // Mọi chip nằm trên cùng một hàng ngang (cùng toạ độ y).
      final ys = {for (final k in ['all', 'NEW', 'LEARNING', 'WEEKLY', 'MONTHLY', 'QUARTERLY']) tester.getTopLeft(_k('stage-chip-$k')).dy};
      expect(ys.length, 1);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('kho trống: lời mời nhập thẻ, bấm sang màn nhập', (tester) async {
      final api = _api(cards: const []);
      await _pump(tester, api);
      expect(_k('library-empty'), findsOneWidget);
      expect(find.text('Kho thẻ còn trống.'), findsOneWidget);
      await tester.tap(_k('library-empty-import'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/them?subjectId=$_subject');
    });

    testWidgets('nút chính "Ôn thẻ hôm nay" ở đầu màn mở màn ôn thẻ của môn', (tester) async {
      await _pump(tester, _api());
      expect(find.text('Ôn thẻ hôm nay'), findsOneWidget);
      // nằm trên ô tìm kiếm
      expect(tester.getTopLeft(_k('card-review-start')).dy, lessThan(tester.getTopLeft(_k('card-search')).dy));
      await tester.tap(_k('card-review-start'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/on?subjectId=$_subject');
    });

    testWidgets('thanh trên có nút "Thống kê" mở màn Nhóm khó của môn', (tester) async {
      await _pump(tester, _api());
      expect(find.byTooltip('Thống kê'), findsOneWidget);
      await tester.tap(_k('card-stats'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/thong-ke?subjectId=$_subject');
    });

    testWidgets('nút "+ Thêm thẻ từ Claude" mở màn nhập', (tester) async {
      await _pump(tester, _api());
      expect(find.text('+ Thêm thẻ từ Claude'), findsOneWidget);
      await tester.tap(_k('card-import'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh/hoc-tap/the/them?subjectId=$_subject');
    });

    testWidgets('có nút quay lại', (tester) async {
      await _pump(tester, _api());
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  group('lọc và tìm', () {
    testWidgets('đổi chip giai đoạn: gọi API với stage, danh sách đổi, số đếm vẫn của cả môn', (tester) async {
      final api = _api(cards: [_card('a', 'break the ice'), _card('b', 'look forward to', stage: CardStage.newCard)]);
      await _pump(tester, api);
      expect(_k('card-a'), findsOneWidget);
      expect(_k('card-b'), findsOneWidget);

      await tester.tap(_k('stage-chip-NEW'));
      await tester.pumpAndSettle();
      expect(api.cardQueries.last.stage, CardStage.newCard);
      expect(_k('card-a'), findsNothing);
      expect(_k('card-b'), findsOneWidget);
      expect(find.text('Tất cả 2'), findsOneWidget);

      await tester.tap(_k('stage-chip-all'));
      await tester.pumpAndSettle();
      expect(api.cardQueries.last.stage, isNull);
      expect(_k('card-a'), findsOneWidget);
    });

    testWidgets('tìm kiếm: chờ gõ xong (debounce) rồi mới gọi API với q', (tester) async {
      final api = _api();
      await _pump(tester, api);
      final before = api.cardQueries.length;
      await tester.enterText(_k('card-search'), 'forw');
      await tester.pump(const Duration(milliseconds: 100));
      expect(api.cardQueries.length, before, reason: 'chưa hết thời gian chờ');
      await tester.enterText(_k('card-search'), 'forward');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(api.cardQueries.length, before + 1, reason: 'chỉ một lần gọi cho cả lượt gõ');
      expect(api.cardQueries.last.q, 'forward');
      expect(_k('card-a'), findsNothing);
      expect(_k('card-b'), findsOneWidget);
    });

    testWidgets('không khớp: báo "không có thẻ nào khớp", Xoá bộ lọc đưa danh sách về như cũ', (tester) async {
      final api = _api();
      await _pump(tester, api);
      await tester.enterText(_k('card-search'), 'zzz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(_k('library-no-match'), findsOneWidget);
      await tester.tap(_k('library-clear-filters'));
      await tester.pumpAndSettle();
      expect(_k('card-a'), findsOneWidget);
      expect(tester.widget<TextField>(_k('card-search')).controller!.text, isEmpty);
      expect(api.cardQueries.last.q, anyOf(isNull, isEmpty));
    });

    testWidgets('sheet "Lọc": chọn loại và chủ đề (từ API chủ đề) → gọi API với kind + topic, nút hiện số bộ lọc', (tester) async {
      final api = _api(cards: [_card('a', 'break the ice', topics: ['work']), _card('b', 'look forward to', kind: CardKind.phrasalVerb, topics: ['daily life'])]);
      await _pump(tester, api);
      await tester.tap(_k('card-filter'));
      await tester.pumpAndSettle();
      expect(find.text('Lọc thẻ'), findsOneWidget);
      expect(find.byType(CloseButton), findsOneWidget);
      await _tapScrolled(tester, 'kind-PHRASAL_VERB');
      await _tapScrolled(tester, 'topic-daily life');
      await tester.pump();
      await tester.tap(_k('filter-apply'));
      await tester.pumpAndSettle();
      expect(api.cardQueries.last.kind, CardKind.phrasalVerb);
      expect(api.cardQueries.last.topic, 'daily life');
      expect(find.text('Lọc (2)'), findsOneWidget);
      expect(_k('card-a'), findsNothing);
      expect(_k('card-b'), findsOneWidget);
    });
  });

  group('cuộn vô hạn', () {
    List<StudyCard> many(int n) => [for (var i = 0; i < n; i++) _card('id$i', 'phrase number $i')];

    testWidgets('danh sách chưa lấp đầy màn hình thì tự nối trang kế cho tới khi đủ hoặc hết', (tester) async {
      final api = _api(cards: many(30))..cardPageSize = 12;
      await _pump(tester, api); // màn cao 2600: 12 thẻ chưa đầy
      final cursors = api.cardQueries.map((q) => q.cursor).toList();
      expect(cursors.length, greaterThanOrEqualTo(2), reason: 'trang đầu chưa đầy màn hình nên phải tự nối tiếp');
      expect(cursors.take(3), [null, '12', '24'].take(cursors.length.clamp(0, 3)), reason: 'đúng con trỏ của trang trước');
      expect(_k('card-id12'), findsOneWidget, reason: 'thẻ đầu của trang 2 đã hiện');
    });

    testWidgets('cuộn gần cuối thì nối trang kế bằng con trỏ; hết thì dừng', (tester) async {
      final api = _api(cards: many(30))..cardPageSize = 12;
      await _pump(tester, api, height: 700);
      expect(api.cardQueries.map((q) => q.cursor), [null]);
      for (var i = 0; i < 6 && api.cardQueries.length < 3; i++) {
        await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
        await tester.pumpAndSettle();
      }
      expect(api.cardQueries.map((q) => q.cursor), [null, '12', '24']);
      await tester.drag(find.byType(ListView).last, const Offset(0, -6000));
      await tester.pumpAndSettle();
      expect(api.cardQueries.length, 3, reason: 'hết trang thì không gọi thêm');
      expect(_k('card-id29'), findsOneWidget);
    });

    testWidgets('lỗi khi tải thêm: giữ danh sách, hiện "Thử lại" ở cuối, bấm thì nối tiếp', (tester) async {
      final api = _api(cards: many(30))
        ..cardPageSize = 20
        ..cardsMoreError = apiError(500, {'error': 'x'});
      await _pump(tester, api, height: 700);
      await tester.drag(find.byType(ListView).last, const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(find.text('Không tải thêm được thẻ.'), findsOneWidget);
      expect(_k('card-id19'), findsOneWidget, reason: 'thẻ cuối của trang đã tải vẫn còn');
      final calls = api.cardQueries.length;
      await tester.pump(const Duration(seconds: 1));
      expect(api.cardQueries.length, calls, reason: 'không tự thử lại liên tục');
      api.cardsMoreError = null;
      await tester.tap(_k('library-retry-more'));
      await tester.pumpAndSettle();
      expect(find.text('Không tải thêm được thẻ.'), findsNothing);
      await tester.drag(find.byType(ListView).last, const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(_k('card-id29'), findsOneWidget);
    });
  });

  group('thêm / sửa / xoá', () {
    testWidgets('+ ở thanh trên: thêm một thẻ bằng tay, gửi đúng nội dung, danh sách tải lại', (tester) async {
      final api = _api();
      await _pump(tester, api);
      await tester.tap(_k('card-add'));
      await tester.pumpAndSettle();
      expect(find.text('Thêm thẻ'), findsWidgets);
      expect(tester.widget<FilledButton>(_k('card-save')).onPressed, isNull, reason: 'thiếu trường bắt buộc');
      await tester.enterText(_k('card-phrase'), 'get along with');
      await tester.enterText(_k('card-meaning'), 'to have a good relationship with');
      await tester.enterText(_k('card-example'), 'I get along with my coworkers.');
      await tester.pump();
      expect(tester.widget<FilledButton>(_k('card-save')).onPressed, isNull, reason: 'chưa chọn loại');
      await _tapScrolled(tester, 'card-kind-PHRASAL_VERB');
      await tester.pump();
      await tester.enterText(_k('card-topic-input'), ' Work, DAILY life ,travel, extra');
      await tester.tap(_k('card-topic-add'));
      await tester.pump();
      expect(find.byKey(const ValueKey('card-topic-work')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-topic-daily life')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-topic-travel')), findsOneWidget);
      expect(find.byKey(const ValueKey('card-topic-extra')), findsNothing, reason: 'tối đa 3 chủ đề');
      expect(_k('card-topic-input'), findsNothing, reason: 'đủ 3 thì ẩn ô nhập');
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      expect(api.cardCreates.single, {
        'subjectId': _subject,
        'phrase': 'get along with',
        'meaning': 'to have a good relationship with',
        'example': 'I get along with my coworkers.',
        'kind': 'PHRASAL_VERB',
        'topics': ['work', 'daily life', 'travel'],
      });
      expect(find.text('get along with'), findsOneWidget, reason: 'danh sách đã tải lại');
    });

    testWidgets('thêm trùng cụm: báo "đã có trong kho", sheet vẫn mở để sửa', (tester) async {
      final api = _api()..cardCreateError = apiError(409, fixtureMap('cards_error_duplicate'));
      await _pump(tester, api);
      await tester.tap(_k('card-add'));
      await tester.pumpAndSettle();
      await tester.enterText(_k('card-phrase'), 'break the ice');
      await tester.enterText(_k('card-meaning'), 'm');
      await tester.enterText(_k('card-example'), 'e');
      await _tapScrolled(tester, 'card-kind-IDIOM');
      await tester.pump();
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      expect(find.text('Cụm từ này đã có trong kho của môn'), findsOneWidget);
      expect(_k('card-save'), findsOneWidget);
    });

    testWidgets('chạm dòng: sheet sửa có nội dung, giai đoạn / hạn / số lần ôn chỉ xem', (tester) async {
      final api = FakeHocTapApi()
        ..cards = [
          StudyCard(
            id: 'w',
            subjectId: _subject,
            phrase: 'break the ice',
            meaning: 'to relax people',
            example: 'He told a joke to break the ice.',
            note: 'idiom',
            kind: CardKind.idiom,
            topics: const ['work'],
            stage: CardStage.weekly,
            dueAt: DateTime.parse('2026-11-15T00:00:00+07:00'),
            reviewCount: 4,
            notYetCount: 1,
          ),
        ];
      await _pump(tester, api);
      await tester.tap(_k('card-w'));
      await tester.pumpAndSettle();
      expect(find.text('Thẻ từ vựng'), findsOneWidget);
      expect(tester.widget<TextField>(_k('card-phrase')).controller!.text, 'break the ice');
      expect(tester.widget<TextField>(_k('card-note')).controller!.text, 'idiom');
      expect(find.byKey(const ValueKey('card-topic-work')), findsOneWidget);
      expect(tester.widget<Text>(_k('info-stage')).data, 'Hàng tuần');
      expect(tester.widget<Text>(_k('info-due')).data, '15/11');
      expect(tester.widget<Text>(_k('info-reviews')).data, '4 lần');
      expect(tester.widget<Text>(_k('info-notyet')).data, '1 lần');
      // chỉ xem: không có ô nhập nào cho các trường đó
      expect(find.widgetWithText(TextField, 'Hàng tuần'), findsNothing);
    });

    testWidgets('sửa + tạm dừng: gửi PATCH đủ trường, không gửi giai đoạn / hạn; dòng thành "Tạm dừng"', (tester) async {
      final api = _api();
      await _pump(tester, api);
      await tester.tap(_k('card-a'));
      await tester.pumpAndSettle();
      await tester.enterText(_k('card-meaning'), 'to start a friendly talk');
      await tester.tap(_k('card-suspended'));
      await tester.pump();
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      final patch = api.cardPatches.single;
      expect(patch['id'], 'a');
      expect(patch['meaning'], 'to start a friendly talk');
      expect(patch['suspended'], true);
      expect(patch['kind'], 'IDIOM');
      expect(patch.containsKey('stage'), isFalse);
      expect(patch.containsKey('dueAt'), isFalse);
      expect(patch.containsKey('subjectId'), isFalse);
      expect(tester.widget<Text>(_k('due-a')).data, 'Tạm dừng');
    });

    testWidgets('sửa cụm thành cụm đã có → báo lỗi tiếng Việt, không đóng sheet', (tester) async {
      final api = _api()..cardPatchError = apiError(409, {'error': 'duplicate_phrase'});
      await _pump(tester, api);
      await tester.tap(_k('card-a'));
      await tester.pumpAndSettle();
      await tester.enterText(_k('card-phrase'), 'look forward to');
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      expect(find.text('Cụm từ này đã có trong kho của môn'), findsOneWidget);
    });

    testWidgets('thẻ đã bị xoá nơi khác → card_not_found hiện tiếng Việt', (tester) async {
      final api = _api()..cardPatchError = apiError(404, {'error': 'card_not_found'});
      await _pump(tester, api);
      await tester.tap(_k('card-a'));
      await tester.pumpAndSettle();
      await tester.enterText(_k('card-meaning'), 'x');
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy thẻ, có thể đã bị xoá'), findsOneWidget);
    });

    testWidgets('xoá có hỏi lại: "Giữ lại" thì không xoá, "Xoá" thì xoá và danh sách bớt thẻ', (tester) async {
      final api = _api();
      await _pump(tester, api);
      await tester.tap(_k('card-a'));
      await tester.pumpAndSettle();
      await tester.tap(_k('card-delete'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá thẻ này?'), findsOneWidget);
      await tester.tap(find.text('Giữ lại'));
      await tester.pumpAndSettle();
      expect(api.cardDeletes, isEmpty);
      await tester.tap(_k('card-delete'));
      await tester.pumpAndSettle();
      await tester.tap(_k('card-delete-confirm'));
      await tester.pumpAndSettle();
      expect(api.cardDeletes, ['a']);
      expect(_k('card-a'), findsNothing);
      expect(_k('card-b'), findsOneWidget);
    });

    testWidgets('kiểm tra từng trường của server (single_word) hiện đúng câu', (tester) async {
      final api = _api()..cardPatchError = apiError(400, fixtureMap('cards_error_validation'));
      await _pump(tester, api);
      await tester.tap(_k('card-a'));
      await tester.pumpAndSettle();
      await tester.enterText(_k('card-phrase'), 'hello');
      await tester.tap(_k('card-save'));
      await tester.pumpAndSettle();
      expect(find.text('Cụm từ phải có ít nhất 2 từ (kho không nhận từ đơn)'), findsOneWidget);
    });
  });
}
