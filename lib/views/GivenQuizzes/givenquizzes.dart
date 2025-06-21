import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Givenquizzes extends StatefulWidget {
  const Givenquizzes({super.key});

  @override
  State<Givenquizzes> createState() => _GivenquizzesState();
}

class _GivenquizzesState extends State<Givenquizzes> {
  final List<Map<String, dynamic>> quizzes = [
    {
      'name': 'Integers Quiz',
      'quizCount': 10,
      'icon': 'assets/maths.png',
    },
    {
      'name': 'General Knowledge',
      'quizCount': 6,
      'icon': 'assets/school.png',
    },
    {
      'name': 'Statistics Math Quiz',
      'quizCount': 12,
      'icon': 'assets/statistics.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EBDF),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Your Quizzes',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Container(
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE7E5F1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4FD),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child:
                                Image.asset(quiz['icon'], fit: BoxFit.contain),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz['name'],
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${quiz['quizCount']} Quizzes',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bar_chart,
                              color: Color(0xFF3D5CFF)),
                          label: const Text(
                            'Result',
                            style: TextStyle(color: Color(0xFF3D5CFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Stack(
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: EdgeInsets.only(left: (18 * i).toDouble()),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/150?img=${i + 4}'),
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
          },
        ),
      ),
    );
  }
}
