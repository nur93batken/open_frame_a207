import '../presentations/notes/models/notes_model_open_frame.dart';

abstract class NotesStateOpenFrame {}

class NotesInitial extends NotesStateOpenFrame {}

class NotesLoaded extends NotesStateOpenFrame {
  final List<Note> notes;
  NotesLoaded({required this.notes});
}
