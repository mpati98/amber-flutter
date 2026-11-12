import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_card_queue.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_enums.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/models/study_log.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/card_review_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_review_screen.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/screens/card_session_end_screen.dart';
import 'package:amber_flutter/shared/utils/vn_time.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hoc_tap_test_support.dart';
import 'hoc_tap_widget_support.dart';

// Màn "Xong phiên ôn": tổng kết, nhập số phút (lưu thành buổi CARD_REVIEW), tiến độ mục tiêu ngày, Bỏ qua.

Finder _k(String key) => find.byKey(ValueKey(key));

const _session = CardReviewState(
  phase: ReviewPhase.done,
  progress: CardProgress(planned: 12, finished: 12),
  notYet: 2,
  again: 3,
  remembered: 7,
);

StudyLog _log(String subjectId, int minutes, LogActivity activity) => StudyLog(
  id: 'l$minutes-${activity.api}',
  subjectId: subjectId,
  logDate: vnToday(),
  minutes: minutes,
  createdAt: DateTime.now(),
  activity: activity,
);

/// Môn có mục tiêu 60 phút (môn đầu của fixture overview) và môn không có mục tiêu (môn thứ hai).
({FakeHocTapApi api, String withGoal, String noGoal}) _api({List<(int, LogActivity)> logs = const []}) {
  final api = FakeHocTapApi();
  final withGoal = api.overview.subjects.firstWhere((s) => s.goalMinutes != null).subjectId;
  final noGoal = api.overview.subjects.firstWhere((s) => s.goalMinutes == null).subjectId;
  api.logs = [for (final (m, a) in logs) _log(withGoal, m, a)];
  return (api: api, withGoal: withGoal, noGoal: noGoal);
}

Future<void> _pump(WidgetTester tester, FakeHocTapApi api, String subjectId, {String? name = 'Tiếng Anh', double width = 390}) =>
    pumpHocTap(tester, CardSessionEndScreen(subjectId: subjectId, subjectName: name, session: _session), api: api, width: width, height: 1400);

FilledButton _save(WidgetTester tester) => tester.widget<FilledButton>(_k('end-save'));

