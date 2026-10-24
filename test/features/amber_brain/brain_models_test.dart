import 'package:amber_flutter/features/amber_brain/models/brain_models.dart';
import 'package:amber_flutter/features/amber_brain/providers/brain_status_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> statusJson([Object? logPush]) => {
  'serverEnv': 'DEV',
  'serverHost': 'localhost:3000',
  'ollama': 'up',
  'model': 'amber-gemma4',
  ...?logPush == null ? null : {'logPush': logPush},
};

void main() {
  group('LogPushStatus parsing', () {
    test('missing or malformed logPush is ignored', () {
      expect(BrainStatus.fromJson(statusJson()).logPush, isNull);
      expect(BrainStatus.fromJson(statusJson('bad')).logPush, isNull);
    });

    test(
      'malformed fields use safe defaults and never expose unknown codes',
      () {
        final parsed = BrainStatus.fromJson(
          statusJson({
            'pending': 'many',
            'lastSuccessAt': 42,
            'lastErrorAt': 'not-a-date',
            'lastError': 'https://internal.invalid/path',
          }),
        ).logPush!;

        expect(parsed.pending, 0);
        expect(parsed.lastSuccessAt, isNull);
        expect(parsed.lastErrorAt, isNull);
        expect(parsed.lastError, isNull);
        expect(parsed.shouldWarn, isFalse);
      },
    );

    test('parses ISO timestamps and only recognized short error codes', () {
      final parsed = BrainStatus.fromJson(
        statusJson({
          'pending': 3,
          'lastSuccessAt': '2026-10-24T02:00:00Z',
          'lastErrorAt': '2026-10-24T02:01:00+00:00',
          'lastError': 'auth',
        }),
      ).logPush!;

      expect(parsed.pending, 3);
      expect(parsed.lastSuccessAt, DateTime.utc(2026, 10, 24, 2));
      expect(parsed.lastErrorAt, DateTime.utc(2026, 10, 24, 2, 1));
      expect(parsed.lastError, 'auth');
    });

    test('recognizes each documented error code', () {
      for (final error in ['network', 'auth', 'server', 'unknown']) {
        expect(
          BrainStatus.fromJson(statusJson({'lastError': error}))
              .logPush!
              .lastError,
          error,
        );
      }
    });
  });

  group('log-push warning threshold', () {
    test('pending counts 0 and 4 are quiet; 5 warns', () {
      for (final pending in [0, 4]) {
        expect(
          LogPushStatus.fromJson({'pending': pending}).shouldWarn,
          isFalse,
        );
      }
      expect(LogPushStatus.fromJson({'pending': 5}).shouldWarn, isTrue);
    });

    test('any recognized error warns even with no pending rows', () {
      for (final error in ['network', 'auth', 'server', 'unknown']) {
        expect(
          LogPushStatus.fromJson({'pending': 0, 'lastError': error}).shouldWarn,
          isTrue,
        );
      }
    });

    test('offline connection suppresses an otherwise eligible warning', () {
      final status = BrainStatus.fromJson(statusJson({'pending': 5}));
      expect(
        BrainConnection(
          link: BrainLink.offline,
          status: status,
        ).shouldWarnLogPush,
        isFalse,
      );
      expect(
        BrainConnection(
          link: BrainLink.online,
          status: status,
        ).shouldWarnLogPush,
        isTrue,
      );
    });
  });
}
