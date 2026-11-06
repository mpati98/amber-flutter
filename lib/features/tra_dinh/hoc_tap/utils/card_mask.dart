/// Câu ví dụ tách làm ba đoạn quanh cụm tìm thấy: [before] + [match] + [after] = câu gốc.
class MaskedExample {
  const MaskedExample({required this.before, required this.match, required this.after});

  final String before;
  final String match;
  final String after;
}

final _wordChar = RegExp(r'[\p{L}\p{N}_]', unicode: true);

bool _isWordChar(String ch) => _wordChar.hasMatch(ch);

/// Mẫu "thân từ": từ ≤ 3 chữ giữ nguyên; từ dài hơn bỏ 2 chữ cuối rồi `\w*` (looking ← look, forwarded ← forward).
String _stemPattern(String word) => word.length <= 3 ? RegExp.escape(word) : '${RegExp.escape(word.substring(0, word.length - 2))}\\w*';

/// Lần khớp đầu tiên nằm trọn ở ranh giới từ (không dính vào giữa từ khác: "to" không khớp trong "today").
/// Tự kiểm tra ranh giới thay vì lookbehind của RegExp, vì Safari iOS cũ không có lookbehind.
Match? _firstWholeWord(RegExp re, String text) {
  for (final m in re.allMatches(text)) {
    final startOk = m.start == 0 || !_isWordChar(text[m.start - 1]);
    final endOk = m.end == text.length || !_isWordChar(text[m.end]);
    if (startOk && endOk) return m;
  }
  return null;
}

/// Tìm [phrase] trong [example] để che ở mặt trước thẻ và tô đậm ở mặt sau.
///
/// 1. Khớp đúng cụm như đã viết (không phân biệt hoa thường, khoảng trắng bất kỳ giữa các từ).
/// 2. Không có thì khớp theo thân từ: mỗi từ của cụm → thân (xem [_stemPattern]), nối bằng khoảng trắng
///    ("look forward to" khớp "looking forward to").
/// 3. Vẫn không có → null: mặt trước không hiện câu ví dụ.
MaskedExample? maskPhrase(String example, String phrase) {
  final words = phrase.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty || example.isEmpty) return null;
  final exact = RegExp(words.map(RegExp.escape).join(r'\s+'), caseSensitive: false);
  final stem = RegExp(words.map(_stemPattern).join(r'\s+'), caseSensitive: false);
  for (final re in [exact, stem]) {
    final m = _firstWholeWord(re, example);
    if (m != null) return MaskedExample(before: example.substring(0, m.start), match: m.group(0)!, after: example.substring(m.end));
  }
  return null;
}
