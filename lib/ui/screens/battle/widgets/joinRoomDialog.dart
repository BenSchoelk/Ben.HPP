import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/waitingForPlayersDialog.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class JoinRoomDialog extends StatelessWidget {
  JoinRoomDialog({Key? key}) : super(key: key);

  final TextEditingController _textEditingController = TextEditingController();

  Widget _buildJoinTab(BoxConstraints constraints, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(UiUtils.dailogRadius), bottomRight: Radius.circular(UiUtils.dailogRadius))),
      child: Column(
        children: [
          SizedBox(
            height: constraints.maxHeight * (0.1),
          ),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(15.0))),
            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * .04, right: MediaQuery.of(context).size.width * .04),
            height: MediaQuery.of(context).size.height * .1,
            padding: EdgeInsets.all(10),
            child: DottedBorder(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              color: Theme.of(context).backgroundColor,
              dashPattern: [5, 8],
              strokeWidth: 1,
              child: TextField(
                style: TextStyle(color: Theme.of(context).backgroundColor),
                controller: _textEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalization.of(context)!.getTranslatedValues('enterCodeLbl')! + "...",
                  hintStyle: TextStyle(color: Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
          SizedBox(
            height: constraints.maxHeight * (0.05),
          ),
          BlocConsumer<MultiUserBattleRoomCubit, MultiUserBattleRoomState>(
            listener: (context, state) {
              if (state is MultiUserBattleRoomSuccess) {
                Navigator.of(context).pop();
                showDialog(context: context, builder: (context) => WaitingForPlayesDialog());
              } else if (state is MultiUserBattleRoomFailure) {
                UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)));
              }
            },
            bloc: context.read<MultiUserBattleRoomCubit>(),
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is MultiUserBattleRoomInProgress
                    ? () {}
                    : () {
                        if (_textEditingController.text.trim().isEmpty) {
                          return;
                        }
                        UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
                        context.read<MultiUserBattleRoomCubit>().joinRoom(
                              currentCoin: userProfile.coins!,
                              name: userProfile.name,
                              uid: userProfile.userId,
                              profileUrl: userProfile.profileUrl,
                              roomCode: _textEditingController.text.trim(),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width * .4, MediaQuery.of(context).size.height * .07),
                  onPrimary: Theme.of(context).accentColor,
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  state is MultiUserBattleRoomInProgress ? AppLocalization.of(context)!.getTranslatedValues('joiningLoadingLbl')! : AppLocalization.of(context)!.getTranslatedValues('joinLbl')!,
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
            return _buildJoinTab(constraints, context);
          },
        ),
      ),
    );
  }
}
