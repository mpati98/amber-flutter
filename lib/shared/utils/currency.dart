/// Giống formatVND bên web (`toLocaleString("vi-VN") + "₫"`): 3058792 → "3.058.792₫".
/// Số tiền trong DB là numeric(14,2) nhưng thực tế luôn là số nguyên VND.
String formatVnd(num amount) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}$buf₫';
}
