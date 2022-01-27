import 'package:flutter/material.dart';
import 'package:hpp/app/appLocalization.dart';
import 'package:hpp/app/routes.dart';
import 'package:hpp/ui/widgets/menuTile.dart';
import 'package:hpp/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:hpp/ui/widgets/roundedAppbar.dart';
import 'package:hpp/utils/stringLabels.dart';
import 'package:hpp/utils/uiUtils.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage + 0.025),
            ),
            child: Column(
              children: [
                MenuTile(
                  isSvgIcon: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.appSettings, arguments: contactUs);
                  },
                  title: contactUs,
                  leadingIcon: "contactus_icon.svg",
                ),
                MenuTile(
                  isSvgIcon: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.appSettings, arguments: aboutUs);
                  },
                  title: aboutUs,
                  leadingIcon: "aboutus_icon.svg",
                ),
                MenuTile(
                  isSvgIcon: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditions);
                  },
                  title: termsAndConditions,
                  leadingIcon: "termscond_icon.svg",
                ),
                MenuTile(
                  isSvgIcon: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicy);
                  },
                  title: privacyPolicy,
                  leadingIcon: "privacypolicy_icon.svg",
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
              title: AppLocalization.of(context)!.getTranslatedValues(aboutQuizAppKey)!,
            ),
          ),
        ],
      ),
    );
  }
}
