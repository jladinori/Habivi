import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/domain/services/habit_mood_service.dart';

final moodPercentageProvider = FutureProvider<double>((ref) async {
  return await HabitMoodService.calculateMoodPercentage();
});
