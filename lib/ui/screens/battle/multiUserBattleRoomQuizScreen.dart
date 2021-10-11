import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageBoxContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/rectangleUserProfileContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitForOthersContainer.dart';
import 'package:flutterquiz/ui/widgets/bookmarkButton.dart';

import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
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
              BlocProvider<MessageCubit>(create: (context) => MessageCubit(BattleRoomRepository())),
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

  late AnimationController messageAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300), reverseDuration: Duration(milliseconds: 300));
  late Animation<double> messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: messageAnimationController, curve: Curves.easeOutBack));

  late List<AnimationController> opponentMessageAnimationControllers = [];
  late List<Animation<double>> opponentMessageAnimations = [];

  late List<AnimationController> opponentProgressAnimationControllers = [];

  late AnimationController messageBoxAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
  late Animation<double> messageBoxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: messageBoxAnimationController, curve: Curves.easeInOut));

  int currentQuestionIndex = 0;

  //if user has minimized the app
  bool showUserLeftTheGame = false;

  bool showWaitForOthers = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  //current user message timer
  Timer? currentUserMessageDisappearTimer;
  int currentUserMessageDisappearTimeInSeconds = 4;

  List<Timer?> opponentsMessageDisappearTimer = [];
  List<int> opponentsMessageDisappearTimeInSeconds = [];

  double userDetailsPadding = 15;

  @override
  void initState() {
    //deduct coins of entry fee
    Future.delayed(Duration.zero, () {
      context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), context.read<MultiUserBattleRoomCubit>().getEntryFee(), false);
      context.read<UserDetailsCubit>().updateCoins(addCoin: false, coins: context.read<MultiUserBattleRoomCubit>().getEntryFee());
      context.read<MessageCubit>().subscribeToMessages(context.read<MultiUserBattleRoomCubit>().getRoomId());
    });
    initializeAnimation();
    initOpponentConfig();
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
    messageAnimationController.dispose();
    opponentMessageAnimationControllers.forEach((element) {
      element.dispose();
    });
    opponentProgressAnimationControllers.forEach((element) {
      element.dispose();
    });
    opponentsMessageDisappearTimer.forEach((element) {
      element?.cancel();
    });
    messageBoxAnimationController.dispose();
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //remove user from room
    if (state == AppLifecycleState.paused) {
      MultiUserBattleRoomCubit multiUserBattleRoomCubit = context.read<MultiUserBattleRoomCubit>();
      deleteMessages(multiUserBattleRoomCubit);
      multiUserBattleRoomCubit.deleteUserFromRoom(context.read<UserDetailsCubit>().getUserId());
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        showUserLeftTheGame = true;
      });
      timerAnimationController.stop();
    }
  }

  void deleteMessages(MultiUserBattleRoomCubit battleRoomCubit) {
    //to delete messages by given user
    context.read<MessageCubit>().deleteMessages(battleRoomCubit.getRoomId(), context.read<UserDetailsCubit>().getUserId());
  }

  void initOpponentConfig() {
    for (var i = 0; i < 3; i++) {
      opponentMessageAnimationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 300)));
      opponentProgressAnimationControllers.add(AnimationController(vsync: this));
      opponentMessageAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: opponentMessageAnimationControllers[i], curve: Curves.easeOutBack)));
      opponentsMessageDisappearTimer.add(null);
      opponentsMessageDisappearTimeInSeconds.add(4);
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

  void setCurrentUserMessageDisappearTimer() {
    if (currentUserMessageDisappearTimeInSeconds != 4) {
      currentUserMessageDisappearTimeInSeconds = 4;
    }

    currentUserMessageDisappearTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentUserMessageDisappearTimeInSeconds == 0) {
        //
        timer.cancel();
        messageAnimationController.reverse();
      } else {
        currentUserMessageDisappearTimeInSeconds--;
      }
    });
  }

  void setOpponentUserMessageDisappearTimer(int opponentUserIndex) {
    //
    if (opponentsMessageDisappearTimeInSeconds[opponentUserIndex] != 4) {
      opponentsMessageDisappearTimeInSeconds[opponentUserIndex] = 4;
    }

    opponentsMessageDisappearTimer[opponentUserIndex] = Timer.periodic(Duration(seconds: 1), (timer) {
      if (opponentsMessageDisappearTimeInSeconds[opponentUserIndex] == 0) {
        //
        timer.cancel();
        opponentMessageAnimationControllers[opponentUserIndex].reverse();
      } else {
        //print("Opponent $opponentUserMessageDisappearTimeInSeconds");
        opponentsMessageDisappearTimeInSeconds[opponentUserIndex] = opponentsMessageDisappearTimeInSeconds[opponentUserIndex] - 1;
      }
    });
  }

  void messagesListener(MessageState state) async {
    if (state is MessageFetchedSuccess) {
      if (state.messages.isNotEmpty) {
        if (state.messages.last.by == context.read<UserDetailsCubit>().getUserId()) {
          //current user message
          //
          //means timer is running
          if (currentUserMessageDisappearTimeInSeconds > 0 && currentUserMessageDisappearTimeInSeconds < 4) {
            print(currentUserMessageDisappearTimeInSeconds);
            currentUserMessageDisappearTimer?.cancel();
            setCurrentUserMessageDisappearTimer();
          } else {
            messageAnimationController.forward();
            setCurrentUserMessageDisappearTimer();
          }
        } else {
          List<UserBattleRoomDetails?> opponentUsers = context.read<MultiUserBattleRoomCubit>().getOpponentUsers(context.read<UserDetailsCubit>().getUserId());
          int opponentUserIndex = opponentUsers.indexWhere((element) => state.messages.last.by == element!.uid);

          //opponent message
          //
          //means timer is running
          if (opponentUserIndex != -1) {
            if (opponentsMessageDisappearTimeInSeconds[opponentUserIndex] > 0 && opponentsMessageDisappearTimeInSeconds[opponentUserIndex] < 4) {
              //
              opponentsMessageDisappearTimer[opponentUserIndex]?.cancel();
              setOpponentUserMessageDisappearTimer(opponentUserIndex);
            } else {
              opponentMessageAnimationControllers[opponentUserIndex].forward();
              setOpponentUserMessageDisappearTimer(opponentUserIndex);
            }
          }
        }
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
          deleteMessages(context.read<MultiUserBattleRoomCubit>());

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
                      //delete messages
                      deleteMessages(context.read<MultiUserBattleRoomCubit>());

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
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: userDetailsPadding,
          bottom: userDetailsPadding,
        ),
        child: RectangleUserProfileContainer(
          userBattleRoomDetails: userBattleRoomDetails,
          isLeft: true,
          animationController: timerAnimationController,
          progressColor: Theme.of(context).backgroundColor,
        ),
      ),
    );
  }

  Widget _buildOpponentUserDetails({required int questionsLength, required AlignmentDirectional alignment, required List<UserBattleRoomDetails?> opponentUsers, required int opponentUserIndex}) {
    UserBattleRoomDetails userBattleRoomDetails = opponentUsers[opponentUserIndex]!;
    double progressPercentage = (100.0 * userBattleRoomDetails.answers.length) / questionsLength;
    opponentProgressAnimationControllers[opponentUserIndex].value = NormalizeNumber.inRange(currentValue: progressPercentage, minValue: 0.0, maxValue: 100.0, newMaxValue: 1.0, newMinValue: 0.0);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: alignment == AlignmentDirectional.bottomEnd || alignment == AlignmentDirectional.topEnd ? 0 : userDetailsPadding,
          end: alignment == AlignmentDirectional.bottomEnd || alignment == AlignmentDirectional.topEnd ? userDetailsPadding : 0,
          bottom: userDetailsPadding,
          top: alignment == AlignmentDirectional.topStart || alignment == AlignmentDirectional.topEnd ? MediaQuery.of(context).padding.top : 0,
        ),
        child: RectangleUserProfileContainer(
          userBattleRoomDetails: userBattleRoomDetails,
          isLeft: alignment == AlignmentDirectional.bottomStart || alignment == AlignmentDirectional.topStart,
          animationController: opponentProgressAnimationControllers[opponentUserIndex],
          progressColor: Theme.of(context).backgroundColor,
        ),
      ),
    );
  }

  Widget _buildMessageButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: messageBoxAnimationController,
        builder: (context, child) {
          Color? buttonColor = messageBoxAnimation.drive(ColorTween(begin: Theme.of(context).colorScheme.secondary, end: Theme.of(context).backgroundColor)).value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: IconButton(
              onPressed: () {
                if (messageBoxAnimationController.isCompleted) {
                  messageBoxAnimationController.reverse();
                } else {
                  messageBoxAnimationController.forward();
                }
              },
              icon: Icon(CupertinoIcons.chat_bubble_2_fill),
              color: buttonColor,
            ),
          );
        },
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

  Widget _buildMessageBoxContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: messageBoxAnimation.drive(Tween<Offset>(begin: Offset(1.5, 0), end: Offset.zero)),
        child: MessageBoxContainer(
          quizType: QuizTypes.groupPlay,
          topPadding: MediaQuery.of(context).size.height * (0.095) + MediaQuery.of(context).padding.top,
          closeMessageBox: () {
            messageBoxAnimationController.reverse();
          },
        ),
      ),
    );
  }

  Widget _buildCurrentUserMessageContainer() {
    return PositionedDirectional(
      child: ScaleTransition(
        scale: messageAnimation,
        child: MessageContainer(
          quizType: QuizTypes.groupPlay,
          isCurrentUser: true,
        ),
        alignment: Alignment(-0.5, 1.0), //-0.5 left side nad 0.5 is right side,
      ),
      start: userDetailsPadding,
      bottom: MediaQuery.of(context).size.height * RectangleUserProfileContainer.userDetailsHeightPercentage + userDetailsPadding * 2.5,
    );
  }

  Widget _buildOpponentUserMessageContainer(int opponentUserIndex) {
    Alignment alignment = Alignment(-0.5, 1.0);
    if (opponentUserIndex == 0) {
      alignment = Alignment(0.5, 1.0);
    } else if (opponentUserIndex == 1) {
      alignment = Alignment(-0.5, -1.0);
    } else {
      alignment = Alignment(0.5, -1.0);
    }

    return PositionedDirectional(
      child: ScaleTransition(
        scale: messageAnimation,
        child: MessageContainer(
          quizType: QuizTypes.groupPlay,
          isCurrentUser: false,
          opponentUserIndex: opponentUserIndex,
        ),
        alignment: alignment, //-0.5 left side and 0.5 is right side,
      ),
      start: userDetailsPadding,
      bottom: MediaQuery.of(context).size.height * RectangleUserProfileContainer.userDetailsHeightPercentage + userDetailsPadding * 2,
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
                    deleteMessages(battleRoomCubit);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: MultiBlocListener(
          listeners: [
            //update ui and do other callback based on changes in MultiUserBattleRoomCubit
            BlocListener<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
              bloc: battleRoomCubit,
              listener: (context, state) {
                battleRoomListener(context, state, battleRoomCubit);
              },
            ),
            BlocListener<MessageCubit, MessageState>(
              bloc: context.read<MessageCubit>(),
              listener: (context, state) {
                //this listener will be call everytime when new message will add
                messagesListener(state);
              },
            ),
          ],
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * (0.08),
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: showWaitForOthers
                          ? WaitForOthersContainer(
                              key: Key("waitForOthers"),
                            )
                          : QuestionsContainer(
                              quizType: QuizTypes.groupPlay,
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
                    ),
                  )),
              _buildMessageBoxContainer(),

              showUserLeftTheGame ? Container() : _buildCurrentUserDetails(battleRoomCubit.getUser(context.read<UserDetailsCubit>().getUserId())!),
              _buildCurrentUserMessageContainer(),
              //user in bottom Right corner

              showUserLeftTheGame
                  ? Container()
                  : BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                      bloc: battleRoomCubit,
                      builder: (context, state) {
                        if (state is MultiUserBattleRoomSuccess) {
                          List<UserBattleRoomDetails?> opponentUsers = battleRoomCubit.getOpponentUsers(context.read<UserDetailsCubit>().getUserId());
                          return opponentUsers.length >= 1
                              ? _buildOpponentUserDetails(
                                  questionsLength: state.questions.length,
                                  alignment: AlignmentDirectional.bottomEnd,
                                  opponentUsers: opponentUsers,
                                  opponentUserIndex: 0,
                                )
                              : Container();
                        }
                        return Container();
                      },
                    ),
              //user in topLeft corner
              showUserLeftTheGame
                  ? Container()
                  : BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                      bloc: battleRoomCubit,
                      builder: (context, state) {
                        if (state is MultiUserBattleRoomSuccess) {
                          List<UserBattleRoomDetails?> opponentUsers = battleRoomCubit.getOpponentUsers(context.read<UserDetailsCubit>().getUserId());
                          return opponentUsers.length >= 2
                              ? _buildOpponentUserDetails(
                                  questionsLength: state.questions.length,
                                  alignment: AlignmentDirectional.topStart,
                                  opponentUsers: opponentUsers,
                                  opponentUserIndex: 1,
                                )
                              : Container();
                        }
                        return Container();
                      },
                    ),
              //user in top End corner
              showUserLeftTheGame
                  ? Container()
                  : BlocBuilder<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                      bloc: battleRoomCubit,
                      builder: (context, state) {
                        if (state is MultiUserBattleRoomSuccess) {
                          List<UserBattleRoomDetails?> opponentUsers = battleRoomCubit.getOpponentUsers(context.read<UserDetailsCubit>().getUserId());
                          return opponentUsers.length >= 3
                              ? _buildOpponentUserDetails(
                                  questionsLength: state.questions.length,
                                  alignment: AlignmentDirectional.topEnd,
                                  opponentUsers: opponentUsers,
                                  opponentUserIndex: 2,
                                )
                              : Container();
                        }
                        return Container();
                      },
                    ),
              _buildMessageButton(),
              _buildYouWonContainer(battleRoomCubit),
              _buildUserLeftTheGame(),
            ],
          ),
        ),
      ),
    );
  }
}
