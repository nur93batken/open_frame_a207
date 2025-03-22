import 'package:hive_flutter/adapters.dart';

part 'poject_model_open_frame.g.dart'; // Эта часть будет сгенерирована автоматически build_runner'ом.

@HiveType(typeId: 2)
enum ProjectResult {
  @HiveField(0)
  better,

  @HiveField(1)
  noChange,

  @HiveField(2)
  worse,
}

/// Модель проекта, которую мы будем хранить в Hive.
/// `HiveObject` даёт удобный доступ к методам save(), delete(), и т.п.
@HiveType(typeId: 1)
class Project extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  String projectName;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> photosBefore;

  @HiveField(4)
  List<String> photosAfter;

  @HiveField(5)
  ProjectResult? result;

  Project({
    required this.category,
    required this.projectName,
    this.description,
    this.photosBefore = const [],
    this.photosAfter = const [],
    this.result,
  });

  copyWith({
    String? category,
    String? projectName,
    String? description,
    List<String>? photosBefore,
    List<String>? photosAfter,
    ProjectResult? result,
  }) {
    return Project(
      category: category ?? this.category,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      photosBefore: photosBefore ?? this.photosBefore,
      photosAfter: photosAfter ?? this.photosAfter,
      result: result ?? this.result,
    );
  }
}
