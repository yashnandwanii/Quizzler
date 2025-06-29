import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Optional background color for visibility
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: const <TextSpan>[
            TextSpan(
                text: 'Wallpaper',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' Master!', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    debugPrint("preferredSize getter called");

    return const Size.fromHeight(60);
  }
}
