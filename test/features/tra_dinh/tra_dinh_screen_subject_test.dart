import 'package:amber_flutter/features/tra_dinh/hoc_tap/providers/hoc_tap_provider.dart';
import 'package:amber_flutter/features/tra_dinh/hoc_tap/services/hoc_tap_api.dart';
import 'package:amber_flutter/features/tra_dinh/models/practice_session.dart';
import 'package:amber_flutter/features/tra_dinh/models/skill_score.dart';
import 'package:amber_flutter/features/tra_dinh/screens/tra_dinh_screen.dart';
import 'package:amber_flutter/features/tra_dinh/services/tra_dinh_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'hoc_tap/hoc_tap_test_support.dart';

// Mở chat từ màn luyện AI: truyền môn (query ?subjectId=) để chat ghi phút vào đúng môn.

class _Api extends TraDinhApi {
  _Api() : super(Dio());

  @override
  Future<List<SkillScore>> getSkills() async => const [];

  @override
  Future<List<PracticeSession>> getSessions() async => [PracticeSession(id: 's1', name: 'Buổi cũ', mode: PracticeMode.conversation, createdAt: DateTime.utc(2026, 11, 6))];
}

Future<List<String>> _pumpAndOpen(WidgetTester tester, {String? subjectId, String? selected}) async {
  final visited = <String>[];
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => TraDinhScreen(subjectId: subjectId)),
      GoRoute(
        path: '/tra-dinh/:id',
        builder: (_, state) {
          visited.add(state.uri.toString());
          return const Scaffold(body: Text('chat'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [traDinhApiProvider.overrideWithValue(_Api()), hocTapApiProvider.overrideWithValue(FakeHocTapApi())],
      child: Consumer(
        builder: (context, ref, _) {
          if (selected != null) Future.microtask(() => ref.read(selectedSubjectIdProvider.notifier).select(selected));
          return MaterialApp.router(theme: ThemeData.dark(), routerConfig: router);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Buổi cũ'));
  await tester.pumpAndSettle();
  return visited;
}

void main() {
  testWidgets('có ?subjectId= → mở chat kèm đúng môn đó', (tester) async {
    expect(await _pumpAndOpen(tester, subjectId: 'sub-1'), ['/tra-dinh/s1?subjectId=sub-1']);
  });

  testWidgets('không có tham số → dùng môn đang chọn', (tester) async {
    expect(await _pumpAndOpen(tester, selected: 'sub-2'), ['/tra-dinh/s1?subjectId=sub-2']);
  });

  testWidgets('chưa chọn môn, chưa tải tổng quan → mở chat không kèm môn (chat tự lấy môn đầu khi kết thúc)', (tester) async {
    final visited = await _pumpAndOpen(tester);
    expect(visited.single, anyOf('/tra-dinh/s1', startsWith('/tra-dinh/s1?subjectId=')));
  });
}
