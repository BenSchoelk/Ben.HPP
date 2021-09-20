import 'dart:io';
import 'package:flutter/material.dart';
class HorizontalTimerContainer extends StatelessWidget {
  final AnimationController timerAnimationController;

  HorizontalTimerContainer({Key? key, required this.timerAnimationController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
          alignment: Alignment.topCenter,
          height: 10.0,
          width: Platform.isIOS?MediaQuery.of(context).size.width*.8:MediaQuery.of(context).size.width,
        ),
        AnimatedBuilder(
          animation: timerAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              alignment: Alignment.topCenter,
              height: 10.0,
              width:Platform.isIOS? MediaQuery.of(context).size.width*.8* timerAnimationController.value:MediaQuery.of(context).size.width* timerAnimationController.value,
            );
          },
        ),
      ],
    );
  }
}
