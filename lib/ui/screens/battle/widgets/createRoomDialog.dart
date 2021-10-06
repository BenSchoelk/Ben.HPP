import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';

import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitingForPlayersDialog.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRoomDialog extends StatefulWidget {
  final String categoryId;
  final QuizTypes quizType;
  final String ?battleLbl;
  CreateRoomDialog({Key? key, required this.categoryId, required this.quizType, this.battleLbl}) : super(key: key);

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  bool liveChat = false;
  int coins = minCoinsForGroupBattleCreation;

  Widget _buildCreateTab(BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(UiUtils.dailogRadius), bottomRight: Radius.circular(UiUtils.dailogRadius)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: constraints.maxHeight * (0.1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
                onPressed: coins == minCoinsForGroupBattleCreation
                    ? null
                    : () {
                        setState(() {
                          coins = coins - 5;
                        });
                      },
                icon: Icon(
                  Icons.remove,
                  color: Theme.of(context).primaryColor,
                  size: 30.0,
                )),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                color: Theme.of(context).primaryColor,
              ),
              height: constraints.maxHeight * 0.425,
              width: constraints.maxHeight * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: constraints.maxHeight * 0.285,
                    width: constraints.maxHeight * 0.3,
                    decoration: BoxDecoration(
                        gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
                    margin: EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      top: 15.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(UiUtils.getImagePath("coin.svg")),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Theme.of(context).primaryColor),
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: 2.0,
                          ),
                          child: Text(
                            "$coins",
                            style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 1.5,
                  ),
                  Container(
                    child: Text(
                      AppLocalization.of(context)!.getTranslatedValues('entryLbl')!,
                      style: Theme.of(context).textTheme.subtitle1!.merge(TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
                onPressed: coins == maxCoinsForGroupBattleCreation
                    ? null
                    : () {
                        setState(() {
                          coins = coins + 5;
                        });
                      },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 30.0,
                )),
          ]),
          SizedBox(
            height: constraints.maxHeight * (0.075),
          ),
          BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
            bloc: context.read<MultiUserBattleRoomCubit>(),

            //this listener will be in use for both creating and join room callbacks
            listener: (context, state) {
              if (state is MultiUserBattleRoomSuccess) {
                //wait for others
                Navigator.of(context).pop();
                showDialog(context: context, builder: (context) => WaitingForPlayesDialog(quizType: widget.quizType==QuizTypes.battle?QuizTypes.battle:QuizTypes.groupPlay,battleLbl: widget.quizType==QuizTypes.battle?widget.battleLbl:"",));
              } else if (state is MultiUserBattleRoomFailure) {
                UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is MultiUserBattleRoomInProgress
                    ? () {}
                    : () {
                        UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();

                        if (int.parse(userProfile.coins!) < coins) {
                          UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
                          return;
                        }
                        context.read<MultiUserBattleRoomCubit>().createRoom(
                              categoryId: widget.categoryId,
                              entryFee: coins,
                              name: userProfile.name,
                              profileUrl: userProfile.profileUrl,
                              roomType: "public",
                              uid: userProfile.userId,
                              questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(constraints.maxWidth * (0.5), constraints.maxHeight * (0.15)),
                  onPrimary: Theme.of(context).colorScheme.secondary,
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  state is MultiUserBattleRoomInProgress ? AppLocalization.of(context)!.getTranslatedValues('creatingLoadingLbl')! + "..." : AppLocalization.of(context)!.getTranslatedValues('creatingLbl')!,
                  style: Theme.of(context).textTheme.subtitle1!.merge(TextStyle(color: Theme.of(context).backgroundColor, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      height: MediaQuery.of(context).size.height * (0.45),
      onWillPop: () {
        if (context.read<MultiUserBattleRoomCubit>().state is MultiUserBattleRoomInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      onBackButtonPress: () {
        if (context.read<MultiUserBattleRoomCubit>().state is MultiUserBattleRoomInProgress) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildCreateTab(constraints);
          },
        ),
      ),
    );
  }
}
