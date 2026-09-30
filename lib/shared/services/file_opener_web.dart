import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: Blob URL mở ở tab mới — trình duyệt tự hiển thị (PDF, ảnh, text) hoặc
/// tải xuống (loại khác). Gọi ngay sau cú bấm (trong ~5s) để không bị chặn popup.
Future<void> openBytes(Uint8List bytes, {required String filename, String? mimeType}) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mimeType ?? 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final opened = web.window.open(url, '_blank');
  if (opened == null) {
    // Popup bị chặn → tải xuống thay vì im lặng không làm gì.
    (web.document.createElement('a') as web.HTMLAnchorElement)
      ..href = url
      ..download = filename
      ..click();
  }
  // Tab mới cần thời gian đọc blob trước khi thu hồi URL.
  Future<void>.delayed(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
}
