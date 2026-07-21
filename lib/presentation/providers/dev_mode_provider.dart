import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/data/repositories/racha_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/utils/app_clock.dart';

// Caja propia SIN tipo, para guardar un bool y un int juntos.
const _boxName = 'devSettings';

// ===== ¿Modo desarrollador activo? (bool) =====
class DevModeNotifier extends StateNotifier<bool> {
  DevModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    state = box.get('devMode', defaultValue: false) as bool;
  }

  Future<void> toggle() async {
    state = !state;
    final box = await Hive.openBox(_boxName);
    await box.put('devMode', state);
    await box.flush();
  }
}

final devModeProvider =
    StateNotifierProvider<DevModeNotifier, bool>((ref) => DevModeNotifier());

// ===== ¿Cuánto tiempo adelantamos? (Duration) =====
class TimeOffsetNotifier extends StateNotifier<Duration> {
  TimeOffsetNotifier() : super(Duration.zero) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final minutos = box.get('offsetMin', defaultValue: 0) as int;
    state = Duration(minutes: minutos);
    AppClock.offset = state; // aplica el offset guardado al arrancar
  }

  Future<void> avanzar(Duration d) async {
    state = state + d;
    AppClock.offset = state; // empuja el reloj global
    final box = await Hive.openBox(_boxName);
    await box.put('offsetMin', state.inMinutes);
    await box.flush();
  }

      Future<void> reset() async {
    // 1. Reloj de vuelta a la hora REAL del sistema (del computador)
    state = Duration.zero;
    AppClock.offset = Duration.zero;
    final box = await Hive.openBox(_boxName);
    await box.put('offsetMin', 0);
    await box.flush();

    // Día actual REAL (sacado del reloj del computador, NO del virtual).
    // Todo lo que sea posterior a hoy es dato de prueba y se elimina.
    final hoyReal = _fechaRealHoy();

    final habitRepo = HabitRepository();
    final habitosMap = await habitRepo.readAll();

    final archivo = await Hive.openBox('devHistorial');
    final previos =
        (archivo.get('registros', defaultValue: <String>[]) as List).cast<String>();
    final archivados = <String>[];

    for (final entry in habitosMap.entries) {
      final h = entry.value;
      final conservadas = <String>[];
      for (final fecha in h.safeFechasCompletadas) {
        if (fecha.compareTo(hoyReal) <= 0) {
          conservadas.add(fecha); // hoy real o antes → se queda
        } else {
          archivados.add('${h.idHabito}|$fecha'); // futuro → se archiva y se quita
        }
      }
      h.fechasCompletadas = conservadas;
      h.fechaUltimoCompletado = conservadas.isEmpty
          ? ''
          : conservadas.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      h.completadoHoy = conservadas.contains(hoyReal);
      await habitRepo.update(entry.key, h);
    }

    // Guardar en el archivo histórico lo que se borró (por si acaso)
    if (archivados.isNotEmpty) {
      final marca = 'RESET ${DateTime.now().toIso8601String()}';
      await archivo.put('registros', [...previos, marca, ...archivados]);
      await archivo.flush();
    }

    // Reiniciar ambas rachas a cero
    final rachaRepo = RachaRepository();
    final diaria = await rachaRepo.readDailyRacha();
    if (diaria != null) {
      await rachaRepo.update(diaria.copyWith(
        cantidad: 0, fechaUltimoCompletado: '', enRiesgo: false,
        fechaInicioPeriodoRecuperacion: '',
      ));
    }
    final semanal = await rachaRepo.readWeeklyRacha();
    if (semanal != null) {
      await rachaRepo.update(semanal.copyWith(
        cantidad: 0, fechaUltimoCompletado: '', enRiesgo: false,
        fechaInicioPeriodoRecuperacion: '',
      ));
    }
  }

  // Fecha de HOY según el reloj REAL del computador (sin el offset virtual)
  String _fechaRealHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}


final timeOffsetProvider =
    StateNotifierProvider<TimeOffsetNotifier, Duration>(
        (ref) => TimeOffsetNotifier());