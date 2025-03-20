import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_frame_a207/widgets/app_bar_open_frame.dart';
import '../../blocs/notes_cubit_open_frame.dart';
import 'models/notes_model_open_frame.dart';

class AddEditNoteScreenOpenFrame extends StatefulWidget {
  final Note? note;
  final int? noteIndex;

  const AddEditNoteScreenOpenFrame({super.key, this.note, this.noteIndex});

  @override
  State<AddEditNoteScreenOpenFrame> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreenOpenFrame> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _categories = ["Important", "Urgent", "Think about it"];
  String _selectedCategory = "Important";
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.content;
      _selectedCategory = widget.note!.category;
    }
    _titleController.addListener(_validateFields);
    _descriptionController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      _isButtonEnabled =
          _titleController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        appBar: CustomAppBar(
          title: widget.note == null ? 'Add Note' : 'Edit Note',
          leadingIconPath: 'assets/icons/btn_back.svg',
          onLeadingPressed: () => Navigator.pop(context),
          actionIconPath:
              widget.note == null ? null : 'assets/icons/delete.svg',
          color: Colors.red,
          onActionPressed: () {
            if (widget.note != null) {
              BlocProvider.of<NotesCubitOpenFrame>(
                context,
              ).deleteNote(widget.noteIndex!);
              Navigator.pop(context);
            }
          },
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Note Name",
                      style: TextStyle(
                        color: Colors.black /* Grays-Black */,
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      cursorColor: const Color(0xFF4FC3F7),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black /* Grays-Black */,
                        fontSize: 15,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        letterSpacing: -0.23,
                      ),

                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Enter project name",
                        hintStyle: TextStyle(
                          color: Colors.black /* Grays-Black */,
                          fontSize: 15,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          letterSpacing: -0.23,
                        ),
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF4FC3F7),
                            /* Grays-Black */
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            /* Grays-Black */
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Note Description",
                      style: TextStyle(
                        color: Colors.black /* Grays-Black */,
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      maxLines: 15,
                      minLines: 7,
                      cursorColor: const Color(0xFF4FC3F7),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.black /* Grays-Black */,
                        fontSize: 15,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        letterSpacing: -0.23,
                      ),

                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: TextStyle(
                          color: Colors.black /* Grays-Black */,
                          fontSize: 15,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          letterSpacing: -0.23,
                        ),
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF4FC3F7),
                            /* Grays-Black */
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            /* Grays-Black */
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Note Tag",
                      style: TextStyle(
                        color: Colors.black /* Grays-Black */,
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    SizedBox(height: 8),
                    widget.note != null
                        ? Wrap(
                          spacing: 8,
                          children:
                              _categories.map((category) {
                                final bool isSelected =
                                    _selectedCategory == category;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    height: 40,

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? getCategoryColor(category)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: getCategoryColor(category),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : getCategoryColor(category),
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w400,
                                        height: 1.38,
                                        letterSpacing: -0.08,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        )
                        : Wrap(
                          spacing: 8,
                          children:
                              _categories.map((category) {
                                final bool isSelected =
                                    _selectedCategory == category;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    height: 40,

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? getCategoryColor(
                                                _selectedCategory,
                                              )
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? getCategoryColor(category)
                                                : Color(0xFF4FC3F7),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Color(0xFF4FC3F7),
                                        fontSize: 13,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w400,
                                        height: 1.38,
                                        letterSpacing: -0.08,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
            ),
            Align(
              // Өйдө жылдыруу
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 24,
                  left: 16,
                  right: 16,
                ), // Өйдө жылдыруу
                // ignore: sized_box_for_whitespace
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isButtonEnabled
                            ? () {
                              final title = _titleController.text.trim();
                              final description =
                                  _descriptionController.text.trim();

                              final newNote = Note(
                                title: title,
                                content: description,
                                date: DateTime.now().toString(),
                                category:
                                    _selectedCategory, // ✅ Жаңы категория туура берилди
                              );

                              final cubit = context.read<NotesCubitOpenFrame>();

                              if (widget.note == null) {
                                cubit.addNote(newNote);
                              } else {
                                if (widget.noteIndex != null) {
                                  cubit.updateNote(widget.noteIndex!, newNote);
                                }
                              }

                              Navigator.pop(context);
                              cubit.getTotalNotesCount();
                            }
                            : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isButtonEnabled
                              ? Color(0xFF4FC3F7)
                              : Color(0xFF8E8E93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.note == null ? "Add" : "Update",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "Important":
        return Color(0xFFFF9500);
      case "Urgent":
        return Color(0xFFFF3B30);
      case "Think about it":
        return Color(0xFF34C759);
      case "Work":
        return Colors.blueAccent;
      case "Personal":
        return Colors.purple;
      case "Health":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
