import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/createRoomDialog.dart';
import 'package:flutterquiz/ui/widgets/adMobBanner.dart';

import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class CategoryScreen extends StatefulWidget {
  final QuizTypes? quizType;
  final String? type;
  final String? typeId;

  CategoryScreen({this.quizType, this.type, this.typeId});

  @override
  _CategoryScreen createState() => _CategoryScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<QuizCategoryCubit>(
              create: (_) => QuizCategoryCubit(QuizRepository()),
              child: CategoryScreen(
                quizType: arguments['quizType'] as QuizTypes,
                type: arguments['type'],
                typeId: arguments['typeId'],
              ),
            ));
  }
}

class _CategoryScreen extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), widget.type == "category" ? widget.typeId! : "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageBackgroundGradientContainer(),
          Column(children: <Widget>[
            Expanded(flex: 2, child: back()),
            Expanded(flex: 15, child: showCategory()),
          ])
        ],
      ),
      bottomNavigationBar: AdMobBanner(),
    );
  }

  Widget back() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            iconColor: Theme.of(context).primaryColor,isShowDialog: false,
          )
        ],
      ),
    );
  }

  Widget showCategory() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
        bloc: context.read<QuizCategoryCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),
            );
          }
          if (state is QuizCategoryFailure) {
            return ErrorContainer(showBackButton: false,
              errorMessageColor: Theme.of(context).primaryColor,
              showErrorImage: true,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage),
              ),
              onTapRetry: () {
                context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), widget.type == "category" ? widget.typeId! : "");
              },
            );
          }
          final categoryList = (state as QuizCategorySuccess).categories;
          return ListView.builder(
            controller: scrollController,
            // scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: categoryList.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (widget.quizType == QuizTypes.battle) {
                    Navigator.of(context).pushNamed(Routes.battleRoomFindOpponent, arguments: categoryList[index].id).then((value) {
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
                        if (context.read<BattleRoomCubit>().state is! BattleRoomUserFound) {
                          context.read<BattleRoomCubit>().deleteBattleRoom();
                        }
                      });
                    });
                  } else if (widget.quizType == QuizTypes.quizZone) {
                    //noOf means how many subcategory it has
                    //if subcategory is 0 then check for level

                    if (categoryList[index].noOf == "0") {
                      //means this category does not have level
                      if (categoryList[index].maxLevel == "0") {
                        //direct move to quiz screen pass level as 0
                        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
                          "numberOfPlayer": 1,
                          "quizType": QuizTypes.quizZone,
                          "categoryId": categoryList[index].id,
                          "subcategoryId": "",
                          "level": "0",
                          "subcategoryMaxLevel": "0",
                          "unlockedLevel": 0,
                          "contestId": "",
                          "comprehensionId": "",
                          "quizName": "Quiz Zone"
                        });
                      } else {
                        //navigate to level screen
                        Navigator.of(context).pushNamed(Routes.levels, arguments: {
                          "maxLevel": categoryList[index].maxLevel,
                          "categoryId": categoryList[index].id,
                        });
                      }
                    } else {
                      Navigator.of(context).pushNamed(Routes.subcategoryAndLevel, arguments: categoryList[index].id);
                    }
                  } else if (widget.quizType == QuizTypes.groupPlay) {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return CreateRoomDialog(
                            categoryId: categoryList[index].id!,
                          );
                        });
                  }
                },
                child: Container(
                    height: 90,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Theme.of(context).primaryColor),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        placeholder: (context, _) => SizedBox(),
                        imageUrl: categoryList[index].image!,
                        errorWidget: (context, imageUrl, _) => Icon(
                          Icons.error,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next_outlined,
                        size: 40,
                        color: Theme.of(context).backgroundColor,
                      ),
                      title: Text(
                        categoryList[index].categoryName!,
                        style: TextStyle(color: Theme.of(context).backgroundColor),
                      ),
                    )),
              );
            },
          );
        });
  }
}
