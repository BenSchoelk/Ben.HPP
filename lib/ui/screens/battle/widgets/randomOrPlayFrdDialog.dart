import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomOptionDialog.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:provider/src/provider.dart';

class RandomOrOlayFrdDialog extends StatelessWidget{
  RandomOrOlayFrdDialog({Key? key}) : super(key: key);

  TextStyle _buildTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 16.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    return SimpleDialog(
      children: [
        TextButton(
          onPressed: () {
            if (int.parse(userProfile.coins!) < 5) {
              UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
              return;
            }
            UiUtils.navigateToOneVSOneBattleScreen(context);
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("randomLbl")!+"(Entry Fee 5 Coins)",
            style: _buildTextStyle(context),
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => RoomOptionDialog(quizType:QuizTypes.battle,type: "playFrd",));
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("playWithFrdLbl")!,
            style: _buildTextStyle(context),
          ),
        )
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiUtils.dailogRadius)),
    );
  }

}