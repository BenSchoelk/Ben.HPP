import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/questionBackgroundCard.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class WaitForOthersContainer extends StatelessWidget {
  const WaitForOthersContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 7.5,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          QuestionBackgroundCard(opacity: 0.7, topMarginPercentage: 0.05, widthPercentage: 0.65),
          QuestionBackgroundCard(opacity: 0.85, topMarginPercentage: 0.03, widthPercentage: 0.75),
          Container(
            child: Center(
              child: Text(AppLocalization.of(context)!.getTranslatedValues('waitOtherComplete')!),
            ),
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            width: MediaQuery.of(context).size.width * (0.85),
            height: MediaQuery.of(context).size.height * UiUtils.questionContainerHeightPercentage,
            decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(25)),
          )
        ],
      ),
    );
  }
}
