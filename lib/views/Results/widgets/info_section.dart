import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class infoSection extends StatelessWidget {
  const infoSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            content,
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
