/// Modelo que contiene sugerencias para un tipo específico de hábito
class HabitSuggestion {
  final String id;              // "físico", "mental", "espiritual"
  final String categoria;       // Nombre amigable: "Físico", "Mental", "Espiritual"
  final String emoji;           // Emoji representativo
  final List<String> tips;      // Consejos prácticos
  final List<String> quickActions; // Acciones rápidas para empezar
  final int pomodoroMinutos;    // Minutos recomendados para Pomodoro
  final String descripcion;     // Descripción de qué es este tipo de hábito

  HabitSuggestion({
    required this.id,
    required this.categoria,
    required this.emoji,
    required this.tips,
    required this.quickActions,
    required this.pomodoroMinutos,
    required this.descripcion,
  });
}
