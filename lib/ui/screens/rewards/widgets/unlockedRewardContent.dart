import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

//TODO : Add localization in rewards
class UnlockedRewardContent extends StatelessWidget {
  final Badge reward;
  final bool increaseFont;
  const UnlockedRewardContent({Key? key, required this.reward, required this.increaseFont}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.825,
          child: SvgPicture.asset(
            UiUtils.getImagePath("celebration.svg"),
            color: Theme.of(context).backgroundColor,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                type: MaterialType.transparency,
                child: Text(
                  "${reward.badgeReward} coins",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: increaseFont ? 29 : 25,
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: Text(
                  "By unlocking ${reward.badgeLabel}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: increaseFont ? 18 : 14,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
