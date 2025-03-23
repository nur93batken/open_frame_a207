import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_frame_a207/presentations/projects/models/poject_model_open_frame.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProjectCubit extends Cubit<List<Project>> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  final Box<Project> _projectsBox;
  ProjectCubit(this._projectsBox) : super(_projectsBox.values.toList());

  Future<void> addProjectWithPhotos(
    Project project,
    List<XFile> photosBefore,
    List<XFile> photosAfter,
  ) async {
    try {
      final List<String> savedPathBefore = [];
      for (var photo in photosBefore) {
        final savedPath = await _saveImageToAppDir(photo);
        savedPathBefore.add(savedPath);
      }
      final List<String> savedPathAfter = [];
      for (var photo in photosAfter) {
        final savedPath = await _saveImageToAppDir(photo);
        savedPathAfter.add(savedPath);
      }

      final newProject = project.copyWith(
        photosBefore: savedPathBefore,
        photosAfter: savedPathAfter,
      );

      await _projectsBox.add(newProject);

      emit([...state, newProject]);
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  Future<String> _saveImageToAppDir(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = File('${appDir.path}/$fileName');
    await savedFile.writeAsBytes(await file.readAsBytes());
    return savedFile.path;
  }

  void updateProject(int index, Project updatedproject) async {
    try {
      await _projectsBox.putAt(index, updatedproject);

      emit(_projectsBox.values.toList());
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<XFile>> pickImages() async {
    if (_isPicking) return []; // Если уже идёт процесс, просто выходим
    _isPicking = true;
    try {
      if (await Permission.photos.request().isGranted) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
        return images;
      }
      return [];
    } on Exception catch (e) {
      throw Exception('Failed to pick images: $e');
    } finally {
      _isPicking = false;
    }
  }

  void deleteProject(int index) async {
    try {
      await _projectsBox.delete(index);

      emit(_projectsBox.values.toList());
    } catch (e) {
      throw Exception();
    }
  }

  Project getProject(int index) {
    return _projectsBox.getAt(index)!;
  }
}
