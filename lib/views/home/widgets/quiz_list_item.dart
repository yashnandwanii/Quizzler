import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/home/home_screen.dart';

class quizListItem extends StatelessWidget {
  const quizListItem({
    super.key,
    required this.category,
  });

  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Image.asset(category.iconPath, width: 30.w),
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text('${category.quizCount} Quizzes',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart, color: Color(0xFF3D5CFF)),
                  label: const Text(
                    'Results',
                    style: TextStyle(color: Color.fromARGB(255, 37, 72, 243)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Stack(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: (18 * index).toDouble()),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=${index + 4}'),
                    ),
                  );
                }),
              ),
              SizedBox(width: (18 * 3).w + 8.w),
              Text(
                '+437 People join',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
