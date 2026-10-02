import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import 'recording_file.dart';

/// Lỗi ghi âm có thông điệp hiển thị được cho người dùng.
class RecordingException implements Exception {
  const RecordingException(this.message);

  final String message;

  @override
  String toString() => 'RecordingException: $message';
}

/// Định dạng ghi + đuôi file tương ứng. Đuôi quan trọng: Groq Whisper đoán định
/// dạng theo tên file (web cũ luôn đặt "recording.webm" kể cả khi Safari ghi mp4).
typedef _Format = ({AudioEncoder encoder, String extension});

/// Bọc package record: xin quyền, ghi ra file tạm (web: blob), trả đường dẫn.
class RecordingService {
  RecordingService([AudioRecorder? recorder]) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  _Format? _format;

  // Web: opus/webm (Chrome, Firefox), Safari không ghi được webm → aac/mp4.
  // Mobile: aac/m4a có sẵn trên cả Android lẫn iOS. wav là phương án cuối.
  static const List<_Format> _candidates = kIsWeb
      ? [
          (encoder: AudioEncoder.opus, extension: 'webm'),
          (encoder: AudioEncoder.aacLc, extension: 'm4a'),
          (encoder: AudioEncoder.wav, extension: 'wav'),
        ]
      : [(encoder: AudioEncoder.aacLc, extension: 'm4a'), (encoder: AudioEncoder.wav, extension: 'wav')];

  /// Tên file gửi lên transcribe, đuôi đúng với định dạng của lần ghi gần nhất.
  String get fileName => 'recording.${_format?.extension ?? 'webm'}';

  /// Xin quyền micro nếu chưa có (hiện hộp thoại hệ thống / trình duyệt).
  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Ném [RecordingException] nếu bị từ chối quyền hoặc không ghi được.
  Future<void> startRecording() async {
    if (!await hasPermission()) {
      throw const RecordingException('Chưa có quyền dùng micro — hãy cho phép trong cài đặt rồi thử lại.');
    }
    try {
      final format = await _pickFormat();
      _format = format;
      await _recorder.start(RecordConfig(encoder: format.encoder), path: await newRecordingPath(format.extension));
    } on RecordingException {
      rethrow;
    } catch (e) {
      throw RecordingException('Không bắt đầu ghi âm được ($e).');
    }
  }

  /// Đường dẫn bản ghi (web: URL blob), null nếu chưa ghi gì hoặc lỗi.
  Future<String?> stopRecording() async {
    try {
      return await _recorder.stop();
    } catch (_) {
      return null;
    }
  }

  /// Huỷ lần ghi đang chạy và bỏ bản ghi (vd rời màn hình giữa chừng).
  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } catch (_) {
      // Đang không ghi — không có gì để huỷ.
    }
  }

  Future<Uint8List> readFile(String path) => readRecording(path);

  /// Xoá file tạm / thu hồi blob. Không ném lỗi — dọn dẹp là best-effort.
  Future<void> deleteFile(String path) async {
    try {
      await deleteRecording(path);
    } catch (_) {}
  }

  Future<void> dispose() => _recorder.dispose();

  Future<_Format> _pickFormat() async {
    for (final f in _candidates) {
      if (await _recorder.isEncoderSupported(f.encoder)) return f;
    }
    throw const RecordingException('Thiết bị không hỗ trợ định dạng ghi âm nào.');
  }
}

final recordingServiceProvider = Provider.autoDispose<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(service.dispose);
  return service;
});
