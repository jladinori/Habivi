import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/app.dart';
import 'package:habivi/core/hive/hive_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInitializer.init();

  runApp(
    const ProviderScope(
      child: HabiviApp(),
    ),
  );
}