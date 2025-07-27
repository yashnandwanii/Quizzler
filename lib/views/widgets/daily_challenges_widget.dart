import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/services/daily_challenge_service.dart';

class DailyChallengesWidget extends StatefulWidget {
  const DailyChallengesWidget({super.key});

  @override
  State<DailyChallengesWidget> createState() => _DailyChallengesWidgetState();
}

class _DailyChallengesWidgetState extends State<DailyChallengesWidget> {
  List<DailyChallenge> challenges = [];
  Map<String, int> stats = {};
  bool isLoading = true;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;

    try {
      final userChallenges =
          await DailyChallengeService.getUserDailyChallenges(userId);
      final challengeStats =
          await DailyChallengeService.getChallengeStats(userId);

      setState(() {
        challenges = userChallenges;
        stats = challengeStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (challenges.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedCount = stats['completed'] ?? 0;
    final totalCount = stats['total'] ?? 0;
    final allCompleted = completedCount == totalCount && totalCount > 0;

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allCompleted
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.indigo.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (allCompleted ? Colors.green : Colors.indigo)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (isExpanded) ...[
                  SizedBox(height: 16.h),
                  _buildChallengesList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final completedCount = stats['completed'] ?? 0;
    final totalCount = stats['total'] ?? 0;
    final coinsEarned = stats['coinsEarned'] ?? 0;
    final allCompleted = completedCount == totalCount && totalCount > 0;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            allCompleted ? '🎉' : '🎯',
            style: TextStyle(fontSize: 24.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allCompleted ? 'All Challenges Complete!' : 'Daily Challenges',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                allCompleted
                    ? 'Amazing work! +$coinsEarned coins earned'
                    : '$completedCount/$totalCount completed',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (!allCompleted) ...[
          Container(
            width: 50.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalCount > 0 ? completedCount / totalCount : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 24.sp,
        ),
      ],
    );
  }

  Widget _buildChallengesList() {
    return Column(
      children: challenges
          .map((challenge) => _buildChallengeItem(challenge))
          .toList(),
    );
  }

  Widget _buildChallengeItem(DailyChallenge challenge) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: challenge.isCompleted
            ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Text(
            challenge.icon,
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (challenge.isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                  ],
                ),
                Text(
                  challenge.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                if (!challenge.isCompleted &&
                    challenge.type == 'quiz_count') ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: challenge.progressPercentage,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4.h,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${challenge.progress}/${challenge.targetValue}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${challenge.coinReward} coins',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
