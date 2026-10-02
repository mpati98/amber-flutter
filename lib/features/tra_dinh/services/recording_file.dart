// Đọc/xoá bản ghi âm do package record tạo ra. Mobile/desktop: đường dẫn file
// trong thư mục tạm. Web: record trả URL `blob:` (MediaRecorder), không có file.
export 'recording_file_io.dart' if (dart.library.js_interop) 'recording_file_web.dart';
