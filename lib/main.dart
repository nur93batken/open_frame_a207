import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_frame_a207/blocs/project_cubit.dart';
import 'package:open_frame_a207/presentations/projects/models/poject_model_open_frame.dart';

import 'blocs/notes_cubit_open_frame.dart';
import 'presentations/main/splash_screen_open_frame.dart';
import 'presentations/notes/models/notes_model_open_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ProjectResultAdapter());
  final projectsBox = await Hive.openBox<Project>('projectsBox');

  runApp(MyApp(projectsBox: projectsBox));
}

class MyApp extends StatelessWidget {
  final Box<Project> projectsBox;

  const MyApp({super.key, required this.projectsBox});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotesCubitOpenFrame()),
        BlocProvider(create: (context) => ProjectCubit(projectsBox)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp(
          title: 'Open Frame A207',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4FC3F7)),
          ),
          home: SplashScreenOpenFrame(),
        ),
      ),
    );
  }
}
