import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/views/categories/categories_screen.dart';

class CategoriesShowcase extends StatelessWidget {
  const CategoriesShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Linux',
        'description': 'Commands, system administration, bash scripting',
        'icon': Icons.terminal,
        'color': const Color(0xFF4CAF50),
        'difficulty': 'Medium',
      },
      {
        'name': 'DevOps',
        'description': 'CI/CD, automation, infrastructure',
        'icon': Icons.settings_applications,
        'color': const Color(0xFF2196F3),
        'difficulty': 'Hard',
      },
      {
        'name': 'Networking',
        'description': 'Protocols, security, infrastructure',
        'icon': Icons.network_check,
        'color': const Color(0xFFFF9800),
        'difficulty': 'Medium',
      },
      {
        'name': 'Programming',
        'description': 'Languages, algorithms, development',
        'icon': Icons.code,
        'color': const Color(0xFF9C27B0),
        'difficulty': 'Medium',
      },
      {
        'name': 'Cloud Computing',
        'description': 'AWS, Azure, GCP, serverless',
        'icon': Icons.cloud,
        'color': const Color(0xFF795548),
        'difficulty': 'Hard',
      },
      {
        'name': 'Docker',
        'description': 'Containerization, best practices',
        'icon': Icons.inventory_2,
        'color': const Color(0xFFE91E63),
        'difficulty': 'Medium',
      },
      {
        'name': 'Kubernetes',
        'description': 'Container orchestration, K8s concepts',
        'icon': Icons.hub,
        'color': const Color(0xFF673AB7),
        'difficulty': 'Hard',
      },
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.category,
                color: Colors.blue.shade700,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Quiz Categories',
                style: GoogleFonts.robotoMono(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Get.to(
                    () => const CategoriesScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 400),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            '7 comprehensive categories to test your knowledge',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 20.h),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: categories.length > 6
                ? 6
                : categories.length, // Show max 6, save space for "View All"
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = category['color'] as Color;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        size: 28.sp,
                        color: color,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Name
                    Text(
                      category['name'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Difficulty badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        category['difficulty'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        category['description'] as String,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Show "+1 more" if there are more than 6 categories
          if (categories.length > 6) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                Get.to(
                  () => const CategoriesScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 400),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '+${categories.length - 6} more categories',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
