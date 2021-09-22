import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  static Route<BadgesScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => BadgesScreen());
  }

  Widget _buildBadges(BuildContext context) {
    return GridView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage + 0.025),
          left: 15.0,
          right: 15.0,
          bottom: 20.0,
        ),
        itemCount: 14,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 7.5,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.575,
        ),
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: constraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * (0.425),
                            ),
                            Text(
                              index % 2 == 0 ? "Sharing is caring" : "Super sonic",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 13.5,
                                height: 1.1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            /*
                            SizedBox(
                              height: constraints.maxHeight * (0.035),
                            ),
                            Text(
                              "Achieved",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12.0,
                                height: 1.0,
                              ),
                            ),
                            */
                          ],
                        ),
                        height: constraints.maxHeight * (0.65),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * (0.075),
                        ),
                        child: CustomPaint(
                          painter: HexagonCustomPainter(color: Theme.of(context).primaryColor, paintingStyle: PaintingStyle.fill),
                          child: Container(
                            width: constraints.maxWidth * (0.875),
                            height: constraints.maxHeight * (0.65),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * (0.125), //outer hexagon top padding + differnce of inner and outer height
                        ),
                        child: CustomPaint(
                          painter: HexagonCustomPainter(color: Theme.of(context).backgroundColor, paintingStyle: PaintingStyle.stroke),
                          child: Container(
                            width: constraints.maxWidth * (0.725),
                            height: constraints.maxHeight * (0.55),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildBadges(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
              title: AppLocalization.of(context)!.getTranslatedValues(badgesKey)!,
            ),
          ),

          /*
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: HexagonCustomPainter(color: Theme.of(context).primaryColor, paintingStyle: PaintingStyle.fill),
              child: Container(
                width: 150,
                height: 175,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              painter: HexagonCustomPainter(color: Theme.of(context).backgroundColor, paintingStyle: PaintingStyle.stroke),
              child: Container(
                width: 125,
                height: 150,
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}

class HexagonCustomPainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;
  HexagonCustomPainter({required this.color, required this.paintingStyle});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = paintingStyle;

    if (paintingStyle == PaintingStyle.stroke) {
      paint.strokeWidth = 2.5;
    }
    Path path = Path();
    path.moveTo(size.width * (0.5), 0);
    path.lineTo(size.width, size.height * (0.25));
    path.lineTo(size.width, size.height * (0.75));
    path.lineTo(size.width * (0.5), size.height);
    path.lineTo(0, size.height * (0.75));
    path.lineTo(0, size.height * (0.25));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
