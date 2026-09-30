import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Android/iOS/desktop: ghi vào thư mục tạm rồi mở bằng app mặc định.
Future<void> openBytes(Uint8List bytes, {required String filename, String? mimeType}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: mimeType);
  if (result.type != ResultType.done) {
    throw FileSystemException('Không mở được tệp: ${result.message}', file.path);
  }
}
