import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/model/user_model.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({
    super.key,
    required this.wish,
    required this.user,
  });

  final String wish;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wish.toUpperCase(),
              style: GoogleFonts.robotoMono(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            SizedBox(height: 4.h),
            Text(
              user.fullName, // Show first name
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20.r,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : const NetworkImage(
                  'https://cdn.pixabay.com/photo/2014/06/27/16/47/person-378368_1280.png',
                ),
        ),
      ],
    );
  }
}
