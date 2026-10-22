/// Giống formatVND bên web (`toLocaleString("vi-VN") + "₫"`): 3058792 → "3.058.792₫".
/// Số tiền trong DB là numeric(14,2) nhưng thực tế luôn là số nguyên VND.
String formatVnd(num amount) => _group(amount, '.');

/// English chat messages: comma separators, 3058792 → "3,058,792₫".
String formatVndEn(num amount) => _group(amount, ',');

String _group(num amount, String sep) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(sep);
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buf₫';
}
