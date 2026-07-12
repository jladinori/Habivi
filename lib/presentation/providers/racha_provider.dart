import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/repositories/racha_repository.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/domain/services/racha_service.dart';

/// Provider para acceder al repositorio de rachas
final rachaRepositoryProvider = Provider<RachaRepository>((ref) {
  return RachaRepository();
});

/// Provider que inicializa las rachas por defecto si no existen
final initializeRachasProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  await repo.initializeDefaults();
});

/// Provider para obtener la racha diaria
final dailyRachaProvider = FutureProvider<Racha?>((ref) async {
  // Primero inicializar
  await ref.watch(initializeRachasProvider.future);
  
  final repo = ref.watch(rachaRepositoryProvider);
  return repo.readDailyRacha();
});

/// Provider para obtener la racha semanal
final weeklyRachaProvider = FutureProvider<Racha?>((ref) async {
  // Primero inicializar
  await ref.watch(initializeRachasProvider.future);
  
  final repo = ref.watch(rachaRepositoryProvider);
  return repo.readWeeklyRacha();
});

/// Provider para obtener todas las rachas
final allRachasProvider = FutureProvider<Map<dynamic, Racha>>((ref) async {
  // Primero inicializar
  await ref.watch(initializeRachasProvider.future);
  
  final repo = ref.watch(rachaRepositoryProvider);
  return repo.readAll();
});

/// Provider para actualizar la racha diaria cuando cambian los hábitos
final updateDailyRachaProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  
  final currentRacha = await repo.readDailyRacha();
  if (currentRacha == null) return;
  
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedDailyHabitToday(habits.values.toList());
  
  final updatedRacha = RachaService.updateDailyRacha(
    currentRacha: currentRacha,
    completedDailyHabitToday: hasCompleted,
  );
  
  await repo.update(updatedRacha);
  ref.refresh(dailyRachaProvider);
});

/// Provider para actualizar la racha semanal cuando cambian los hábitos
final updateWeeklyRachaProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  
  final currentRacha = await repo.readWeeklyRacha();
  if (currentRacha == null) return;
  
  final habits = await habitRepo.readAll();
  final hasCompleted = RachaService.hasCompletedWeeklyHabitThisWeek(habits.values.toList());
  
  final updatedRacha = RachaService.updateWeeklyRacha(
    currentRacha: currentRacha,
    completedWeeklyHabitThisWeek: hasCompleted,
  );
  
  await repo.update(updatedRacha);
  ref.refresh(weeklyRachaProvider);
});
