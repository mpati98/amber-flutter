import 'package:amber_flutter/features/du_do/world/world_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lệnh gọi trước khi iframe sẵn sàng được giữ lại, gửi đúng thứ tự khi nhận ready', () async {
    final b = WorldBridge();
    final sent = <(String, List<Object?>)>[];
    b.attach((m, a) => sent.add((m, a)));
    b.call('setStat', ['kyNang', 40]);
    b.call('select', ['tradinh']);
    expect(sent, isEmpty);
    b.receive(const WorldReady());
    expect(sent.map((e) => e.$1), ['setStat', 'select']);
    b.call('music.pause');
    expect(sent.last.$1, 'music.pause');
    b.dispose();
  });

  test('sự kiện từ iframe đi ra stream', () async {
    final b = WorldBridge();
    final got = <WorldEvent>[];
    final sub = b.events.listen(got.add);
    b.receive(const WorldSheet(open: true, towerId: 'nghisu'));
    b.receive(const WorldNavigate('/nghi-su-duong'));
    await Future<void>.delayed(Duration.zero);
    expect(got.whereType<WorldSheet>().single.towerId, 'nghisu');
    expect(got.whereType<WorldNavigate>().single.path, '/nghi-su-duong');
    await sub.cancel();
    b.dispose();
  });
}
