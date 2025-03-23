import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_frame_a207/blocs/project_cubit.dart';
import 'package:open_frame_a207/presentations/projects/models/poject_model_open_frame.dart';
import 'package:open_frame_a207/widgets/custom_app_bar_open_frame.dart';
import 'package:open_frame_a207/widgets/show_cupertino_dialog_open_fram.dart';

class EditProjectOpenFrame extends StatefulWidget {
  final int projectIndex; // Индекс проекта в Hive
  final Project existingProject;

  const EditProjectOpenFrame({
    super.key,
    required this.projectIndex,
    required this.existingProject,
  });

  @override
  State<EditProjectOpenFrame> createState() => _EditProjectOpenFrameState();
}

class _EditProjectOpenFrameState extends State<EditProjectOpenFrame> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final FocusNode _otherCategoryFocus = FocusNode();

  // Для показа всплывающего списка категорий
  bool _showCustomDropdown = false;

  // Фото "до" и "после"
  final List<XFile> _selectedPhotosBefore = [];
  final List<XFile> _selectedPhotosAfter = [];

  // Текущие значения
  String? _selectedCategory;
  bool _showOtherField = false;
  String? _finalResult;

  // Исходный проект (для сравнения)
  late final Project _originalProject;

  // Проверка, есть ли изменения
  bool get _hasChanges {
    // Сравниваем поля с _originalProject
    if (_selectedCategory != _originalProject.category) return true;
    if (_projectNameController.text != _originalProject.projectName)
      return true;
    if (_descriptionController.text != (_originalProject.description ?? ''))
      return true;

    // Сравнение фото "до"
    final originalBefore = _originalProject.photosBefore;
    final currentBefore = _selectedPhotosBefore.map((f) => f.path).toList();
    if (originalBefore.length != currentBefore.length) return true;
    for (int i = 0; i < originalBefore.length; i++) {
      if (originalBefore[i] != currentBefore[i]) return true;
    }

    // Сравнение фото "после"
    final originalAfter = _originalProject.photosAfter;
    final currentAfter = _selectedPhotosAfter.map((f) => f.path).toList();
    if (originalAfter.length != currentAfter.length) return true;
    for (int i = 0; i < originalAfter.length; i++) {
      if (originalAfter[i] != currentAfter[i]) return true;
    }

    // Результат
    final originalResultStr = _originalProject.result?.toString();
    final currentResultStr = mapStringToProjectResult(_finalResult)?.toString();
    if (originalResultStr != currentResultStr) return true;

    // Если ничего не отличается
    return false;
  }

  // Проверка, что форма заполнена (минимум одно фото "до" и есть категория, имя проекта)
  bool get _isFormValid =>
      _selectedCategory != null &&
      _projectNameController.text.isNotEmpty &&
      (!_showOtherField || _otherCategoryController.text.isNotEmpty) &&
      _selectedPhotosBefore.isNotEmpty;

  // Кнопка "Save" активна, если валидна форма и есть изменения
  bool get _canSave => _isFormValid && _hasChanges;

  @override
  void initState() {
    super.initState();
    _originalProject = widget.existingProject;

    // Инициализация полей
    _selectedCategory = _originalProject.category;
    final knownCategories = ['Renovation', 'Cleaning', 'Training', 'Self-care'];
    _showOtherField = !knownCategories.contains(_selectedCategory);

    if (_showOtherField) {
      _otherCategoryController.text = _originalProject.category;
    }

    _projectNameController.text = _originalProject.projectName;
    _descriptionController.text = _originalProject.description ?? '';

    // Переводим paths -> XFile
    for (final path in _originalProject.photosBefore) {
      _selectedPhotosBefore.add(XFile(path));
    }
    for (final path in _originalProject.photosAfter) {
      _selectedPhotosAfter.add(XFile(path));
    }

    // Результат enum -> строка
    if (_originalProject.result != null) {
      switch (_originalProject.result) {
        case ProjectResult.better:
          _finalResult = 'Better';
          break;
        case ProjectResult.noChange:
          _finalResult = 'No Change';
          break;
        case ProjectResult.worse:
          _finalResult = 'Worse';
          break;
        case null:
          throw UnimplementedError();
      }
    }
  }

  @override
  void dispose() {
    _otherCategoryFocus.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  // Методы добавления/удаления фото
  Future<void> _pickImagesBefore() async {
    try {
      final images = await context.read<ProjectCubit>().pickImages();
      final remainingSlots = 3 - _selectedPhotosBefore.length;
      if (remainingSlots > 0) {
        final newImages = images.take(remainingSlots).toList();
        setState(() => _selectedPhotosBefore.addAll(newImages));
      }
    } catch (e) {
      debugPrint('Error picking images (before): $e');
    }
  }

  void _removePhotoBefore(int index) {
    setState(() => _selectedPhotosBefore.removeAt(index));
  }

  Future<void> _pickImagesAfter() async {
    try {
      final images = await context.read<ProjectCubit>().pickImages();
      final remainingSlots = 3 - _selectedPhotosAfter.length;
      if (remainingSlots > 0) {
        final newImages = images.take(remainingSlots).toList();
        setState(() => _selectedPhotosAfter.addAll(newImages));
      }
    } catch (e) {
      debugPrint('Error picking images (after): $e');
    }
  }

  void _removePhotoAfter(int index) {
    setState(() => _selectedPhotosAfter.removeAt(index));
  }

  // Сохранить
  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) return; // нет изменений

    final updatedProject = Project(
      category:
          _showOtherField ? _otherCategoryController.text : _selectedCategory!,
      projectName: _projectNameController.text,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
      photosBefore: _selectedPhotosBefore.map((x) => x.path).toList(),
      photosAfter: _selectedPhotosAfter.map((x) => x.path).toList(),
      result: mapStringToProjectResult(_finalResult),
    );

    try {
      context.read<ProjectCubit>().updateProject(
        widget.projectIndex,
        updatedProject,
      );
      Navigator.pop(context); // Закрываем экран редактирования
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating project: $e')));
    }
  }

  // Удалить проект
  void _deleteProject() {
    showCupertinoDialogOpenFrame(
      context,
      'Delete Project',
      'Are you sure you want to delete this project?',
      'Delete',
      'Cancel',
      Colors.red,
      () {
        // При подтверждении удаляем проект
        context.read<ProjectCubit>().deleteProject(widget.projectIndex);
        Navigator.pop(context); // Закрываем диалог
      },
    );
  }

  // Обработка нажатия "Назад"
  void _onBackPressed() {
    if (_hasChanges) {
      showCupertinoDialogOpenFrame(
        context,
        'Discard changes?',
        'You have unsaved changes. Leave anyway?',
        'Leave',
        'Cancel',
        Colors.blue,
        () => Navigator.pop(context), // подтверждаем выход
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      // AppBar со стрелкой назад и иконкой удаления
      appBar: CustomAppBarOpenFrame(
        title: 'Edit Project',
        leadingIconPath: 'assets/icons/btn_back.svg',
        onLeadingPressed: _onBackPressed,
        actionIconPath: 'assets/icons/delete.svg',
        color: Colors.red, // для иконки мусорки
        onActionPressed: _deleteProject,
      ),
      body: Stack(
        children: [
          // Основной контент
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Выбор категории
                    _CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                          _showOtherField = (cat == 'Other');
                          if (!_showOtherField) {
                            _otherCategoryController.clear();
                          }
                          _showCustomDropdown = false;
                        });
                      },
                      onDropdownPressed: () {
                        setState(
                          () => _showCustomDropdown = !_showCustomDropdown,
                        );
                      },
                      isDropdownVisible: _showCustomDropdown,
                    ),
                    const SizedBox(height: 15),

                    if (_showOtherField) ...[
                      const Text(
                        'Other Category Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _otherCategoryController,
                        focusNode: _otherCategoryFocus,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Write other category here',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (_showOtherField &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter category name';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Project Name
                    const Text(
                      'Project Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _projectNameController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Project Name',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Please enter project name'
                                  : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Row(
                      children: const [
                        Text(
                          'Project Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '(optional)',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.lightBlueAccent),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Enter Description',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Photos Before
                    _PhotoUploadSection(
                      sectionLabel: 'Photo Before ',
                      photos: _selectedPhotosBefore,
                      onAddPhoto: _pickImagesBefore,
                      onRemovePhoto: _removePhotoBefore,
                    ),
                    const SizedBox(height: 20),

                    // Photos After
                    _PhotoUploadSection(
                      sectionLabel: 'Photo After ',
                      photos: _selectedPhotosAfter,
                      onAddPhoto: _pickImagesAfter,
                      onRemovePhoto: _removePhotoAfter,
                    ),
                    const SizedBox(height: 20),

                    // Final Result (если есть фото "после")
                    if (_selectedPhotosAfter.isNotEmpty) ...[
                      Row(
                        children: const [
                          Text(
                            'Select Final Result',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '(optional)',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _FinalResultSelector(
                        selectedValue: _finalResult,
                        onSelected: (val) {
                          setState(() {
                            _finalResult = val;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Кнопка "Save"
                    ElevatedButton(
                      onPressed: _canSave ? _saveForm : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        disabledBackgroundColor: const Color(0xFF8E8E93),
                        backgroundColor: _canSave ? Colors.blue : Colors.grey,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Если _showCustomDropdown == true, показываем всплывающее окно категорий
          if (_showCustomDropdown)
            Positioned(
              top: 85,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _showCustomDropdown = false),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color.fromARGB(255, 165, 212, 234),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...[
                          'Renovation',
                          'Cleaning',
                          'Training',
                          'Self-care',
                          'Other',
                        ].map((category) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _showOtherField = (category == 'Other');
                                if (category != 'Other') {
                                  _otherCategoryController.clear();
                                }
                                _showCustomDropdown = false;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color:
                                        category == _selectedCategory
                                            ? Color(0xFF4FC3F7)
                                            : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 147, 204, 230),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  category,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------- Виджеты _PhotoUploadSection, _FinalResultSelector и т.д. ----------------------

class _PhotoUploadSection extends StatelessWidget {
  final String sectionLabel;
  final List<XFile> photos;
  final VoidCallback onAddPhoto;
  final Function(int) onRemovePhoto;

  const _PhotoUploadSection({
    required this.sectionLabel,
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              sectionLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text('(maximum of 3 photos)', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: photos.length + 1,
          itemBuilder: (context, index) {
            if (index == photos.length) {
              // Кнопка добавления
              if (photos.length < 3) {
                return _AddPhotoButton(onPressed: onAddPhoto);
              } else {
                return const SizedBox.shrink();
              }
            }
            return _PhotoItem(
              file: File(photos[index].path),
              onDelete: () => onRemovePhoto(index),
            );
          },
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _AddPhotoButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/add_photo.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const _PhotoItem({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.delete, color: Colors.red, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinalResultSelector extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  const _FinalResultSelector({
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final results = ['Better', 'No Change', 'Worse'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          results.map((result) {
            final isSelected = (selectedValue == result);
            return GestureDetector(
              onTap: () => onSelected(result),
              child: Container(
                width: 109,
                height: 45,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4FC3F7) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4FC3F7),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    result,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF4FC3F7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final bool isDropdownVisible;
  final Function(String) onCategorySelected;
  final VoidCallback onDropdownPressed;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onDropdownPressed,
    required this.isDropdownVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDropdownPressed,
          child: Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory ?? 'Select',
                  style: TextStyle(
                    color:
                        selectedCategory != null
                            ? Colors.black
                            : Colors.grey.shade500,
                  ),
                ),
                Icon(
                  isDropdownVisible
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDropdownVisible ? Colors.blue : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
