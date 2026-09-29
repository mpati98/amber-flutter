import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document.dart';
import '../services/document_api.dart';

/// Tham số = filter loại (null = tất cả) — cùng pattern với publicationsProvider.
final documentsProvider = FutureProvider.autoDispose.family<List<Document>, DocumentType?>(
  (ref, type) => ref.watch(documentApiProvider).getDocuments(type: type),
);
