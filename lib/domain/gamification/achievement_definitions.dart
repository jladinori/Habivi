import 'package:flutter/material.dart';
import 'package:habivi/domain/services/energy_service.dart';

class GamificationStats {
  final int totalCompletados;
  final int racha;
  final int habitosHoy;
  final int totalHabitos;
  final int sesionesEstudio;
  final int puntosEstudio;
  final EnergiaAtributos atributos;

  const GamificationStats({
    required this.totalCompletados,
    required this.racha,
    required this.habitosHoy,
    required this.totalHabitos,
    required this.sesionesEstudio,
    required this.puntosEstudio,
    required this.atributos,
  });

  bool get diaPerfecto => totalHabitos > 0 && habitosHoy >= totalHabitos;
}

class AchievementDef {
  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final bool Function(GamificationStats stats) condicion;

  const AchievementDef({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.condicion,
  });
}

final List<AchievementDef> achievementCatalog = [
  AchievementDef(
    id: 'primer_paso',
    titulo: 'Primer paso',
    descripcion: 'Completa tu primer hábito',
    icono: Icons.flag,
    condicion: (s) => s.totalCompletados >= 1,
  ),
  AchievementDef(
    id: 'constante_10',
    titulo: 'Constante',
    descripcion: 'Completa 10 hábitos en total',
    icono: Icons.trending_up,
    condicion: (s) => s.totalCompletados >= 10,
  ),
  AchievementDef(
    id: 'imparable_50',
    titulo: 'Imparable',
    descripcion: 'Completa 50 hábitos en total',
    icono: Icons.rocket_launch,
    condicion: (s) => s.totalCompletados >= 50,
  ),
  AchievementDef(
    id: 'racha_3',
    titulo: 'Calentando motores',
    descripcion: 'Mantén una racha de 3 días',
    icono: Icons.local_fire_department,
    condicion: (s) => s.racha >= 3,
  ),
  AchievementDef(
    id: 'racha_7',
    titulo: 'Semana en llamas',
    descripcion: 'Mantén una racha de 7 días',
    icono: Icons.whatshot,
    condicion: (s) => s.racha >= 7,
  ),
  AchievementDef(
    id: 'racha_30',
    titulo: 'Leyenda del mes',
    descripcion: 'Mantén una racha de 30 días',
    icono: Icons.emoji_events,
    condicion: (s) => s.racha >= 30,
  ),
  AchievementDef(
    id: 'estudiante',
    titulo: 'Estudiante',
    descripcion: 'Registra tu primera sesión de estudio',
    icono: Icons.school,
    condicion: (s) => s.sesionesEstudio >= 1,
  ),
  AchievementDef(
    id: 'sabio_500',
    titulo: 'Sabio',
    descripcion: 'Acumula 500 puntos de estudio',
    icono: Icons.auto_stories,
    condicion: (s) => s.puntosEstudio >= 500,
  ),
  AchievementDef(
    id: 'dia_perfecto',
    titulo: 'Día perfecto',
    descripcion: 'Completa todos tus hábitos en un día',
    icono: Icons.star,
    condicion: (s) => s.diaPerfecto,
  ),
  AchievementDef(
    id: 'equilibrio_total',
    titulo: 'Equilibrio total',
    descripcion: 'Cuerpo, Mente y Alma por encima de 70%',
    icono: Icons.balance,
    condicion: (s) =>
        s.atributos.tieneCuerpo && s.atributos.tieneMente && s.atributos.tieneAlma &&
        s.atributos.cuerpo >= 70 && s.atributos.mente >= 70 && s.atributos.alma >= 70,
  ),
];
