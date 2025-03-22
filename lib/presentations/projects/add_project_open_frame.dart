import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_frame_a207/blocs/project_cubit.dart';
import 'package:open_frame_a207/presentations/projects/models/poject_model_open_frame.dart';

class AddProjectOpenFrame extends StatefulWidget {
  const AddProjectOpenFrame({super.key});

  @override
  State<AddProjectOpenFrame> createState() => _AddProjectOpenFrameState();
}

class _AddProjectOpenFrameState extends State<AddProjectOpenFrame> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final FocusNode _otherCategoryFocus = FocusNode();

  bool _showCustomDropdown = false;

  final List<XFile> _selectedPhotosBefore = [];

  final List<XFile> _selectedPhotosAfter = [];

  String? _selectedCategory;
  bool _showOtherField = false;

  String? _finalResult;

  bool _isLoading = false;

  bool get _isFormValid =>
      _selectedCategory != null &&
      _projectNameController.text.isNotEmpty &&
      (!_showOtherField || _otherCategoryController.text.isNotEmpty) &&
      _selectedPhotosBefore.isNotEmpty;

  Future<void> _pickImagesBefore() async {
    setState(() => _isLoading = true);
    try {
      final images = await context.read<ProjectCubit>().pickImages();
      final remainingSlots = 3 - _selectedPhotosBefore.length;
      if (remainingSlots > 0) {
        final newImages = images.take(remainingSlots).toList();
        setState(() => _selectedPhotosBefore.addAll(newImages));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhotoBefore(int index) {
    setState(() => _selectedPhotosBefore.removeAt(index));
  }

  Future<void> _pickImagesAfter() async {
    setState(() => _isLoading = true);
    try {
      final images = await context.read<ProjectCubit>().pickImages();
      final remainingSlots = 3 - _selectedPhotosAfter.length;
      if (remainingSlots > 0) {
        final newImages = images.take(remainingSlots).toList();
        setState(() => _selectedPhotosAfter.addAll(newImages));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhotoAfter(int index) {
    setState(() => _selectedPhotosAfter.removeAt(index));
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final project = Project(
      category:
          _showOtherField ? _otherCategoryController.text : _selectedCategory!,
      projectName: _projectNameController.text,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,

      photosBefore: _selectedPhotosBefore.map((file) => file.path).toList(),

      photosAfter: _selectedPhotosAfter.map((file) => file.path).toList(),

      result: _finalResult,
    );

    try {
      setState(() => _isLoading = true);
      await context.read<ProjectCubit>().addProjectWithPhotos(
        project,
        _selectedPhotosBefore,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(title: const Text('Add Project')),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                          _showOtherField = (category == 'Other');
                          if (category != 'Other') {
                            _otherCategoryController.clear();
                          }
                          _showCustomDropdown = false;
                        });
                        if (_showOtherField) {
                          Future.delayed(Duration.zero, () {
                            _otherCategoryFocus.requestFocus();
                          });
                        }
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
                      10.verticalSpace,
                      TextFormField(
                        controller: _otherCategoryController,
                        focusNode: _otherCategoryFocus,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Write other platform here',
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

                    Text(
                      'Project Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    10.verticalSpace,
                    TextFormField(
                      controller: _projectNameController,
                      decoration: InputDecoration(
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

                    Row(
                      children: [
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
                    10.verticalSpace,
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Enter Description',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _PhotoUploadSection(
                      sectionLabel: 'Photo Before',
                      photos: _selectedPhotosBefore,
                      onAddPhoto: _pickImagesBefore,
                      onRemovePhoto: _removePhotoBefore,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 30),

                    if (_selectedCategory != null) ...[
                      _PhotoUploadSection(
                        sectionLabel: 'Photo After',
                        photos: _selectedPhotosAfter,
                        onAddPhoto: _pickImagesAfter,
                        onRemovePhoto: _removePhotoAfter,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Select Final Result (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _FinalResultSelector(
                        selectedValue: _finalResult,
                        onSelected: (value) {
                          setState(() {
                            _finalResult = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                    ],

                    ElevatedButton(
                      onPressed: _isFormValid ? _submitForm : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        disabledBackgroundColor: const Color(0xFF8E8E93),
                        backgroundColor:
                            _isFormValid
                                ? const Color(0xFF4FC3F7)
                                : Colors.grey,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showCustomDropdown)
            Positioned(
              top: 90,
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
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color.fromARGB(255, 147, 204, 230),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        category == 'Other'
                                            ? Colors.blue
                                            : Colors.grey.shade600,
                                  ),
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

class _PhotoUploadSection extends StatelessWidget {
  final String sectionLabel;
  final List<XFile> photos;
  final VoidCallback onAddPhoto;
  final Function(int) onRemovePhoto;
  final bool isLoading;

  const _PhotoUploadSection({
    required this.sectionLabel,
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.isLoading,
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
            const Text(
              '(maximum of 3 photos)',
              style: TextStyle(color: Colors.grey),
            ),
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
              return _AddPhotoButton(
                onPressed: photos.length < 3 ? onAddPhoto : null,
                isLoading: isLoading,
              );
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
  final bool isLoading;

  const _AddPhotoButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
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
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          results.map((result) {
            final isSelected = (selectedValue == result);
            return ChoiceChip(
              label: Text(result),
              selected: isSelected,
              onSelected: (bool selected) {
                onSelected(selected ? result : null);
              },
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
    );
  }
}
