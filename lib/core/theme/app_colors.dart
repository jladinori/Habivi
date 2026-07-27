import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Colores primarios - Azul profesional moderno
  static const Color seed = Color.fromARGB(255, 25, 118, 210); // Azul profesional (#1976D2)

  // Modo Oscuro - Tonos grises oscuros profesionales
  static const Color darkSurface = Color.fromARGB(255, 18, 18, 18);      // Fondo muy oscuro (casi negro)
  static const Color darkSurfaceHigh = Color.fromARGB(255, 28, 28, 28); // Superficie elevada
  static const Color darkOnSurfaceMuted = Color.fromARGB(255, 189, 189, 189); // Texto gris claro

  // Modo Claro - Tonos claros limpios
  static const Color lightSurface = Color.fromARGB(255, 255, 255, 255);      // Fondo blanco puro
  static const Color lightSurfaceHigh = Color.fromARGB(255, 248, 248, 248);  // Superficie elevada gris muy claro
  static const Color lightOnSurfaceMuted = Color.fromARGB(255, 66, 66, 66); // Texto gris oscuro
}
