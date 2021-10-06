import 'package:flutter/material.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';

class AudioQuestionContainer extends StatefulWidget {
  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<Question> questions;
  final Function submitAnswer;
  final AnimationController timerAnimationController;
  AudioQuestionContainer({
    Key? key,
    required this.constraints,
    required this.currentQuestionIndex,
    required this.questions,
    required this.submitAnswer,
    required this.timerAnimationController,
  }) : super(key: key);

  @override
  _AudioQuestionContainerState createState() => _AudioQuestionContainerState();
}

class _AudioQuestionContainerState extends State<AudioQuestionContainer> {
  double textSize = 14;
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(context: context, builder: (context) => SettingsDialogContainer());
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "${question.question}",
            style: TextStyle(height: 1.125, fontSize: textSize, color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        SizedBox(
          height: widget.constraints.maxHeight * (0.025),
        ),
        IconButton(
            onPressed: () {
              widget.timerAnimationController.forward(from: 0.0);
            },
            icon: Icon(Icons.play_arrow))
      ],
    ));
  }
}
