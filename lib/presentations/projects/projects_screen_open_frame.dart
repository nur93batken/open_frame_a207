import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:open_frame_a207/blocs/project_cubit.dart';
import 'package:open_frame_a207/presentations/projects/edit_project_screen_open_frame.dart';
import 'package:open_frame_a207/presentations/projects/models/poject_model_open_frame.dart';
import 'package:open_frame_a207/widgets/custom_app_bar_open_frame.dart';
import 'package:open_frame_a207/widgets/show_foto_view_dialog.dart';

import 'add_project_open_frame.dart';

class ProjectsScreenOpenFrame extends StatefulWidget {
  const ProjectsScreenOpenFrame({super.key});

  @override
  State<ProjectsScreenOpenFrame> createState() =>
      _ProjectsScreenOpenFrameState();
}

class _ProjectsScreenOpenFrameState extends State<ProjectsScreenOpenFrame> {
  // По умолчанию выбран "All"
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffF7F7F7),
          appBar: CustomAppBarOpenFrame(title: 'Projects'),
          body: BlocBuilder<ProjectCubit, List<Project>>(
            builder: (context, projects) {
              // Если вообще нет проектов
              if (projects.isEmpty) {
                return _EmptyProjectsPlaceholder();
              }

              // Если есть проекты, сначала фильтруем их
              final filteredProjects = _filterProjects(projects);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // ---- Ряд кнопок-фильтров ----
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FilterButton(
                            label: 'All',
                            isSelected: (selectedFilter == 'All'),
                            onTap: () => setState(() => selectedFilter = 'All'),
                          ),
                          _FilterButton(
                            label: 'Better',
                            isSelected: (selectedFilter == 'Better'),
                            onTap:
                                () => setState(() => selectedFilter = 'Better'),
                          ),
                          _FilterButton(
                            label: 'No Change',
                            isSelected: (selectedFilter == 'No Change'),
                            onTap:
                                () => setState(
                                  () => selectedFilter = 'No Change',
                                ),
                          ),
                          _FilterButton(
                            label: 'Worse',
                            isSelected: (selectedFilter == 'Worse'),
                            onTap:
                                () => setState(() => selectedFilter = 'Worse'),
                          ),
                        ],
                      ),
                    ),

                    // ---- Список или заглушка ----
                    filteredProjects.isEmpty
                        ? _WhenIsEmpty(
                          message:
                              (selectedFilter == 'All')
                                  ? 'No added projects yet'
                                  : 'No "$selectedFilter" projects \nadded yet',
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            return _ProjectCard(
                              project: project,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (ctx) => EditProjectOpenFrame(
                                          projectIndex: index,
                                          existingProject: project,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 15,

          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: const Color(0xFF4FC3F7),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const AddProjectOpenFrame(),
                  ),
                );
              },
              child: const Text(
                'Add Project',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Фильтруем проекты по результату
  List<Project> _filterProjects(List<Project> projects) {
    if (selectedFilter == 'All') {
      return projects;
    }

    final resultEnum = mapStringToProjectResult(selectedFilter);
    // Оставляем только проекты, у которых result совпадает
    return projects.where((p) => p.result == resultEnum).toList();
  }
}

