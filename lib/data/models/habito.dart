import 'package:hive/hive.dart';

part 'habito.g.dart';

@HiveType(typeId: 2)
class Habito {
  @HiveField(0)
  int idHabito;

  @HiveField(1)
  String nombreHabito;

  @HiveField(2)
  String atributo;

  @HiveField(3)
  String tipo;

  @HiveField(4)
  bool completadoHoy;

  @HiveField(5)
  String fechaUltimoCompletado;

  @HiveField(6)
  List<String>? fechasCompletadas;

  @HiveField(7)
  int? vecesPorSemana;

  @HiveField(8)
  String? fechaCreacion;

  List<String> get safeFechasCompletadas => fechasCompletadas ?? [];

  int get safeVecesPorSemana =>
      (vecesPorSemana != null && vecesPorSemana! > 0) ? vecesPorSemana! : 1;

  String get safeFechaCreacion {
    if (fechaCreacion != null && fechaCreacion!.isNotEmpty) {
      return fechaCreacion!;
    }
    if (fechaUltimoCompletado.isNotEmpty) {
      return fechaUltimoCompletado;
    }
    return _formatDate(DateTime.now());
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get aspecto {
    if (tipo.contains('|')) {
      return tipo.split('|')[0];
    }
    return 'físico'; // Default aspect
  }

  String get iconoKey {
    if (tipo.contains('|')) {
      final parts = tipo.split('|');
      if (parts.length > 1) return parts[1];
    }
    // Default fallback based on ID
    final defaultKeys = ['spa', 'heart', 'book', 'smoke'];
    return defaultKeys[idHabito % defaultKeys.length];
  }

  set aspecto(String val) {
    tipo = "$val|$iconoKey";
  }

  set iconoKey(String val) {
    tipo = "$aspecto|$val";
  }

  Habito(
    this.idHabito,
    this.nombreHabito,
    this.atributo,
    this.tipo, {
    this.completadoHoy = false,
    this.fechaUltimoCompletado = '',
    List<String>? fechasCompletadas,
    this.vecesPorSemana,
    this.fechaCreacion,
  }) : fechasCompletadas = fechasCompletadas ?? [];
}
