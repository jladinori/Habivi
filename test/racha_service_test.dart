import 'package:flutter_test/flutter_test.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/core/utils/app_clock.dart';
import 'package:habivi/domain/services/racha_service.dart';

void main() {
  setUpAll(() {
    final fixedNow = DateTime(2026, 7, 28);
    AppClock.offset = fixedNow.difference(DateTime.now());
  });

  tearDownAll(() {
    AppClock.offset = Duration.zero;
  });

  test('daily streak only counts when all daily habits complete same day', () {
    final habits = [
      Habito(1, 'H1', 'desc', 'físico|run', completadoHoy: true, fechasCompletadas: ['2026-07-27', '2026-07-28'], vecesPorSemana: 7),
      Habito(2, 'H2', 'desc', 'mental|book', completadoHoy: false, fechasCompletadas: ['2026-07-27'], vecesPorSemana: 7),
    ];

    final streak = RachaService.calcularRachaDiaria(habits);
    expect(streak, 1);
  });

  test('weekly streak counts weeks with at least one habit from each section', () {
    final habits = [
      Habito(1, 'H1', 'desc', 'físico|run', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 1),
      Habito(2, 'H2', 'desc', 'mental|book', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 1),
      Habito(3, 'H3', 'desc', 'espiritual|spa', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 1),
    ];

    final streak = RachaService.calcularRachaSemanal(habits);
    expect(streak, 1);
  });

  test('weekly streak counts across different days in the same week', () {
    final habits = [
      Habito(1, 'H1', 'desc', 'físico|run', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 1),
      Habito(2, 'H2', 'desc', 'mental|book', fechasCompletadas: ['2026-07-28'], vecesPorSemana: 1),
      Habito(3, 'H3', 'desc', 'espiritual|spa', fechasCompletadas: ['2026-07-29'], vecesPorSemana: 1),
    ];

    final streak = RachaService.calcularRachaSemanal(habits);
    expect(streak, 1);
  });

  test('daily streak preserves with rest day even when daily habits are skipped', () {
    final habits = [
      Habito(1, 'H1', 'desc', 'físico|run', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 7),
      Habito(2, 'H2', 'desc', 'mental|book', fechasCompletadas: ['2026-07-27'], vecesPorSemana: 7),
    ];

    final streak = RachaService.calcularRachaDiaria(
      habits,
      restDays: ['2026-07-28'],
    );

    expect(streak, 2);
  });

  test('rest day can only be used once per week', () {
    expect(RachaService.puedeUsarDiaDescanso('2026-07-28'), isFalse);
    expect(RachaService.puedeUsarDiaDescanso('2026-07-21'), isTrue);
  });
}
