import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';

class FunAndLearnScreen extends StatefulWidget {
  final QuizTypes? quizType;
  final String? detail, id;
  const FunAndLearnScreen({Key? key, this.quizType, this.detail, this.id}) : super(key: key);
  @override
  _FunAndLearnScreen createState() => _FunAndLearnScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
        builder: (_) => FunAndLearnScreen(
              quizType: arguments!['quizType'] as QuizTypes?,
              detail: arguments['detail'],
              id: arguments["id"],
            ));
  }
}

class _FunAndLearnScreen extends State<FunAndLearnScreen> with TickerProviderStateMixin {
  final double topPartHeightPrecentage = 0.275;
  final double userDetailsHeightPrecentage = 0.115;
  late AnimationController timerAnimationController;

  @override
  void initState() {
    timerAnimationController = AnimationController(vsync: this, duration: Duration(seconds: comprehensionParagraphReadingTimeInSeconds));
    timerAnimationController.forward().then((value) => navigateToQuestionScreen());
    super.initState();
  }

  @override
  void dispose() {
    timerAnimationController.dispose();
    super.dispose();
  }

  void navigateToQuestionScreen() {
    Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
      "numberOfPlayer": 1,
      "quizType": QuizTypes.funAndLearn,
      "comprehensionId": widget.id,
      "quizName": "Fun 'N'Learn",
    });
  }

  Widget _buildTimerContainer() {
    return Align(
      alignment:Platform.isIOS? Alignment.topRight:Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 7.5),
        child: HorizontalTimerContainer(
          timerAnimationController: timerAnimationController,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 20.0,
          left: MediaQuery.of(context).size.width * (0.075),
          right: MediaQuery.of(context).size.width * (0.075),
        ),
        child: CustomRoundedButton(
          widthPercentage: MediaQuery.of(context).size.width * (0.85),
          backgroundColor: Theme.of(context).primaryColor,
          buttonTitle: AppLocalization.of(context)!.getTranslatedValues(letsStart)!,
          radius: 5,
          onTap: () {
            timerAnimationController.stop();
            navigateToQuestionScreen();
          },
          titleColor: Theme.of(context).backgroundColor,
          showBorder: false,
          height: 40.0,
          elevation: 5.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          margin: EdgeInsetsDirectional.only(
            start: 20,
            end: 20,
            top: 35.0,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80),
            child: Html(data: widget.detail!),
          )),
    );
  }
  Widget backButton(){
    return Align(
        alignment: Alignment.topLeft,
        child:Padding(
            padding: EdgeInsets.only(left: 10),
            child:CustomBackButton(iconColor: Theme.of(context).primaryColor,bgColor: Theme.of(context).backgroundColor,isShowDialog: false,)
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          PageBackgroundGradientContainer(),
          _buildTimerContainer(),
          Platform.isIOS?backButton():Container(),
          _buildParagraph(),
          _buildStartButton(),


        ],
      ),
    ));
  }
}
