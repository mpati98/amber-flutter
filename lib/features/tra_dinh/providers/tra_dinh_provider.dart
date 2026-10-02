import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/practice_session.dart';
import '../models/skill_score.dart';
import '../services/tra_dinh_api.dart';

final skillScoresProvider = FutureProvider.autoDispose<List<SkillScore>>(
  (ref) => ref.watch(traDinhApiProvider).getSkills(),
);

final practiceSessionsProvider = FutureProvider.autoDispose<List<PracticeSession>>(
  (ref) => ref.watch(traDinhApiProvider).getSessions(),
);
