/// Estados de ánimo del personaje (placeholder para Rive).
enum CharacterMood {
  feliz,
  neutral,
  triste,
  frustrado,
  sinEnergia,
}

extension CharacterMoodLabel on CharacterMood {
  String get label => switch (this) {
        CharacterMood.feliz => 'Feliz',
        CharacterMood.neutral => 'Neutral',
        CharacterMood.triste => 'Triste',
        CharacterMood.frustrado => 'Frustrado',
        CharacterMood.sinEnergia => 'Sin energía',
      };
}
