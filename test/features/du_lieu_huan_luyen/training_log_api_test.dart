import 'package:amber_flutter/features/du_lieu_huan_luyen/models/training_log.dart';
import 'package:amber_flutter/features/du_lieu_huan_luyen/services/training_log_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route filter is sent with existing filters and paging query', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'items': <dynamic>[], 'nextCursor': null},
              ),
            );
          },
        ),
      );

    await TrainingLogApi(dio).list(
      agent: 'chat',
      outcome: LogOutcome.corrected,
      route: TrainingRoute.cloud,
      cursor: 'next',
      limit: 12,
    );

    expect(requests.single.path, '/api/brain-logs');
    expect(requests.single.queryParameters, {
      'agent': 'chat',
      'outcome': 'corrected',
      'route': 'CLOUD',
      'cursor': 'next',
      'limit': 12,
    });
  });

  test('saving and clearing correction PATCH correctedOutput including explicit null', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(Response(requestOptions: options, statusCode: 200));
          },
        ),
      );
    final api = TrainingLogApi(dio);

    await api.setCorrection('log-id', {'action': 'chitchat', 'reply': 'Hello'});
    await api.setCorrection('log-id', null);

    expect(requests.map((request) => request.method), ['PATCH', 'PATCH']);
    expect(requests.map((request) => request.path), [
      '/api/brain-logs/log-id',
      '/api/brain-logs/log-id',
    ]);
    expect(requests[0].data, {
      'correctedOutput': {'action': 'chitchat', 'reply': 'Hello'},
    });
    expect(requests[1].data, {'correctedOutput': null});
  });
}
