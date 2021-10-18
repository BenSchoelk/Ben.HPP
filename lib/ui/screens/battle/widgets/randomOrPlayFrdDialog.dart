import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomDialog.dart';
import 'package:flutterquiz/utils/constants.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class RandomOrOlayFrdDialog extends StatefulWidget {
  RandomOrOlayFrdDialog({Key? key}) : super(key: key);

  @override
  _RandomOrOlayFrdDialogState createState() => _RandomOrOlayFrdDialogState();
}

class _RandomOrOlayFrdDialogState extends State<RandomOrOlayFrdDialog> {
  static String _defaultSelectedCategoryValue = selectCategoryKey;
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedCategoryId = "";
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1") {
        context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
      }
    });
    super.initState();
  }

  TextStyle _buildTextStyle() {
    return TextStyle(
      color: Theme.of(context).backgroundColor,
      fontSize: 16.0,
    );
  }

  Widget topLabelDesign(BoxConstraints constraints) {
    return Container(
      height: constraints.maxHeight * (0.2),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      alignment: Alignment.center,
      child: Text(
        AppLocalization.of(context)!.getTranslatedValues("randomLbl")!,
        style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 21, fontWeight: FontWeight.w700),
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
          setState(() {
            selectedCategory = value!;
            selectedCategoryId = values.where((element) => element['name']! == value).toList().first['id'];
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

  Widget _buildDropDownContainer(BoxConstraints constraints) {
    return context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1"
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
                      selectedCategory = state.categories.first.categoryName;
                      selectedCategoryId = state.categories.first.id;
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
                }),
          )
        : Container();
  }

  Widget entryFee() {
    return Container(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 18),
            children: <TextSpan>[
              TextSpan(text: 'Entry Fee ', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              TextSpan(text: '$randomBattleEntryCoins ', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
              TextSpan(text: 'coins', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ],
          ),
        ));
  }

  Widget currentCoin(BoxConstraints constraints) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * (0.1)),
      decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(25.0)),
      height: constraints.maxHeight * (0.135),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${AppLocalization.of(context)!.getTranslatedValues(currentCoinsKey)!}:  ",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.75),
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            context.read<UserDetailsCubit>().getCoins()!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget letsGoButton(BoxConstraints boxConstraints) {
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shadowColor: Theme.of(context).primaryColor,
          minimumSize: Size(boxConstraints.maxWidth * (0.9), boxConstraints.maxHeight * 0.15),
          onPrimary: Theme.of(context).colorScheme.secondary,
          primary: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (int.parse(userProfile.coins!) < randomBattleEntryCoins) {
            UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
            return;
          }
          if (selectedCategory == _defaultSelectedCategoryValue && context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1") {
            UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(pleaseSelectCategoryKey)!);
            return;
          }
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.battleRoomFindOpponent, arguments: selectedCategoryId).then((value) {
            //need to delete room if user exit the process in between of finding opponent
            //or instantly press exit button

            Future.delayed(Duration(milliseconds: 3000)).then((value) {
              //In battleRoomFindOpponent screen
              //we are calling pushReplacement method so it will trigger this
              //callback so we need to check if state is not battleUserFound then
              //and then we need to call deleteBattleRoom

              //when user press the backbutton and choose to exit the game and
              //process of creating room(in firebase) is still running
              //then state of battleRoomCubit will not be battleRoomUserFound
              //deleteRoom call execute
              if (mounted) {
                if (context.read<BattleRoomCubit>().state is! BattleRoomUserFound) {
                  context.read<BattleRoomCubit>().deleteBattleRoom(false);
                }
              }
            });
          });
        },
        child: Text(
          "Let's Play",
          style: _buildTextStyle(),
        ),
      ),
    );
  }

  Widget playWithFrdBtn(BoxConstraints constraints) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
          minimumSize: Size(MediaQuery.of(context).size.width * (0.65), constraints.maxHeight * 0.1),
          onPrimary: Theme.of(context).colorScheme.secondary,
          primary: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          Navigator.pop(context);
          showDialog(context: context, builder: (context) => BlocProvider<QuizCategoryCubit>(create: (_) => QuizCategoryCubit(QuizRepository()), child: RoomDialog(quizType: QuizTypes.battle)));
        },
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("playWithFrdLbl")!,
          style: _buildTextStyle(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      topPadding: MediaQuery.of(context).size.height * (0.15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiUtils.dailogRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  CustomPaint(
                    child: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * (0.74),
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Column(
                          children: [
                            topLabelDesign(constraints),
                            SizedBox(
                              height: constraints.maxHeight * (0.075),
                            ),
                            _buildDropDownContainer(constraints),
                            SizedBox(
                              height: constraints.maxHeight * (0.075),
                            ),
                            entryFee(),
                            SizedBox(
                              height: constraints.maxHeight * (0.075),
                            ),
                            currentCoin(constraints),
                            SizedBox(
                              height: constraints.maxHeight * (0.075),
                            ),
                            letsGoButton(constraints),
                          ],
                        );
                      }),
                    ),
                    painter: CurvePainter(color: Theme.of(context).backgroundColor),
                  ),
                  Spacer(),
                  playWithFrdBtn(constraints),
                  SizedBox(
                    height: constraints.maxHeight * (0.025),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      height: MediaQuery.of(context).size.height * (0.575),
    );
  }
}

class CurvePainter extends CustomPainter {
  final Color color;
  CurvePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(size.width * (0.5), size.height * (1.25), 0, size.height);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
