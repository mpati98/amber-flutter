import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trang chủ "/" (Dư Đồ / Âm Dương Giới). TẠM: danh sách lối vào để thay các
/// icon trên AppBar Kiều Lâu — cảnh bản đồ thật làm ở bước sau.
class DuDoScreen extends StatelessWidget {
  const DuDoScreen({super.key});

  static const _entries = [
    (path: '/tang-kinh-cac', name: 'Tàng Kinh Các', sub: 'Lưu trữ & tri thức', icon: Icons.account_balance_outlined),
    (path: '/nghi-su-duong', name: 'Nghị Sự Đường', sub: 'Việc chính & thông báo', icon: Icons.work_outline),
    (path: '/kieu-lau', name: 'Kiều Lâu', sub: 'Thông báo & tin tức', icon: Icons.notifications_outlined),
    (path: '/tra-dinh', name: 'Trà Đình', sub: 'Trò chuyện & luyện tập', icon: Icons.emoji_food_beverage_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Âm Dương Giới')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in _entries)
            ListTile(
              leading: Icon(e.icon),
              title: Text(e.name),
              subtitle: Text(e.sub),
              onTap: () => context.push(e.path),
            ),
        ],
      ),
    );
  }
}
