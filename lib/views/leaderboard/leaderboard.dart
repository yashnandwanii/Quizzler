// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // A placeholder model for user data.
// class _LeaderboardUser {
//   final String name;
//   final int score;
//   final String avatarUrl; // Using network images for simplicity
//   final String flagUrl;

//   const _LeaderboardUser({
//     required this.name,
//     required this.score,
//     required this.avatarUrl,
//     required this.flagUrl,
//   });
// }

// class LeaderboardScreen extends StatefulWidget {
//   const LeaderboardScreen({super.key});

//   @override
//   State<LeaderboardScreen> createState() => _LeaderboardScreenState();
// }

// class _LeaderboardScreenState extends State<LeaderboardScreen> {
//   // Dummy data for the leaderboard
//   final List<_LeaderboardUser> _users = [
//     _LeaderboardUser(
//         name: 'Davis Curtis',
//         score: 2569,
//         avatarUrl: 'https://i.pravatar.cc/150?img=1',
//         flagUrl: ''),
//     _LeaderboardUser(
//         name: 'Alena Donin',
//         score: 1469,
//         avatarUrl: 'https://i.pravatar.cc/150?img=2',
//         flagUrl: ''),
//     _LeaderboardUser(
//         name: 'Craig Gouse',
//         score: 1053,
//         avatarUrl: 'https://i.pravatar.cc/150?img=3',
//         flagUrl: ''),
//     _LeaderboardUser(
//         name: 'Madelyn Dias',
//         score: 590,
//         avatarUrl: 'https://i.pravatar.cc/150?img=4',
//         flagUrl: 'https://flagcdn.com/w40/hu.png'),
//     _LeaderboardUser(
//         name: 'Zain Vaccaro',
//         score: 448,
//         avatarUrl: 'https://i.pravatar.cc/150?img=5',
//         flagUrl: 'https://flagcdn.com/w40/it.png'),
//     _LeaderboardUser(
//         name: 'Skylar Geidt',
//         score: 448,
//         avatarUrl: 'https://i.pravatar.cc/150?img=6',
//         flagUrl: 'https://flagcdn.com/w40/cz.png'),
//     _LeaderboardUser(
//         name: 'User 7',
//         score: 300,
//         avatarUrl: 'https://i.pravatar.cc/150?img=7',
//         flagUrl: 'https://flagcdn.com/w40/us.png'),
//   ];

//   bool _isWeekly = true;

//   @override
//   Widget build(BuildContext context) {
//     // Separate top 3 from the rest
//     final topThree = _users.take(3).toList();
//     final restOfUsers = _users.skip(3).toList();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             _buildToggle(),
//             SizedBox(height: 24.h),
//             _buildPodium(topThree),
//             SizedBox(height: 24.h),
//             _buildLeaderboardList(restOfUsers),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//       child: const Text(
//         'Leaderboard',
//         style: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget _buildToggle() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 24.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(24.r),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () => setState(() => _isWeekly = true),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12.h),
//                 decoration: BoxDecoration(
//                   color: _isWeekly ? Colors.blue : Colors.transparent,
//                   borderRadius: BorderRadius.circular(24.r),
//                 ),
//                 child: Text(
//                   'Weekly',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: _isWeekly ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () => setState(() => _isWeekly = false),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12.h),
//                 decoration: BoxDecoration(
//                   color: !_isWeekly ? Colors.blue : Colors.transparent,
//                   borderRadius: BorderRadius.circular(24.r),
//                 ),
//                 child: Text(
//                   'All Time',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: !_isWeekly ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPodium(List<_LeaderboardUser> topThree) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPodiumMember(topThree[1], 2, 120.h), // 2nd place
//           _buildPodiumMember(topThree[0], 1, 150.h), // 1st place
//           _buildPodiumMember(topThree[2], 3, 100.h), // 3rd place
//         ],
//       ),
//     );
//   }

//   Widget _buildPodiumMember(_LeaderboardUser user, int rank, double height) {
//     final colors = [
//       const [Color(0xFFFFD700), Color(0xFFFFA500)], // 1st
//       const [Color(0xFFC0C0C0), Color(0xFFA9A9A9)], // 2nd
//       const [Color(0xFFCD7F32), Color(0xFFB87333)], // 3rd
//     ];
//     final podiumColors = [
//       const Color(0xFFFF5C5C),
//       const Color(0xFF6A82FF),
//       const Color(0xFFAD5CFF),
//     ];

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Stack(
//           alignment: Alignment.topCenter,
//           clipBehavior: Clip.none,
//           children: [
//             Positioned(
//               top: -25,
//               child: Icon(Icons.emoji_events,
//                   color: colors[rank - 1][0], size: 30),
//             ),
//             CircleAvatar(
//               radius: 30.r,
//               backgroundImage: NetworkImage(user.avatarUrl),
//             ),
//           ],
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           height: height,
//           width: 100.w,
//           decoration: BoxDecoration(
//             color: podiumColors[rank - 1],
//             borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 user.name,
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 '${user.score} points',
//                 style: const TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLeaderboardList(List<_LeaderboardUser> users) {
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//         ),
//         child: ListView.builder(
//           padding: EdgeInsets.all(16.w),
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final user = users[index];
//             return _buildListTile(user, index + 4);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildListTile(_LeaderboardUser user, int rank) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Text('$rank',
//               style:
//                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           SizedBox(width: 16.w),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               CircleAvatar(
//                 radius: 24.r,
//                 backgroundImage: NetworkImage(user.avatarUrl),
//               ),
//               Positioned(
//                 bottom: -4,
//                 right: -8,
//                 child: CircleAvatar(
//                   radius: 10.r,
//                   backgroundImage: NetworkImage(user.flagUrl),
//                   backgroundColor: Colors.transparent,
//                 ),
//               )
//             ],
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(user.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text('${user.score} points',
//                     style: const TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
