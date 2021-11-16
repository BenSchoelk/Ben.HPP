import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamQuestionStatusBottomSheetContainer extends StatelessWidget {
  const ExamQuestionStatusBottomSheetContainer({Key? key}) : super(key: key);

  Widget _buildQuestionAttemptedByMarksContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (0.1)),
      child: Column(
        children: [
          Text(
            "1 Mark (10)",
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          Wrap(
            children: List.generate(10, (index) => index).map((index) => hasQuestionAttemptedContainer(attempted: index % 2 == 0 ? true : false, context: context, questionIndex: index)).toList(),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.02),
          ),
        ],
      ),
    );
  }

  Widget hasQuestionAttemptedContainer({required int questionIndex, required bool attempted, required BuildContext context}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        color: attempted ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
        height: 30.0,
        width: 30.0,
        child: Text(
          "${questionIndex + 1}",
          style: TextStyle(color: Theme.of(context).backgroundColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (0.95),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Text(
                        "Total Question : 50",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28.0,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ],
            ),
            _buildQuestionAttemptedByMarksContainer(context),
            _buildQuestionAttemptedByMarksContainer(context),
            Container(
              width: MediaQuery.of(context).size.width * (0.25),
              child: CustomRoundedButton(
                onTap: () {},
                widthPercentage: MediaQuery.of(context).size.width,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: AppLocalization.of(context)!.getTranslatedValues("submitBtn")!,
                radius: 10,
                showBorder: false,
                titleColor: Theme.of(context).backgroundColor,
                height: 30.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 15,
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).backgroundColor,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    AppLocalization.of(context)!.getTranslatedValues("attemptedLbl")!,
                    style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.secondary),
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).backgroundColor,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    AppLocalization.of(context)!.getTranslatedValues("unAttemptedLbl")!,
                    style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
          ],
        ),
      ),
    );
  }
}
