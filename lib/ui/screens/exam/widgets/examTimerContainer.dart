import 'dart:async';

import 'package:flutter/material.dart';

class ExamTimerContainer extends StatefulWidget {
  final int examDurationInMinutes;
  final Function navigateToResultScreen;
  ExamTimerContainer({Key? key, required this.examDurationInMinutes, required this.navigateToResultScreen}) : super(key: key);

  @override
  ExamTimerContainerState createState() => ExamTimerContainerState();
}

class ExamTimerContainerState extends State<ExamTimerContainer> {
  late int minutesLeft = widget.examDurationInMinutes;

  void startTimer() {
    examTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (minutesLeft == 0) {
        timer.cancel();
        widget.navigateToResultScreen();
      } else {
        minutesLeft--;
        setState(() {});
      }
    });
  }

  Timer? examTimer;

  int getCompletedExamDuration() {
    return (widget.examDurationInMinutes - minutesLeft);
  }

  @override
  void dispose() {
    examTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String hours = (minutesLeft ~/ 60).toString().length == 1 ? "0${(minutesLeft ~/ 60)}" : (minutesLeft ~/ 60).toString();

    String minutes = (minutesLeft % 60).toString().length == 1 ? "0${(minutesLeft % 60)}" : (minutesLeft % 60).toString();
    return Text(
      "$hours:$minutes",
      style: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
