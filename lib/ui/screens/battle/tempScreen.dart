import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageBoxContainer.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/messageContainer.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class TempScreen extends StatelessWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * (0.5),
                  ),
                  margin: EdgeInsets.only(bottom: 20.0, right: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /*
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
                            child: Text(
                              "Sender Name",
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          */
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0, right: 10.0),
                            child: Text(
                              "23:00",
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                      CustomPaint(
                        painter: ChatMessagePainter(isLeft: false, color: Colors.blue),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.0, top: 10.0, left: 10.0, right: 10.0),
                          child: Text(
                            "Some message some long message buddy",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}

class EshopCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.red;
    Path path = Path();

    path.moveTo(size.width * (0.1), 0);
    path.lineTo(size.width * (0.9), 0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height * (0.25));

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
