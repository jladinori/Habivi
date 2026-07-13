import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class Racha {
  @HiveField(0)
  int idRacha;

  @HiveField(1)
  String tipo;

  @HiveField(2)
  int cantidad;

  @HiveField(3)
  String fechaUltimoCompletado;

  @HiveField(4)
  bool enRiesgo;

  @HiveField(5)
  String fechaInicioPeriodoRecuperacion;

  @HiveField(6)
  String? fechaCreacion;

  Racha({
    required this.idRacha,
    required this.tipo,
    required this.cantidad,
    required this.fechaUltimoCompletado,
    this.enRiesgo = false,
    this.fechaInicioPeriodoRecuperacion = '',
    this.fechaCreacion,
  });

  Racha copyWith({
    int? idRacha,
    String? tipo,
    int? cantidad,
    String? fechaUltimoCompletado,
    bool? enRiesgo,
    String? fechaInicioPeriodoRecuperacion,
    String? fechaCreacion,
  }) {
    return Racha(
      idRacha: idRacha ?? this.idRacha,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      fechaUltimoCompletado: fechaUltimoCompletado ?? this.fechaUltimoCompletado,
      enRiesgo: enRiesgo ?? this.enRiesgo,
      fechaInicioPeriodoRecuperacion: fechaInicioPeriodoRecuperacion ?? this.fechaInicioPeriodoRecuperacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String getTodayFormatted() => _formatDate(DateTime.now());

  static bool isSameDay(String fecha1, String fecha2) => fecha1 == fecha2;

  static bool isNextDay(String previousDay, String nextDay) {
    try {
      final prev = DateTime.parse(previousDay);
      final next = DateTime.parse(nextDay);
      return next.difference(prev).inDays == 1;
    } catch (e) {
      return false;
    }
  }

  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(firstDayOfYear).inDays;
    return ((difference + firstDayOfYear.weekday) / 7).ceil();
  }

  static bool isSameWeek(String fecha1, String fecha2) {
    try {
      final date1 = DateTime.parse(fecha1);
      final date2 = DateTime.parse(fecha2);
      return getWeekNumber(date1) == getWeekNumber(date2) && date1.year == date2.year;
    } catch (e) {
      return false;
    }
  }

  static String getMondayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    final monday = date.subtract(Duration(days: dayOfWeek - 1));
    return _formatDate(monday);
  }

  static String getSundayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    final sunday = date.add(Duration(days: 7 - dayOfWeek));
    return _formatDate(sunday);
  }

  static int daysBetween(String fecha1, String fecha2) {
    try {
      final date1 = DateTime.parse(fecha1);
      final date2 = DateTime.parse(fecha2);
      return date2.difference(date1).inDays;
    } catch (e) {
      return 0;
    }
  }
}

class RachaAdapter extends TypeAdapter<Racha> {
  @override
  final int typeId = 11;

  @override
  Racha read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Racha(
      idRacha: fields[0] as int,
      tipo: fields[1] as String,
      cantidad: fields[2] as int,
      fechaUltimoCompletado: fields[3] as String,
      enRiesgo: fields[4] as bool? ?? false,
      fechaInicioPeriodoRecuperacion: fields[5] as String? ?? '',
      fechaCreacion: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Racha obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.idRacha)
      ..writeByte(1)
      ..write(obj.tipo)
      ..writeByte(2)
      ..write(obj.cantidad)
      ..writeByte(3)
      ..write(obj.fechaUltimoCompletado)
      ..writeByte(4)
      ..write(obj.enRiesgo)
      ..writeByte(5)
      ..write(obj.fechaInicioPeriodoRecuperacion)
      ..writeByte(6)
      ..write(obj.fechaCreacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RachaAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
