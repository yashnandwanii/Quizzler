import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/GivenQuizzes/givenquizzes.dart';

class QuizzesSection extends StatelessWidget {
  const QuizzesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Quizzes',
                style: GoogleFonts.inter(
                    fontSize: 20.sp, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Get.to(
                  () => Givenquizzes(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  fullscreenDialog: true,
                  popGesture: true,
                );
              },
              child: Text(
                'See all',
                style: GoogleFonts.robotoMono(
                    fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
