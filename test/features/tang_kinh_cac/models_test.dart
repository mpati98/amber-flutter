import 'package:amber_flutter/features/tang_kinh_cac/models/db_timestamp.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/document.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/highlight.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/publication.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/reading_goal.dart';
import 'package:amber_flutter/features/tang_kinh_cac/models/topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timestamp không múi giờ của backend được hiểu là UTC', () {
    final t = parseDbTimestamp('2026-09-20 11:01:44.321');
    expect(t.isUtc, isTrue);
    expect(t, DateTime.utc(2026, 9, 20, 11, 1, 44, 321));
    expect(parseDbTimestamp('2026-09-20T11:01:44.321Z'), t);
  });

  // Response thật của GET /documents (curl 2026-09-29), content rút gọn.
  test('Document từ response thật', () {
    final d = Document.fromJson({
      'id': 'cmu9phypt000004l3iqfn6hlw',
      'title': 'Ubuntu cmd',
      'type': 'TEXT',
      'content': 'Chạy winboat: xfreerdp3 /v:127',
      'attachmentUrl': null,
      'tags': <dynamic>[],
      'pinned': false,
      'sourceUrl': null,
      'topicId': null,
      'createdAt': '2026-09-20 11:01:44.321',
      'updatedAt': '2026-09-20 11:01:44.321',
      'topic': null,
    });
    expect(d.type, DocumentType.text);
    expect(d.type.hasTextContent, isTrue);
    expect(d.topic, isNull);
    expect(d.updatedAt, DateTime.utc(2026, 9, 20, 11, 1, 44, 321));
  });

  test('Document kèm topic, type lạ không làm vỡ', () {
    final d = Document.fromJson({
      'id': 'x', 'title': 't', 'type': 'VIDEO', 'content': null, 'attachmentUrl': null,
      'tags': ['a'], 'pinned': true, 'sourceUrl': null, 'topicId': 'tp',
      'createdAt': '2026-01-01 00:00:00', 'updatedAt': '2026-01-01 00:00:00',
      'topic': {'id': 'tp', 'name': 'Kiều Lâu', 'description': null},
    });
    expect(d.type, DocumentType.unknown);
    expect(d.topic!.name, 'Kiều Lâu');
    expect(d.topic!.documentCount, isNull);
  });

  // Response thật của GET /reading-goals/2026 (curl 2026-09-29).
  test('ReadingGoal từ response thật', () {
    final g = ReadingGoal.fromJson(
        {'year': 2026, 'targetBooks': null, 'targetPages': null, 'note': null, 'booksRead': 0, 'pagesRead': 0});
    expect(g.percent, 0);
    expect(ReadingGoal.fromJson({'year': 2026, 'targetBooks': 3, 'booksRead': 5, 'pagesRead': 0}).percent, 100);
  });

  // Chưa có publication/highlight/topic trong DB — shape dựng từ schema Drizzle.
  test('Publication đủ field theo schema', () {
    final p = Publication.fromJson({
      'id': 'p1', 'title': 'Dune', 'author': 'Frank Herbert', 'isbn': null,
      'coverUrl': '/api/tang-kinh-cac/blob/tang-kinh-cac/1-dune.jpg', 'format': 'EBOOK', 'status': 'READING',
      'rating': null, 'currentPage': 120, 'totalPages': 600, 'tags': <dynamic>[], 'url': null,
      'review': null, 'notes': 'ghi chú nhanh', 'dateAdded': '2026-09-01 08:00:00',
      'dateStarted': '2026-09-02 08:00:00.5', 'dateFinished': null,
    });
    expect(p.format, PublicationFormat.ebook);
    expect(p.status, PublicationStatus.reading);
    expect(p.notes, 'ghi chú nhanh');
    expect(p.dateStarted, DateTime.utc(2026, 9, 2, 8, 0, 0, 500));
    expect(p.dateFinished, isNull);
  });

  test('highlights/random kèm publication {title, author, coverUrl}', () {
    final r = ResurfacedHighlight.fromJson({
      'id': 'h1', 'publicationId': 'p1', 'quote': 'Fear is the mind-killer.', 'page': 12, 'note': null,
      'createdAt': '2026-09-03 10:00:00',
      'publication': {'title': 'Dune', 'author': 'Frank Herbert', 'coverUrl': null},
    });
    expect(r.highlight.page, 12);
    expect(r.source!.author, 'Frank Herbert');
  });

  test('Topic từ GET /topics có _count', () {
    final t = Topic.fromJson({'id': 't', 'name': 'n', 'description': null, '_count': {'documents': 4}});
    expect(t.documentCount, 4);
  });
}
