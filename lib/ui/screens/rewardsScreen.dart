import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:scratcher/scratcher.dart';

class RewardsScreen extends StatelessWidget {
  RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Scratcher(
              brushSize: 25,
              threshold: 50,
              accuracy: ScratchAccuracy.low,
              color: Colors.red,
              onChange: (value) => print("Scratch progress: $value%"),
              onThreshold: () => print("Threshold reached, you won!"),
              child: Container(
                height: 300,
                width: 300,
                child: Center(child: Text("Aeeee safed kapda")),
                color: Colors.blue,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
              title: AppLocalization.of(context)!.getTranslatedValues("rewardsLbl")!,
            ),
          ),
        ],
      ),
    );
  }
}
