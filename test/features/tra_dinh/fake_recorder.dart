import 'dart:typed_data';

import 'package:amber_flutter/features/tra_dinh/services/recording_service.dart';

/// Thay package record — không cần micro. Ghi lại mọi lời gọi để kiểm tra.
class FakeRecorder implements RecordingService {
  RecordingException? startError;
  String? stopResult = '/tmp/tra-dinh-test.webm';
  int startCalls = 0;
  int cancelCalls = 0;
  final deleted = <String>[];

  @override
  String get fileName => 'recording.webm';

  @override
  Future<bool> hasPermission() async => startError == null;

  @override
  Future<void> startRecording() async {
    startCalls++;
    if (startError case final e?) throw e;
  }

  @override
  Future<String?> stopRecording() async => stopResult;

  @override
  Future<void> cancelRecording() async => cancelCalls++;

  @override
  Future<void> deleteFile(String path) async => deleted.add(path);

  @override
  Future<Uint8List> readFile(String path) async => Uint8List(0);

  @override
  Future<void> dispose() async {}
}
