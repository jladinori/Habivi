import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habivi/app.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_widget_test');
    await HiveInitializer.initForTesting(tempDir.path);
    await Hive.openBox<Habito>(HiveBoxNames.habito);
    await Hive.openBox(HiveBoxNames.sesionEstudio);
    await Hive.openBox(HiveBoxNames.logro);
    await Hive.openBox(HiveBoxNames.racha);
    await Hive.openBox(HiveBoxNames.usuario);
    await Hive.openBox(HiveBoxNames.tarea);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('HabiviApp se inicia correctamente', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabiviApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Habivi'), findsOneWidget);
    expect(find.text('Inicio'), findsWidgets);
  });
}
