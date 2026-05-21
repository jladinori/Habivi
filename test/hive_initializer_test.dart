import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/data/models/habito.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_hive_test');
    await HiveInitializer.initForTesting(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Hive abre la caja de hábitos', () async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    expect(box.isOpen, isTrue);
    await box.close();
  });
}
