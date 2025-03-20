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
    loadNotes(); // Жаңы жазууну кошкондон кийин кайра жүктөө
  }

  void filterNotes(String category) async {
    var box = await Hive.openBox<Note>(boxName);
    List<Note> notes =
        box.values
            .where((note) => category == "All" || note.category == category)
            .toList();
    emit(NotesLoaded(notes: notes));
  }

  /// 🔥 **Жаңы функция: Бардык жазуулардын санын кайтарат**
  Future<int> getTotalNotesCount() async {
    var box = await Hive.openBox<Note>(boxName);
    return box.length; // Бардык жазуулардын жалпы санын кайтарат
  }

  /// 🔥 **Жаңы функция: Белгилүү бир жазууну өчүрүү**
  void deleteNote(int index) async {
    var box = await Hive.openBox<Note>(boxName);
    await box.deleteAt(index); // Индекстеги жазууну өчүрөт
    loadNotes(); // Өчүргөндөн кийин кайра жүктөө
  }

  void updateNote(int index, Note updatedNote) async {
    var box = await Hive.openBox<Note>(boxName);
    // ✅ Бул log'ду терминалда текшер
    await box.putAt(index, updatedNote); // Note'ту жаңыртуу
    loadNotes(); // Жаңыртуудан кийин кайра жүктөө
  }
}
