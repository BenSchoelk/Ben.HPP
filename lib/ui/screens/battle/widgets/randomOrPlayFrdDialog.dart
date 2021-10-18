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
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/roomOptionDialog.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:provider/src/provider.dart';
import 'dart:math' as math;
class RandomOrOlayFrdDialog extends StatefulWidget{
  RandomOrOlayFrdDialog({Key? key}) : super(key: key);

  @override
  _RandomOrOlayFrdDialogState createState() => _RandomOrOlayFrdDialogState();
}

class _RandomOrOlayFrdDialogState extends State<RandomOrOlayFrdDialog> {
  static String _defaultSelectedCategoryValue = selectCategoryKey;
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedCategoryId = "";
  @override
  void initState(){
    context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
    super.initState();
  }
  TextStyle _buildTextStyle() {
    return TextStyle(
      color: Theme.of(context).backgroundColor,
      fontSize: 16.0,
    );
  }
  Widget topLabelDesign(){
    return  Container(height: MediaQuery.of(context).size.height*.08,decoration: BoxDecoration(color: Theme.of(context).primaryColor,borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
      alignment: Alignment.center,
      child: Text(AppLocalization.of(context)!.getTranslatedValues("randomLbl")!,style: TextStyle(color: Theme.of(context).backgroundColor,fontSize: 21,fontWeight: FontWeight.w700),),
    );
  }
  //using for category and subcategory
  Widget _buildDropdown({required List<Map<String, String?>> values,}) {
    return DropdownButton<String>(
     value: selectedCategory,iconEnabledColor: Theme.of(context).primaryColor,
      dropdownColor: Theme.of(context).canvasColor,
      style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.7), fontSize: 16.0),
      isExpanded: true, alignment: Alignment.center,
      onChanged: (value) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        //if no category selected then do nothing
        if (value != _defaultSelectedCategoryValue) {
          int index = values.indexWhere((element) => element['name'] == value);
          setState(() {
            selectedCategory = value;
            selectedCategoryId = values[index]['id'];
          });
        }else {
          context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
        }
        },
      underline: SizedBox(),
      //values is map of name and id. only passing name to dropdown
      items: values.map((e) => e['name']).toList().map((name) {
        return DropdownMenuItem(
          child:Text(name!),
          value: name,
        );
      }).toList(),
    );
  }

  //dropdown container with border
  Widget _buildDropdownContainer(Widget child) {
    return Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*.07,right:  MediaQuery.of(context).size.width*.07,top: 5,bottom: 5),
      padding: EdgeInsets.only(left: 10,right: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(30.0)),
      child: child,
    );
  }
  Widget dropDownDesign(){
    return context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1"?BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
        bloc: context.read<QuizCategoryCubit>(),
        listener: (context, state) {
          if (state is QuizCategorySuccess) {
            setState(() {
              selectedCategory = state.categories.first.categoryName;
              selectedCategoryId = state.categories.first.id;
            });
          }
        },
        builder: (context, state) {
          if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
            return Center(
              child: CircularProgressContainer(
                useWhiteLoader: false,
              ),);
          }
          if (state is QuizCategoryFailure) {
            return ErrorContainer(
              showBackButton: false,
              errorMessageColor: Theme.of(context).primaryColor,
              showErrorImage: true,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage),
              ),
              onTapRetry: () {
                context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
              },
            );
          }
          final categoryList = (state as QuizCategorySuccess).categories;
          return _buildDropdownContainer(AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child:  state is QuizCategorySuccess?_buildDropdown(values: categoryList.map((e) => {"name": e.categoryName, "id": e.id}).toList()): Opacity(
              opacity: 0.75,
              child: _buildDropdown(values: [
                {"name": _defaultSelectedCategoryValue, "id": "0"}
              ],
              ),
            ),
          )
          );
        }
    ):Container();
  }
  Widget entryFee(){
    return Container(alignment: Alignment.center,
        child:RichText(
          text: TextSpan(
            style: TextStyle(color:Theme.of(context).colorScheme.secondary, fontSize: 18),
            children: <TextSpan>[
              TextSpan(text: 'Entry Fee ', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              TextSpan(text: '5 ',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 20,fontWeight: FontWeight.bold)),
              TextSpan(text: 'coins',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ],
          ),
        )
    );
  }
  Widget currentCoin(){
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    return Container(height: MediaQuery.of(context).size.height*.04,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*.17,right:  MediaQuery.of(context).size.width*.15),
        decoration: BoxDecoration(color: Theme.of(context).canvasColor,borderRadius: BorderRadius.all(Radius.circular(20))),
        child:RichText(
          text: TextSpan(
            style: TextStyle(color:Theme.of(context).colorScheme.secondary, fontSize: 17),
            children: <TextSpan>[
              TextSpan(text: 'Current Coins: ', style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.7))),
              TextSpan(text: '${userProfile.coins}',style: TextStyle(overflow: TextOverflow.ellipsis,color: Theme.of(context).primaryColor,fontSize: 17,fontWeight: FontWeight.bold)),
            ],
          ),
        )
    );
  }
  Widget letsGoButton(){
    UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();
    return  Container(alignment: Alignment.center,
      child: ElevatedButton(style: ElevatedButton.styleFrom(elevation: 10,shadowColor: Theme.of(context).primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width * (.6), MediaQuery.of(context).size.height * .06),
        onPrimary: Theme.of(context).colorScheme.secondary,
        primary: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
        onPressed: () {
          Navigator.pop(context);
          if (int.parse(userProfile.coins!) < 5) {
            UiUtils.errorMessageDialog(context, AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(notEnoughCoinsCode)));
            return;
          }
          if (selectedCategory != _defaultSelectedCategoryValue && context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1"){
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
                if (context.read<BattleRoomCubit>().state is! BattleRoomUserFound) {
                  context.read<BattleRoomCubit>().deleteBattleRoom(false);
                }
              });
            });

            //UiUtils.navigateToOneVSOneBattleScreen(context);
          }
          else {
            Navigator.of(context).pushNamed(Routes.battleRoomFindOpponent, arguments:"").then((value) {
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
                  context.read<BattleRoomCubit>().deleteBattleRoom(false);
                }
              });
            });
          }
        },
        child: Text("Let's Play",
          style: _buildTextStyle(),
        ),
      ),
    );
  }
  Widget playWithFrdBtn(){
    return Container(
       padding: EdgeInsets.only(top: 25),
      alignment: Alignment.center,
      child: ElevatedButton(style: ElevatedButton.styleFrom(
          side: BorderSide(width: 1.0, color:Theme.of(context).backgroundColor),
        minimumSize: Size(MediaQuery.of(context).size.width * (.5), MediaQuery.of(context).size.height * .05),
        onPrimary: Theme.of(context).colorScheme.secondary,
        primary: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
        onPressed: () {
          Navigator.pop(context);
          showDialog(context: context, builder: (context) => RoomOptionDialog(quizType:QuizTypes.battle,type: "playFrd",));
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
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiUtils.dailogRadius)),
      children:[
        topLabelDesign(),
        SizedBox(height: 10,),
        dropDownDesign(),
        SizedBox(height: 10,),
        entryFee(),
        SizedBox(height: 10,),
        currentCoin(),
        SizedBox(height: 10,),
        letsGoButton(),
        Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height*.15,decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius:BorderRadius.only(bottomLeft:Radius.circular(20),bottomRight: Radius.circular(20) )),
          child: CustomPaint(
            painter: CurvePainter(),
            child: playWithFrdBtn(),
          ),
        ),

      ],
    );

  }
}
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height/2.5, size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill; // Change this to fill
    Path path = Path();
    //path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height/2.3, size.width, 0);
    canvas.drawPath(path, paint);

    /*var path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width/2, size.height/3, size.width, 0);
    //path.lineTo(size.width, 0);
   // path.lineTo(0, 0);

    canvas.drawPath(path, paint);*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
