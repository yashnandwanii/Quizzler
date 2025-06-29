import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];
  String _sortBy = 'coins'; // or 'rank'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final query = await FirebaseFirestore.instance.collection('users').get();
    final users = <UserModel>[];
    for (final doc in query.docs) {
      if (doc.data().containsKey('profile')) {
        final profile = doc['profile'];
        users.add(UserModel.fromJson({
          ...profile,
          'coins': doc['coins'] ?? 0,
          'rank': doc['rank'] ?? 0,
        }));
      }
    }
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  List<UserModel> get sortedUsers {
    final users = List<UserModel>.from(_users);
    if (_sortBy == 'coins') {
      users.sort((a, b) => b.coins.compareTo(a.coins));
    } else {
      users.sort((a, b) => a.rank.compareTo(b.rank));
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        ToggleButtons(
                          isSelected: [_sortBy == 'coins', _sortBy == 'rank'],
                          onPressed: (index) {
                            setState(() {
                              _sortBy = index == 0 ? 'coins' : 'rank';
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          selectedColor: Colors.white,
                          fillColor: Colors.blue,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Coins'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Rank'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(24.w),
                      itemCount: sortedUsers.length,
                      itemBuilder: (context, index) {
                        final user = sortedUsers[index];
                        return _buildLeaderboardTile(user, index + 1);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLeaderboardTile(UserModel user, int rank) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 16.w),
          CircleAvatar(
            radius: 28.r,
            backgroundImage: user.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : const AssetImage('assets/app_logo.png') as ImageProvider,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  'Coins: ${user.coins}',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'Rank: #${user.rank}',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
