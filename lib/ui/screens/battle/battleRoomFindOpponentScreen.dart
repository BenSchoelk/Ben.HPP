import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';

import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';

import 'package:flutterquiz/ui/screens/battle/widgets/findingOpponentLetterAnimation.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/userFoundMapContainer.dart';
import 'package:flutterquiz/ui/widgets/circularImageContainer.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class BattleRoomFindOpponentScreen extends StatefulWidget {
  final String categoryId;
  BattleRoomFindOpponentScreen({Key? key, required this.categoryId}) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BattleRoomFindOpponentScreen(
              categoryId: routeSettings.arguments as String,
            ));
  }

  @override
  _BattleRoomFindOpponentScreenState createState() => _BattleRoomFindOpponentScreenState();
}

class _BattleRoomFindOpponentScreenState extends State<BattleRoomFindOpponentScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScrollController scrollController = ScrollController();
  late AnimationController letterAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 4));
  late AnimationController quizCountDownAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 4));
  late Animation<int> quizCountDownAnimation = IntTween(begin: 3, end: 0).animate(quizCountDownAnimationController);
  late AnimationController animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 950))..forward();
  late Animation<double> mapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Interval(0.0, 0.4, curve: Curves.easeInOut)));
  late Animation<double> playerDetailsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Interval(0.4, 0.7, curve: Curves.easeInOut)));
  late Animation<double> findingOpponentStatusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Interval(0.7, 1.0, curve: Curves.easeInOut)));

  //to store images of map so we can simulate the mapSlideAnimation
  late List<String> images = [];

  //
  late bool waitForOpponent = true;
  //waiting time to find opponent to join
  late int waitingTime = waitForOpponentDurationInSeconds;
  Timer? waitForOpponentTimer;

  @override
  void initState() {
    addImages();

    Future.delayed(Duration(milliseconds: 1000), () {
      //search for battle room after initial animation completed
      searchBattleRoom();
      startScrollImageAnimation();

      letterAnimationController.repeat(reverse: false);
    });
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //delete battle room if user press home button or move from battleOpponentFind screen
    if (state == AppLifecycleState.paused) {
      context.read<BattleRoomCubit>().deleteBattleRoom();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    letterAnimationController.dispose();
    quizCountDownAnimationController.dispose();
    animationController.dispose();
    waitForOpponentTimer?.cancel();
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  void searchBattleRoom() {
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    context.read<BattleRoomCubit>().searchRoom(
          categoryId: widget.categoryId,
          name: userProfile.name!,
          profileUrl: userProfile.profileUrl!,
          uid: userProfile.userId!,
          questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
        );
  }

  void addImages() {
    for (var i = 0; i < 20; i++) {
      images.add(UiUtils.getImagePath("map_finding.png"));
    }
  }

  //this will be call only when user has created room successfully
  void setWaitForOpponentTimer() {
    waitForOpponentTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (waitingTime == 0) {
        //delete room so other user can not join
        context.read<BattleRoomCubit>().deleteBattleRoom();
        //stop other activities
        letterAnimationController.stop();
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        timer.cancel();
        setState(() {
          waitForOpponent = false;
        });
      } else {
        waitingTime--;
      }
    });
  }

  Future<void> startScrollImageAnimation() async {
    //if scroll controller is attached to any scrollable widgets
    if (scrollController.hasClients) {
      double maxScroll = scrollController.position.maxScrollExtent;

      if (maxScroll == 0) {
        startScrollImageAnimation();
      }

      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(seconds: 20), curve: Curves.linear);
    }
  }

  void retryToSearchBattleRoom() {
    scrollController.dispose();
    setState(() {
      scrollController = ScrollController();
      waitingTime = waitForOpponentDurationInSeconds;
      waitForOpponent = true;
    });
    letterAnimationController.repeat(reverse: false);
    Future.delayed(Duration(milliseconds: 100), () {
      startScrollImageAnimation();
    });
    searchBattleRoom();
  }

  //
  Widget _buildUserDetails(String name, String profileUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            //
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
              height: MediaQuery.of(context).size.height * (0.15),
            ),
            CircularImageContainer(height: MediaQuery.of(context).size.height * (0.14), imagePath: profileUrl, width: MediaQuery.of(context).size.width * (0.3)),
          ],
        ),
        SizedBox(
          height: 2.5,
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * (0.3),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),
          ),
        )
      ],
    );
  }

  Widget _buildCurrentUserDetails() {
    return Container(
      margin: EdgeInsetsDirectional.only(
        end: MediaQuery.of(context).size.width * (0.45),
      ),
      child: _buildUserDetails(context.read<UserDetailsCubit>().getUserProfile().name!, context.read<UserDetailsCubit>().getUserProfile().profileUrl!),
    );
  }

  //
  Widget _buildOpponentUserDetails() {
    return Container(
      margin: EdgeInsetsDirectional.only(
        start: MediaQuery.of(context).size.width * (0.45),
      ),
      child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
        bloc: context.read<BattleRoomCubit>(),
        builder: (context, state) {
          if (state is BattleRoomFailure) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Center(
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                  height: MediaQuery.of(context).size.height * (0.15),
                ),
                SizedBox(
                  height: 2.5,
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * (0.3),
                  child: Text(
                    "....",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),
                  ),
                )
              ],
            );
          }
          if (state is BattleRoomUserFound) {
            UserBattleRoomDetails opponentUserDetails = context.read<BattleRoomCubit>().getOpponentUserDetails(context.read<UserDetailsCubit>().getUserId());
            return _buildUserDetails(opponentUserDetails.name, opponentUserDetails.profileUrl);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FindOpponentLetterAnimation(animationController: letterAnimationController),
              SizedBox(
                height: 2.5,
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * (0.3),
                child: Text(
                  "....",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  //to show user status of process (opponent found or finding opponent etc)
  Widget _buildFindingOpponentStatus() {
    return FadeTransition(
      opacity: findingOpponentStatusAnimation,
      child: SlideTransition(
        position: findingOpponentStatusAnimation.drive(Tween<Offset>(begin: Offset(0.075, 0.0), end: Offset.zero)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * (0.05),
              ),
              child: waitForOpponent
                  ? BlocBuilder<BattleRoomCubit, BattleRoomState>(
                      bloc: context.read<BattleRoomCubit>(),
                      builder: (context, state) {
                        if (state is BattleRoomFailure) {
                          return Container();
                        }
                        if (state is! BattleRoomUserFound) {
                          return Text(
                            AppLocalization.of(context)!.getTranslatedValues('findingOpponentLbl')!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return Text(
                          AppLocalization.of(context)!.getTranslatedValues('foundOpponentLbl')!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    )
                  : Container()),
        ),
      ),
    );
  }

  //TODO: need to find optimize solution for this map animation
  //to display map animation
  Widget _buildFindingMap() {
    return Align(
      key: Key("userFinding"),
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        ignoring: true,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              height: MediaQuery.of(context).size.height * (0.6),
              child: Row(
                children: images
                    .map((e) => Image.asset(
                          e,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              )),
        ),
      ),
    );
  }

  //build details when opponent found
  Widget _buildUserFoundDetails() {
    return Align(
        key: Key("userFound"),
        alignment: Alignment.topCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * (0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * (0.05)),
              Text(
                AppLocalization.of(context)!.getTranslatedValues('getReadyLbl')!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * (0.025)),
              AnimatedBuilder(
                  animation: quizCountDownAnimationController,
                  builder: (context, child) {
                    return Text(
                      quizCountDownAnimation.value == 0 ? AppLocalization.of(context)!.getTranslatedValues('bestOfLuckLbl')! : "${quizCountDownAnimation.value}",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
              SizedBox(height: MediaQuery.of(context).size.height * (0.0275)),
              UserFoundMapContainer(),
            ],
          ),
        ));
  }

  //show details when opponent not found
  Widget _buildOpponentNotFoundDetails() {
    return Align(
      alignment: Alignment.topCenter,
      key: Key("userNotFound"),
      child: Container(
        height: MediaQuery.of(context).size.height * (0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * (0.05)),
            Text(
              AppLocalization.of(context)!.getTranslatedValues('opponentNotFoundLbl')!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 25,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * (0.025)),
            Platform.isIOS?Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomRoundedButton(
                  widthPercentage: 0.375,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!.getTranslatedValues('retryLbl')!,
                  radius: 5,
                  showBorder: false,
                  height: 40,
                  titleColor: Theme.of(context).backgroundColor,
                  elevation: 5.0,
                  onTap: () {
                    retryToSearchBattleRoom();
                  },
                ),
                CustomRoundedButton(
                  widthPercentage: 0.375,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: "Back",
                  radius: 5,
                  showBorder: false,
                  height: 40,
                  titleColor: Theme.of(context).backgroundColor,
                  elevation: 5.0,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ): CustomRoundedButton(
              widthPercentage: 0.375,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle: AppLocalization.of(context)!.getTranslatedValues('retryLbl')!,
              radius: 5,
              showBorder: false,
              height: 40,
              titleColor: Theme.of(context).backgroundColor,
              elevation: 5.0,
              onTap: () {
                retryToSearchBattleRoom();
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * (0.03)),
            UserFoundMapContainer(),
          ],
        ),
      ),
    );
  }

  //to build details for findinng opponent with map
  Widget _buildFindingOpponentMapDetails() {
    return FadeTransition(
      opacity: mapAnimation,
      child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
        bloc: context.read<BattleRoomCubit>(),
        builder: (context, state) {
          Widget child = _buildFindingMap();
          if (state is BattleRoomFailure) {
            child = ErrorContainer(showBackButton: true,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode))!,
                errorMessageColor: Theme.of(context).primaryColor,
                onTapRetry: () {
                  retryToSearchBattleRoom();
                },
                showErrorImage: true);
          }
          if (state is BattleRoomUserFound) {
            child = _buildUserFoundDetails();
          }
          return AnimatedSwitcher(duration: Duration(milliseconds: 500), child: waitForOpponent ? child : _buildOpponentNotFoundDetails());
        },
      ),
    );
  }

  Widget _buildVsImageContainer() {
    return Container(
      child: Image.asset(
        UiUtils.getImagePath("vs_icon.png"),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPlayersDetails() {
    return FadeTransition(
      opacity: playerDetailsAnimation,
      child: SlideTransition(
        position: playerDetailsAnimation.drive(Tween<Offset>(begin: Offset(0.075, 0.0), end: Offset.zero)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.125),
            ),
            height: MediaQuery.of(context).size.height * (0.2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCurrentUserDetails(),
                _buildOpponentUserDetails(),
                _buildVsImageContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        final battleRoomCubit = context.read<BattleRoomCubit>();
        //if user has found opponent then do not allow to go back
        if (battleRoomCubit.state is BattleRoomUserFound) {
          return Future.value(false);
        }

        showDialog(
            context: context,
            builder: (context) => ExitGameDailog(
                  onTapYes: () {
                    battleRoomCubit.deleteBattleRoom();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ));

        return Future.value(true);
      },
      child: Scaffold(
        body: BlocListener<BattleRoomCubit, BattleRoomState>(
          bloc: context.read<BattleRoomCubit>(),
          listener: (context, state) async {
            //start timer for waiting user only room created successfully
            if (state is BattleRoomCreated) {
              setWaitForOpponentTimer();
            } else if (state is BattleRoomUserFound) {
              //if opponent found
              waitForOpponentTimer?.cancel();
              await Future.delayed(Duration(milliseconds: 500));
              await quizCountDownAnimationController.forward();
              Navigator.of(context).pushReplacementNamed(Routes.battleRoomQuiz);
            }
          },
          child: Stack(
            children: [
              PageBackgroundGradientContainer(),
              _buildFindingOpponentMapDetails(),
              _buildPlayersDetails(),
              _buildFindingOpponentStatus(),
            ],
          ),
        ),
      ),
    );
  }
}
