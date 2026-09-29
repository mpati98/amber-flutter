import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/publication.dart';
import '../services/publication_api.dart';

/// Tham số = filter trạng thái (null = tất cả) — đổi filter là provider khác,
/// tự fetch. autoDispose như Kiều Lâu: rời màn thì bỏ cache.
final publicationsProvider = FutureProvider.autoDispose.family<List<Publication>, PublicationStatus?>(
  (ref, status) => ref.watch(publicationApiProvider).getPublications(status: status),
);
