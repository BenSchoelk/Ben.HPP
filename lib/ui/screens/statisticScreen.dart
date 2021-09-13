import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polygon/flutter_polygon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/statistic/cubits/statisticsCubit.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radialResultContainer.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/normalizeNumber.dart';
class StatisticScreen extends StatefulWidget {
  @override
  _StatisticScreen createState() => _StatisticScreen();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<StatisticCubit>(
              create: (_) => StatisticCubit(StatisticRepository()),
              child: StatisticScreen(),
            )
    );
  }
}

class _StatisticScreen extends State<StatisticScreen> with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween<double>(begin: 0.0, end: NormalizeNumber.inRange(currentValue: 65, minValue: 0.0, maxValue: 100.0, newMaxValue: 360.0, newMinValue: 0.0)).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.forward();
    context.read<StatisticCubit>().getStatistic(context.read<UserDetailsCubit>().getUserId() /*"11"*/);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          appBarDesign(),
          SizedBox(
            height: 30,
          ),
          resultShow(),
          score(),
          SizedBox(
            height: 20,
          ),
          curveDesign(),
          profileWinLoss(),
          starShow(),
          SizedBox(
            height: 20,
          ),
          resultCircle(),
          percentageDot()
        ],
      ),
    ));
  }
  Widget appBarDesign() {
    return Container(
      //height: MediaQuery.of(context).size.height * .15,
      // alignment: Alignment.topCenter,s
      child: RoundedAppbar(
        title: "Statistic",
      ),
    );
  }
  Widget resultShow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 20),
          child: Text(
            "Attended Ques",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text("Correct Ans", style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 20),
          child: Text("Incorrect Ans", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget score() {
    return BlocConsumer<StatisticCubit, StatisticState>(
        bloc: context.read<StatisticCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is StatisticFetchInProgress || state is StatisticInitial) {
            return Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
            );
          }
          if (state is StatisticFetchFailure) {
            return ErrorContainer(
              showErrorImage: true,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessageCode)),
              onTapRetry: () {
                context.read<StatisticCubit>().getStatistic( context.read<UserDetailsCubit>().getUserId() /*"11"*/);
              },
            );
          }
          final statisticList = (state as StatisticFetchSuccess).statisticModel;
          var inCorrect = int.parse(statisticList.answeredQuestions!) - int.parse(statisticList.correctAnswers!);
          print(statisticList.correctAnswers);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                statisticList.answeredQuestions!,
                style: TextStyle(color: primaryColor),
              ),
              Text(
                statisticList.correctAnswers.toString(),
                style: TextStyle(color: primaryColor),
              ),
              Text(
                inCorrect.toString(),
                style: TextStyle(color: primaryColor),
              ),
            ],
          );
        });
  }

  Widget curveDesign() {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.centerLeft,
      height: MediaQuery.of(context).size.height * .1,
      //alignment: Alignment.centerLeft,
      child: CustomPaint(
        size: Size(deviceWidth, deviceHeight),
        painter: PathPainter(),
      ),
    );
  }

  Widget profileWinLoss() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height * .06),
            child: Container(
              height: MediaQuery.of(context).size.height * .15,
              width: MediaQuery.of(context).size.width * .15,
              decoration: ShapeDecoration(
                shape: PolygonBorder(
                    borderRadius: 5.0,
                    sides: 6,
                    rotate: 0.0,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    )),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height * .02),
                    height: 50,
                    child: SvgPicture.asset("assets/images/icons/win.svg"),
                  ),
                  BlocConsumer<StatisticCubit, StatisticState>(
                      bloc: context.read<StatisticCubit>(),
                      listener: (context, state) {},
                      builder: (context, state) {
                        if (state is StatisticFetchInProgress || state is StatisticInitial) {
                          return Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                          );
                        }
                        if (state is StatisticFetchFailure) {
                          return Container();
                        }
                        final statisticList = (state as StatisticFetchSuccess).statisticModel;
                        print(statisticList.correctAnswers);
                        return Text(
                          "\n" + statisticList.correctAnswers.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      })
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
                bloc: context.read<UserDetailsCubit>(),
                builder: (_, state) {
                  if (state is UserDetailsFetchSuccess) {
                    return Container(
                        height: 150.0,
                        width: 100.0,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            alignment: Alignment.center,
                            fit: BoxFit.fitHeight,
                            image: NetworkImage(state.userProfile.profileUrl!),
                          ),
                          shape: PolygonBorder(
                              borderRadius: 5.0,
                              sides: 6,
                              rotate: 0.0,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              )),
                        ));
                  } else if (state is UserDetailsFetchInProgress) {
                    return Container(
                        height: 150.0,
                        width: 100.0,
                        decoration: ShapeDecoration(
                          shape: PolygonBorder(
                              borderRadius: 5.0,
                              sides: 6,
                              rotate: 0.0,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              )),
                        ));
                  }
                  return Container(
                      height: 150.0,
                      width: 100.0,
                      decoration: ShapeDecoration(
                        shape: PolygonBorder(
                            borderRadius: 5.0,
                            sides: 6,
                            rotate: 0.0,
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            )),
                      ));
                })),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: 50),
            child: Container(
                height: 100,
                width: 100,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.only(top: 20),
                      height: 50,
                      child: SvgPicture.asset("assets/images/icons/loss.svg"),
                    ),
                    BlocConsumer<StatisticCubit, StatisticState>(
                        bloc: context.read<StatisticCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is StatisticFetchInProgress || state is StatisticInitial) {
                            return Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                            );
                          }
                          if (state is StatisticFetchFailure) {
                            return Container();
                          }
                          final statisticList = (state as StatisticFetchSuccess).statisticModel;
                          var inCorrect = int.parse(statisticList.answeredQuestions!) - int.parse(statisticList.correctAnswers!);
                          print(statisticList.correctAnswers);
                          return Text(
                            "\n$inCorrect",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        })
                  ],
                ),
                decoration: ShapeDecoration(
                  shape: PolygonBorder(
                      borderRadius: 5.0,
                      sides: 6,
                      rotate: 0.0,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      )),
                )),
          ),
        ),
      ],
    );
  }

  Widget starShow() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          height: 100.0,
          width: 100.0,
          child: FractionallySizedBox(
              alignment: Alignment.center,
              heightFactor: 0.5,
              child: SvgPicture.asset(
                "assets/images/badges/quizloner.svg",
              )),
          decoration: ShapeDecoration(
            shape: PolygonBorder(
                borderRadius: 5.0,
                sides: 6,
                rotate: 0.0,
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                )),
          )),
    ]);
  }

  Widget resultCircle() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          BlocConsumer<StatisticCubit, StatisticState>(
              bloc: context.read<StatisticCubit>(),
              listener: (context, state) {},
              builder: (context, state) {
                if (state is StatisticFetchInProgress || state is StatisticInitial) {
                  return Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                  );
                }
                if (state is StatisticFetchFailure) {
                  return Container();
                }
                final statisticList = (state as StatisticFetchSuccess).statisticModel;
                return Container(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width * .3,
                    child: /*CustomPaint(
                      painter:CircleCustomPainter())*/
                        RadialPercentageResultContainer(
                      size: Size.fromRadius(50),
                      percentage: double.parse(statisticList.ratio1!),
                      arcStrokeWidth: 25.0,
                      circleStrokeWidth: 25.0,
                      radiusPercentage: 0.40,
                      arcColor: Colors.green,
                      circleColor: Theme.of(context).primaryColor,
                    )

                    //CircleCustomPainter(),
                    );
              }),
          // ),
          /*  Container(

            height:100,
            width: 100,
            child: AnimatedBuilder(
                builder: (context, _) {
                  return CustomPaint(
                    willChange: false,
                    painter: ArcCustomPainter(color:Theme.of(context).primaryColor, sweepAngle: animation.value,),
                  );
                },
                animation: animationController),
          )*/
        ],
      ),
    );
  }

  Widget percentageDot() {
    return BlocConsumer<StatisticCubit, StatisticState>(
        bloc: context.read<StatisticCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is StatisticFetchInProgress || state is StatisticInitial) {
            return Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
            );
          }
          if (state is StatisticFetchFailure) {
            return Container();
          }
          final statisticList = (state as StatisticFetchSuccess).statisticModel;
          return Row(
            children: [
              SizedBox(
                width: 120,
              ),
              Container(child: CustomPaint(painter: DotDraw())),
              SizedBox(width: 20),
              Text(
                statisticList.ratio1!+"%",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 70,
              ),
              Text(
                statisticList.ratiod2!+"%",
                style: TextStyle(fontSize: 16),
              ),
            ],
          );
        });
  }
}