void main() {
  testWidgets('tổng kết: tiêu đề "Hôm nay đã ôn X / Y thẻ", ba chip của phiên, nút quay lại', (tester) async {
    final t = _api();
    await _pump(tester, t.api, t.withGoal);
    expect(find.text('Xong phiên ôn'), findsOneWidget);
    expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn 12 / 12 thẻ');
    expect(find.text('Chưa nhớ 2'), findsOneWidget);
    expect(find.text('Cần ôn lại 3'), findsOneWidget);
    expect(find.text('Đã nhớ 7'), findsOneWidget);
    expect(find.text('Số phút bạn đã ôn thẻ'), findsOneWidget);
  });

  group('mở lại khi hôm nay đã ôn xong từ trước (phiên này chưa ôn thẻ nào)', () {
    const none = CardReviewState(phase: ReviewPhase.done, progress: CardProgress(planned: 12, finished: 12));

    testWidgets('tiêu đề "Hôm nay đã ôn xong", ẩn ba chip của phiên, vẫn có ô số phút và các nút', (tester) async {
      final t = _api(logs: [(30, LogActivity.lesson)]);
      await pumpHocTap(tester, CardSessionEndScreen(subjectId: t.withGoal, subjectName: 'Tiếng Anh', session: none), api: t.api, height: 1400);
      expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn xong');
      expect(_k('end-chip-notYet'), findsNothing);
      expect(_k('end-chip-again'), findsNothing);
      expect(_k('end-chip-remembered'), findsNothing);
      expect(find.text('Chưa nhớ 0'), findsNothing);
      expect(_k('end-minutes'), findsOneWidget);
      expect(_k('end-quick-15'), findsOneWidget);
      expect(_k('end-save'), findsOneWidget);
      expect(_k('end-skip'), findsOneWidget);
      expect(_k('end-goal-bar'), findsOneWidget);
      expect(find.byKey(const ValueKey('design-top-bar-back')), findsOneWidget);
    });

    testWidgets('vẫn lưu được số phút như bình thường', (tester) async {
      final t = _api();
      await pumpHocTap(tester, CardSessionEndScreen(subjectId: t.withGoal, subjectName: 'Tiếng Anh', session: none), api: t.api, height: 1400);
      await tester.tap(_k('end-quick-10'));
      await tester.pump();
      await tester.tap(_k('end-save'));
      await tester.pumpAndSettle();
      expect(t.api.logCreates.single, {'subjectId': t.withGoal, 'activity': 'CARD_REVIEW', 'minutes': 10});
      expect(visited.last, '/tra-dinh');
    });

    testWidgets('chỉ cần ôn một thẻ trong phiên là có lại tiêu đề đếm và các chip', (tester) async {
      final t = _api();
      const one = CardReviewState(phase: ReviewPhase.done, progress: CardProgress(planned: 12, finished: 12), remembered: 1);
      await pumpHocTap(tester, CardSessionEndScreen(subjectId: t.withGoal, subjectName: 'Tiếng Anh', session: one), api: t.api, height: 1400);
      expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn 12 / 12 thẻ');
      expect(find.text('Đã nhớ 1'), findsOneWidget);
    });
  });

  group('ô nhập số phút', () {
    testWidgets('trống mặc định, Lưu bị khoá; 4 chip nhanh 10 / 15 / 20 / 30 điền vào ô', (tester) async {
      final t = _api();
      await _pump(tester, t.api, t.withGoal);
      expect(tester.widget<TextField>(_k('end-minutes')).controller!.text, isEmpty);
      expect(_save(tester).onPressed, isNull);
      for (final m in [10, 15, 20, 30]) {
        await tester.tap(_k('end-quick-$m'));
        await tester.pump();
        expect(tester.widget<TextField>(_k('end-minutes')).controller!.text, '$m');
        expect(_save(tester).onPressed, isNotNull);
      }
      expect(find.byType(Wrap), findsNothing, reason: 'chip nhanh nằm trong hàng cuộn ngang');
    });

    testWidgets('chỉ nhận chữ số; hợp lệ từ 1 đến 1440, ngoài khoảng thì báo và khoá Lưu', (tester) async {
      final t = _api();
      await _pump(tester, t.api, t.withGoal);
      await tester.enterText(_k('end-minutes'), '1a5b');
      await tester.pump();
      expect(tester.widget<TextField>(_k('end-minutes')).controller!.text, '15', reason: 'bỏ ký tự không phải số');
      for (final bad in ['0', '1441', '9999']) {
        await tester.enterText(_k('end-minutes'), bad);
        await tester.pump();
        expect(_save(tester).onPressed, isNull, reason: bad);
        expect(find.text('Nhập từ 1 đến 1440 phút'), findsOneWidget, reason: bad);
      }
      for (final ok in ['1', '1440']) {
        await tester.enterText(_k('end-minutes'), ok);
        await tester.pump();
        expect(_save(tester).onPressed, isNotNull, reason: ok);
        expect(find.text('Nhập từ 1 đến 1440 phút'), findsNothing);
      }
    });
  });

  group('tiến độ mục tiêu ngày', () {
    testWidgets('"A phút học bài + B phút ôn thẻ" theo loại buổi học hôm nay, cộng cả số phút vừa nhập', (tester) async {
      final t = _api(logs: [(30, LogActivity.lesson), (15, LogActivity.lesson), (10, LogActivity.cardReview)]);
      await _pump(tester, t.api, t.withGoal);
      expect(tester.widget<Text>(_k('end-breakdown')).data, '45 phút học bài + 10 phút ôn thẻ');
      expect(tester.widget<Text>(_k('end-goal-text')).data, 'Tiếng Anh hôm nay: 55 / 60 phút');
      expect(tester.widget<LinearProgressIndicator>(_k('end-goal-bar')).value, closeTo(55 / 60, 1e-9));
      await tester.enterText(_k('end-minutes'), '5');
      await tester.pump();
      expect(tester.widget<Text>(_k('end-breakdown')).data, '45 phút học bài + 15 phút ôn thẻ');
      expect(tester.widget<Text>(_k('end-goal-text')).data, 'Tiếng Anh hôm nay: 60 / 60 phút');
      expect(tester.widget<LinearProgressIndicator>(_k('end-goal-bar')).value, 1.0);
    });

    testWidgets('phút luyện AI cũng tính vào tổng ngày và hiện thêm "+ N phút luyện AI"; không có thì dòng giữ nguyên', (tester) async {
      final t = _api(logs: [(30, LogActivity.lesson), (10, LogActivity.cardReview), (20, LogActivity.practice)]);
      await _pump(tester, t.api, t.withGoal);
      expect(tester.widget<Text>(_k('end-breakdown')).data, '30 phút học bài + 10 phút ôn thẻ + 20 phút luyện AI');
      expect(tester.widget<Text>(_k('end-goal-text')).data, 'Tiếng Anh hôm nay: 60 / 60 phút');
    });

    testWidgets('45 phút học bài + 15 phút ôn thẻ vừa nhập = 60 / 60 (đủ mục tiêu)', (tester) async {
      final t = _api(logs: [(45, LogActivity.lesson)]);
      await _pump(tester, t.api, t.withGoal);
      await tester.tap(_k('end-quick-15'));
      await tester.pump();
      expect(tester.widget<Text>(_k('end-breakdown')).data, '45 phút học bài + 15 phút ôn thẻ');
      expect(tester.widget<Text>(_k('end-goal-text')).data, 'Tiếng Anh hôm nay: 60 / 60 phút');
    });

    testWidgets('vượt mục tiêu: thanh đầy, không tràn', (tester) async {
      final t = _api(logs: [(70, LogActivity.lesson)]);
      await _pump(tester, t.api, t.withGoal);
      expect(tester.widget<Text>(_k('end-goal-text')).data, 'Tiếng Anh hôm nay: 70 / 60 phút');
      expect(tester.widget<LinearProgressIndicator>(_k('end-goal-bar')).value, 1.0);
    });

    testWidgets('môn không có mục tiêu: ẩn thanh, vẫn có dòng "A + B"', (tester) async {
      final t = _api();
      t.api.logs = [_log(t.noGoal, 20, LogActivity.lesson)];
      await _pump(tester, t.api, t.noGoal, name: 'Lập trình');
      expect(_k('end-goal-bar'), findsNothing);
      expect(_k('end-goal-text'), findsNothing);
      expect(tester.widget<Text>(_k('end-breakdown')).data, '20 phút học bài + 0 phút ôn thẻ');
    });

    testWidgets('buổi học thiếu activity (server cũ) tính là học bài', (tester) async {
      final t = _api();
      t.api.logs = [StudyLog.fromJson({'id': 'old', 'subjectId': t.withGoal, 'logDate': vnToday(), 'minutes': 25, 'createdAt': '2026-11-06T01:00:00.000Z'})];
      await _pump(tester, t.api, t.withGoal);
      expect(tester.widget<Text>(_k('end-breakdown')).data, '25 phút học bài + 0 phút ôn thẻ');
    });
  });

  group('lưu và bỏ qua', () {
    testWidgets('"Lưu số phút": tạo buổi CARD_REVIEW đúng nội dung, về màn Học tập, làm mới Tổng quan', (tester) async {
      final t = _api();
      await _pump(tester, t.api, t.withGoal);
      final before = t.api.overviewCalls;
      await tester.tap(_k('end-quick-15'));
      await tester.pump();
      await tester.tap(_k('end-save'));
      await tester.pumpAndSettle();
      expect(t.api.logCreates.single, {'subjectId': t.withGoal, 'activity': 'CARD_REVIEW', 'minutes': 15});
      expect(visited.last, '/tra-dinh');
      expect(t.api.overviewCalls, greaterThan(before), reason: 'Tổng quan được tải lại');
    });

    testWidgets('lưu lỗi: báo bằng câu của helper chung, ở lại màn, Lưu dùng lại được', (tester) async {
      final t = _api();
      t.api.logError = apiError(404, {'error': 'subject_not_found'});
      await _pump(tester, t.api, t.withGoal);
      await tester.enterText(_k('end-minutes'), '20');
      await tester.pump();
      await tester.tap(_k('end-save'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('end-error')).data, 'Không tìm thấy môn học');
      expect(visited, isEmpty);
      expect(_save(tester).onPressed, isNotNull);
      t.api.logError = null;
      await tester.tap(_k('end-save'));
      await tester.pumpAndSettle();
      expect(visited.last, '/tra-dinh');
    });

    testWidgets('lỗi mạng: câu chung "Có lỗi, thử lại"', (tester) async {
      final t = _api();
      t.api.logError = Exception('mất mạng');
      await _pump(tester, t.api, t.withGoal);
      await tester.enterText(_k('end-minutes'), '20');
      await tester.pump();
      await tester.tap(_k('end-save'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(_k('end-error')).data, 'Có lỗi, thử lại');
    });

    testWidgets('"Bỏ qua": không tạo buổi học, về màn Học tập, làm mới Tổng quan', (tester) async {
      final t = _api();
      await _pump(tester, t.api, t.withGoal);
      final before = t.api.overviewCalls;
      await tester.enterText(_k('end-minutes'), '20'); // đã gõ cũng không lưu
      await tester.pump();
      await tester.tap(_k('end-skip'));
      await tester.pumpAndSettle();
      expect(t.api.logCreates, isEmpty);
      expect(visited.last, '/tra-dinh');
      expect(t.api.overviewCalls, greaterThan(before));
    });
  });

  testWidgets('không tràn ở bề rộng 320 với chữ phóng to x1.8', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final t = _api(logs: [(45, LogActivity.lesson), (10, LogActivity.cardReview)]);
    await _pump(tester, t.api, t.withGoal, width: 320);
    await tester.enterText(_k('end-minutes'), '1440');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('luồng đầy đủ từ màn ôn: ôn thẻ → kết thúc → nhập phút → lưu', (tester) async {
    final t = _api();
    await pumpHocTap(
      tester,
      CardReviewScreen(subjectId: t.withGoal),
      api: t.api,
      height: 1400,
    );
    for (var i = 0; i < 3; i++) {
      await tester.tap(_k('review-show-answer'));
      await tester.pumpAndSettle();
      await tester.tap(_k('rate-remembered'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Xong phiên ôn'), findsOneWidget);
    expect(tester.widget<Text>(_k('end-title')).data, 'Hôm nay đã ôn 3 / 3 thẻ');
    await tester.tap(_k('end-quick-20'));
    await tester.pump();
    await tester.tap(_k('end-save'));
    await tester.pumpAndSettle();
    expect(t.api.logCreates.single['activity'], 'CARD_REVIEW');
    expect(t.api.logCreates.single['minutes'], 20);
    expect(visited.last, '/tra-dinh');
  });
}
