/// Cột numeric(14,2) — Postgres trả chuỗi, định dạng không cố định: "118792.00"
/// ở bảng chính nhưng "2940000" khi nằm trong quan hệ lồng. Tính toán server
/// (summary/overview) thì trả số. Nhận cả hai.
double parseMoney(Object? raw) => switch (raw) {
      num n => n.toDouble(),
      String s => double.parse(s),
      _ => throw FormatException('Không đọc được số tiền: $raw'),
    };
