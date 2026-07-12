// GENERATED CODE - hand-authored to match what `flutter pub run build_runner
// build` would output for the BodyMeasurement Hive model. If you change any
// @HiveField in body_measurement.dart, either update this file to match or
// delete it and run:
//   flutter pub run build_runner build --delete-conflicting-outputs
// to have it regenerated automatically.

part of 'body_measurement.dart';

class BodyMeasurementAdapter extends TypeAdapter<BodyMeasurement> {
  @override
  final int typeId = 0;

  @override
  BodyMeasurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMeasurement(
      id: fields[0] as String,
      scannedAt: fields[1] as DateTime,
      photoPath: fields[2] as String,
      heightCm: fields[3] as double,
      chestCm: fields[4] as double,
      waistCm: fields[5] as double,
      hipCm: fields[6] as double,
      shoulderWidthCm: fields[7] as double,
      neckCm: fields[8] as double,
      sleeveLengthCm: fields[9] as double,
      armLengthCm: fields[10] as double,
      inseamCm: fields[11] as double,
      estimatedWeightKg: fields[12] as double,
      bmi: fields[13] as double,
      bodyShape: fields[14] as BodyShape,
      accuracy: fields[15] as AccuracyLevel,
      wasHeightCalibrated: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMeasurement obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scannedAt)
      ..writeByte(2)
      ..write(obj.photoPath)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.chestCm)
      ..writeByte(5)
      ..write(obj.waistCm)
      ..writeByte(6)
      ..write(obj.hipCm)
      ..writeByte(7)
      ..write(obj.shoulderWidthCm)
      ..writeByte(8)
      ..write(obj.neckCm)
      ..writeByte(9)
      ..write(obj.sleeveLengthCm)
      ..writeByte(10)
      ..write(obj.armLengthCm)
      ..writeByte(11)
      ..write(obj.inseamCm)
      ..writeByte(12)
      ..write(obj.estimatedWeightKg)
      ..writeByte(13)
      ..write(obj.bmi)
      ..writeByte(14)
      ..write(obj.bodyShape)
      ..writeByte(15)
      ..write(obj.accuracy)
      ..writeByte(16)
      ..write(obj.wasHeightCalibrated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccuracyLevelAdapter extends TypeAdapter<AccuracyLevel> {
  @override
  final int typeId = 1;

  @override
  AccuracyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccuracyLevel.high;
      case 1:
        return AccuracyLevel.medium;
      case 2:
        return AccuracyLevel.low;
      default:
        return AccuracyLevel.medium;
    }
  }

  @override
  void write(BinaryWriter writer, AccuracyLevel obj) {
    switch (obj) {
      case AccuracyLevel.high:
        writer.writeByte(0);
        break;
      case AccuracyLevel.medium:
        writer.writeByte(1);
        break;
      case AccuracyLevel.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccuracyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BodyShapeAdapter extends TypeAdapter<BodyShape> {
  @override
  final int typeId = 2;

  @override
  BodyShape read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BodyShape.slim;
      case 1:
        return BodyShape.athletic;
      case 2:
        return BodyShape.average;
      case 3:
        return BodyShape.heavy;
      default:
        return BodyShape.average;
    }
  }

  @override
  void write(BinaryWriter writer, BodyShape obj) {
    switch (obj) {
      case BodyShape.slim:
        writer.writeByte(0);
        break;
      case BodyShape.athletic:
        writer.writeByte(1);
        break;
      case BodyShape.average:
        writer.writeByte(2);
        break;
      case BodyShape.heavy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyShapeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
