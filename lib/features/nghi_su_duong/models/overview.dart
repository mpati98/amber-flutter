// Response các endpoint overview mà trang chính Nghị Sự Đường và màn Dự án dùng.
// Chỉ parse field mà UI dùng; field API trả thêm (balanceTrend,
// categoryBreakdown...) chưa có UI nào hiển thị.

class ActiveProject {
  const ActiveProject({
    required this.id,
    required this.name,
    this.color,
    required this.totalTasks,
    required this.doneTasks,
    required this.progressPct,
  });

  factory ActiveProject.fromJson(Map<String, dynamic> json) => ActiveProject(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String?,
        totalTasks: json['totalTasks'] as int,
        doneTasks: json['doneTasks'] as int,
        progressPct: json['progressPct'] as int,
      );

  final String id;
  final String name;
  final String? color;
  final int totalTasks;
  final int doneTasks;

  /// round(done / total × 100), 0 nếu chưa có task.
  final int progressPct;
}

class UpcomingProject {
  const UpcomingProject({required this.id, required this.name, required this.startDate, this.color});

  factory UpcomingProject.fromJson(Map<String, dynamic> json) => UpcomingProject(
        id: json['id'] as String,
        name: json['name'] as String,
        startDate: json['startDate'] as String,
        color: json['color'] as String?,
      );

  final String id;
  final String name;

  /// "YYYY-MM-DD", luôn sau hôm nay (backend đã lọc).
  final String startDate;
  final String? color;
}

/// GET /api/du-an/overview — chỉ project STANDARD.
class DuAnOverview {
  const DuAnOverview({
    required this.year,
    required this.activeProjects,
    required this.completedThisYear,
    required this.upcomingProjects,
  });

  factory DuAnOverview.fromJson(Map<String, dynamic> json) => DuAnOverview(
        year: json['year'] as int,
        activeProjects: [
          for (final p in json['activeProjects'] as List<dynamic>) ActiveProject.fromJson(p as Map<String, dynamic>),
        ],
        completedThisYear: json['completedThisYear'] as int,
        upcomingProjects: [
          for (final p in json['upcomingProjects'] as List<dynamic>) UpcomingProject.fromJson(p as Map<String, dynamic>),
        ],
      );

  final int year;
  final List<ActiveProject> activeProjects;

  /// Số project STANDARD lưu trữ trong năm. Hiện UI chưa có chỗ lưu trữ dự án
  /// nên thực tế luôn 0.
  final int completedThisYear;

  /// Tối đa 5, sớm nhất trước. `upcomingProject` (số ít) của API = phần tử đầu.
  final List<UpcomingProject> upcomingProjects;

  /// "TB hoàn thành" — trung bình progressPct các dự án đang chạy.
  int get averageProgress => activeProjects.isEmpty
      ? 0
      : (activeProjects.fold<int>(0, (s, p) => s + p.progressPct) / activeProjects.length).round();
}

/// GET /api/finance/overview (năm).
class FinanceOverview {
  const FinanceOverview({
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpense,
    this.activeProjectId,
    this.activeProjectName,
  });

  factory FinanceOverview.fromJson(Map<String, dynamic> json) => FinanceOverview(
        currentBalance: json['currentBalance'] as num,
        totalIncome: json['totalIncome'] as num,
        totalExpense: json['totalExpense'] as num,
        activeProjectId: json['activeProjectId'] as String?,
        activeProjectName: json['activeProjectName'] as String?,
      );

  /// Tổng số dư hiện tại của mọi ví chưa lưu trữ.
  final num currentBalance;

  /// Thu/chi cả năm (chỉ giao dịch thuộc các tháng tài chính của năm đó).
  final num totalIncome;
  final num totalExpense;
  final String? activeProjectId;
  final String? activeProjectName;
}
