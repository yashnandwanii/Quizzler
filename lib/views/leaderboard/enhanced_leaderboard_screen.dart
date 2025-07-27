import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/services/leaderboard_service.dart';

class EnhancedLeaderboardScreen extends StatefulWidget {
  const EnhancedLeaderboardScreen({super.key});

  @override
  State<EnhancedLeaderboardScreen> createState() =>
      _EnhancedLeaderboardScreenState();
}

class _EnhancedLeaderboardScreenState extends State<EnhancedLeaderboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() => _isLoading = true);
    try {
      // Get up to 50 users for the leaderboard
      final leaderboard =
          await LeaderboardService.getAllTimeLeaderboard(limit: 50);
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLeaderboardList(_leaderboard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
            Colors.blue.shade900,
          ],
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/score.png',
            height: 30.h,
            width: 30.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          Text(
            'Leaderboards',
            style: GoogleFonts.robotoMono(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loadLeaderboardData,
            child: Image.asset(
              'assets/icons/refresh.png',
              height: 25.h,
              width: 25.w,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> leaderboard) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'No rankings yet',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Play some quizzes to see rankings!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _loadLeaderboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18.sp),
                  SizedBox(width: 8.w),
                  const Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            // Top 3 Podium
            if (leaderboard.length >= 3) _buildTopThreePodium(leaderboard),

            // Section divider and header for remaining rankings
            if (leaderboard.length > 3) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.blue.shade600, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'All Rankings',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${leaderboard.length} players',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // All users from rank 4 onwards (or all users if less than 3)
            if (leaderboard.length >= 3)
              ...leaderboard
                  .asMap()
                  .entries
                  .where((entry) => entry.key >= 3)
                  .map(
                    (entry) =>
                        _buildRegularLeaderboardTile(entry.value, entry.key),
                  )
            else
              // If less than 3 users, show all as regular tiles
              ...leaderboard.asMap().entries.map(
                    (entry) =>
                        _buildRegularLeaderboardTile(entry.value, entry.key),
                  ),

            SizedBox(height: 100.h), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreePodium(List<Map<String, dynamic>> leaderboard) {
    // Ensure we have at least 3 users
    final first = leaderboard.length > 0 ? leaderboard[0] : null;
    final second = leaderboard.length > 1 ? leaderboard[1] : null;
    final third = leaderboard.length > 2 ? leaderboard[2] : null;

    return Container(
      height: 280.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Podium platforms
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place (left)
              if (second != null)
                _buildPodiumPlatform(second, 2, 120.h, Colors.blue),
              SizedBox(width: 8.w),
              // First place (center, tallest)
              if (first != null)
                _buildPodiumPlatform(first, 1, 160.h, Colors.red),
              SizedBox(width: 8.w),
              // Third place (right)
              if (third != null)
                _buildPodiumPlatform(third, 3, 100.h, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlatform(
      Map<String, dynamic> user, int rank, double height, Color color) {
    final crownColor =
        rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey : Colors.brown);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown icon for top 3
        if (rank <= 3)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            child: Icon(
              Icons.emoji_events,
              color: crownColor,
              size: rank == 1 ? 32.sp : 24.sp,
            ),
          ),

        // User avatar
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          child: CircleAvatar(
            radius: rank == 1 ? 35.r : 30.r,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: rank == 1 ? 32.r : 27.r,
              backgroundImage: user['photoUrl'] != null
                  ? NetworkImage(user['photoUrl'])
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: user['photoUrl'] == null
                  ? Icon(Icons.person,
                      size: rank == 1 ? 32.sp : 24.sp,
                      color: Colors.grey.shade600)
                  : null,
            ),
          ),
        ),

        // Platform with user info
        Container(
          width: 100.w,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontSize: rank == 1 ? 16.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  '${user['totalScore'] ?? 0} points',
                  style: GoogleFonts.inter(
                    fontSize: rank == 1 ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularLeaderboardTile(Map<String, dynamic> user, int index) {
    final rank = index + 1;
    final isTopTen = rank <= 10;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isTopTen
            ? Border.all(color: Colors.lightBlueAccent, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number with enhanced styling
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: isTopTen
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              border:
                  isTopTen ? Border.all(color: Colors.amber, width: 1) : null,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isTopTen ? Colors.amber.shade700 : Colors.grey.shade700,
                ),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // User avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: user['photoUrl'] != null
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: user['photoUrl'] == null
                    ? Icon(Icons.person,
                        size: 26.sp, color: Colors.grey.shade600)
                    : null,
              ),
              // Top performer indicator for top 10
              if (isTopTen)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 10.w),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14.sp),
                    SizedBox(width: 1.w),
                    Text(
                      '${user['totalScore'] ?? 0} points',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rank change indicator (for top performers)
          if (isTopTen)
            Column(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16.sp,
                ),
                Text(
                  'Top ${rank}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
