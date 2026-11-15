// Âm Dương Giới 3D (repo amber-world, build vào web/world/) nhúng bằng iframe — chỉ có trên web.
// Nền tảng khác dùng bản stub: worldSupported() = false → màn chủ giữ lưới 2D.
export 'world_view_stub.dart' if (dart.library.js_interop) 'world_view_web.dart';
