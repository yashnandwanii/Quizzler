import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onClick,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onClick;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blue.withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          size: 35,
        ),
      ),
      title: Text(title,
          style: textColor != null
              ? const TextStyle(fontSize: 18)
              : TextStyle(fontSize: 18, color: textColor)),
      trailing: endIcon
          ? Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.keyboard_arrow_right,
                size: 35,
              ),
            )
          : null,
    );
  }
}
