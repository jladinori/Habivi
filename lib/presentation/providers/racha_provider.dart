import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/domain/services/racha_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/racha_repository.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/presentation/providers/dev_mode_provider.dart';

/// Provider para acceder al repositorio de rachas
final rachaRepositoryProvider = Provider<RachaRepository>((ref) {
  return RachaRepository();
});

/// Provider que inicializa las rachas por defecto si no existen
final initializeRachasProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(rachaRepositoryProvider);
  await repo.initializeDefaults();
});

/// Provider que observa cambios en hábitos y actualiza rachas
final habitsChangeListener = StreamProvider<int>((ref) async* {
  final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
  
  yield 0; // Emitir valor inicial
  
  // Escuchar cambios en la caja
  await for (final _ in box.watch()) {
    yield DateTime.now().millisecondsSinceEpoch;
  }
});

/// Provider para obtener la racha diaria
final dailyRachaProvider = FutureProvider<Racha?>((ref) async {
  await ref.watch(initializeRachasProvider.future);
  ref.watch(timeOffsetProvider); // recalcula al avanzar el reloj
  ref.watch(habitsChangeListener); // recalcula al cambiar hábitos

  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final current = await repo.readDailyRacha();
  if (current == null) return null;

  final habits = (await habitRepo.readAll()).values.toList();
  final streak = RachaService.calcularRachaDiaria(habits);
  final activoHoy = RachaService.completadoHoy(habits);
  final updated = current.copyWith(cantidad: streak, enRiesgo: !activoHoy);
  await repo.update(updated);
  return updated;
});

/// Provider para obtener la racha semanal

final weeklyRachaProvider = FutureProvider<Racha?>((ref) async {
  await ref.watch(initializeRachasProvider.future);
  ref.watch(timeOffsetProvider);
  ref.watch(habitsChangeListener);

  final repo = ref.watch(rachaRepositoryProvider);
  final habitRepo = HabitRepository();
  final current = await repo.readWeeklyRacha();
  if (current == null) return null;

  final habits = (await habitRepo.readAll()).values.toList();
  final streak = RachaService.calcularRachaSemanal(habits);
  final activoSemana = RachaService.completadoEstaSemana(habits);
  final updated = current.copyWith(cantidad: streak, enRiesgo: !activoSemana);
  await repo.update(updated);
  return updated;
});

/// Provider para obtener todas las rachas
final allRachasProvider = FutureProvider<Map<dynamic, Racha>>((ref) async {
  // Primero inicializar
  await ref.watch(initializeRachasProvider.future);
  
  final repo = ref.watch(rachaRepositoryProvider);
  return repo.readAll();
});

/// Provider para actualizar la racha diaria cuando cambian los hábitos
// final updateDailyRachaProvider = FutureProvider<void>((ref) async {
//   final repo = ref.watch(rachaRepositoryProvider);
//   final habitRepo = HabitRepository();
  
//   final currentRacha = await repo.readDailyRacha();
//   if (currentRacha == null) return;
  
//   final habits = await habitRepo.readAll();
//   final hasCompleted = RachaService.hasCompletedDailyHabitToday(habits.values.toList());
  
//   final updatedRacha = RachaService.updateDailyRacha(
//     currentRacha: currentRacha,
//     completedDailyHabitToday: hasCompleted,
//   );
  
//   await repo.update(updatedRacha);
//   ref.refresh(dailyRachaProvider);
// });

// /// Provider para actualizar la racha semanal cuando cambian los hábitos
// final updateWeeklyRachaProvider = FutureProvider<void>((ref) async {
//   final repo = ref.watch(rachaRepositoryProvider);
//   final habitRepo = HabitRepository();
  
//   final currentRacha = await repo.readWeeklyRacha();
//   if (currentRacha == null) return;
  
//   final habits = await habitRepo.readAll();
//   final hasCompleted = RachaService.hasCompletedWeeklyHabitThisWeek(habits.values.toList());
  
//   final updatedRacha = RachaService.updateWeeklyRacha(
//     currentRacha: currentRacha,
//     completedWeeklyHabitThisWeek: hasCompleted,
//   );
  
//   await repo.update(updatedRacha);
//   ref.refresh(weeklyRachaProvider);
// });
