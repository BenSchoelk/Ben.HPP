import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitForOthersContainer.dart';
import 'package:flutterquiz/ui/widgets/bookmarkButton.dart';
import 'package:flutterquiz/ui/widgets/circularImageContainer.dart';

import 'package:flutterquiz/ui/widgets/circularTimerContainer.dart';

import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/ui/widgets/quizPlayAreaBackgroundContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/normalizeNumber.dart';

class MultiUserBattleRoomQuizScreen extends StatefulWidget {
  MultiUserBattleRoomQuizScreen({Key? key}) : super(key: key);

  @override
  _MultiUserBattleRoomQuizScreenState createState() => _MultiUserBattleRoomQuizScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<UpdateScoreAndCoinsCubit>(
                create: (context) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              ),
              BlocProvider<UpdateBookmarkCubit>(create: (context) => UpdateBookmarkCubit(BookmarkRepository())),
            ], child: MultiUserBattleRoomQuizScreen()));
  }
}

class _MultiUserBattleRoomQuizScreenState extends State<MultiUserBattleRoomQuizScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController timerAnimationController = AnimationController(vsync: this, duration: Duration(seconds: questionDurationInSeconds))
    ..addStatusListener(currentUserTimerAnimationStatusListener)
    ..forward();

  //to animate the question container
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  //to slide the question container from right to left
  late Animation<double> questionSlideAnimation;
  //to scale up the second question
  late Animation<double> questionScaleUpAnimation;
  //to scale down the second question
  late Animation<double> questionScaleDownAnimation;
  //to slude the question content from right to left
  late Animation<double> questionContentAnimation;

  int currentQuestionIndex = 0;

  //if user has minimized the app
  bool showUserLeftTheGame = false;

  bool showWaitForOthers = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  @override
  void initState() {
    //deduct coins of entry fee
    Future.delayed(Duration.zero, () {
      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), context.read<MultiUserBattleRoomCubit>().getEntryFee(), false);
      context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: context.read<MultiUserBattleRoomCubit>().getEntryFee());
    });
    initializeAnimation();
    questionContentAnimationController.forward();
    //add observer to track app lifecycle activity
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    timerAnimationController.removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //remove user from room
    if (state == AppLifecycleState.paused) {
      context.read<MultiUserBattleRoomCubit>().deleteUserFromRoom(context.read<UserDetailsCubit>().getUserId());
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        showUserLeftTheGame = true;
      });
      timerAnimationController.stop();
    }
  }

  //
  void initializeAnimation() {
    questionAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    questionContentAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionAnimationController, curve: Curves.easeInOut));
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.0, 0.5, curve: Curves.easeInQuad)));
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(CurvedAnimation(parent: questionAnimationController, curve: Interval(0.5, 1.0, curve: Curves.easeOutQuad)));
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: questionContentAnimationController, curve: Curves.easeInQuad));
  }

  void toggleSettingDialog() {
    isSettingDialogOpen = !isSettingDialogOpen;
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      submitAnswer("-1");
    }
  }

  void updateSubmittedAnswerForBookmark(Question question) {
    if (context.read<BookmarkCubit>().hasQuestionBookmarked(question.id)) {
      context.read<BookmarkCubit>().updateSubmittedAnswerId(question);
    }
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    //
    timerAnimationController.stop();
    final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();
    final questions = battleRoomCubit.getQuestions();

    if (!questions[currentQuestionIndex].attempted) {
      //updated answer locally
      battleRoomCubit.updateQuestionAnswer(questions[currentQuestionIndex].id!, submittedAnswer);
      //update answer on cloud
      battleRoomCubit.submitAnswer(context.read<UserDetailsCubit>().getUserId(), submittedAnswer, questions[currentQuestionIndex].correctAnswerOptionId == submittedAnswer);

      updateSubmittedAnswerForBookmark(questions[currentQuestionIndex]);

      //change question
      await Future.delayed(Duration(seconds: inBetweenQuestionTimeInSeconds));
      if (currentQuestionIndex == (questions.length - 1)) {
        setState(() {
          showWaitForOthers = true;
        });
      } else {
        changeQuestion();
        timerAnimationController.forward(from: 0.0);
      }
    }
  }

  //next question
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
    return context.read<MultiUserBattleRoomCubit>().getQuestions()[currentQuestionIndex].attempted;
  }

  void battleRoomListener(BuildContext context, MultiUserBattleRoomState state, MultiUserBattleRoomCubit battleRoomCubit) {
    if (state is MultiUserBattleRoomSuccess) {
      //show result only for more than two user
      if (battleRoomCubit.getUsers().length != 1) {
        //if there is more than one user in room
        //navigate to result
        navigateToResultScreen(battleRoomCubit.getUsers(), state.battleRoom, state.questions);
      }
    }
  }

  void navigateToResultScreen(List<UserBattleRoomDetails?> users, BattleRoom? battleRoom, List<Question>? questions) {
    bool navigateToResult = true;

    //checking if every user has given all question's answer
    users.forEach((element) {
      //if user uid is not empty means user has not left the game so
      //we will check for it's answer completion
      if (element!.uid.isNotEmpty) {
        //if every user has submitted the answer then move user to result screen
        if (element.answers.length != questions!.length) {
          navigateToResult = false;
        }
      }
    });

    //if all users has submitted the answer
    if (navigateToResult) {
      //giving delay
      Future.delayed(
          Duration(
            milliseconds: 1000,
          ), () {
        try {
          //delete battle room by creator of this room
          if (battleRoom!.user1!.uid == context.read<UserDetailsCubit>().getUserId()) {
            context.read<MultiUserBattleRoomCubit>().deleteMultiUserBattleRoom();
          }

          //
          //navigating result screen twice...
          //Find optimize solution of navigating to result screen
          //https://stackoverflow.com/questions/56519093/bloc-listen-callback-called-multiple-times try this solution
          //https: //stackoverflow.com/questions/52249578/how-to-deal-with-unwanted-widget-build
          //tried with mounted is true but not working as expected
          //so executing this code in try catch
          //

          if (isSettingDialogOpen) {
            Navigator.of(context).pop();
          }
          Navigator.pushReplacementNamed(
            context,
            Routes.multiUserBattleRoomQuizResult,
            arguments: {
              "user": context.read<MultiUserBattleRoomCubit>().getUsers(),
              "entryFee": battleRoom.entryFee,
            },
          );
        } catch (e) {}
      });
    }
  }

  Widget _buildYouWonContainer(MultiUserBattleRoomCubit battleRoomCubit) {
    return BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
      bloc: battleRoomCubit,
      builder: (context, state) {
        if (state is MultiUserBattleRoomSuccess) {
          if (battleRoomCubit.getUsers().length == 1 && state.battleRoom.user1!.uid == context.read<UserDetailsCubit>().getUserId()) {
            timerAnimationController.stop();
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).backgroundColor.withOpacity(0.1),
              alignment: Alignment.center,
              child: AlertDialog(
                title: Text(
                  AppLocalization.of(context)!.getTranslatedValues('youWonLbl')!,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                content: Text(
                  AppLocalization.of(context)!.getTranslatedValues('everyOneLeftLbl')!,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      //delete room
                      battleRoomCubit.deleteMultiUserBattleRoom();
                      //add coins locally
                      context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: battleRoomCubit.getEntryFee());
                      //add coins in database
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), battleRoomCubit.getEntryFee(), true);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalization.of(context)!.getTranslatedValues('okayLbl')!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  Widget _buildUserLeftTheGame() {
    //cancel timer when user left the game
    if (showUserLeftTheGame) {
      return Container(
        color: Theme.of(context).backgroundColor.withOpacity(0.1),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AlertDialog(
          content: Text(
            AppLocalization.of(context)!.getTranslatedValues("youLeftLbl")!,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: [
            TextButton(
                child: Text(
                  AppLocalization.of(context)!.getTranslatedValues("okayLbl")!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      );
    }
    return Container();
  }

  Widget _buildCurrentUserDetails(UserBattleRoomDetails userBattleRoomDetails) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.225),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularTimerContainer(timerAnimationController: timerAnimationController, heightAndWidth: MediaQuery.of(context).size.width * 0.14),
              CircularImageContainer(height: MediaQuery.of(context).size.width * (0.125), imagePath: userBattleRoomDetails.profileUrl, width: MediaQuery.of(context).size.width * (0.15))
            ],
          ),
          SizedBox(
            height: 2.5,
          ),
          Text(
            userBattleRoomDetails.name,
            style: TextStyle(fontSize: 13.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentUserDetails(UserBattleRoomDetails userBattleRoomDetails, int questionsLength) {
    double progressPercentage = (100.0 * userBattleRoomDetails.answers.length) / questionsLength;
    double sweepAngle = NormalizeNumber.inRange(currentValue: progressPercentage, minValue: 0.0, maxValue: 100.0, newMaxValue: 360.0, newMinValue: 0.0);
    return Container(
      width: MediaQuery.of(context).size.width * (0.225),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: CustomPaint(
                  painter: CircleCustomPainter(color: Theme.of(context).backgroundColor, radiusPercentage: 0.5, strokeWidth: 3.0),
                ),
                height: MediaQuery.of(context).size.width * (0.14),
                width: MediaQuery.of(context).size.width * (0.14),
              ),
              Container(
                child: CustomPaint(
                  painter: ArcCustomPainter(sweepAngle: sweepAngle, color: Theme.of(context).colorScheme.secondary, radiusPercentage: 0.5, strokeWidth: 3.0),
                ),
                height: MediaQuery.of(context).size.width * (0.14),
                width: MediaQuery.of(context).size.width * (0.14),
              ),
              CircularImageContainer(height: MediaQuery.of(context).size.width * (0.125), imagePath: userBattleRoomDetails.profileUrl, width: MediaQuery.of(context).size.width * (0.15))
            ],
          ),
          SizedBox(
            height: 2.5,
          ),
          Text(
            userBattleRoomDetails.name,
            style: TextStyle(fontSize: 13.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersDetails(MultiUserBattleRoomCubit battleRoomCubit) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCurrentUserDetails(battleRoomCubit.getUser(context.read<UserDetailsCubit>().getUserId())!),
            BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
              bloc: battleRoomCubit,
              builder: (context, state) {
                if (state is MultiUserBattleRoomSuccess) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: battleRoomCubit.getOpponentUsers(context.read<UserDetailsCubit>().getUserId()).map((userDetails) => _buildOpponentUserDetails(userDetails!, state.questions.length)).toList(),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(MultiUserBattleRoomCubit battleRoomCubit) {
    return BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
      bloc: battleRoomCubit,
      builder: (context, state) {
        if (state is MultiUserBattleRoomSuccess)
          return BookmarkButton(
            question: state.questions[currentQuestionIndex],
          );
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<MultiUserBattleRoomCubit>();
    return WillPopScope(
      onWillPop: () {
        //if user hasleft the game
        if (showUserLeftTheGame) {
          return Future.value(true);
        }
        //if user is playing game then show
        //exit game dialog
        showDialog(
            context: context,
            builder: (_) => ExitGameDailog(
                  onTapYes: () {
                    //delete user from game room
                    battleRoomCubit.deleteUserFromRoom(context.read<UserDetailsCubit>().getUserId());
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
        return Future.value(false);
      },
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            //update ui and do other callback based on changes in MultiUserBattleRoomCubit
            BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
              bloc: battleRoomCubit,
              listener: (context, state) {
                battleRoomListener(context, state, battleRoomCubit);
              },
            ),
          ],
          child: Stack(
            children: [
              PageBackgroundGradientContainer(),
              Align(
                alignment: Alignment.topCenter,
                child: QuizPlayAreaBackgroundContainer(
                  heightPercentage: 0.875,
                ),
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: showWaitForOthers
                        ? WaitForOthersContainer(
                            key: Key("waitForOthers"),
                          )
                        : QuestionsContainer(
                            toggleSettingDialog: toggleSettingDialog,
                            showAnswerCorrectness: true,
                            lifeLines: {},
                            bookmarkButton: _buildBookmarkButton(battleRoomCubit),
                            guessTheWordQuestionContainerKeys: [],
                            key: Key("questions"),
                            guessTheWordQuestions: [],
                            hasSubmittedAnswerForCurrentQuestion: hasSubmittedAnswerForCurrentQuestion,
                            questions: battleRoomCubit.getQuestions(),
                            submitAnswer: submitAnswer,
                            questionContentAnimation: questionContentAnimation,
                            questionScaleDownAnimation: questionScaleDownAnimation,
                            questionScaleUpAnimation: questionScaleUpAnimation,
                            questionSlideAnimation: questionSlideAnimation,
                            currentQuestionIndex: currentQuestionIndex,
                            questionAnimationController: questionAnimationController,
                            questionContentAnimationController: questionContentAnimationController,
                          ),
                  )),
              showUserLeftTheGame ? Container() : _buildPlayersDetails(battleRoomCubit),
              _buildYouWonContainer(battleRoomCubit),
              _buildUserLeftTheGame(),
            ],
          ),
        ),
      ),
    );
  }
}
