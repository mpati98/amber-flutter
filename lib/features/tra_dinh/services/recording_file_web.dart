import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web không ghi ra file — record bỏ qua path, trả URL `blob:` khi dừng.
Future<String> newRecordingPath(String extension) async => '';

Future<Uint8List> readRecording(String blobUrl) async {
  final res = await web.window.fetch(blobUrl.toJS).toDart;
  final buffer = await res.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}

/// Thu hồi URL để trình duyệt giải phóng blob.
Future<void> deleteRecording(String blobUrl) async {
  if (blobUrl.startsWith('blob:')) web.URL.revokeObjectURL(blobUrl);
}
