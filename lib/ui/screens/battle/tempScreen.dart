import 'package:flutter/material.dart';

class TempScreen extends StatelessWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            child: Container(
              height: 30,
              width: MediaQuery.of(context).size.width * (0.45),
            ),
          )
        ],
      ),
    );
  }
}
