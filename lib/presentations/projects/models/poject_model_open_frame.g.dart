// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poject_model_open_frame.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      category: fields[0] as String,
      projectName: fields[1] as String,
      description: fields[2] as String?,
      photosBefore: (fields[3] as List).cast<String>(),
      photosAfter: (fields[4] as List).cast<String>(),
      result: fields[5] as ProjectResult?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.projectName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.photosBefore)
      ..writeByte(4)
      ..write(obj.photosAfter)
      ..writeByte(5)
      ..write(obj.result);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectResultAdapter extends TypeAdapter<ProjectResult> {
  @override
  final int typeId = 2;

  @override
  ProjectResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectResult.better;
      case 1:
        return ProjectResult.noChange;
      case 2:
        return ProjectResult.worse;
      default:
        return ProjectResult.better;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectResult obj) {
    switch (obj) {
      case ProjectResult.better:
        writer.writeByte(0);
        break;
      case ProjectResult.noChange:
        writer.writeByte(1);
        break;
      case ProjectResult.worse:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
