import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingPageOpenFrame extends StatefulWidget {
  const SettingPageOpenFrame({super.key});

  @override
  State<SettingPageOpenFrame> createState() => _SettingPageOpenFrameState();
}

class _SettingPageOpenFrameState extends State<SettingPageOpenFrame> {
  final List<String> settings = [
    'Privacy Policy',
    'Terms of Use',
    'Support',
    'Share',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: settings.length,
          itemBuilder:
              (context, index) => SizedBox(
                width: double.infinity,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFBDDFF0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      30.horizontalSpace,
                      Text(
                        settings[index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
