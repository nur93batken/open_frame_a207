import 'package:hive/hive.dart';

part 'notes_model_open_frame.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String date;

  @HiveField(3)
  String category; // "Important", "Urgent", "Think about it"

  Note({
    required this.title,
    required this.content,
    required this.date,
    required this.category,
  });
}
