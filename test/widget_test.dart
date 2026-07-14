import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habivi/app.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/usuario.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async => null;

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) =>
      const Stream.empty();

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform();
    tempDir = Directory.systemTemp.createTempSync('habivi_widget_test');
    await HiveInitializer.initForTesting(tempDir.path);
    await Hive.openBox<Usuario>(HiveBoxNames.usuario);
    await Hive.openBox<Habito>(HiveBoxNames.habito);
    await Hive.openBox<Racha>(HiveBoxNames.racha);
    await Hive.openBox<Tarea>(HiveBoxNames.tarea);
    await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    await Hive.openBox<Logro>(HiveBoxNames.logro);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('HabiviApp muestra titulo', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabiviApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Habivi'), findsOneWidget);
  });
}