//curveDesign
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    canvas.translate(size.width * .04, size.height / 3);
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    Path mPath = new Path();
    var val = 1.0;
    /* mPath.relativeQuadraticBezierTo(60, -val * 60,130, 0);
    mPath.relativeQuadraticBezierTo(60, val * 40, 110, 0);
    mPath.relativeQuadraticBezierTo(60, -val * 60,130, 0);*/
    // canvas.drawShadow(mPath, primaryColor.withAlpha(100), 6.0, false);
    // canvas.drawColor(primaryColor, BlendMode.clear);

    mPath.relativeQuadraticBezierTo(size.width*.12, -val * 70, size.width*.35, 0);
    mPath.relativeQuadraticBezierTo(size.width*.11, val * 40, size.width*.25, 0);
    mPath.relativeQuadraticBezierTo(size.width*.16, -val * 70, size.width*.35, 0);
    //canvas.drawShadow(mPath, primaryColor, 0.0, true);
    canvas.drawPath(mPath, paint);
    var paint1 = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    //a circle
    // canvas.drawCircle(Offset(180, 23), 12, paint1);
    canvas.drawCircle(Offset(size.width*.47, size.height*.25), 12, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DotDraw extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(Offset(0, 0), 12, paint1);
    var paint2 = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    //b circle
    canvas.drawCircle(Offset(100, 0), 12, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//percentage circle
class CircleCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * (0.5), size.height * (0.5));
    Paint paint = Paint()
      ..strokeWidth = 25.0
      ..color = primaryColor
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * 0.40, paint);
    var paint1 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(Offset(0, 120), 12, paint1);
    var paint2 = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(Offset(100, 120), 12, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //generally it return false but when parent widget is changing
    //or animating it should return true
    return false;
  }
}

//for circle use
class ArcCustomPainter extends CustomPainter {
  final double sweepAngle;
  final Color color;

  ArcCustomPainter({required this.sweepAngle, required this.color});

  double _degreeToRadian() {
    return (sweepAngle * pi) / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 25
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * (0.5), size.height * (0.95)), radius: size.width * (0.40)), 3 * (pi / 2), _degreeToRadian(), false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
