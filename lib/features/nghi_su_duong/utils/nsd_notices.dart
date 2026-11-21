import '../../../shared/utils/currency.dart';
import '../../kieu_lau/models/alert.dart';
import '../../kieu_lau/services/kieu_lau_api.dart';
import '../models/overview.dart';
import '../models/project_summary.dart';
import '../models/routine.dart';
import '../services/nghi_su_duong_api.dart';

/// Mức của một dòng cảnh báo — trùng mức `lvl` của cảnh 3D (amber-world `LVL`).
enum NsdNoticeLevel { bad, warn }

/// Một dòng "Cần chú ý" của Nghị Sự Đường. Cùng nguồn cho khung "Cần chú ý" của màn chính và popup Nghị Sự Đường
/// trên cảnh 3D ([buildNsdNotices]).
class NsdNotice {
  const NsdNotice({required this.id, required this.title, this.detail, this.href, this.level = NsdNoticeLevel.warn, this.tasks = const []});

  final String id;
  final String title;
  final String? detail;

  /// Màn mở khi bấm; null = không mở gì (vd âm quỹ — số liệu đã nằm ngay ở khung Tài chính).
  final String? href;
  final NsdNoticeLevel level;

  /// Dòng gộp nhiều việc (vd "N việc nằm im"): bấm mở danh sách các việc này thay vì [href].
  final List<AttentionItem> tasks;

  /// Dạng `push` của cảnh 3D: `{text, lvl}`.
  Map<String, Object?> toWorld() => {'text': detail == null ? title : '$title · $detail', 'lvl': level.name};
}

/// Việc "nằm im" vào Cần chú ý khi đứng yên QUÁ chừng này ngày. Dữ liệu có sẵn ở client là `summary.attention` loại IDLE
/// (backend: việc Đang làm / Chờ duyệt của dự án đang chạy, ≥ 5 ngày kể từ lần đổi trạng thái `statusChangedAt`, kèm số ngày).
const idleNoticeDays = 7;

/// Đường dẫn mở dự án và trang chi tiết đúng việc đó.
String attentionLocation(AttentionItem a) => '/du-an/${a.projectId}?task=${a.taskId}';

/// Loại cảnh báo của GET /api/kieu-lau/notifications thuộc Nghị Sự Đường (LEARN_INACTIVE là của Trà Đình).
const _nsdAlertKinds = {'TASK_DUE', 'BUDGET_EXCEEDED', 'FINANCE_MONTH_MISSING'};

/// href cũ của backend trỏ vào màn đã gộp (`/du-an`, `/finance`) → null: chúng chỉ redirect về chính màn Nghị Sự Đường.
String? _href(String href) => href == '/du-an' || href == '/finance' ? null : href;

/// Gộp cảnh báo, thứ tự: âm quỹ → cảnh báo backend (việc sắp/đã trễ hạn trong 3 ngày theo `prepLeadDays`,
/// vượt ngân sách, chưa mở tháng) → việc quá hạn của dự án (summary.attention, bỏ việc đã có ở trên)
/// → việc nằm im quá [idleNoticeDays] ngày (gộp một dòng, bấm mở danh sách) → routine hôm nay chưa xong (gộp một dòng).
/// Phần nào null (chưa tải / lỗi) thì bỏ qua phần đó.
List<NsdNotice> buildNsdNotices({
  FinanceOverview? finance,
  List<Alert>? alerts,
  List<AttentionItem>? attention,
  List<Routine>? routines,
}) {
  final out = <NsdNotice>[];
  if (finance != null && finance.currentBalance < 0) {
    out.add(NsdNotice(id: 'balance', title: 'Âm quỹ', detail: formatVnd(finance.currentBalance), level: NsdNoticeLevel.bad));
  }
  for (final a in alerts ?? const <Alert>[]) {
    if (!_nsdAlertKinds.contains(a.kind)) continue;
    out.add(
      NsdNotice(
        id: a.id,
        title: a.title,
        detail: a.detail,
        href: _href(a.href),
        level: a.kind == 'BUDGET_EXCEEDED' ? NsdNoticeLevel.bad : NsdNoticeLevel.warn,
      ),
    );
  }
  for (final a in attention ?? const <AttentionItem>[]) {
    if (!a.isOverdue || out.any((n) => n.id == 'task:${a.taskId}')) continue;
    out.add(
      NsdNotice(
        id: 'task:${a.taskId}',
        title: 'Quá hạn: "${a.title}"',
        detail: '${a.projectName} · ${a.days} ngày',
        href: attentionLocation(a),
        level: NsdNoticeLevel.bad,
      ),
    );
  }
  final idle = [for (final a in attention ?? const <AttentionItem>[]) if (!a.isOverdue && a.days > idleNoticeDays) a];
  if (idle.isNotEmpty) {
    out.add(NsdNotice(id: 'idle', title: '${idle.length} việc nằm im', detail: 'quá $idleNoticeDays ngày chưa cập nhật', tasks: idle));
  }
  final pending = [for (final r in routines ?? const <Routine>[]) if (r.dueToday && !r.doneToday) r.name];
  if (pending.isNotEmpty) out.add(NsdNotice(id: 'routines', title: 'Hôm nay chưa xong', detail: pending.join(', ')));
  return out;
}

/// Tải đủ nguồn rồi [buildNsdNotices] — cho nơi không có các provider của màn (cảnh 3D trên màn chủ).
/// Nguồn nào lỗi thì bỏ qua nguồn đó.
Future<List<NsdNotice>> fetchNsdNotices({required KieuLauApi kieuLau, required NghiSuDuongApi nsd}) async {
  Future<T?> safe<T>(Future<T> f) => f.then<T?>((v) => v, onError: (_) => null);
  final (notifications, finance, summary, routines) = await (
    safe(kieuLau.getNotifications()),
    safe(nsd.getFinanceOverview()),
    safe(nsd.getDuAnSummary()),
    safe(nsd.getRoutines()),
  ).wait;
  return buildNsdNotices(
    finance: finance,
    alerts: notifications?.alerts,
    attention: summary?.attention,
    routines: routines,
  );
}
