import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trạng thái để HIỂN THỊ của một provider tải dữ liệu.
///
/// Riverpod tự thử lại khi provider lỗi: trong lúc đó state là `AsyncLoading` kèm lỗi, nên `switch` thường sẽ hiện khung
/// chờ mãi. Ở đây: có giá trị (kể cả giá trị cũ khi đang tải lại) → dữ liệu; chưa có giá trị mà đã có lỗi → [AsyncError]
/// ngay (màn hình hiện lỗi + nút Thử lại); còn lại → đang tải.
extension HocTapAsyncView<T> on AsyncValue<T> {
  AsyncValue<T> get settled => hasValue || !hasError ? this : AsyncError<T>(error!, stackTrace ?? StackTrace.empty);
}
