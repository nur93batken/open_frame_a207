import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/notes_cubit_open_frame.dart';
import 'presentations/notes/models/notes_model_open_frame.dart';
import 'presentations/notes/notes_screen_open_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => NotesCubitOpenFrame())],
      child: MaterialApp(
        title: 'Open Frame A207',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4FC3F7)),
        ),
        home: NotesScreenOpenFrame(),
      ),
    );
  }
}
