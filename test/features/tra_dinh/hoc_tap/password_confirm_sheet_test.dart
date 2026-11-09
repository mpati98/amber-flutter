import 'dart:async';

import 'package:amber_flutter/features/tra_dinh/hoc_tap/widgets/password_confirm_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _err(int status, Object data) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status, data: data),
  );
}

class _Host extends StatelessWidget {
  const _Host({required this.onConfirm, required this.onResult});

  final Future<void> Function(String) onConfirm;
  final void Function(bool) onResult;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.dark(),
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          key: const ValueKey('open'),
          onPressed: () async => onResult(
            await showPasswordConfirmSheet(
              context,
              title: 'Xoá khóa này?',
              subtitle: 'Khóa A',
              bullets: const ['Một', 'Hai', 'Ba'],
              actionLabel: 'Xoá khóa',
              onConfirm: onConfirm,
            ),
          ),
          child: const Text('mở'),
        ),
      ),
    ),
  );
}

Future<void> _open(
  WidgetTester tester,
  Future<void> Function(String) onConfirm, {
  void Function(bool)? onResult,
}) async {
  await tester.pumpWidget(
    _Host(onConfirm: onConfirm, onResult: onResult ?? (_) {}),
  );
  await tester.tap(find.byKey(const ValueKey('open')));
  await tester.pumpAndSettle();
}

FilledButton _submit(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const ValueKey('pw-submit')));

void main() {
  group('PasswordConfirmSheet', () {
    testWidgets('hiện tiêu đề, tên khóa, các gạch đầu dòng, nhãn và hai nút', (
      tester,
    ) async {
      await _open(tester, (_) async {});
      expect(find.text('Xoá khóa này?'), findsOneWidget);
      expect(find.text('Khóa A'), findsOneWidget);
      for (final b in ['Một', 'Hai', 'Ba']) {
        expect(find.text(b), findsOneWidget);
      }
      expect(find.text('Nhập mật khẩu để xoá'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget, reason: 'placeholder');
      expect(find.text('Huỷ'), findsOneWidget);
      expect(find.text('Xoá khóa'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('pw-field')))
            .obscureText,
        isTrue,
      );
      final cancel = tester.getSize(find.byKey(const ValueKey('pw-cancel'))),
          submit = tester.getSize(find.byKey(const ValueKey('pw-submit')));
      expect(cancel.height, greaterThanOrEqualTo(52));
      expect(submit.height, greaterThanOrEqualTo(52));
      expect(cancel.width, submit.width, reason: 'hai nút cùng rộng');
      expect(
        tester.getSize(find.byKey(const ValueKey('pw-field'))).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('nút Xoá bị vô hiệu khi ô trống, bật khi có chữ', (
      tester,
    ) async {
      await _open(tester, (_) async {});
      expect(_submit(tester).onPressed, isNull);
      await tester.enterText(find.byKey(const ValueKey('pw-field')), 'abc');
      await tester.pump();
      expect(_submit(tester).onPressed, isNotNull);
    });

    testWidgets(
      'đang gửi: nút vô hiệu và hiện vòng chờ; thành công thì đóng sheet và trả true',
      (tester) async {
        final gate = Completer<void>();
        final sent = <String>[];
        bool? result;
        await _open(tester, (p) async {
          sent.add(p);
          await gate.future;
        }, onResult: (r) => result = r);
        await tester.enterText(
          find.byKey(const ValueKey('pw-field')),
          'bí-mật',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pump();
        expect(sent, ['bí-mật']);
        expect(_submit(tester).onPressed, isNull);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        gate.complete();
        await tester.pumpAndSettle();
        expect(result, isTrue);
        expect(
          find.text('Xoá khóa này?'),
          findsNothing,
          reason: 'sheet đã đóng',
        );
      },
    );

    testWidgets(
      '403 wrong_password: giữ sheet, báo lỗi dưới ô, xoá ô nhập, nút vô hiệu lại cho tới khi gõ mới',
      (tester) async {
        await _open(
          tester,
          (_) async => throw _err(403, {'error': 'wrong_password'}),
        );
        await tester.enterText(find.byKey(const ValueKey('pw-field')), 'sai');
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Xoá khóa này?'), findsOneWidget);
        expect(find.text('Mật khẩu chưa đúng'), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('pw-field')))
              .controller!
              .text,
          isEmpty,
        );
        expect(_submit(tester).onPressed, isNull, reason: 'ô trống');
        await tester.enterText(
          find.byKey(const ValueKey('pw-field')),
          'thử lại',
        );
        await tester.pump();
        expect(_submit(tester).onPressed, isNotNull);
      },
    );

    testWidgets(
      '429: báo thời gian chờ làm tròn lên và vô hiệu nút dù gõ tiếp',
      (tester) async {
        await _open(
          tester,
          (_) async => throw _err(429, {
            'error': 'password_locked',
            'retryAfterSeconds': 125,
          }),
        );
        await tester.enterText(find.byKey(const ValueKey('pw-field')), 'sai');
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pumpAndSettle();
        expect(
          find.text('Nhập sai nhiều lần. Thử lại sau 3 phút.'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const ValueKey('pw-field')),
          'đúng rồi',
        );
        await tester.pump();
        expect(_submit(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'lỗi khác: thông báo chung, giữ sheet và giữ ô nhập (không mất dữ liệu)',
      (tester) async {
        await _open(tester, (_) async => throw _err(500, 'boom'));
        await tester.enterText(
          find.byKey(const ValueKey('pw-field')),
          'giữ-nguyên',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('pw-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Có lỗi, thử lại'), findsOneWidget);
        expect(find.text('Xoá khóa này?'), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('pw-field')))
              .controller!
              .text,
          'giữ-nguyên',
        );
        expect(_submit(tester).onPressed, isNotNull);
      },
    );

    testWidgets('Huỷ đóng sheet và trả false, không gọi onConfirm', (
      tester,
    ) async {
      var calls = 0;
      bool? result;
      await _open(tester, (_) async => calls++, onResult: (r) => result = r);
      await tester.tap(find.byKey(const ValueKey('pw-cancel')));
      await tester.pumpAndSettle();
      expect((result, calls), (false, 0));
    });
  });
}
