import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_frame_a207/presentations/projects/add_project_open_frame.dart';
import 'package:open_frame_a207/widgets/app_bar_open_frame.dart';

class ProjectsScreenOpenFrame extends StatefulWidget {
  const ProjectsScreenOpenFrame({super.key});

  @override
  State<ProjectsScreenOpenFrame> createState() =>
      _ProjectsScreenOpenFrameState();
}

class _ProjectsScreenOpenFrameState extends State<ProjectsScreenOpenFrame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),
      appBar: CustomAppBar(title: 'Projects'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/home.png',
              height: 120,
              width: 120,
            ),
          ),
          20.verticalSpace,
          Text(
            'No added projects yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          20.verticalSpace,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(311, 56),
                backgroundColor: Color(0xFF4FC3F7),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProjectOpenFrame(),
                  ),
                );
              },
              child: Text(
                'Add Project',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
