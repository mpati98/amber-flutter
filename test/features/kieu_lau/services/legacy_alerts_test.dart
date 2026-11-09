import 'package:amber_flutter/features/kieu_lau/models/alert.dart';
import 'package:amber_flutter/features/kieu_lau/services/kieu_lau_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bỏ cảnh báo Học tập cũ, giữ các loại khác', () {
    const keep = Alert(
      id: 'task:1',
      kind: 'TASK_DUE',
      title: 'Trễ hạn',
      href: '/du-an',
    );
    const learn = Alert(
      id: 'learn:1',
      kind: 'LEARN_INACTIVE',
      title: 'Lâu chưa học',
      href: '/hoc-tap/c1',
    );
    const odd = Alert(
      id: 'x:1',
      kind: 'KIND_LẠ',
      title: 'Lạ',
      href: '/hoc-tap/c2',
    );
    expect(filterLegacyAlerts([keep, learn, odd]).map((a) => a.id), ['task:1']);
  });
}
