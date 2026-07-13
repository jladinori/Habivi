import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/racha_repository.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/domain/services/racha_service.dart';

final rachaRepositoryProvider = Provider<RachaRepository>((ref) {
  return RachaRepository();
});

final initializeRachasProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  await repo.initializeDefaults();
});

final habitsChangeListener = StreamProvider<int>((ref) async* {
  final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
  yield 0;
  await for (final _ in box.watch()) {
    yield DateTime.now().millisecondsSinceEpoch;
  }
});

final dailyRachaProvider = FutureProvider<Racha?>((ref) async {
  await ref.watch(initializeRachasProvider.future);
  ref.watch(habitsChangeListener);
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final currentRacha = await repo.readDailyRacha();
  if (currentRacha == null) return null;
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedDailyHabitToday(habits.values.toList());
  final updatedRacha = RachaService.updateDailyRacha(currentRacha: currentRacha, completedDailyHabitToday: hasCompleted);
  await repo.update(updatedRacha);
  return updatedRacha;
});

final weeklyRachaProvider = FutureProvider<Racha?>((ref) async {
  await ref.watch(initializeRachasProvider.future);
  ref.watch(habitsChangeListener);
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final currentRacha = await repo.readWeeklyRacha();
  if (currentRacha == null) return null;
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedWeeklyHabitThisWeek(habits.values.toList());
  final updatedRacha = RachaService.updateWeeklyRacha(currentRacha: currentRacha, completedWeeklyHabitThisWeek: hasCompleted);
  await repo.update(updatedRacha);
  return updatedRacha;
});

final allRachasProvider = FutureProvider<Map<dynamic, Racha>>((ref) async {
  await ref.watch(initializeRachasProvider.future);
  final repo = ref.watch(rachaRepositoryProvider);
  return repo.readAll();
});

final updateDailyRachaProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final currentRacha = await repo.readDailyRacha();
  if (currentRacha == null) return;
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedDailyHabitToday(habits.values.toList());
  final updatedRacha = RachaService.updateDailyRacha(currentRacha: currentRacha, completedDailyHabitToday: hasCompleted);
  await repo.update(updatedRacha);
  // ignore: unused_result
  ref.refresh(dailyRachaProvider);
});

final updateWeeklyRachaProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final currentRacha = await repo.readWeeklyRacha();
  if (currentRacha == null) return;
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedWeeklyHabitThisWeek(habits.values.toList());
  final updatedRacha = RachaService.updateWeeklyRacha(currentRacha: currentRacha, completedWeeklyHabitThisWeek: hasCompleted);
  await repo.update(updatedRacha);
  // ignore: unused_result
  ref.refresh(weeklyRachaProvider);
});
