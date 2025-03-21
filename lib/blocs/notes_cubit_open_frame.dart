import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import '../presentations/notes/models/notes_model_open_frame.dart';
import 'notes_state_open_frame.dart';

class NotesCubitOpenFrame extends Cubit<NotesStateOpenFrame> {
  NotesCubitOpenFrame() : super(NotesInitial());

  final String boxName = 'notesBox';

  void loadNotes() async {
    var box = await Hive.openBox<Note>(boxName);
    List<Note> notes = box.values.toList();
    emit(NotesLoaded(notes: notes));
  }

  void addNote(Note note) async {
    var box = await Hive.openBox<Note>(boxName);
    await box.add(note);
    loadNotes();
  }

  void filterNotes(String category) async {
    var box = await Hive.openBox<Note>(boxName);
    List<Note> notes =
        box.values
            .where((note) => category == "All" || note.category == category)
            .toList();
    emit(NotesLoaded(notes: notes));
  }

  /// 🔥 **Бардык жазуулардын санын кайтарат**
  Future<int> getTotalNotesCount() async {
    var box = await Hive.openBox<Note>(boxName);
    return box.length;
  }

  /// 🔥 **Белгилүү бир жазууну өчүрүү**
  void deleteNote(int index) async {
    var box = await Hive.openBox<Note>(boxName);
    await box.deleteAt(index);
    loadNotes();
  }

  /// 🔥 **Жазууну жаңыртуу**
  void updateNote(int index, Note updatedNote) async {
    var box = await Hive.openBox<Note>(boxName);
    await box.putAt(index, updatedNote);
    loadNotes();
  }

  /// 🔥 **Категориялар боюнча жазуулардын санын кайтаруу**
  Future<Map<String, int>> getNotesByCategory() async {
    var box = await Hive.openBox<Note>(boxName);
    List<Note> notes = box.values.toList();

    int important = notes.where((note) => note.category == "Important").length;
    int urgent = notes.where((note) => note.category == "Urgent").length;
    int thinkAboutIt =
        notes.where((note) => note.category == "Think about it").length;

    return {
      "Important": important,
      "Urgent": urgent,
      "Think about it": thinkAboutIt,
      "Total": notes.length,
    };
  }

  /// 🔥 **Категориялар боюнча пайыздык көрсөткүчтөрдү кайтаруу**
  Future<Map<String, double>> getCategoryPercentage() async {
    var box = await Hive.openBox<Note>(boxName);
    List<Note> notes = box.values.toList();
    int total = notes.length;

    if (total == 0) {
      return {"Important": 0.0, "Urgent": 0.0, "Think about it": 0.0};
    }

    double important =
        (notes.where((note) => note.category == "Important").length / total) *
        100;
    double urgent =
        (notes.where((note) => note.category == "Urgent").length / total) * 100;
    double thinkAboutIt =
        (notes.where((note) => note.category == "Think about it").length /
            total) *
        100;

    return {
      "Important": important,
      "Urgent": urgent,
      "Think about it": thinkAboutIt,
    };
  }
}
