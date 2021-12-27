import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/horizontalTimerContainer.dart';

class PlayGroundScreen extends StatefulWidget {
  PlayGroundScreen({Key? key}) : super(key: key);

  @override
  _PlayGroundScreenState createState() => _PlayGroundScreenState();
}

class _PlayGroundScreenState extends State<PlayGroundScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(seconds: 50))
        ..forward();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: Center(
        child: HorizontalTimerContainer(
            timerAnimationController: animationController),
      ),
    );
  }
}
