import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';

class RewardsScreen extends StatelessWidget {
  RewardsScreen({Key? key}) : super(key: key);

  Widget _buildRewardItmeContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: ListTile(
        leading: Transform.translate(
          offset: Offset(-12.5, 0.0),
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(10.0)),
            child: SvgPicture.asset("assets/images/badges/quizfan.svg"),
          ),
        ),
        title: Text(
          AppLocalization.of(context)!.getTranslatedValues("quizFanLbl")!,
          style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          AppLocalization.of(context)!.getTranslatedValues("completeSubTitle")!,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildRewardList(BuildContext context) {
    return Column(
      children: List.generate(10, (index) => index).map((e) => _buildRewardItmeContainer(context)).toList(),
    );
  }

  Widget _buildRewardsWithProfilePicture(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * (0.2)),
      child: Column(
        children: [
          SizedBox(
            height: 10.0,
          ),
          //build profile picture
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(border: Border.all(), shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 45.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [Positioned(bottom: -15.0, right: -5, child: SvgPicture.asset("assets/images/badges/quiznewbie.svg"))],
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          //build rewards
          _buildRewardList(context),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildRewardsWithProfilePicture(context),
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
