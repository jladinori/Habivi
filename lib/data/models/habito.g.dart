// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habito.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitoAdapter extends TypeAdapter<Habito> {
  @override
  final int typeId = 2;

  @override
  Habito read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habito(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      completadoHoy: fields[4] as bool? ?? false,
      fechaUltimoCompletado: fields[5] as String? ?? '',
      fechasCompletadas: (fields[6] as List?)?.cast<String>() ?? [],
      vecesPorSemana: fields[7] as int?,
      fechaCreacion: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Habito obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.idHabito)
      ..writeByte(1)
      ..write(obj.nombreHabito)
      ..writeByte(2)
      ..write(obj.atributo)
      ..writeByte(3)
      ..write(obj.tipo)
      ..writeByte(4)
      ..write(obj.completadoHoy)
      ..writeByte(5)
      ..write(obj.fechaUltimoCompletado)
      ..writeByte(6)
      ..write(obj.fechasCompletadas)
      ..writeByte(7)
      ..write(obj.vecesPorSemana)
      ..writeByte(8)
      ..write(obj.fechaCreacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
