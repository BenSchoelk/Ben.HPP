import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class TempScreen extends StatelessWidget {
  const TempScreen({Key? key}) : super(key: key);

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * (0.1),
      width: MediaQuery.of(context).size.width * (0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("CHAT"),
          Text("MESSAGES"),
          Text("EMOJIES"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          //
          Center(
            child: CustomPaint(
              painter: ChatMessagePainter(isLeft: false),
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width * (0.4),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 25,
              ),
              width: MediaQuery.of(context).size.width * (0.75),
              height: MediaQuery.of(context).size.height * (UiUtils.questionContainerHeightPercentage - 0.025),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: _buildTabBar(context),
              )),
        ],
      ),
    );
  }
}

class ChatMessagePainter extends CustomPainter {
  bool isLeft;
  ChatMessagePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    if (isLeft) {
      path.moveTo(size.width * (0.1), 0);
      path.lineTo(size.width * (0.9), 0);

      //add top-right curve effect
      path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);

      path.lineTo(size.width, size.height * (0.8));
      //add bottom-right curve
      path.quadraticBezierTo(size.width, size.height, size.width * (0.9), size.height);
      path.lineTo(size.width * (0.125), size.height);

      //add botom left shape
      path.lineTo(size.width * (0.025), size.height * (1.175));
      path.quadraticBezierTo(-10, size.height * (1.275), 0, size.height * (0.8));

      //add left-top curve
      path.lineTo(0, size.height * (0.2));
      path.quadraticBezierTo(0, 0, size.width * (0.1), 0);
      canvas.drawPath(path, paint);
    } else {
      //

      path.moveTo(size.width * (0.1), 0);
      path.quadraticBezierTo(0, 0, 0, size.height * (0.2));
      path.lineTo(0, size.height * (0.8));

      path.quadraticBezierTo(0, size.height, size.width * (0.1), size.height);
      path.lineTo(size.width * (0.875), size.height);

      //add bottom right shape
      //path.quadraticBezierTo(x1, y1, x2, y2);
      path.lineTo(size.width * (0.975), size.height * (1.175));
      path.quadraticBezierTo(size.width + 10, size.height * (1.275), size.width, size.height * (0.8));

      path.lineTo(size.width, size.height * (0.2));
      path.quadraticBezierTo(size.width, 0, size.width * (0.9), 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
