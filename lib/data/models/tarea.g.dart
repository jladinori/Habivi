// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TareaAdapter extends TypeAdapter<Tarea> {
  @override
  final int typeId = 4;

  @override
  Tarea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tarea(
      fields[0] as int,
      fields[1] as String,
      fields[2] as int,
      metadata: fields[3] as String? ?? '',
      fecha: fields[4] as String? ?? '',
      notas: fields[5] as String? ?? '',
      completada: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Tarea obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.idTarea)
      ..writeByte(1)
      ..write(obj.nombreTarea)
      ..writeByte(2)
      ..write(obj.puntaje)
      ..writeByte(3)
      ..write(obj.metadata)
      ..writeByte(4)
      ..write(obj.fecha)
      ..writeByte(5)
      ..write(obj.notas)
      ..writeByte(6)
      ..write(obj.completada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TareaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
