import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';

class PlaygroundScreen extends StatelessWidget {
  const PlaygroundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(),
                )));
      }),
      body: Center(child: BannerAdContainer()),
    );
  }
}
