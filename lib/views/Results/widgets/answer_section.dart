import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class answerSection extends StatelessWidget {
  const answerSection({
    super.key,
    required this.title,
    required this.answer,
    required this.color,
    required this.icon,
  });

  final String title;
  final String answer;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 6.w),
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
