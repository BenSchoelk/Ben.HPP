import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/createRoomDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/joinRoomDialog.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomOptionDialog extends StatelessWidget {
  final QuizTypes quizType;
  final String ?type;
  RoomOptionDialog({Key? key, required this.quizType, this.type}) : super(key: key);

  TextStyle _buildTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        TextButton(
          onPressed: () {
            if (context.read<SystemConfigCubit>().getIsCategoryEnableForGroupBattle() == "1") {
              Navigator.of(context).pop();
              //go to category page
              Navigator.of(context).pushNamed(Routes.category, arguments: {
                "quizType":quizType==QuizTypes.battle? QuizTypes.battle:QuizTypes.groupPlay,"battleLabel":quizType==QuizTypes.battle?"playFrd":""
              });
            } else {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (context) => CreateRoomDialog(quizType: quizType==QuizTypes.battle? QuizTypes.battle:QuizTypes.groupPlay,
                        categoryId: "",
                      ));
            }
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues(createRoomKey)!,
            style: _buildTextStyle(context),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(context: context, builder: (context) => JoinRoomDialog(quizType: quizType==QuizTypes.battle? QuizTypes.battle:QuizTypes.groupPlay,));
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues(joinRoomKey)!,
            style: _buildTextStyle(context),
          ),
        )
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiUtils.dailogRadius)),
    );
  }
}
