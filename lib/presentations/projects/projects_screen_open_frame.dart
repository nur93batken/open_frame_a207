import 'package:flutter/material.dart';
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
    return Scaffold(appBar: CustomAppBar(title: 'Projects'));
  }
}
