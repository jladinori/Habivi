import 'package:habivi/domain/models/habit_suggestion.dart';

/// Service que proporciona sugerencias contextualizadas según el tipo de hábito
class HabitSuggestionsService {
  static final Map<String, HabitSuggestion> _suggestionsMap = {
    'físico': HabitSuggestion(
      id: 'físico',
      categoria: 'Físico',
      emoji: '💪',
      descripcion:
          'Los hábitos físicos mejoran tu salud, energía y bienestar general.',
      tips: [
        'Calienta durante 5 minutos antes de comenzar.',
        'Usa ropa cómoda y que no te limita el movimiento.',
        'Elige un lugar con suficiente espacio.',
        'Hazlo en el mismo horario cada día para crear rutina.',
        'Si duele, descansa. No es dolor = más resultados.',
        'Hidrátate antes, durante y después.',
        'Empieza lento y aumenta la intensidad gradualmente.',
        'El movimiento es mejor que la perfección.',
      ],
      quickActions: [
        '🚶 Camina 5 minutos alrededor.',
        '🧘 Haz 10 respiraciones profundas.',
        '💧 Bebe un vaso de agua.',
        '🏃 Haz 10 sentadillas.',
        '🤸 Estira brazos y piernas.',
        '👟 Ponte zapatillas de deporte.',
      ],
      pomodoroMinutos: 25,
    ),
    'mental': HabitSuggestion(
      id: 'mental',
      categoria: 'Mental',
      emoji: '🧠',
      descripcion:
          'Los hábitos mentales fortalecen tu concentración, memoria y pensamiento crítico.',
      tips: [
        'Busca un lugar silencioso sin distracciones.',
        'Apaga notificaciones del teléfono.',
        'Ten todo lo que necesitas a mano antes de empezar.',
        'Usa el Pomodoro: 25 min enfocado, 5 min descanso.',
        'Toma notas de lo que aprendes.',
        'Si no entiendes algo, repítelo en voz alta.',
        'Haz descansos cada 90 minutos.',
        'Aprende activamente, no solo leas pasivamente.',
      ],
      quickActions: [
        '📖 Lee una página.',
        '✍️ Escribe tres ideas nuevas.',
        '🤔 Responde una pregunta difícil.',
        '🧩 Resuelve un acertijo.',
        '💭 Explica un concepto en voz alta.',
        '📝 Haz un resumen de 3 líneas.',
      ],
      pomodoroMinutos: 25,
    ),
    'espiritual': HabitSuggestion(
      id: 'espiritual',
      categoria: 'Espiritual',
      emoji: '🧘',
      descripcion:
          'Los hábitos espirituales te conectan contigo mismo, reducen el estrés y traen paz.',
      tips: [
        'Encuentra un lugar tranquilo y cómodo.',
        'Apaga distracciones digitales.',
        'Practica a la misma hora cada día.',
        'Empieza con sesiones cortas (5-10 min).',
        'Respira lentamente y con conciencia.',
        'No juzgues tus pensamientos, solo observa.',
        'Experimenta con diferentes técnicas.',
        'La consistencia es más importante que la intensidad.',
      ],
      quickActions: [
        '🍃 Respira profundamente 5 veces.',
        '🧘 Siéntate en silencio 1 minuto.',
        '🌅 Observa algo bonito alrededor.',
        '📿 Repite una afirmación positiva.',
        '🎵 Escucha música relajante.',
        '📖 Lee una cita inspiradora.',
      ],
      pomodoroMinutos: 20,
    ),
  };

  /// Obtiene las sugerencias para un aspecto específico
  static HabitSuggestion? getSuggestionByAspect(String aspect) {
    return _suggestionsMap[aspect.toLowerCase()];
  }

  /// Obtiene una sugerencia aleatoria de quick actions
  static String getRandomQuickAction(String aspect) {
    final suggestion = getSuggestionByAspect(aspect);
    if (suggestion == null || suggestion.quickActions.isEmpty) {
      return '¡Puedes hacerlo! 💪';
    }
    final random = DateTime.now().millisecondsSinceEpoch % suggestion.quickActions.length;
    return suggestion.quickActions[random];
  }

  /// Obtiene un consejo aleatorio
  static String getRandomTip(String aspect) {
    final suggestion = getSuggestionByAspect(aspect);
    if (suggestion == null || suggestion.tips.isEmpty) {
      return 'Recuerda: pequeños pasos, grandes cambios.';
    }
    final random = DateTime.now().millisecondsSinceEpoch % suggestion.tips.length;
    return suggestion.tips[random];
  }

  /// Obtiene todos los aspectos disponibles
  static List<HabitSuggestion> getAllSuggestions() {
    return _suggestionsMap.values.toList();
  }
}
