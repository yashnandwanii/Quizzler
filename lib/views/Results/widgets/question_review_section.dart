// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:wallpaper_app/views/Results/widgets/question_card.dart';

// class QuestionReviewSection extends StatelessWidget {
//   const QuestionReviewSection({
//     super.key,
//     //required this.widget,
//   });

//   //final ResultsScreen widget;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Question Review',
//             style: GoogleFonts.robotoMono(
//               color: Colors.white,
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             'Tap on each question to see detailed explanations',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14.sp,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: widget.userAnswers.length,
//             itemBuilder: (context, index) {
//               return QuestionCard(
//                   answer: widget.userAnswers[index], questionNumber: index + 1);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
