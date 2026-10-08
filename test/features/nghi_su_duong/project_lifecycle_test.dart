import 'dart:async';

import 'package:amber_flutter/features/kieu_lau/models/activity_log_entry.dart';
import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/providers/kieu_lau_provider.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/project_summary.dart';
import 'package:amber_flutter/features/nghi_su_duong/models/task.dart';
import 'package:amber_flutter/features/nghi_su_duong/screens/project_detail_screen.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/finance_api.dart';
import 'package:amber_flutter/features/nghi_su_duong/services/nghi_su_duong_api.dart';
import 'package:amber_flutter/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'detail_test_support.dart';

// Đóng / mở lại / xoá dự án từ menu ở đầu trang chi tiết. API giả.

DioException _badRequest(String code) {
  final req = RequestOptions(path: '/api/projects/p1/close');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: 400, data: {'error': code}),
  );
}

Future<FakeApi> _pump(
  WidgetTester tester, {
  ProjectStatus status = ProjectStatus.active,
  List<Task> tasks = const [],
  double width = 390,
}) async {
  final api = FakeApi(project: mkProject(status: status), tasks: [...tasks]);
  tester.view.physicalSize = Size(width, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/du-an',
    routes: [
      GoRoute(
        path: '/du-an',
        builder: (_, _) => const Scaffold(body: Text('MÀN DỰ ÁN')),
        routes: [GoRoute(path: ':id', builder: (_, s) => ProjectDetailScreen(projectId: s.pathParameters['id']!))],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(offlineDio()),
        nghiSuDuongApiProvider.overrideWithValue(api),
        financeApiProvider.overrideWithValue(FakeFinanceApi()),
        notificationsProvider.overrideWith((ref) async => (alerts: const <Alert>[], recentActivity: const <ActivityLogEntry>[])),
      ],
      child: MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push('/du-an/p1'));
  await tester.pumpAndSettle();
  return api;
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Thao tác dự án'));
  await tester.pumpAndSettle();
}

final _tasks = [
  mkTask('a', 'Việc xong', TaskStatus.done),
  mkTask('b', 'Việc đang làm', TaskStatus.inProgress),
  mkTask('c', 'Việc chờ', TaskStatus.prep),
];

void main() {
  group('menu', () {
    testWidgets('dự án chưa xong: "Đóng dự án" và "Xoá dự án"', (tester) async {
      await _pump(tester);
      await _openMenu(tester);
      expect(find.text('Đóng dự án'), findsOneWidget);
      expect(find.text('Xoá dự án'), findsOneWidget);
      expect(find.text('Mở lại dự án'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dự án đã xong: "Mở lại dự án" và "Xoá dự án"', (tester) async {
      await _pump(tester, status: ProjectStatus.done);
      await _openMenu(tester);
      expect(find.text('Mở lại dự án'), findsOneWidget);
      expect(find.text('Xoá dự án'), findsOneWidget);
      expect(find.text('Đóng dự án'), findsNothing);
    });

    testWidgets('nút menu có nhãn trợ năng', (tester) async {
      await _pump(tester);
      expect(find.byTooltip('Thao tác dự án'), findsOneWidget);
    });
  });

  group('form Sửa dự án', () {
    testWidgets('trạng thái chỉ còn "Đang triển khai" và "Tạm dừng"', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Sửa dự án'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ChoiceChip, 'Đang triển khai'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Tạm dừng'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Đã xong'), findsNothing);
    });

    testWidgets('dự án đang xong: ẩn ô trạng thái, và không gửi status', (tester) async {
      final api = await _pump(tester, status: ProjectStatus.done);
      await tester.tap(find.text('Sửa dự án'));
      await tester.pumpAndSettle();
      expect(find.text('Trạng thái'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Tạm dừng'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Đang triển khai'), findsNothing);
      await tester.enterText(find.widgetWithText(TextField, 'Tên dự án'), 'Tên mới');
      await tester.pump();
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      expect(api.projectPatches.single, {'name': 'Tên mới'});
    });
  });

  group('đóng dự án', () {
    Future<void> openClose(WidgetTester tester) async {
      await _openMenu(tester);
      await tester.tap(find.text('Đóng dự án'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Đóng dự án'), findsOneWidget);
    }

    testWidgets('giải thích, cảnh báo việc chưa xong (không chặn), không autofocus', (tester) async {
      await _pump(tester, tasks: _tasks);
      await openClose(tester);
      expect(find.textContaining('Dự án sẽ chuyển sang Đã xong. Một tài liệu tổng kết'), findsOneWidget);
      expect(find.textContaining('sẽ được lưu vào Tàng Kinh Các.'), findsOneWidget);
      expect(find.text('Còn 2 việc chưa xong.'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Đóng dự án')).onPressed, isNotNull);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));
    });

    testWidgets('xong hết thì không có cảnh báo', (tester) async {
      await _pump(tester, tasks: [mkTask('a', 'Việc xong', TaskStatus.done)]);
      await openClose(tester);
      expect(find.textContaining('việc chưa xong'), findsNothing);
    });

    testWidgets('gửi đúng ghi chú, đóng sheet, báo thành công, dự án chuyển sang Đã xong', (tester) async {
      final api = await _pump(tester, tasks: _tasks);
      await openClose(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Ghi chú tổng kết'), '  Làm tốt.\nRút kinh nghiệm.  ');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Đóng dự án'));
      await tester.pumpAndSettle();
      expect(api.closes, ['Làm tốt.\nRút kinh nghiệm.']);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Đã lưu tổng kết vào Tàng Kinh Các.'), findsOneWidget);
      expect(find.text('Đã xong'), findsWidgets);
    });

    testWidgets('ghi chú trống → không gửi note', (tester) async {
      final api = await _pump(tester);
      await openClose(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Đóng dự án'));
      await tester.pumpAndSettle();
      expect(api.closes, [null]);
    });

    testWidgets('project_already_done → "Dự án đã được đóng trước đó."; sheet vẫn mở', (tester) async {
      final api = await _pump(tester);
      await openClose(tester);
      api.closeError = _badRequest('project_already_done');
      await tester.tap(find.widgetWithText(FilledButton, 'Đóng dự án'));
      await tester.pumpAndSettle();
      expect(find.text('Dự án đã được đóng trước đó.'), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Đóng dự án'), findsOneWidget);
    });

    testWidgets('bấm hai lần chỉ gửi một lần; không tràn ở 390 kể cả khi bàn phím mở', (tester) async {
      final api = await _pump(tester, tasks: _tasks);
      await openClose(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      api.closeGate = Completer();
      await tester.tap(find.byType(FilledButton).last);
      await tester.pump();
      expect(tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed, isNull, reason: 'khoá khi đang gửi');
      await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
      await tester.pump();
      expect(api.closes, hasLength(1));
      api.closeGate!.complete();
      await tester.pumpAndSettle();
      expect(api.closes, hasLength(1));
    });
  });

  group('mở lại dự án', () {
    testWidgets('hộp xác nhận; Huỷ không gọi API; đồng ý → PATCH status ACTIVE và nhãn Đã xong biến mất', (tester) async {
      final api = await _pump(tester, status: ProjectStatus.done);
      expect(find.text('Đã xong'), findsWidgets);
      await _openMenu(tester);
      await tester.tap(find.text('Mở lại dự án'));
      await tester.pumpAndSettle();
      expect(find.text('Mở lại dự án? Tài liệu tổng kết đã lưu vẫn giữ trong Tàng Kinh Các.'), findsOneWidget);
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.projectPatches, isEmpty);

      await _openMenu(tester);
      await tester.tap(find.text('Mở lại dự án'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Mở lại'));
      await tester.pumpAndSettle();
      expect(api.projectPatches.single, {'status': 'ACTIVE'});
      await _openMenu(tester);
      expect(find.text('Đóng dự án'), findsOneWidget, reason: 'đã mở lại → menu quay về "Đóng dự án"');
    });
  });

  group('xoá dự án', () {
    testWidgets('hộp xác nhận ghi rõ tên và hệ quả; Huỷ không xoá', (tester) async {
      final api = await _pump(tester);
      await _openMenu(tester);
      await tester.tap(find.text('Xoá dự án'));
      await tester.pumpAndSettle();
      expect(find.text('Xoá dự án "Sự kiện tháng 11"?'), findsOneWidget);
      expect(
        find.text(
          'Toàn bộ KR, việc và checklist sẽ bị xoá vĩnh viễn. Giao dịch đã gắn vẫn nằm trong sổ thu-chi; tài liệu tổng kết (nếu có) vẫn giữ.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(api.projectDeletes, isEmpty);
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
    });

    testWidgets('"Xoá vĩnh viễn" → gọi API và quay về màn Dự án', (tester) async {
      final api = await _pump(tester);
      await _openMenu(tester);
      await tester.tap(find.text('Xoá dự án'));
      await tester.pumpAndSettle();
      final confirm = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Xoá vĩnh viễn'));
      expect(confirm.style?.foregroundColor?.resolve({}), isNotNull, reason: 'màu lỗi của theme');
      await tester.tap(find.widgetWithText(TextButton, 'Xoá vĩnh viễn'));
      await tester.pumpAndSettle();
      expect(api.projectDeletes, ['p1']);
      expect(find.byType(ProjectDetailScreen), findsNothing);
      expect(find.text('MÀN DỰ ÁN'), findsOneWidget);
    });
  });
}
