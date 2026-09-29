// Mở 1 file đã tải về (bytes) bằng ứng dụng/trình xem của hệ thống. Cần vì
// file đính kèm nằm sau route có withAuth: url_launcher không gửi được Bearer,
// nên phải tải qua Dio (có interceptor) rồi mới mở.
export 'file_opener_io.dart' if (dart.library.js_interop) 'file_opener_web.dart';
