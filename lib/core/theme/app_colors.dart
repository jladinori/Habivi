import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  static const Color seed = Color.fromARGB(255, 0, 179, 255);

  static const Color darkSurface = Color.fromARGB(255, 3, 14, 36);
  static const Color darkSurfaceHigh = Color.fromARGB(255, 1, 17, 36);
  static const Color darkOnSurfaceMuted = Color.fromARGB(255, 128, 206, 255);

  static const Color lightSurface = Color.fromARGB(255, 240, 248, 255);
  static const Color lightSurfaceHigh = Color.fromARGB(255, 255, 255, 255);
  static const Color lightOnSurfaceMuted = Color.fromARGB(255, 0, 100, 148);
}
