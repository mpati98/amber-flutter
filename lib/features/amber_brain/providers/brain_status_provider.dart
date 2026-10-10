import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import '../models/brain_models.dart';
import '../services/brain_api.dart';

const brainPollInterval = Duration(seconds: 20);

enum BrainLink { checking, online, offline }

class BrainConnection {
  const BrainConnection({this.link = BrainLink.checking, this.status, this.apiHost = ''});

  final BrainLink link;
  final BrainStatus? status;

  /// Host của amber-v4 mà app đang nối (đã chuẩn hóa) — để so với `status.serverHost`.
  final String apiHost;

  bool get online => link == BrainLink.online;
  bool get offline => link == BrainLink.offline;

  /// Brain nối backend khác với app: ghi nhầm môi trường là rủi ro thật nên khóa nhập.
  bool get mismatch => online && status != null && hostKey(status!.serverHost) != hostKey(apiHost);

  /// Cho phép gửi tin: brain trả lời được VÀ cùng môi trường với app.
  bool get canChat => online && !mismatch;
}

/// "http://localhost:3000" / "localhost:3000" / "127.0.0.1:3000" → "localhost:3000";
/// bỏ cổng mặc định 80/443.
String hostKey(String hostOrUrl) {
  final raw = hostOrUrl.contains('://') ? hostOrUrl : 'x://$hostOrUrl';
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.host.isEmpty) return hostOrUrl.toLowerCase();
  var host = uri.host.toLowerCase();
  if (host == '127.0.0.1' || host == '::1') host = 'localhost';
  final port = uri.hasPort ? uri.port : null;
  final isDefault = port == null || port == 80 || port == 443;
  return isDefault ? host : '$host:$port';
}

/// Gọi GET /v1/status khi tạo và mỗi 20 giây khi app đang hiển thị (tạm dừng khi
/// ẩn/nền, gọi lại ngay khi quay lại).
class BrainStatusNotifier extends Notifier<BrainConnection> with WidgetsBindingObserver {
  Timer? _timer;
  var _disposed = false;

  @override
  BrainConnection build() {
    _disposed = false;
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    final apiHost = hostKey(apiBaseUrl);
    _start();
    return BrainConnection(apiHost: apiHost);
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(brainPollInterval, (_) => refresh());
    Future.microtask(refresh);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> refresh() async {
    try {
      final status = await ref.read(brainApiProvider).status();
      if (_disposed) return;
      state = BrainConnection(link: BrainLink.online, status: status, apiHost: state.apiHost);
    } on Object {
      if (_disposed) return;
      state = BrainConnection(link: BrainLink.offline, apiHost: state.apiHost);
    }
  }
}

final brainStatusProvider = NotifierProvider<BrainStatusNotifier, BrainConnection>(BrainStatusNotifier.new);

/// Lỗi do không nối được brain (không có response)?
bool isUnreachable(Object e) => e is DioException && e.response == null && e.type != DioExceptionType.cancel;
