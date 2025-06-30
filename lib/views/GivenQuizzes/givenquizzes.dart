import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/model/quiz_model.dart' as quiz_model;
import 'package:wallpaper_app/model/quiz_history_model.dart' as history_model;

class Givenquizzes extends StatefulWidget {
  const Givenquizzes({super.key});

  @override
  State<Givenquizzes> createState() => _GivenquizzesState();
}

class _GivenquizzesState extends State<Givenquizzes> {
  List<Map<String, dynamic>> recentQuizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentQuizzes();
  }

  Future<void> _fetchRecentQuizzes() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .orderBy('date', descending: true)
        .get();
    final List<Map<String, dynamic>> quizzesWithMeta = [];
    for (final doc in query.docs) {
      final data = doc.data();
      final quizId = data['quizId'];
      final metaDoc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .get();
      if (metaDoc.exists &&
          metaDoc.data() != null &&
          metaDoc.data()!.containsKey('metadata')) {
        quizzesWithMeta.add({
          'meta': metaDoc['metadata'],
          'history': data,
        });
      }
    }
    setState(() {
      recentQuizzes = quizzesWithMeta;
      isLoading = false;
    });
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recentQuizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey.shade300),
                      SizedBox(height: 12.h),
                      Text('No quizzes played yet!',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 18)),
                      SizedBox(height: 6.h),
                      Text('Play a quiz and it will appear here.',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: ListView.builder(
                    itemCount: recentQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = recentQuizzes[index];
                      final meta = quiz_model.QuizMetaModel.fromMap(
                          quiz['meta'] as Map<String, dynamic>);
                      final history = history_model.QuizHistory.fromMap(
                          quiz['history'] as Map<String, dynamic>);
                      debugPrint(meta.title);
                      debugPrint(history.score.toString());
                      debugPrint(
                          history.date.toLocal().toString().split(' ')[0]);
                      debugPrint(meta.imageUrl);
                      debugPrint(meta.category);
                      return _buildQuizHistoryCard(meta, history);
                    },
                  ),
                ),
    );
  }

  Widget _buildQuizHistoryCard(
      quiz_model.QuizMetaModel meta, history_model.QuizHistory history) {
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
          Row(
            children: [
              if (meta.imageUrl.isNotEmpty)
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FD),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(meta.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              if (meta.imageUrl.isEmpty)
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FD),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child:
                      Icon(Icons.quiz, size: 32, color: Colors.grey.shade400),
                ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    meta.category,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Score: ${history.score}',
                    style: TextStyle(
                        color: Colors.deepPurple, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Completed: ${history.date.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart, color: Color(0xFF3D5CFF)),
                label: const Text(
                  'Result',
                  style: TextStyle(color: Color(0xFF3D5CFF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
