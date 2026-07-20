import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/utils/app_clock.dart';

// Usamos una caja propia y SIN tipo (dynamic) para poder guardar
// un bool (devMode) y un int (minutos de offset) en el mismo lugar.
// No reusamos 'settings' porque el theme_provider la abre como
// Box<bool> y mezclar tipos daría error.
const _boxName = 'devSettings';

// ============================================================
// DEV MODE: bool que enciende/apaga el modo desarrollador
// ============================================================
class DevModeNotifier extends StateNotifier<bool> {
  DevModeNotifier() : super(false) {
    _load();
  }

  // Lee el valor guardado al arrancar la app
  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    state = box.get('devMode', defaultValue: false) as bool;
  }

  // Alterna encendido/apagado y lo guarda
  Future<void> toggle() async {
    state = !state;
    final box = await Hive.openBox(_boxName);
    await box.put('devMode', state);
    await box.flush();
  }
}

final devModeProvider = StateNotifierProvider<DevModeNotifier, bool>((ref) {
  return DevModeNotifier();
});

// ============================================================
// TIME OFFSET: cuánto tiempo hemos "adelantado" el reloj
// ============================================================
class TimeOffsetNotifier extends StateNotifier<Duration> {
  TimeOffsetNotifier() : super(Duration.zero) {
    _load();
  }

  // Lee el offset guardado (en minutos) y lo aplica al reloj global
  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final minutos = box.get('offsetMin', defaultValue: 0) as int;
    state = Duration(minutes: minutos);
    AppClock.offset = state; // ← que el reloj arranque con el offset guardado
  }

  // Avanza el tiempo la cantidad indicada y lo persiste
  Future<void> avanzar(Duration d) async {
    state = state + d;
    AppClock.offset = state; // ← empuja el reloj global
    final box = await Hive.openBox(_boxName);
    await box.put('offsetMin', state.inMinutes);
    await box.flush();
  }

  // Vuelve el reloj a la hora real
  Future<void> reset() async {
    state = Duration.zero;
    AppClock.offset = Duration.zero;
    final box = await Hive.openBox(_boxName);
    await box.put('offsetMin', 0);
    await box.flush();
  }
}

final timeOffsetProvider =
    StateNotifierProvider<TimeOffsetNotifier, Duration>((ref) {
  return TimeOffsetNotifier();
});
