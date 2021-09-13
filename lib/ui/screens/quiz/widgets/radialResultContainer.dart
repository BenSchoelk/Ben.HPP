import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/normalizeNumber.dart';

class RadialPercentageResultContainer extends StatefulWidget {
  final Size size;
  final double percentage;
  final double circleStrokeWidth;
  final double arcStrokeWidth;
  final Color? circleColor;
  final Color? arcColor;
  final double radiusPercentage; //respect to width

  const RadialPercentageResultContainer({
    Key? key,
    required this.percentage,
    required this.size,
    required this.circleStrokeWidth,
    required this.arcStrokeWidth,
    required this.radiusPercentage,
    this.arcColor,
    this.circleColor,
  }) : super(key: key);

  @override
  _RadialPercentageResultContainerState createState() => _RadialPercentageResultContainerState();
}

class _RadialPercentageResultContainerState extends State<RadialPercentageResultContainer> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween<double>(begin: 0.0, end: NormalizeNumber.inRange(currentValue: widget.percentage, minValue: 0.0, maxValue: 100.0, newMaxValue: 360.0, newMinValue: 0.0)).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.size.height,
          width: widget.size.width,
          child: CustomPaint(
            painter: CircleCustomPainter(
              color: widget.circleColor ?? Theme.of(context).backgroundColor,
              radiusPercentage: widget.radiusPercentage,
              strokeWidth: widget.circleStrokeWidth,
            ),
          ),
        ),
        Container(
          height: widget.size.height,
          width: widget.size.width,
          child: AnimatedBuilder(
              builder: (context, _) {
                return CustomPaint(
                  child: Center(
                      child: Text(
                    "${widget.percentage.toStringAsFixed(0)}%",
                    style: TextStyle(fontSize: 17.5, color: Theme.of(context).backgroundColor, fontWeight: FontWeight.w500),
                  )),
                  willChange: false,
                  painter: ArcCustomPainter(sweepAngle: animation.value, color: Theme.of(context).backgroundColor, radiusPercentage: widget.radiusPercentage, strokeWidth: widget.arcStrokeWidth),
                );
              },
              animation: animationController),
        )
      ],
    );
  }
}

class CircleCustomPainter extends CustomPainter {
  final Color? color;
  final double? strokeWidth;
  final double? radiusPercentage;
  CircleCustomPainter({this.color, this.radiusPercentage, this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * (0.5), size.height * (0.5));
    Paint paint = Paint()
      ..strokeWidth = strokeWidth!
      ..color = color!
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width * radiusPercentage!, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //generally it return false but when parent widget is changing
    //or animating it should return true
    return false;
  }
}

class ArcCustomPainter extends CustomPainter {
  final double sweepAngle;
  final Color color;
  final double radiusPercentage;
  final double strokeWidth;

  ArcCustomPainter({required this.sweepAngle, required this.color, required this.radiusPercentage, required this.strokeWidth});

  double _degreeToRadian() {
    return (sweepAngle * pi) / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(Rect.fromCircle(center: Offset(size.width * (0.5), size.height * (0.5)), radius: size.width * radiusPercentage), 3 * (pi / 2), _degreeToRadian(), false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
