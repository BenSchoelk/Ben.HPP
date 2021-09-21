import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: Center(
        child: CustomPaint(
          painter: MessageCustomPainter(triangleIsLeft: false, color: Theme.of(context).colorScheme.secondary),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.5),
            child: SvgPicture.asset(
              "assets/images/emojis/1.svg",
              color: Theme.of(context).backgroundColor,
            ),
            height: 40,
            width: MediaQuery.of(context).size.width * (0.25),
          ),
        ),
      ),
    );
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
