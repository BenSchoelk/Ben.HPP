import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class QuestionBackgroundCard extends StatelessWidget {
  final double opacity;
  final double widthPercentage;
  final double topMarginPercentage;

  QuestionBackgroundCard({Key? key, required this.opacity, required this.topMarginPercentage, required this.widthPercentage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * topMarginPercentage),
        width: MediaQuery.of(context).size.width * widthPercentage,
        height: MediaQuery.of(context).size.height * UiUtils.questionContainerHeightPercentage,
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
