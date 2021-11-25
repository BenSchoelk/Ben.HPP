import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamResultBottomSheetContainer extends StatelessWidget {
  const ExamResultBottomSheetContainer({Key? key}) : super(key: key);

  Widget _buildExamDetailsContainer({required String title, required String examData, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "$title :",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 17.0,
              ),
            ),
            width: MediaQuery.of(context).size.width * (0.4),
            height: 45,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "$examData",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            height: 45,
            width: MediaQuery.of(context).size.width * (0.4),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionStatistic({required String title, required BuildContext context, required int totalQuestion, required int questionsMark, required int correct, required int incorrect}) {
    return Container(
      height: MediaQuery.of(context).size.height * (0.2),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Total Questions",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20.0,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, boxConstraints) {
              final textStyle = TextStyle(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                height: 1.3,
              );
              return Container(
                child: Column(
                  children: [
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Total \n Questions",
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                            width: boxConstraints.maxWidth * (0.32),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                left: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                                ),
                                right: BorderSide(
                                  width: 2,
                                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                                ),
                              )),
                              alignment: Alignment.center,
                              child: Text(
                                "Correct \n Questions",
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "Incorrect \n Questions",
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                            width: boxConstraints.maxWidth * (0.36),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: boxConstraints.maxHeight * (0.3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                              ),
                              child: Text(
                                "$totalQuestion",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              width: boxConstraints.maxWidth * (0.32),
                            ),
                            Container(
                              child: Text(
                                "$correct",
                                style: TextStyle(
                                  fontSize: 17.5,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.9)),
                              width: boxConstraints.maxWidth * (0.32),
                            ),
                            Container(
                              child: Text(
                                "$incorrect",
                                style: TextStyle(
                                  color: Theme.of(context).backgroundColor,
                                  fontSize: 17.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9)),
                              width: boxConstraints.maxWidth * (0.36),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: badgeLockedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * (0.95)),
      decoration: BoxDecoration(borderRadius: UiUtils.getBottomSheetRadius(), color: Theme.of(context).backgroundColor),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                "Exam Result",
                style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 20.0),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * (0.075),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: UiUtils.getBottomSheetRadius()),
            ),
            SizedBox(
              height: 15.0,
            ),
            _buildExamDetailsContainer(title: "Obtained Marks", examData: "25/45", context: context),
            SizedBox(
              height: 10.0,
            ),
            _buildExamDetailsContainer(title: "Exam Duration", examData: "00:30", context: context),
            SizedBox(
              height: 10.0,
            ),
            _buildExamDetailsContainer(title: "Completed in", examData: "00:28", context: context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Divider(
                thickness: 1.5,
              ),
            ),
            _buildQuestionStatistic(title: "Total Questions", context: context, totalQuestion: 10, questionsMark: 1, correct: 8, incorrect: 2),
            _buildQuestionStatistic(title: "1 Mark Questions", context: context, totalQuestion: 10, questionsMark: 1, correct: 8, incorrect: 2),
            //_buildQuestionStatistic(title: "2 Mark Questions", context: context, totalQuestion: 10, questionsMark: 1, correct: 8, incorrect: 2),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.05),
            ),
          ],
        ),
      ),
    );
  }
}
