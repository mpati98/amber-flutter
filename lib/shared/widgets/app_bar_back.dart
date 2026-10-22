import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quay lại: pop nếu còn trang để pop, không thì [GoRouter.go] tới [fallback] (mặc định '/' = Âm Dương Giới).
///
/// Flutter chỉ tự thêm mũi tên quay lại khi Navigator còn trang bên dưới. Trong bản web/PWA đã cài, mở lại app ở một đường dẫn
/// (vd /tra-dinh) hay `context.go(...)` (đổi tab, xoá query) đều thay cả stack nên màn đó thành trang gốc và mất mũi tên —
/// không còn đường về. Không có GoRouter trong cây (một số test) thì rơi về `Navigator.maybePop`.
void goBackOr(BuildContext context, [String fallback = '/']) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    Navigator.maybeOf(context)?.maybePop();
  } else if (router.canPop()) {
    router.pop();
  } else {
    router.go(fallback);
  }
}

/// `AppBar.leading` dùng chung cho mọi màn có AppBar: luôn có nút quay lại. [fallback] là trang cha khi không pop được.
class AppBarBack extends StatelessWidget {
  const AppBarBack({super.key, this.fallback = '/'});

  final String fallback;

  @override
  Widget build(BuildContext context) => BackButton(onPressed: () => goBackOr(context, fallback));
}
