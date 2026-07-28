
import 'package:hive/hive.dart';

part 'tarea.g.dart';

@HiveType(typeId: 4)
class Tarea {

  @HiveField(0)
  int idTarea;

  @HiveField(1)
  String nombreTarea;

  @HiveField(2)
  int puntaje;

  // Guardamos fecha y notas como parte del nombre o notas para compatibilidad
  // Formato: "nombre|fecha|notas" separado por |
  @HiveField(3)
  String metadata;

  @HiveField(4)
  String fecha;

  @HiveField(5)
  String notas;

  @HiveField(6)
  bool completada;

  @HiveField(7)
  bool archivada;
  
  Tarea(
    this.idTarea,
    this.nombreTarea,
    this.puntaje, {
    this.metadata = '',
    this.fecha = '',
    this.notas = '',
    this.completada = false,
    this.archivada = false,
  });

  // Helpers para extraer datos
  String get fechaFormateada {
    if (fecha.isNotEmpty) return fecha;
    final parts = metadata.split('|');
    return parts.length > 1 ? parts[1] : '';
  }

  String get notasFormateadas {
    if (notas.isNotEmpty) return notas;
    final parts = metadata.split('|');
    return parts.length > 2 ? parts[2] : '';
  }

  // Crear metadata desde fecha y notas
  static String crearMetadata(String fecha, String notas) {
    return '|$fecha|$notas';
  }
}
