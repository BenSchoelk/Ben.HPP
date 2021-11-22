import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  TournamentScreen({Key? key}) : super(key: key);

  @override
  _TournamentScreenState createState() => _TournamentScreenState();

  static Route<TournamentScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => TournamentScreen(),
    );
  }
}

class _TournamentScreenState extends State<TournamentScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
