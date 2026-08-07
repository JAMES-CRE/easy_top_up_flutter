// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedStationAdapter extends TypeAdapter<CachedStation> {
  @override
  final int typeId = 0;

  @override
  CachedStation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedStation(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      lat: fields[3] as double,
      lng: fields[4] as double,
      status: fields[5] as String?,
      price: fields[6] as String?,
      phone: fields[7] as String?,
      whatsapp: fields[8] as String?,
      photos: (fields[9] as List).cast<String>(),
      verified: fields[10] as bool,
      petrolData: (fields[11] as Map?)?.cast<String, dynamic>(),
      dieselData: (fields[12] as Map?)?.cast<String, dynamic>(),
      lpgType: (fields[13] as List?)?.cast<dynamic>(),
      chargingPoints: (fields[14] as List?)?.cast<dynamic>(),
      hasBackupGenerator: fields[15] as bool,
      deliveryAvailable: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CachedStation obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.lng)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.whatsapp)
      ..writeByte(9)
      ..write(obj.photos)
      ..writeByte(10)
      ..write(obj.verified)
      ..writeByte(11)
      ..write(obj.petrolData)
      ..writeByte(12)
      ..write(obj.dieselData)
      ..writeByte(13)
      ..write(obj.lpgType)
      ..writeByte(14)
      ..write(obj.chargingPoints)
      ..writeByte(15)
      ..write(obj.hasBackupGenerator)
      ..writeByte(16)
      ..write(obj.deliveryAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedStationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
