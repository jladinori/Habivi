import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/domain/services/habit_mood_service.dart';

final moodPercentageProvider = StreamProvider<double>((ref) async* {
  final box = await Hive.openBox<Habito>(HiveBoxNames.habito);

  // Emit current mood percentage immediately.
  yield await HabitMoodService.calculateMoodPercentage();

  await for (final _ in box.watch()) {
    yield await HabitMoodService.calculateMoodPercentage();
  }
});