/// Заглушка, если в Hive совсем нет проектов
class _EmptyProjectsPlaceholder extends StatelessWidget {
  const _EmptyProjectsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/home.png', height: 120, width: 120),
          20.verticalSpace,
          const Text(
            'No added projects yet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: const Color(0xFF4FC3F7),
              ),
              onPressed: () {
                // Переход на экран добавления
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const AddProjectOpenFrame(),
                  ),
                );
              },
              child: const Text(
                'Add Project',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет, если после фильтра список пуст
class _WhenIsEmpty extends StatelessWidget {
  final String message;
  const _WhenIsEmpty({this.message = 'No added projects yet'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        150.verticalSpace,
        Image.asset('assets/images/home.png', height: 120, width: 120),
        20.verticalSpace,
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Кнопка фильтра (Better / No Change / Worse / All)
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (label == 'No Change') ? 100 : 73,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xffF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4FC3F7), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4FC3F7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок (Project Name)
              Text(
                project.projectName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // -- Если и "до" и "после" содержат ровно по 1 фото,
              //    выводим их в одном ряду (side by side).
              if (project.photosBefore.length == 1 &&
                  project.photosAfter.length == 1)
                _buildSingleRowBeforeAfter(context)
              else
                // Иначе используем стандартный подход
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Блок "Before" ---
                    if (project.photosBefore.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Before',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 122,
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: project.photosBefore.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(width: 8),
                              itemBuilder:
                                  (context, index) => GestureDetector(
                                    onTap: () {
                                      final allImages = project.photosBefore;
                                      final initialIndex =
                                          index; // если хотим открыть именно это фото

                                      showPhotoViewerDialog(
                                        context: context,
                                        images: allImages,
                                        initialIndex: initialIndex,
                                        title: 'Before',
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(project.photosBefore[index]),
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),

                    // --- Если вообще нет фото "до" (по ТЗ можно добавить заглушку,
                    //     но сейчас её нет) ---
                    if (project.photosBefore.isEmpty)
                      const SizedBox(), // Или Text('No "before" photo')

                    const SizedBox(height: 8),

                    // --- Блок "After" ---
                    if (project.photosAfter.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'After',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 122,
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: project.photosAfter.length,
                              separatorBuilder:
                                  (context, index) => const SizedBox(width: 8),
                              itemBuilder:
                                  (context, index) => GestureDetector(
                                    onTap: () {
                                      final allImages = project.photosAfter;
                                      final initialIndex = index;

                                      showPhotoViewerDialog(
                                        context: context,
                                        images: allImages,
                                        initialIndex: initialIndex,
                                        title: 'After',
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(project.photosAfter[index]),
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Если нет ни одной фото "после", показываем заглушку
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'After',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Image.asset(
                            'assets/images/no_photo.png',
                            height: 44,
                            width: 44,
                          ),
                        ],
                      ),
                  ],
                ),

              const SizedBox(height: 8),

              // Строка с категорией и результатом
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Категория
                  Text(
                    project.category,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // Метка результата (Better/No Change/Worse)
                  project.result == null
                      ? const SizedBox.shrink()
                      : _ResultBadge(result: project.result),
                ],
              ),

              const SizedBox(height: 8),
              // Описание или заглушка
              Text(project.description ?? 'No description'),
            ],
          ),
        ),
      ),
    );
  }

  /// Если в `photosBefore` и `photosAfter` ровно по одному фото,
  /// выводим их в одном ряду.
  Widget _buildSingleRowBeforeAfter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Колонка "Before" ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Before',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  final allImages = project.photosBefore;
                  final initialIndex = 0;

                  showPhotoViewerDialog(
                    context: context,
                    images: allImages,
                    initialIndex: initialIndex,
                    title: 'Before',
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(project.photosBefore.first),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // --- Колонка "After" ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'After',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  final allImages = project.photosAfter;
                  final initialIndex = 0;

                  showPhotoViewerDialog(
                    context: context,
                    images: allImages,
                    initialIndex: initialIndex,
                    title: 'After',
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(project.photosAfter.first),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Цветная метка с текстом результата
class _ResultBadge extends StatelessWidget {
  final ProjectResult? result;
  const _ResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    // Получаем цвет и текст
    final color = _getResultColor(result);
    final text = _getResultText(result);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  /// Определяем цвет по результату
  Color _getResultColor(ProjectResult? result) {
    switch (result) {
      case ProjectResult.better:
        return Colors.green; // Better -> зелёный
      case ProjectResult.noChange:
        return Colors.grey; // No Change -> серый
      case ProjectResult.worse:
        return Colors.red; // Worse -> красный
      default:
        return Colors.grey; // null -> тоже серый
    }
  }

  /// Определяем текст по результату
  String _getResultText(ProjectResult? result) {
    switch (result) {
      case ProjectResult.better:
        return 'Better';
      case ProjectResult.noChange:
        return 'No Change';
      case ProjectResult.worse:
        return 'Worse';
      default:
        return 'No Result'; // Если result == null
    }
  }
}
