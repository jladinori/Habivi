// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BackupAdapter extends TypeAdapter<Backup> {
  @override
  final int typeId = 8;

  @override
  Backup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Backup(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Backup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idBackup)
      ..writeByte(1)
      ..write(obj.fechaBackup)
      ..writeByte(2)
      ..write(obj.descripcion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
