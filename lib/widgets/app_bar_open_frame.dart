import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leadingIconPath,
    this.actionIconPath,
    this.onLeadingPressed,
    this.onActionPressed,
    this.color,
  });

  final String title;
  final String? leadingIconPath;
  final String? actionIconPath;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onActionPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading:
          leadingIconPath != null
              ? IconButton(
                onPressed: onLeadingPressed ?? () => Navigator.pop(context),
                icon: SvgPicture.asset(leadingIconPath!, width: 24, height: 24),
              )
              : null,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black /* Grays-Black */,
          fontSize: 20,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.45,
        ),
      ),
      actions: [
        if (actionIconPath != null)
          IconButton(
            onPressed: onActionPressed ?? () {},
            icon: SvgPicture.asset(
              actionIconPath!,
              width: 24,
              height: 24,
              color: color,
            ),
          ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
