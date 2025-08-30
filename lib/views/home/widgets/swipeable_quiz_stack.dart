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

class _SwipeableQuizStackState extends State<SwipeableQuizStack>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> localQuizCards;
  late AnimationController _swipeHintController;
  late AnimationController _bubbleController;
  late Animation<double> _swipeHintAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _bubbleOpacityAnimation;
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    localQuizCards = List.from(widget.quizCards);

    // Initialize swipe hint animation
    _swipeHintController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _swipeHintAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _swipeHintController,
      curve: Curves.easeInOut,
    ));

    _bubbleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.elasticInOut,
    ));

    _bubbleOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));

    // Start animations after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_hasUserInteracted) {
        _startSwipeHintAnimation();
        _startBubbleAnimation();
      }
    });
  }

  void _startSwipeHintAnimation() {
    if (!_hasUserInteracted && mounted) {
      _swipeHintController.forward().then((_) {
        if (mounted && !_hasUserInteracted) {
          _swipeHintController.reverse().then((_) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted && !_hasUserInteracted) {
                _startSwipeHintAnimation();
              }
            });
          });
        }
      });
    }
  }

  void _startBubbleAnimation() {
    if (!_hasUserInteracted && mounted) {
      _bubbleController.forward().then((_) {
        if (mounted && !_hasUserInteracted) {
          _bubbleController.reverse().then((_) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && !_hasUserInteracted) {
                _startBubbleAnimation();
              }
            });
          });
        }
      });
    }
  }

  void _onUserInteraction() {
    setState(() {
      _hasUserInteracted = true;
    });
    _swipeHintController.stop();
    _bubbleController.stop();
  }

  @override
  void dispose() {
    _swipeHintController.dispose();
    _bubbleController.dispose();
    super.dispose();
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
        children: [
          // Animated bubble indicators
          if (!_hasUserInteracted) ...[
            // Left swipe bubble
            AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, child) {
                return Positioned(
                  left: 20.w,
                  top: 140.h,
                  child: Transform.scale(
                    scale: _bubbleAnimation.value,
                    child: Opacity(
                      opacity: _bubbleOpacityAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Right swipe bubble
            AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, child) {
                return Positioned(
                  right: 20.w,
                  top: 140.h,
                  child: Transform.scale(
                    scale: _bubbleAnimation.value,
                    child: Opacity(
                      opacity: _bubbleOpacityAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          // Quiz cards with swipe hint animation
          ...localQuizCards
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
                  child: AnimatedBuilder(
                    animation: _swipeHintAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: index == 0 && !_hasUserInteracted
                            ? Offset(_swipeHintAnimation.value, 0)
                            : Offset.zero,
                        child: AnimatedScale(
                          scale: scale,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: GestureDetector(
                            onPanStart: (_) => _onUserInteraction(),
                            onTap: () => _onUserInteraction(),
                            child: Dismissible(
                              key: Key(card['title']),
                              direction: DismissDirection.horizontal,
                              resizeDuration: const Duration(milliseconds: 300),
                              onDismissed: (direction) {
                                _onUserInteraction();
                                setState(() {
                                  final removed = localQuizCards.removeAt(0);
                                  localQuizCards.add(removed);
                                });
                              },
                              background: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  color: Colors.blue.withValues(alpha: 0.1),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.skip_next,
                                      color: Colors.blue,
                                      size: 32.sp,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Skip Quiz',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  color: Colors.green.withValues(alpha: 0.1),
                                ),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      color: Colors.green,
                                      size: 32.sp,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Start Quiz',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                        ),
                      );
                    },
                  ),
                );
              })
              .toList()
              .reversed
              .toList(),
        ],
      ),
    );
  }
}
