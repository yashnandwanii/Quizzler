import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.feedback,
  });

  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image(
                image: const AssetImage('assets/trophy.png'),
                height: 120.h,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Quiz Completed!',
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            feedback,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
