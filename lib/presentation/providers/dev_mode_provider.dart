import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    state = Duration.zero;
    AppClock.offset = Duration.zero;
    final box = await Hive.openBox(_boxName);
    await box.put('offsetMin', 0);
    await box.flush();
  }
}

final timeOffsetProvider =
    StateNotifierProvider<TimeOffsetNotifier, Duration>(
        (ref) => TimeOffsetNotifier());