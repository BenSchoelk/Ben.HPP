import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitingForPlayersDialog.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomDialog extends StatefulWidget {
  final QuizTypes quizType;
  RoomDialog({Key? key, required this.quizType}) : super(key: key);

  @override
  _RoomDialogState createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  int currentSelectedTab = 1; //1 is create and second is join

  String selectedCategory = selectCategoryKey;
  List<int> entryFees = [minCoinsForGroupBattleCreation, 5, 10, 15];
  int entryFee = minCoinsForGroupBattleCreation; //difference between two entries is
  TextEditingController textEditingController = TextEditingController();
  TextEditingController roomCodeEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      //to get categories
      if (isCategoryEnabled()) {
        context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
      }
    });
  }

  InputBorder _getInputBorder(BuildContext buildContext) {
    return UnderlineInputBorder(
        borderSide: BorderSide(
      color: Theme.of(context).primaryColor,
    ));
  }

  bool isCategoryEnabled() {
    if (widget.quizType == QuizTypes.battle) {
      return context.read<SystemConfigCubit>().getIsCategoryEnableForBattle()! == "1";
    }
    return context.read<SystemConfigCubit>().getIsCategoryEnableForGroupBattle()! == "1";
  }

  String getCategoryId() {
    QuizCategoryCubit quizCategoryCubit = context.read<QuizCategoryCubit>();
    if (quizCategoryCubit.state is QuizCategorySuccess) {
      return (quizCategoryCubit.state as QuizCategorySuccess).categories.where((element) => element.categoryName == selectedCategory).toList().first.id!;
    }
    return "";
  }

  Widget _buildTabContainer(int index, String title, BoxConstraints boxConstraints) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentSelectedTab = index;
        });
      },
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: Duration(
          milliseconds: 250,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: index == currentSelectedTab ? FontWeight.bold : FontWeight.w500,
            color: index == currentSelectedTab ? Theme.of(context).backgroundColor : Theme.of(context).primaryColor,
          ),
        ),
        height: boxConstraints.maxHeight * (0.15),
        width: boxConstraints.maxWidth * (0.5),
        decoration: BoxDecoration(
            color: index == currentSelectedTab ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
            borderRadius: index == 1
                ? BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.dailogRadius),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(UiUtils.dailogRadius),
                  )),
      ),
    );
  }

  //using for category
  Widget _buildDropdown({
    required List<Map<String, String?>> values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        dropdownColor: Theme.of(context).canvasColor, //same as background of dropdown color
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),
        isExpanded: true,
        iconEnabledColor: Theme.of(context).primaryColor,
        onChanged: (value) {
          // ScaffoldMessenger.of(context).removeCurrentSnackBar();

          setState(() {
            selectedCategory = value!;
          });
        },
        underline: SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            child: name! == selectCategoryKey ? Text(AppLocalization.of(context)!.getTranslatedValues(name)!) : Text(name),
            value: name,
          );
        }).toList(),
        value: selectedCategory);
  }

  Widget _buildEntryFeeContainer(int entryFeeValue, BoxConstraints boxConstraints, bool useManualValue) {
    return GestureDetector(
      onTap: useManualValue
          ? null
          : () {
              setState(() {
                entryFee = entryFeeValue;
              });
            },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        width: boxConstraints.maxWidth * (0.145),
        height: boxConstraints.maxHeight * (0.2),
        alignment: Alignment.center,
        padding: useManualValue ? EdgeInsets.symmetric(horizontal: 10.0) : null,
        child: useManualValue
            ? TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  entryFee = int.parse(value);
                  setState(() {});
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
                controller: textEditingController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  hintText: "00",
                  hintStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                  contentPadding: EdgeInsets.all(0),
                  isDense: true,
                  enabledBorder: _getInputBorder(context),
                  border: _getInputBorder(context),
                  focusedBorder: _getInputBorder(context),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$entryFeeValue",
                    style: TextStyle(
                      color: entryFeeValue == entryFee ? Theme.of(context).backgroundColor : Theme.of(context).primaryColor,
                      fontSize: 16.0,
                      fontWeight: entryFeeValue == entryFee ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
        decoration: BoxDecoration(
            boxShadow: entryFeeValue == entryFee ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.5), blurRadius: 5, offset: Offset(2.5, 2.5))] : null,
            color: entryFeeValue == entryFee ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  Widget _buildJoinRoomTab(BoxConstraints constraints) {
    return Column(
      key: Key("joinTab"),
      children: [
        Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues(enterRoomCodeHereKey)!,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 18.0),
            )),
        SizedBox(
          height: constraints.maxHeight * (0.04),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
          decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(25.0)),
          height: constraints.maxHeight * (0.115),
          child: TextField(
            style: TextStyle(color: Theme.of(context).primaryColor),
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalization.of(context)!.getTranslatedValues(enterCodeLbl),
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                )),
            controller: roomCodeEditingController,
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.1),
        ),
        widget.quizType == QuizTypes.battle
            ? BlocConsumer<BattleRoomCubit, BattleRoomState>(
                listener: (context, state) {
                  if (state is BattleRoomUserFound) {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (context) => WaitingForPlayesDialog(quizType: QuizTypes.battle));
                  } else if (state is BattleRoomFailure) {
                    UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
                  }
                },
                bloc: context.read<BattleRoomCubit>(),
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is BattleRoomJoining
                        ? () {}
                        : () {
                            if (roomCodeEditingController.text.trim().isEmpty) {
                              return;
                            }
                            UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
                            context.read<BattleRoomCubit>().joinRoom(
                                  currentCoin: userProfile.coins!,
                                  name: userProfile.name,
                                  uid: userProfile.userId,
                                  profileUrl: userProfile.profileUrl,
                                  roomCode: roomCodeEditingController.text.trim(),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: state is BattleRoomJoining ? AppLocalization.of(context)!.getTranslatedValues('joiningLoadingLbl')! : AppLocalization.of(context)!.getTranslatedValues(joinRoomKey)!,
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
            : BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => WaitingForPlayesDialog(
                              quizType: QuizTypes.groupPlay,
                            ));
                  } else if (state is MultiUserBattleRoomFailure) {
                    UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
                  }
                },
                bloc: context.read<MultiUserBattleRoomCubit>(),
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is MultiUserBattleRoomInProgress
                        ? () {}
                        : () {
                            if (roomCodeEditingController.text.trim().isEmpty) {
                              return;
                            }
                            UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
                            context.read<MultiUserBattleRoomCubit>().joinRoom(
                                  currentCoin: userProfile.coins!,
                                  name: userProfile.name,
                                  uid: userProfile.userId,
                                  profileUrl: userProfile.profileUrl,
                                  roomCode: roomCodeEditingController.text.trim(),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: state is MultiUserBattleRoomInProgress ? AppLocalization.of(context)!.getTranslatedValues('joiningLoadingLbl')! : AppLocalization.of(context)!.getTranslatedValues(joinRoomKey)!,
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildCreateRoomTab(BoxConstraints constraints) {
    return Column(
      key: Key("createTab"),
      children: [
        isCategoryEnabled()
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.05)),
                decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(25.0)),
                height: constraints.maxHeight * (0.115),
                child: BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                  bloc: context.read<QuizCategoryCubit>(),
                  listener: (context, state) {
                    if (state is QuizCategorySuccess) {
                      setState(() {
                        selectedCategory = state.categories.first.categoryName!;
                      });
                    }
                    if (state is QuizCategoryFailure) {
                      showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      //context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                                    },
                                    child: Text(
                                      AppLocalization.of(context)!.getTranslatedValues(retryLbl)!,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  )
                                ],
                                content: Text(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!),
                              )).then((value) {
                        if (value != null && value) {
                          context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                        }
                      });
                    }
                  },
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: state is QuizCategorySuccess
                          ? _buildDropdown(values: state.categories.map((e) => {"name": e.categoryName, "id": e.id}).toList(), keyValue: "selectCategorySuccess")
                          : Opacity(
                              opacity: 0.65,
                              child: _buildDropdown(values: [
                                {"name": selectCategoryKey, "id": "0"}
                              ], keyValue: "selectCategory"),
                            ),
                    );
                  },
                ),
              )
            : Container(),
        SizedBox(
          height: constraints.maxHeight * (isCategoryEnabled() ? 0.05 : 0),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.05)),
          child: Row(
            children: [
              ...entryFees.map((e) => _buildEntryFeeContainer(e, constraints, false)).toList(),
              _buildEntryFeeContainer(-1, constraints, true),
            ],
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.075),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
          decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(25.0)),
          height: constraints.maxHeight * (0.115),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${AppLocalization.of(context)!.getTranslatedValues(currentCoinsKey)!}:  ",
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.75),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                context.read<UserDetailsCubit>().getCoins()!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: constraints.maxHeight * (0.05),
        ),
        widget.quizType == QuizTypes.battle
            ? BlocConsumer<BattleRoomCubit, BattleRoomState>(
                bloc: context.read<BattleRoomCubit>(),
                //this listener will be in use for both creating and join room callbacks
                listener: (context, state) {
                  if (state is BattleRoomCreated) {
                    //wait for others
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (context) => WaitingForPlayesDialog(quizType: QuizTypes.battle, battleLbl: "playFrd"));
                  } else if (state is BattleRoomFailure) {
                    UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is BattleRoomCreating
                        ? () {}
                        : () {
                            if (isCategoryEnabled() && getCategoryId().isEmpty) {
                              UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(pleaseSelectCategoryKey)!);
                              return;
                            }
                            UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();

                            if (int.parse(userProfile.coins!) < entryFee) {
                              UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
                              return;
                            }
                            context.read<BattleRoomCubit>().createRoom(
                                  categoryId: getCategoryId(),
                                  entryFee: entryFee,
                                  name: userProfile.name,
                                  profileUrl: userProfile.profileUrl,
                                  roomType: "public",
                                  uid: userProfile.userId,
                                  questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: state is BattleRoomCreating ? AppLocalization.of(context)!.getTranslatedValues(creatingLoadingLbl) : AppLocalization.of(context)!.getTranslatedValues(createRoomKey),
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
            : BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
                bloc: context.read<MultiUserBattleRoomCubit>(),
                listener: (context, state) {
                  if (state is MultiUserBattleRoomSuccess) {
                    //wait for others
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => WaitingForPlayesDialog(
                              quizType: QuizTypes.groupPlay,
                              battleLbl: "",
                            ));
                  } else if (state is MultiUserBattleRoomFailure) {
                    UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
                  }
                },
                builder: (context, state) {
                  return CustomRoundedButton(
                    onTap: state is MultiUserBattleRoomInProgress
                        ? () {}
                        : () {
                            if (isCategoryEnabled() && getCategoryId().isEmpty) {
                              UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(pleaseSelectCategoryKey)!);
                              return;
                            }
                            UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();

                            if (int.parse(userProfile.coins!) < entryFee) {
                              UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
                              return;
                            }
                            context.read<MultiUserBattleRoomCubit>().createRoom(
                                  categoryId: getCategoryId(),
                                  entryFee: entryFee,
                                  name: userProfile.name,
                                  profileUrl: userProfile.profileUrl,
                                  roomType: "public",
                                  uid: userProfile.userId,
                                  questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
                                );
                          },
                    widthPercentage: UiUtils.dailogWidthPercentage - 0.1,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: state is MultiUserBattleRoomInProgress ? AppLocalization.of(context)!.getTranslatedValues(creatingLoadingLbl) : AppLocalization.of(context)!.getTranslatedValues(createRoomKey),
                    radius: 25.0,
                    elevation: 5.0,
                    titleColor: Theme.of(context).backgroundColor,
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    showBorder: false,
                    height: constraints.maxHeight * (0.115),
                    fontWeight: FontWeight.bold,
                  );
                },
              )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      onWillPop: () {
        //means user is in create tab
        if (currentSelectedTab == 1) {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state is MultiUserBattleRoomInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            if (context.read<BattleRoomCubit>().state is BattleRoomCreating) {
              return Future.value(false);
            }
            return Future.value(true);
          }
        }
        //user in join tab
        else {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state is MultiUserBattleRoomInProgress) {
              return Future.value(false);
            }
            return Future.value(true);
          } else {
            if (context.read<BattleRoomCubit>().state is BattleRoomJoining) {
              return Future.value(false);
            }
            return Future.value(true);
          }
        }
      },
      onBackButtonPress: () {
        if (currentSelectedTab == 1) {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state is! MultiUserBattleRoomInProgress) {
              Navigator.of(context).pop();
            }
          } else {
            if (context.read<BattleRoomCubit>().state is! BattleRoomCreating) {
              Navigator.of(context).pop();
            }
          }
        } else {
          if (widget.quizType == QuizTypes.groupPlay) {
            if (context.read<MultiUserBattleRoomCubit>().state is! MultiUserBattleRoomInProgress) {
              Navigator.of(context).pop();
            }
          } else {
            if (context.read<BattleRoomCubit>().state is! BattleRoomJoining) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      topPadding: MediaQuery.of(context).size.height * (0.15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Theme.of(context).backgroundColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildTabContainer(1, "Create", constraints),
                      _buildTabContainer(2, "Join", constraints),
                    ],
                  ),
                  // Container(
                  //   color: Theme.of(context).primaryColorDark,
                  //   height: 5.0,
                  // ),
                  SizedBox(
                    height: constraints.maxHeight * (0.05),
                  ),
                  currentSelectedTab == 1 ? _buildCreateRoomTab(constraints) : _buildJoinRoomTab(constraints)
                  //
                ],
              ),
            );
          },
        ),
      ),
      height: MediaQuery.of(context).size.height * (0.5),
    );
  }
}
