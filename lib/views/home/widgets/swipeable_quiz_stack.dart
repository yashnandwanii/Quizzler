// swipeable_quiz_stack.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'quiz_card.dart';

class SwipeableQuizStack extends StatefulWidget {
  final List<Map<String, dynamic>> quizCards;

  const SwipeableQuizStack({super.key, required this.quizCards});

  @override
  State<SwipeableQuizStack> createState() => _SwipeableQuizStackState();
}

class _SwipeableQuizStackState extends State<SwipeableQuizStack> {
  late List<Map<String, dynamic>> localQuizCards;

  @override
  void initState() {
    super.initState();
    localQuizCards = List.from(widget.quizCards);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: localQuizCards
            .asMap()
            .entries
            .map((entry) {
              int index = entry.key;
              final card = entry.value;

              if (index > 2) return const SizedBox();

              double topOffset = 10.0 * index;
              double scale = 1.0 - (0.05 * index);

              return Positioned(
                top: topOffset.h,
                child: AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Dismissible(
                    key: Key(card['title']),
                    direction: DismissDirection.horizontal,
                    resizeDuration: const Duration(milliseconds: 300),
                    onDismissed: (direction) {
                      setState(() {
                        final removed = localQuizCards.removeAt(0);
                        localQuizCards.add(removed);
                      });
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.transparent),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Colors.transparent.withValues(alpha: 0.2),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child:
                          const Icon(Icons.arrow_forward, color: Colors.green),
                    ),
                    child: QuizCard(
                      title: card['title'],
                      category: card['category'],
                      duration: card['duration'],
                      quizzes: card['quizzes'],
                      sharedBy: card['sharedBy'],
                      avatarUrl: card['image'],
                      backgroundColor: card['color'],
                      context: context,
                    ),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }
}
