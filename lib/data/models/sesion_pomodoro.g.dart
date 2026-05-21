// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesion_pomodoro.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SesionPomodoroAdapter extends TypeAdapter<SesionPomodoro> {
  @override
  final int typeId = 5;

  @override
  SesionPomodoro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SesionPomodoro(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
      fields[4] as bool,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SesionPomodoro obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idSesion)
      ..writeByte(1)
      ..write(obj.fechaInicio)
      ..writeByte(2)
      ..write(obj.fechaFinal)
      ..writeByte(3)
      ..write(obj.duracion)
      ..writeByte(4)
      ..write(obj.completada)
      ..writeByte(5)
      ..write(obj.tipoSesion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionPomodoroAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
