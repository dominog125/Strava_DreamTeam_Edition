// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_history_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityHistoryHiveModelAdapter
    extends TypeAdapter<ActivityHistoryHiveModel> {
  @override
  final int typeId = 34;

  @override
  ActivityHistoryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityHistoryHiveModel(
      id: fields[0] as String,
      dateIso: fields[1] as String,
      type: fields[2] as String,
      durationSeconds: fields[3] as int,
      distanceKm: fields[4] as double,
      paceMinPerKm: fields[5] as double,
      avgSpeedKmH: fields[6] as double,
      syncStatus: fields[7] as SyncStatus,
      createdAtIso: fields[8] as String,
      updatedAtIso: fields[9] as String,
      title: fields[10] as String?,
      note: fields[11] as String?,
      photoPath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityHistoryHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateIso)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.paceMinPerKm)
      ..writeByte(6)
      ..write(obj.avgSpeedKmH)
      ..writeByte(7)
      ..write(obj.syncStatus)
      ..writeByte(8)
      ..write(obj.createdAtIso)
      ..writeByte(9)
      ..write(obj.updatedAtIso)
      ..writeByte(10)
      ..write(obj.title)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.photoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityHistoryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 33;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.pending;
      case 1:
        return SyncStatus.synced;
      case 2:
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.pending:
        writer.writeByte(0);
        break;
      case SyncStatus.synced:
        writer.writeByte(1);
        break;
      case SyncStatus.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
