import 'package:flutter/material.dart';

enum CharacterMood {
  feliz,
  frustrado,
  sonoliento,
  apagado,
  triste,
}

extension CharacterMoodInfo on CharacterMood {
  String get label => switch (this) {
        CharacterMood.feliz => 'Feliz',
        CharacterMood.frustrado => 'Frustrado',
        CharacterMood.sonoliento => 'Soñoliento',
        CharacterMood.apagado => 'Apagado',
        CharacterMood.triste => 'Triste',
      };

  String get mensaje => switch (this) {
        CharacterMood.feliz => '¡Vamos genial! Sigue así 💪',
        CharacterMood.frustrado => 'Estás dando mucho en un solo aspecto. ¡Equilibra cuerpo, mente y alma!',
        CharacterMood.sonoliento => 'Vamos bien, pero hoy puedes dar un pasito más.',
        CharacterMood.apagado => 'Ivi te extraña... completa un hábito para despertarlo.',
        CharacterMood.triste => 'Energía baja. Un hábito pequeño puede cambiar el día.',
      };

  IconData get icon => switch (this) {
        CharacterMood.feliz => Icons.sentiment_very_satisfied,
        CharacterMood.frustrado => Icons.sentiment_very_dissatisfied,
        CharacterMood.sonoliento => Icons.bedtime,
        CharacterMood.apagado => Icons.power_settings_new,
        CharacterMood.triste => Icons.sentiment_dissatisfied,
      };

  Color get color => switch (this) {
        CharacterMood.feliz => Colors.green,
        CharacterMood.frustrado => Colors.deepOrange,
        CharacterMood.sonoliento => Colors.amber,
        CharacterMood.apagado => Colors.blueGrey,
        CharacterMood.triste => Colors.red,
      };
}
