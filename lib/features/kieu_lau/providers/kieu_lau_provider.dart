import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feed_article.dart';
import '../models/feed_source.dart';
import '../services/kieu_lau_api.dart';

// autoDispose: rời màn là bỏ cache, quay lại thì tải mới — tránh hiện dữ liệu
// cũ sau khi thêm/xoá nguồn. Trong màn thì invalidate sau mỗi thao tác ghi.

final notificationsProvider = FutureProvider.autoDispose<KieuLauNotifications>(
  (ref) => ref.watch(kieuLauApiProvider).getNotifications(),
);

final feedArticlesProvider = FutureProvider.autoDispose<List<FeedArticle>>(
  (ref) => ref.watch(kieuLauApiProvider).getFeedArticles(),
);

final feedSourcesProvider = FutureProvider.autoDispose<List<FeedSource>>(
  (ref) => ref.watch(kieuLauApiProvider).getFeedSources(),
);
