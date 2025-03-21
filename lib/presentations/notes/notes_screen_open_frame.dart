import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_frame_a207/widgets/app_bar_open_frame.dart';

import '../../blocs/notes_cubit_open_frame.dart';
import '../../blocs/notes_state_open_frame.dart';
import '../../widgets/show_cupertino_dialog_open_fram.dart';
import 'add_edit_note_screen_open_frame.dart';
import 'models/notes_model_open_frame.dart';
import 'package:intl/intl.dart';

class NotesScreenOpenFrame extends StatefulWidget {
  const NotesScreenOpenFrame({super.key});

  @override
  State<NotesScreenOpenFrame> createState() => _NotesScreenOpenFrameState();
}

class _NotesScreenOpenFrameState extends State<NotesScreenOpenFrame> {
  final List<String> categories = [
    "All",
    "Important",
    "Urgent",
    "Think about it",
  ];
  String formatDate(DateTime date) {
    return DateFormat("dd.MM.yyyy, HH:mm").format(date);
  }

  String selectedCategory = "All";
  int countNotes = 0;

  // Кубитти алуу жана санын алуу
  Future<void> _fetchTotalNotesCount(BuildContext context) async {
    int count = await context.read<NotesCubitOpenFrame>().getTotalNotesCount();
    setState(() {
      countNotes = count;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesCubitOpenFrame>().loadNotes();
    });
    _fetchTotalNotesCount(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: CustomAppBar(title: 'Notes'),
      body: BlocBuilder<NotesCubitOpenFrame, NotesStateOpenFrame>(
        builder: (context, state) {
          List<Note> notes = [];
          if (state is NotesLoaded) {
            notes =
                state.notes
                    .where(
                      (note) =>
                          selectedCategory == "All" ||
                          note.category == selectedCategory,
                    )
                    .toList();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                countNotes > 0
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              categories.map((category) {
                                final bool isSelected =
                                    selectedCategory == category;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = category;
                                      });
                                      context
                                          .read<NotesCubitOpenFrame>()
                                          .filterNotes(category);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: ShapeDecoration(
                                        color:
                                            isSelected
                                                ? const Color(0xFF4FC3F7)
                                                : Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          side: BorderSide(
                                            color:
                                                isSelected
                                                    ? Colors.transparent
                                                    : const Color(0xFF4FC3F7),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF4FC3F7),
                                          fontSize: 13,
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w600,
                                          height: 1.38,
                                          letterSpacing: -0.08,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    )
                    : SizedBox(),

                Expanded(
                  child:
                      state is NotesLoaded
                          ? (notes.isNotEmpty
                              ? ListView.builder(
                                itemCount: notes.length,
                                itemBuilder: (context, index) {
                                  final note = notes[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  AddEditNoteScreenOpenFrame(
                                                    note: note,
                                                    noteIndex: index,
                                                  ),
                                        ),
                                      );
                                    },
                                    child: Slidable(
                                      key: Key(note.title),
                                      endActionPane: ActionPane(
                                        motion:
                                            const BehindMotion(), // ✅ Smooth ачылыш үчүн
                                        children: [
                                          SlidableAction(
                                            onPressed: (dialogContext) {
                                              final notesCubit =
                                                  dialogContext
                                                      .read<
                                                        NotesCubitOpenFrame
                                                      >(); // ✅ Алдын ала сактап коёбуз

                                              showCupertinoDialogOpenFrame(
                                                dialogContext,
                                                'Delete note',
                                                'If you delete this note, you will not be able to restore it',
                                                'Delete',
                                                'Cancel',
                                                const Color(0xFFFF3B30),
                                                () {
                                                  // ✅ Flutter иштеп жаткан учурда Cubit чакырабыз
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        if (mounted) {
                                                          notesCubit.deleteNote(
                                                            index,
                                                          ); // ✅ `context`'сиз колдонуу
                                                        }
                                                      });
                                                },
                                              );
                                            },

                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    note.title,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.29,
                                                      letterSpacing: -0.43,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: getCategoryColor(
                                                      note.category,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    note.category,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.38,
                                                      letterSpacing: -0.08,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              formatDate(
                                                DateTime.parse(note.date),
                                              ),
                                              style: const TextStyle(
                                                color: Color(0xFF8E8E93),
                                                fontSize: 13,
                                                fontFamily: 'SF Pro',
                                                fontWeight: FontWeight.w400,
                                                height: 1.38,
                                                letterSpacing: -0.08,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              note.content,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF8E8E93),
                                                fontSize: 13,
                                                fontFamily: 'SF Pro',
                                                fontWeight: FontWeight.w400,
                                                height: 1.38,
                                                letterSpacing: -0.08,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/notes.svg',
                                        width: 120,
                                        height: 120,
                                      ),
                                      Text(
                                        countNotes < 1
                                            ? 'No added notes yet'
                                            : 'No “Think about it” notes added yet',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black /* Grays-Black */,
                                          fontSize: 22,
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w700,
                                          height: 1.27,
                                          letterSpacing: -0.26,
                                        ),
                                      ),
                                      if (countNotes < 1)
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 30),
                                            SizedBox(
                                              width: double.infinity,
                                              height:
                                                  50, // Бираз бийиктик коштук
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              const AddEditNoteScreenOpenFrame(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: const Color(
                                                    0xFF4FC3F7,
                                                  ), // FAB түстүү болот
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ), // Жээк бурчтарын жумшартуу
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Add Note",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontFamily: 'SF Pro',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.29,
                                                    letterSpacing: -0.43,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ))
                          : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar:
          countNotes > 0
              ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 24,
                  left: 10,
                  right: 10,
                ), // 20px өйдө көтөрдүк
                child: SizedBox(
                  width: double.infinity,
                  height: 50, // Бираз бийиктик коштук
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const AddEditNoteScreenOpenFrame(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(
                        0xFF4FC3F7,
                      ), // FAB түстүү болот
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Жээк бурчтарын жумшартуу
                      ),
                    ),
                    child: const Text(
                      "Add Note",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.29,
                        letterSpacing: -0.43,
                      ),
                    ),
                  ),
                ),
              )
              : null,
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
