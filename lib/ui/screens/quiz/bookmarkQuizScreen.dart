import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/questionsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';

import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';

import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';

class BookmarkQuizScreen extends StatefulWidget {
  //final List<Question> questions;
  BookmarkQuizScreen({Key? key}) : super(key: key);

  @override
  _BookmarkQuizScreenState createState() => _BookmarkQuizScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    //keys of arguments are numberOfPlayer and quizType (required)
    //if quizType is quizZone then need to pass following keys
    //categoryId, subcategoryId, level, subcategoryMaxLevel and unlockedLevel
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              //for quesitons and points
              BlocProvider<QuestionsCubit>(
                create: (_) => QuestionsCubit(QuizRepository()),
              ),
              BlocProvider<UpdateBookmarkCubit>(create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
            ], child: BookmarkQuizScreen()));
  }
}

class _BookmarkQuizScreenState extends State<BookmarkQuizScreen> with TickerProviderStateMixin {
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController = AnimationController(vsync: this, duration: Duration(seconds: questionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener)
    ..forward();
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;
  int currentQuestionIndex = 0;
  late List<Question> ques;
  bool completedQuiz = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  _getQuestions() {
    Future.delayed(Duration.zero, () {
      //emitting success as we do not need tofetch questios from cloud and here only questions is important
      //other parameters can be ignored
      //other parameters need to pass so cubit functionlity does not break

      context.read<QuestionsCubit>().emit(QuestionsFetchSuccess(questions: List.from(context.read<BookmarkCubit>().questions()), currentPoints: 0, quizType: QuizTypes.bookmarkQuiz));

      //start timer
    });
  }

  @override
  void initState() {
    context.read<QuestionsCubit>().emit(QuestionsFetchSuccess(questions: List.from(context.read<BookmarkCubit>().questions()), currentPoints: 0, quizType: QuizTypes.bookmarkQuiz));
    initializeAnimation();
    //_getQuestions();
    super.initState();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250))..forward();
    questionAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 525));
    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionContentAnimationController, curve: Curves.easeInQuad));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
      context.read<BookmarkCubit>().updateSubmittedAnswerId(context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
    }
  }

  //change to next Question
  void changeQuestion() {
    questionAnimationController.forward(from: 0.0).then((value) {
      //need to dispose the animation controllers
      questionAnimationController.dispose();
      questionContentAnimationController.dispose();
      //initializeAnimation again
      setState(() {
        initializeAnimation();
        currentQuestionIndex++;
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return ques[currentQuestionIndex].attempted;
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();
    if (!ques[currentQuestionIndex].attempted) {
      print("Submit answer for $currentQuestionIndex");
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(ques[currentQuestionIndex].id, submittedAnswer);
      //change question
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
      if (currentQuestionIndex != (ques.length - 1)) {
        changeQuestion();
        timerAnimationController.forward(from: 0.0);
      } else {
        setState(() {
          completedQuiz = true;
        });
      }
    }
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer("-1");
    }
  }

  @override
  void dispose() {
    timerAnimationController.removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    super.dispose();
  }

  Widget backButton() {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top - 10),
            child: CustomBackButton(
              iconColor: Theme.of(context).primaryColor,
              bgColor: Theme.of(context).backgroundColor,
              isShowDialog: true,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();
    return WillPopScope(
        onWillPop: () {
          showDialog(context: context, builder: (context) => ExitGameDailog());
          return Future.value(false);
        },
        child: Scaffold(
          body: Stack(
            children: [
              PageBackgroundGradientContainer(),
              Align(
                alignment: Alignment.topCenter,
                child: QuizPlayAreaBackgroundContainer(),
              ),
              completedQuiz
                  ? Container()
                  : Align(
                      alignment: Platform.isIOS ? Alignment.topRight : Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 7.5),
                        child: HorizontalTimerContainer(
                          timerAnimationController: timerAnimationController,
                        ),
                      ),
                    ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: completedQuiz
                    ? Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalization.of(context)!.getTranslatedValues("completeAllQueLbl")! + " (:",
                              style: TextStyle(
                                color: Theme.of(context).backgroundColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (0.3)),
                              child: CustomRoundedButton(
                                widthPercentage: MediaQuery.of(context).size.width * (0.3),
                                backgroundColor: Theme.of(context).backgroundColor,
                                buttonTitle: AppLocalization.of(context)!.getTranslatedValues("goBAckLbl")!,
                                titleColor: Theme.of(context).primaryColor,
                                radius: 5.0,
                                showBorder: false,
                                elevation: 5.0,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                height: 35.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : BlocConsumer<QuestionsCubit, QuestionsState>(
                        bloc: quesCubit,
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is QuestionsFetchInProgress || state is QuestionsIntial) {
                            return Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                            );
                          }
                          if (state is QuestionsFetchFailure) {
                            return Center(
                              child: ErrorContainer(
                                showBackButton: true,
                                errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage)),
                                onTapRetry: () {
                                  _getQuestions();
                                },
                                showErrorImage: true,
                              ),
                            );
                          }
                          final questions = (state as QuestionsFetchSuccess).questions;
                          ques = questions;
                          return Align(
                              alignment: Alignment.topCenter,
                              child: QuestionsContainer(
                                quizType: QuizTypes.bookmarkQuiz,
                                toggleSettingDialog: toggleSettingDialog,
                                topPadding: 30.0,
                                showAnswerCorrectness: true,
                                lifeLines: {},
                                bookmarkButton: Container(),
                                hasSubmittedAnswerForCurrentQuestion: hasSubmittedAnswerForCurrentQuestion,
                                questions: questions,
                                submitAnswer: submitAnswer,
                                questionContentAnimation: questionContentAnimation,
                                questionScaleDownAnimation: questionScaleDownAnimation,
                                questionScaleUpAnimation: questionScaleUpAnimation,
                                questionSlideAnimation: questionSlideAnimation,
                                currentQuestionIndex: currentQuestionIndex,
                                questionAnimationController: questionAnimationController,
                                questionContentAnimationController: questionContentAnimationController,
                                guessTheWordQuestions: [],
                                guessTheWordQuestionContainerKeys: [],
                              ));
                        }),
              ),
              Platform.isIOS ? backButton() : Container(),
            ],
          ),
        ));
  }
}
