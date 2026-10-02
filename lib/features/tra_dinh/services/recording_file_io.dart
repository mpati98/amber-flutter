import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Đường dẫn file tạm cho 1 lần ghi, đuôi theo định dạng ([extension] không có dấu chấm).
Future<String> newRecordingPath(String extension) async {
  final dir = await getTemporaryDirectory();
  return '${dir.path}/tra-dinh-${DateTime.now().millisecondsSinceEpoch}.$extension';
}

Future<Uint8List> readRecording(String path) => File(path).readAsBytes();

/// Không lỗi nếu file đã không còn.
Future<void> deleteRecording(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}
