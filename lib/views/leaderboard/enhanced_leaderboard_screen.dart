import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/services/leaderboard_service.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';

class EnhancedLeaderboardScreen extends StatefulWidget {
  const EnhancedLeaderboardScreen({super.key});

  @override
  State<EnhancedLeaderboardScreen> createState() => _EnhancedLeaderboardScreenState();
}

class _EnhancedLeaderboardScreenState extends State<EnhancedLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _weeklyLeaderboard = [];
  Map<String, int> _userRank = {'globalRank': -1, 'weeklyRank': -1};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;

      // Load both leaderboards concurrently
      final results = await Future.wait([
        LeaderboardService.getGlobalLeaderboard(),
        LeaderboardService.getWeeklyLeaderboard(),
        if (userId != null) LeaderboardService.getUserRank(userId),
      ]);

      setState(() {
        _globalLeaderboard = results[0] as List<Map<String, dynamic>>;
        _weeklyLeaderboard = results[1] as List<Map<String, dynamic>>;
        if (results.length > 2) {
          _userRank = results[2] as Map<String, int>;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
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
            _buildUserRankCard(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLeaderboardList(_globalLeaderboard),
                        _buildLeaderboardList(_weeklyLeaderboard),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.leaderboard, color: Colors.white, size: 28.sp),
          SizedBox(width: 12.w),
          Text(
            'Leaderboard',
            style: GoogleFonts.robotoMono(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadLeaderboardData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankCard() {
    final authRepo = Get.find<AuthenticationRepository>();
    final user = authRepo.firebaseUser.value;
    
    if (user == null) return const SizedBox();

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!)
                : const AssetImage('assets/app_logo.png') as ImageProvider,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'You',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your Rankings',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildRankBadge('Global', _userRank['globalRank'] ?? -1, Colors.blue),
          SizedBox(width: 8.w),
          _buildRankBadge('Weekly', _userRank['weeklyRank'] ?? -1, Colors.green),
        ],
      ),
    );
  }

  Widget _buildRankBadge(String label, int rank, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            rank > 0 ? '#$rank' : '--',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(12.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        tabs: const [
          Tab(text: 'All Time'),
          Tab(text: 'This Week'),
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboardData,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          return _buildLeaderboardTile(user, index);
        },
      ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> user, int index) {
    final rank = user['rank'] ?? (index + 1);
    final isTopThree = rank <= 3;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isTopThree ? _getTopThreeColor(rank).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isTopThree 
            ? Border.all(color: _getTopThreeColor(rank), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRankIcon(rank),
          SizedBox(width: 16.w),
          CircleAvatar(
            radius: 24.r,
            backgroundImage: user['photoUrl']?.isNotEmpty == true
                ? NetworkImage(user['photoUrl'])
                : const AssetImage('assets/app_logo.png') as ImageProvider,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullName'] ?? user['userName'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${user['totalScore'] ?? 0} points',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.monetization_on, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${user['coins'] ?? 0} coins',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isTopThree)
            Icon(
              Icons.emoji_events,
              color: _getTopThreeColor(rank),
              size: 24.sp,
            ),
        ],
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank <= 3) {
      return Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: _getTopThreeColor(rank),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Color _getTopThreeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.blue;
    }
  }
}