import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewardedAdCubit.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/questionsCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';

import 'package:flutterquiz/ui/widgets/bookmarkButton.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';

import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

enum LifelineStatus { unused, using, used }

class QuizScreen extends StatefulWidget {
  final int numberOfPlayer;
  final QuizTypes quizType;
  final String level; //will be in use for quizZone quizType
  final String categoryId; //will be in use for quizZone quizType
  final String subcategoryId; //will be in use for quizZone quizType
  final String subcategoryMaxLevel; //will be in use for quizZone quizType (to pass in result screen)
  final int unlockedLevel;
  final String contestId;
  final String comprehensionId; // will be in use for quizZone quizType (to pass in result screen)
  final String quizName;

  QuizScreen(
      {Key? key,
      required this.numberOfPlayer,
      required this.subcategoryMaxLevel,
      required this.quizType,
      required this.categoryId,
      required this.level,
      required this.subcategoryId,
      required this.unlockedLevel,
      required this.contestId,
      required this.comprehensionId,
      required this.quizName})
      : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();

  //to provider route
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    //keys of arguments are numberOfPlayer and quizType (required)
    //if quizType is quizZone then need to pass following keys
    //categoryId, subcategoryId, level, subcategoryMaxLevel and unlockedLevel

    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                //for quesitons and points
                BlocProvider<QuestionsCubit>(
                  create: (_) => QuestionsCubit(QuizRepository()),
                ),
                //to update user coins after using lifeline
                BlocProvider<UpdateScoreAndCoinsCubit>(
                  create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                ),
                BlocProvider<UpdateBookmarkCubit>(create: (_) => UpdateBookmarkCubit(BookmarkRepository())),
              ],
              child: QuizScreen(
                  numberOfPlayer: arguments['numberOfPlayer'] as int,
                  quizType: arguments['quizType'] as QuizTypes,
                  categoryId: arguments['categoryId'] ?? "",
                  level: arguments['level'] ?? "",
                  subcategoryId: arguments['subcategoryId'] ?? "",
                  subcategoryMaxLevel: arguments['subcategoryMaxLevel'] ?? "",
                  unlockedLevel: arguments['unlockedLevel'] ?? 0,
                  contestId: arguments["contestId"] ?? "",
                  comprehensionId: arguments["comprehensionId"] ?? "",
                  quizName: arguments["quizName"] ?? ""),
            ));
  }
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController = AnimationController(vsync: this, duration: Duration(seconds: questionDurationInSeconds))..addStatusListener(currentUserTimerAnimationStatusListener);

  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;
  late AnimationController showOptionAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  late Animation<double> showOptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: showOptionAnimationController, curve: Curves.easeInOut));
  late List<GlobalKey<AudioQuestionContainerState>> audioQuestionContainerKeys = [];
  int currentQuestionIndex = 0;
  final double optionWidth = 0.7;
  final double optionHeight = 0.09;

  late double totalSecondsToCompleteQuiz = 0;

  late Map<String, LifelineStatus> lifelines = {
    fiftyFifty: LifelineStatus.unused,
    audiencePoll: LifelineStatus.unused,
    skip: LifelineStatus.unused,
    resetTime: LifelineStatus.unused,
  };

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;
  _getQuestions() {
    Future.delayed(
      Duration.zero,
      () {
        //check if languageId need to pass or not
        context.read<QuestionsCubit>().getQuestions(widget.quizType,
            userId: context.read<UserDetailsCubit>().getUserId(),
            categoryId: widget.categoryId,
            level: widget.level,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            subcategoryId: widget.subcategoryId,
            contestId: widget.contestId,
            funAndLearnId: widget.comprehensionId);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //init reward ad
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context, onFbRewardAdCompleted: _addCoinsAfterRewardAd);
    });
    //init animations
    initializeAnimation();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    topContainerAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    //
    _getQuestions();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    questionAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 525));
    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionContentAnimationController, curve: Curves.easeInQuad));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
  }

  @override
  void dispose() {
    timerAnimationController.removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();

    super.dispose();
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  void navigateToResultScreen() {
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    //move to result page
    //to see the what are the keys to pass in arguments for result screen
    //visit static route function in resultScreen.dart
    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "numberOfPlayer": widget.numberOfPlayer,
      "myPoints": context.read<QuestionsCubit>().currentPoints(),
      "quizType": widget.quizType,
      "questions": context.read<QuestionsCubit>().questions(),
      "subcategoryMaxLevel": widget.subcategoryMaxLevel,
      "unlockedLevel": widget.unlockedLevel,
      "contestId": widget.contestId,
      "comprehensionId": widget.comprehensionId,
      "timeTakenToCompleteQuiz": totalSecondsToCompleteQuiz,
      "hasUsedAnyLifeline": checkHasUsedAnyLifeline(),
      "entryFee": 0
    });
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
      context.read<BookmarkCubit>().updateSubmittedAnswerId(context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
    }
  }

  void markLifeLineUsed() {
    if (lifelines[fiftyFifty] == LifelineStatus.using) {
      lifelines[fiftyFifty] = LifelineStatus.used;
    }
    if (lifelines[audiencePoll] == LifelineStatus.using) {
      lifelines[audiencePoll] = LifelineStatus.used;
    }
    if (lifelines[resetTime] == LifelineStatus.using) {
      lifelines[resetTime] = LifelineStatus.used;
    }
    if (lifelines[skip] == LifelineStatus.using) {
      lifelines[skip] = LifelineStatus.used;
    }
  }

  bool checkHasUsedAnyLifeline() {
    bool hasUsedAnyLifeline = false;

    for (var lifelineStatus in lifelines.values) {
      if (lifelineStatus == LifelineStatus.used) {
        hasUsedAnyLifeline = true;
        break;
      }
    }
    //
    print("Has used any lifeline : $hasUsedAnyLifeline");
    return hasUsedAnyLifeline;
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
        markLifeLineUsed();
      });
      //load content(options, image etc) of question
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return context.read<QuestionsCubit>().questions()[currentQuestionIndex].attempted;
  }

  Map<String, LifelineStatus> getLifeLines() {
    if (widget.quizType == QuizTypes.quizZone || widget.quizType == QuizTypes.dailyQuiz) {
      return lifelines;
    }
    return {};
  }

  void updateTotalSecondsToCompleteQuiz() {
    totalSecondsToCompleteQuiz = totalSecondsToCompleteQuiz + UiUtils.timeTakenToSubmitAnswer(animationControllerValue: timerAnimationController.value, quizType: widget.quizType);
    print("Time to complete quiz: $totalSecondsToCompleteQuiz");
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    timerAnimationController.stop();
    if (!context.read<QuestionsCubit>().questions()[currentQuestionIndex].attempted) {
      context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(context.read<QuestionsCubit>().questions()[currentQuestionIndex].id, submittedAnswer);
      updateTotalSecondsToCompleteQuiz();
      //change question
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
      if (currentQuestionIndex != (context.read<QuestionsCubit>().questions().length - 1)) {
        updateSubmittedAnswerForBookmark(context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
        changeQuestion();
        //if quizType is not audio then start timer again
        if (widget.quizType == QuizTypes.audioQuestions) {
          timerAnimationController.value = 0.0;
          showOptionAnimationController.forward();
        } else {
          timerAnimationController.forward(from: 0.0);
        }
      } else {
        updateSubmittedAnswerForBookmark(context.read<QuestionsCubit>().questions()[currentQuestionIndex]);
        navigateToResultScreen();
      }
    }
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    print(status.toString());
    if (status == AnimationStatus.completed) {
      print("User has left the question so submit answer as -1");
      submitAnswer("-1");
    } else if (status == AnimationStatus.forward) {
      if (widget.quizType == QuizTypes.audioQuestions) {
        showOptionAnimationController.reverse();
      }
    }
  }

  bool hasEnoughCoinsForLifeline(BuildContext context) {
    int currentCoins = int.parse(context.read<UserDetailsCubit>().getCoins()!);
    //cost of using lifeline is 5 coins
    if (currentCoins < 5) {
      return false;
    }
    return true;
  }

  Widget _buildShowOptionButton() {
    if (widget.quizType == QuizTypes.audioQuestions) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: showOptionAnimation.drive<Offset>(Tween<Offset>(
            begin: Offset(0.0, 1.5),
            end: Offset.zero,
          )),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.025),
              left: MediaQuery.of(context).size.width * (0.2),
              right: MediaQuery.of(context).size.width * (0.2),
            ),
            child: CustomRoundedButton(
              widthPercentage: MediaQuery.of(context).size.width * (0.5),
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: AppLocalization.of(context)!.getTranslatedValues(showOptionsKey)!,
              radius: 5,
              onTap: () {
                if (!showOptionAnimationController.isAnimating) {
                  showOptionAnimationController.reverse();
                  audioQuestionContainerKeys[currentQuestionIndex].currentState!.changeShowOption();
                  timerAnimationController.forward(from: 0.0);
                }
              },
              titleColor: Theme.of(context).backgroundColor,
              showBorder: false,
              height: 40.0,
              elevation: 5.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildBookmarkButton(QuestionsCubit questionsCubit) {
    if (widget.quizType == QuizTypes.funAndLearn) {
      return Container();
    }
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      bloc: questionsCubit,
      builder: (context, state) {
        if (state is QuestionsFetchSuccess)
          return BookmarkButton(
            question: state.questions[currentQuestionIndex],
          );
        return Container();
      },
    );
  }

  Widget _buildLifelineContainer(VoidCallback onTap, String lifelineTitle, String lifelineIcon) {
    return GestureDetector(
      onTap: lifelineTitle == fiftyFifty && context.read<QuestionsCubit>().questions()[currentQuestionIndex].answerOptions!.length == 2
          ? () {
              UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues("notAvailable")!, context, false);
            }
          : onTap,
      child: Container(
          decoration: BoxDecoration(
              color: lifelineTitle == fiftyFifty && context.read<QuestionsCubit>().questions()[currentQuestionIndex].answerOptions!.length == 2 ? Theme.of(context).backgroundColor.withOpacity(0.7) : Theme.of(context).backgroundColor,
              boxShadow: [
                UiUtils.buildBoxShadow(),
              ],
              borderRadius: BorderRadius.circular(10.0)),
          width: 45.0,
          height: 45.0,
          padding: EdgeInsets.all(11),
          child: SvgPicture.asset(
            UiUtils.getImagePath(lifelineIcon),
            color: Theme.of(context).colorScheme.secondary,
          )),
    );
  }

  void _addCoinsAfterRewardAd() {
    //once user sees app then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );
    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          context.read<UserDetailsCubit>().getUserId(),
          lifeLineDeductCoins,
          true,
        );
    timerAnimationController.forward(from: timerAnimationController.value);
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode))!, context, false);
      return;
    }
    //stop timer
    timerAnimationController.stop();
    showDialog<bool>(
        context: context,
        builder: (_) => WatchRewardAdDialog(
              onTapYesButton: () {
                //on tap of yes button show ad
                context.read<RewardedAdCubit>().showAd(context: context, onAdDismissedCallback: _addCoinsAfterRewardAd);
              },
              onTapNoButton: () {
                //pass true to start timer
                Navigator.of(context).pop(true);
              },
            )).then((startTimer) {
      //if user do not want to see ad
      if (startTimer != null && startTimer) {
        timerAnimationController.forward(from: timerAnimationController.value);
      }
    });
  }

  Widget _buildLifeLines() {
    if (widget.quizType == QuizTypes.dailyQuiz || widget.quizType == QuizTypes.quizZone) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLifelineContainer(() {
                  if (lifelines[fiftyFifty] == LifelineStatus.unused) {
                    if (hasEnoughCoinsForLifeline(context)) {
                      if (context.read<QuestionsCubit>().questions()[currentQuestionIndex].answerOptions!.length == 2) {
                        UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues("notAvailable")!, context, false);
                      } else {
                        //deduct coins for using lifeline
                        context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: lifeLineDeductCoins);
                        //mark fiftyFifty lifeline as using

                        //update coins in cloud
                        context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), 5, false);
                        setState(() {
                          lifelines[fiftyFifty] = LifelineStatus.using;
                        });
                      }
                    } else {
                      showAdDialog();
                    }
                  } else {
                    UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(lifeLineUsedCode))!, context, false);
                  }
                }, fiftyFifty, "fiftyfifty icon.svg"),
                _buildLifelineContainer(() {
                  if (lifelines[audiencePoll] == LifelineStatus.unused) {
                    if (hasEnoughCoinsForLifeline(context)) {
                      //deduct coins for using lifeline
                      context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: lifeLineDeductCoins);
                      //update coins in cloud
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), 5, false);
                      setState(() {
                        lifelines[audiencePoll] = LifelineStatus.using;
                      });
                    } else {
                      showAdDialog();
                    }
                  } else {
                    UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(lifeLineUsedCode))!, context, false);
                  }
                }, audiencePoll, "audience_poll.svg"),
                _buildLifelineContainer(() {
                  if (lifelines[resetTime] == LifelineStatus.unused) {
                    if (hasEnoughCoinsForLifeline(context)) {
                      //deduct coins for using lifeline
                      context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: lifeLineDeductCoins);
                      //mark fiftyFifty lifeline as using

                      //update coins in cloud
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), lifeLineDeductCoins, false);
                      setState(() {
                        lifelines[resetTime] = LifelineStatus.using;
                      });
                      timerAnimationController.stop();
                      timerAnimationController.forward(from: 0.0);
                    } else {
                      showAdDialog();
                    }
                  } else {
                    UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(lifeLineUsedCode))!, context, false);
                  }
                }, resetTime, "reset_time.svg"),
                _buildLifelineContainer(() {
                  if (lifelines[skip] == LifelineStatus.unused) {
                    if (hasEnoughCoinsForLifeline(context)) {
                      //deduct coins for using lifeline
                      context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: 5);
                      //update coins in cloud
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), lifeLineDeductCoins, false);
                      setState(() {
                        lifelines[skip] = LifelineStatus.using;
                      });
                      submitAnswer("0");
                    } else {
                      showAdDialog();
                    }
                  } else {
                    UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(lifeLineUsedCode))!, context, false);
                  }
                }, skip, "skip_icon.svg"),
              ],
            ),
          ));
    }
    return Container();
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
        showDialog(context: context, builder: (_) => ExitGameDailog());
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageBackgroundGradientContainer(),
            Align(
              alignment: Alignment.topCenter,
              child: QuizPlayAreaBackgroundContainer(
                heightPercentage: 0.885,
              ),
            ),
            //showDialog(context: context, builder: (_) => ExitGameDailog());

            Align(
              alignment: Platform.isIOS ? Alignment.topRight : Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 7.5, right: Platform.isIOS ? 10 : 0),
                child: HorizontalTimerContainer(
                  timerAnimationController: timerAnimationController,
                ),
              ),
            ),
            BlocConsumer<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                listener: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    if (currentQuestionIndex == 0 && !state.questions[currentQuestionIndex].attempted) {
                      if (widget.quizType == QuizTypes.audioQuestions) {
                        state.questions.forEach((element) {
                          audioQuestionContainerKeys.add(GlobalKey<AudioQuestionContainerState>());
                        });

                        //
                        showOptionAnimationController.forward();
                        questionContentAnimationController.forward();
                        //add audio question container keys

                      } else {
                        timerAnimationController.forward();
                        questionContentAnimationController.forward();
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (state is QuestionsFetchInProgress || state is QuestionsIntial) {
                    return Center(
                      child: CircularProgressContainer(
                        useWhiteLoader: true,
                      ),
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
                  return Align(
                    alignment: Alignment.topCenter,
                    child: QuestionsContainer(
                      audioQuestionContainerKeys: audioQuestionContainerKeys,
                      quizType: widget.quizType,
                      toggleSettingDialog: toggleSettingDialog,
                      showAnswerCorrectness: true,
                      lifeLines: getLifeLines(),
                      timerAnimationController: widget.quizType == QuizTypes.audioQuestions ? timerAnimationController : null,
                      bookmarkButton: _buildBookmarkButton(quesCubit),
                      topPadding: 30.0,
                      hasSubmittedAnswerForCurrentQuestion: hasSubmittedAnswerForCurrentQuestion,
                      questions: context.read<QuestionsCubit>().questions(),
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
                      level: widget.level,
                    ),
                  );
                }),

            BlocBuilder<QuestionsCubit, QuestionsState>(
              bloc: quesCubit,
              builder: (context, state) {
                if (state is QuestionsFetchSuccess) {
                  return _buildLifeLines();
                }
                return Container();
              },
            ),

            BlocBuilder<QuestionsCubit, QuestionsState>(
              bloc: quesCubit,
              builder: (context, state) {
                if (state is QuestionsFetchSuccess) {
                  return _buildShowOptionButton();
                }
                return Container();
              },
            ),
            Platform.isIOS ? backButton() : Container(),
          ],
        ),
      ),
    );
  }
}
