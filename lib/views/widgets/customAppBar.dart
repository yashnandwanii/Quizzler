import 'package:flutter/material.dart';

class Customappbar extends StatelessWidget implements PreferredSizeWidget {
  const Customappbar({super.key});

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
    print("preferredSize getter called");
    return const Size.fromHeight(60);
  }
}
