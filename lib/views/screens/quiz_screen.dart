import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallpaper_app/services/api_services.dart';
import 'package:wallpaper_app/views/screens/results_screen.dart';

// ignore: must_be_immutable
class QuizScreen extends StatefulWidget {
  QuizScreen({super.key, required this.category, required this.any});
  int category;
  bool any;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Future? quiz;
  int seconds = 60;
  var currentIndexOfQuestion = 0;
  Timer? timer;
  bool isLoading = false;
  var optionsList = [];
  int incorrectAnswers = 0;
  int correctAnswers = 0;

  var optionColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  startTimer() async {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (seconds == 0) {
          gotoNextQuestion();
        } else {
          setState(
            () {
              seconds--;
            },
          );
        }
      },
    );
  }

  gotoNextQuestion() {
    setState(() {
      isLoading = false;
      resetColor();
      currentIndexOfQuestion++;
      timer!.cancel();
      seconds = 60;
      startTimer();
    });
  }

  resetColor() {
    optionColors = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  @override
  void initState() {
    super.initState();
    quiz = getQuizData(widget.category, widget.any); // Fetch quiz data
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black26,
              Colors.black87,
            ],
          ),
        ),
        child: FutureBuilder(
          future: quiz,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(' Error occured : ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data['results'];
              if (isLoading == false) {
                optionsList = data[currentIndexOfQuestion]['incorrect_answers'];
                optionsList.add(data[currentIndexOfQuestion]['correct_answer']);

                optionsList.shuffle();
                isLoading = true;
              }
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.red),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close, size: 30),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '$seconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(
                                  value: seconds / 60,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Image(
                        image: AssetImage('assets/ideas.png'),
                        width: 200,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Question ${currentIndexOfQuestion + 1} of ${data.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        data[currentIndexOfQuestion]['question'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // now we start the timer.
                      // we will show the options here
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (context, index) {
                          var correctAnswer =
                              data[currentIndexOfQuestion]['correct_answer'];
                          return GestureDetector(
                            onTap: () {
                              setState(
                                () {
                                  if (correctAnswer.toString() ==
                                      optionsList[index].toString()) {
                                    optionColors[index] = Colors.green;
                                    correctAnswers++;
                                  } else {
                                    optionColors[index] = Colors.red;
                                    incorrectAnswers++;
                                  }
                                  if (currentIndexOfQuestion <
                                      data.length - 1) {
                                    Future.delayed(
                                        const Duration(milliseconds: 400), () {
                                      gotoNextQuestion();
                                    });
                                  } else {
                                    timer!.cancel();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResultsScreen(
                                            correctAnswers: correctAnswers,
                                            incorrectAnswers: incorrectAnswers,
                                            totalQuestions:
                                                currentIndexOfQuestion + 1),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - 100,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: optionColors[index],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                optionsList[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("No data found."));
            }
          },
        ),
      ),
    );
  }
}
