import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomOptionDialog.dart';
import 'package:flutterquiz/ui/screens/home/widgets/languageBottomSheetContainer.dart';
import 'package:flutterquiz/ui/screens/home/widgets/quizTypeContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/ui/widgets/userAchievementScreen.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/notificationHandler.dart';
import 'package:flutterquiz/utils/quizTypes.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class HomeScreen extends StatefulWidget {
  final bool isNewUser;
  HomeScreen({Key? key, required this.isNewUser}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => BlocProvider<ReferAndEarnCubit>(
              create: (_) => ReferAndEarnCubit(AuthRepository()),
              child: HomeScreen(
                isNewUser: routeSettings.arguments as bool,
              ),
            ));
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final double quizTypeWidthPercentage = 0.4;
  final double quizTypeTopMargin = 0.425;
  final double quizTypeHorizontalMarginPercentage = 0.08;
  final List<int> maxHeightQuizTypeIndexes = [0, 3, 4, 7];

  final double quizTypeBetweenVerticalSpacing = 0.02;

  late List<QuizType> _quizTypes = quizTypes;

  late AnimationController animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  late AnimationController bottomQuizTypeOpacityAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300))..forward();

  late AnimationController profileAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 85));
  late AnimationController selfChallengeAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 85));

  late Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
  late Animation<double> bottomQuizTypeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: bottomQuizTypeOpacityAnimationController, curve: Curves.easeInOut));

  late Animation<Offset> profileSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -0.0415)).animate(CurvedAnimation(parent: profileAnimationController, curve: Curves.easeIn));

  late Animation<Offset> selfChallengeSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -0.0415)).animate(CurvedAnimation(parent: selfChallengeAnimationController, curve: Curves.easeIn));
  late FirebaseMessaging messaging;
  @override
  void initState() {
    //initFirebaseMessaging();
    super.initState();
  }

  void initFirebaseMessaging() {
    messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
    new NotificationHandler().initializeFcmNotification(context);
  }

  @override
  void dispose() {
    bottomQuizTypeOpacityAnimationController.dispose();
    animationController.dispose();
    profileAnimationController.dispose();
    selfChallengeAnimationController.dispose();
    super.dispose();
  }

  void startAnimation() async {
    await animationController.forward();

    selfChallengeAnimationController.forward().then((value) async {
      await profileAnimationController.forward();
      await selfChallengeAnimationController.reverse();
      profileAnimationController.reverse();
    });

    animationController.dispose();
    bottomQuizTypeOpacityAnimationController.dispose();
    setState(() {
      _quizTypes = _quizTypes.sublist(4, 8)..addAll(_quizTypes.sublist(0, 4));
      animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
      animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOutQuad));
      bottomQuizTypeOpacityAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
      bottomQuizTypeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: bottomQuizTypeOpacityAnimationController, curve: Curves.easeInOut));
    });
    bottomQuizTypeOpacityAnimationController.forward();
  }

  //to track vertical update on quizType container
  void verticalDragUpdate(DragUpdateDetails dragUpdateDetails) {
    double dragged = dragUpdateDetails.primaryDelta! / MediaQuery.of(context).size.height;

    animationController.value = animationController.value - (2.5) * dragged;
  }

  void verticalDragEnd(DragEndDetails details) {
    if (animationController.value != 0) {
      startAnimation();
    }
  }

  void onQuizTypeContainerTap(int quizTypeIndex) {
    if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.dailyQuiz) {
      if (context.read<SystemConfigCubit>().getIsDailyQuizAvailable() == "1") {
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {"quizType": QuizTypes.dailyQuiz, "numberOfPlayer": 1, "quizName": "Daily Quiz"});
      } else {
        UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(currentlyNotAvailableKey)!, context, false);
      }
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.quizZone) {
      Navigator.of(context).pushNamed(Routes.category, arguments: {"quizType": QuizTypes.quizZone});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.selfChallenge) {
      Navigator.of(context).pushNamed(Routes.selfChallenge);
    } //
    else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.battle) {
      UiUtils.navigateToOneVSOneBattleScreen(context);
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.trueAndFalse) {
      Navigator.of(context).pushNamed(Routes.quiz, arguments: {"quizType": QuizTypes.trueAndFalse, "numberOfPlayer": 1, "quizName": "True & False"});
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.funAndLearn) {
      Navigator.of(context).pushNamed(Routes.funAndLearnTitle, arguments: {"quizType": _quizTypes[quizTypeIndex].quizTypeEnum});
    }
    //
    else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.groupPlay) {
      showDialog(context: context, builder: (context) => RoomOptionDialog());
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.contest) {
      if (context.read<SystemConfigCubit>().getIsContestAvailable() == "1") {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(currentlyNotAvailableKey)!, context, false);
      }
    } else if (_quizTypes[quizTypeIndex].quizTypeEnum == QuizTypes.guessTheWord) {
      Navigator.of(context).pushNamed(Routes.guessTheWord);
    }
  }

  Widget _buildProfileContainer(double statusBarPadding) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          //
          Navigator.of(context).pushNamed(Routes.profile);
        },
        child: SlideTransition(
          position: profileSlideAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
              bloc: context.read<UserDetailsCubit>(),
              builder: (context, state) {
                if (state is UserDetailsFetchSuccess) {
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 37.5,
                        backgroundImage: CachedNetworkImageProvider(state.userProfile.profileUrl!),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * (0.0175),
                      ),
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.userProfile.name!,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.userProfile.email!.isEmpty ? state.userProfile.mobileNumber! : state.userProfile.email!,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: constraints.maxHeight * (0.05),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    UserAchievementContainer(title: AppLocalization.of(context)!.getTranslatedValues("rankLbl")!, value: state.userProfile.allTimeRank ?? "0"),
                                    UserAchievementContainer(title: AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!, value: state.userProfile.coins ?? "0"),
                                    UserAchievementContainer(title: AppLocalization.of(context)!.getTranslatedValues("scoreLbl")!, value: UiUtils.formatNumber(int.parse(state.userProfile.allTimeScore ?? "0"))),
                                  ], //
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
                return Container();
              },
            ),
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.085) + statusBarPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              //gradient: UiUtils.buildLinerGradient([Theme.of(context).primaryColor, Theme.of(context).accentColor], Alignment.topCenter, Alignment.bottomCenter),
              boxShadow: [
                UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10.0),
              ],
              borderRadius: BorderRadius.circular(30.0),
            ),
            width: MediaQuery.of(context).size.width * (0.84),
            height: MediaQuery.of(context).size.height * (0.16),
          ),
        ),
      ),
    );
  }

  Widget _buildSelfChallenge(double statusBarPadding) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.selfChallenge);
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: selfChallengeSlideAnimation,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.28 + statusBarPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,

              //gradient: UiUtils.buildLinerGradient([Theme.of(context).accentColor, Theme.of(context).primaryColor], Alignment.centerLeft, Alignment.centerRight),

              boxShadow: [UiUtils.buildBoxShadow(offset: Offset(5.0, 5.0), blurRadius: 10.0)],
              borderRadius: BorderRadius.circular(20.0),
            ),
            width: MediaQuery.of(context).size.width * (0.84),
            height: MediaQuery.of(context).size.height * (0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      margin: EdgeInsetsDirectional.only(start: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalization.of(context)!.getTranslatedValues(selfChallengeLbl)!,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 1.0,
                          ),
                          Text(
                            AppLocalization.of(context)!.getTranslatedValues(challengeYourselfLbl)!,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Theme.of(context).primaryColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Transform.scale(scale: 0.55, child: SvgPicture.asset("assets/images/selfchallenge_icon.svg")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizType(int quizTypeIndex, double statusBarPadding) {
    double topMarginPercentage = quizTypeTopMargin;

    if (quizTypeIndex - 2 < 0) {
      topMarginPercentage = quizTypeTopMargin;
    } else {
      int baseCondition = quizTypeIndex % 2 == 0 ? 0 : 1;
      for (int i = quizTypeIndex; i > baseCondition; i = i - 2) {
        //
        double topQuizTypeHeight = maxHeightQuizTypeIndexes.contains(i - 2) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage;

        topMarginPercentage = topMarginPercentage + quizTypeBetweenVerticalSpacing + topQuizTypeHeight;
      }
    }

    if (quizTypeIndex % 2 == 0) {
      //if questionType index is less than 4
      if (quizTypeIndex <= 3) {
        //add animation for horizontal slide and opacity
        return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Positioned(
                child: GestureDetector(
                  onTap: () {
                    onQuizTypeContainerTap(quizTypeIndex);
                  },
                  onVerticalDragUpdate: verticalDragUpdate,
                  onVerticalDragEnd: verticalDragEnd,
                  child: Opacity(
                      opacity: 1.0 - (1.0 * animation.value),
                      child: QuizTypeContainer(
                        quizType: _quizTypes[quizTypeIndex],
                        widthPercentage: quizTypeWidthPercentage,
                        heightPercentage: maxHeightQuizTypeIndexes.contains(quizTypeIndex) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage,
                      )),
                ),
                top: MediaQuery.of(context).size.height * topMarginPercentage + statusBarPadding,
                left: quizTypeHorizontalMarginPercentage * MediaQuery.of(context).size.width -
                    MediaQuery.of(context).size.width * quizTypeWidthPercentage * animation.value -
                    quizTypeHorizontalMarginPercentage * MediaQuery.of(context).size.width * animation.value,
              );
            });
      }
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          double end = quizTypeTopMargin;
          //change static number to length of menu
          if (quizTypeIndex == (_quizTypes.length - 1) || quizTypeIndex == (_quizTypes.length - 2)) {
            double previousTopQuizTypeHeight = maxHeightQuizTypeIndexes.contains(quizTypeIndex - 2) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage;
            end = quizTypeTopMargin + quizTypeBetweenVerticalSpacing + previousTopQuizTypeHeight;
          }
          double topMargin = animation.drive(Tween(begin: topMarginPercentage, end: end)).value;

          return Positioned(
            child: GestureDetector(
              onVerticalDragUpdate: verticalDragUpdate,
              onVerticalDragEnd: verticalDragEnd,
              child: FadeTransition(
                  opacity: bottomQuizTypeOpacityAnimation,
                  child: QuizTypeContainer(
                    quizType: _quizTypes[quizTypeIndex],
                    widthPercentage: quizTypeWidthPercentage,
                    heightPercentage: maxHeightQuizTypeIndexes.contains(quizTypeIndex) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage,
                  )),
            ),
            top: MediaQuery.of(context).size.height * topMargin + statusBarPadding,
            left: MediaQuery.of(context).size.width * quizTypeHorizontalMarginPercentage,
          );
        },
      );
    } else {
      //for odd index
      if (quizTypeIndex <= 3) {
        //add animation for horizontal slide and opacity
        return AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Positioned(
                child: GestureDetector(
                  onTap: () {
                    onQuizTypeContainerTap(quizTypeIndex);
                  },
                  onVerticalDragUpdate: verticalDragUpdate,
                  onVerticalDragEnd: verticalDragEnd,
                  child: Opacity(
                      opacity: 1.0 - (1.0 * animation.value),
                      child: QuizTypeContainer(
                        quizType: _quizTypes[quizTypeIndex],
                        widthPercentage: quizTypeWidthPercentage,
                        heightPercentage: maxHeightQuizTypeIndexes.contains(quizTypeIndex) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage,
                      )),
                ),
                top: MediaQuery.of(context).size.height * topMarginPercentage + statusBarPadding,
                right: quizTypeHorizontalMarginPercentage * MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * quizTypeWidthPercentage * animation.value - quizTypeHorizontalMarginPercentage * animation.value,
              );
            });
      }

      return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          double end = quizTypeTopMargin;
          //change static number to length of menu
          if (quizTypeIndex == (_quizTypes.length - 1) || quizTypeIndex == (_quizTypes.length - 2)) {
            double previousTopQuizTypeHeight = maxHeightQuizTypeIndexes.contains(quizTypeIndex - 2) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage;
            end = quizTypeTopMargin + quizTypeBetweenVerticalSpacing + previousTopQuizTypeHeight;
          }

          double topMargin = animation.drive(Tween(begin: topMarginPercentage, end: end)).value;

          return Positioned(
            child: GestureDetector(
                onVerticalDragUpdate: verticalDragUpdate,
                onVerticalDragEnd: verticalDragEnd,
                child: FadeTransition(
                    opacity: bottomQuizTypeOpacityAnimation,
                    child: QuizTypeContainer(
                      quizType: _quizTypes[quizTypeIndex],
                      widthPercentage: quizTypeWidthPercentage,
                      heightPercentage: maxHeightQuizTypeIndexes.contains(quizTypeIndex) ? UiUtils.quizTypeMaxHeightPercentage : UiUtils.quizTypeMinHeightPercentage,
                    ))),
            top: MediaQuery.of(context).size.height * topMargin + statusBarPadding,
            right: quizTypeHorizontalMarginPercentage * MediaQuery.of(context).size.width,
          );
        },
      );
    }
  }

  List<Widget> _buildQuizTypes(double statusBarPadding) {
    List<Widget> children = [];
    for (int i = 0; i < _quizTypes.length; i++) {
      Widget child = AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return _buildQuizType(i, statusBarPadding);
        },
      );
      children.add(child);
    }
    return children;
  }

  Widget _buildLeaderBoardButton(double statusBarPadding) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarPadding + 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /*  Container(
                width: 45,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  boxShadow: [
                    UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10.0),
                  ],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Switch(
                  value: changeAppTheme,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveThumbColor: primaryColor,
                  onChanged: (value) {
                    changeAppTheme = !changeAppTheme;
                    changeAppTheme ? BlocProvider.of<ThemeCubit>(context).changeTheme(AppTheme.Dark) : BlocProvider.of<ThemeCubit>(context).changeTheme(AppTheme.Light);
                  },
                )),
            SizedBox(
              width: 12.5,
            ),*/
            
            Container(
              width: 45,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10.0),
                ],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.notification);
                  },
                  icon: Icon(
                    Icons.notification_important,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            SizedBox(
              width: 12.5,
            ),

            Container(
              width: 45,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10.0),
                ],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.leaderBoard);
                  },
                  icon: SvgPicture.asset(
                    UiUtils.getImagePath("leaderboard_dark.svg"),
                  )),
            ),
            context.read<SystemConfigCubit>().getLanguageMode() == "1"
                ? SizedBox(
                    width: 12.5,
                  )
                : SizedBox(),
            context.read<SystemConfigCubit>().getLanguageMode() == "1"
                ? Container(
                    width: 45,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      boxShadow: [
                        UiUtils.buildBoxShadow(offset: Offset(5, 5), blurRadius: 10.0),
                      ],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: IconButton(
                        onPressed: () {
                          showDialog(context: context, builder: (_) => LanguageDailogContainer());
                        },
                        icon: SvgPicture.asset(
                          UiUtils.getImagePath("language_icon.svg"),
                        )),
                  )
                : SizedBox(),
            SizedBox(
              width: MediaQuery.of(context).size.width * (0.085),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen(List<Widget> children) {
    return Stack(
      children: [
        PageBackgroundGradientContainer(),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: BlocConsumer<UserDetailsCubit, UserDetailsState>(
        listener: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            //fetch bookmark
            if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
              context.read<BookmarkCubit>().getBookmark(state.userProfile.userId);
            }
          }
        },
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchInProgress || state is UserDetailsInitial) {
            return _buildHomeScreen([
              Center(
                child: CircularProgressContainer(
                  useWhiteLoader: false,
                ),
              )
            ]);
          }
          if (state is UserDetailsFetchFailure) {
            return _buildHomeScreen([
              ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!,
                onTapRetry: () {
                  context.read<UserDetailsCubit>().fetchUserDetails(context.read<AuthCubit>().getUserFirebaseId());
                },
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              )
            ]);
          }

          UserProfile userProfile = (state as UserDetailsFetchSuccess).userProfile;
          if (userProfile.status == "0") {
            return _buildHomeScreen([
              ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(accountDeactivatedKey)!,
                onTapRetry: () {
                  context.read<UserDetailsCubit>().fetchUserDetails(context.read<AuthCubit>().getUserFirebaseId());
                },
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              )
            ]);
          }

          return _buildHomeScreen([
            _buildLeaderBoardButton(statusBarPadding),
            _buildProfileContainer(statusBarPadding),
            _buildSelfChallenge(statusBarPadding),
            ..._buildQuizTypes(statusBarPadding),
          ]);
        },
      ),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}
/*
Container(
height: MediaQuery.of(context).size.height,
width: MediaQuery.of(context).size.width,
decoration: BoxDecoration(
image: DecorationImage(image: AssetImage("assets/images/C+.png"),fit: BoxFit.fill),
)),*/
