import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mở link khóa học bằng trình duyệt; link hỏng / không mở được thì báo bằng SnackBar.
Future<void> openCourseLink(BuildContext context, String? url) async {
  final uri = url == null ? null : Uri.tryParse(url);
  final ok = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không mở được link khóa học')));
  }
}
