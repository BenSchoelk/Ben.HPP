import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => WalletScreen());
  }
}

class _WalletScreenState extends State<WalletScreen> {
  int _currentSelectedTab = 1;

  Widget _buildTabContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 25.0),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(requestKey)!,
                    1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(transactionKey)!,
                    2),
              ],
            ),
          ),
        ],
      ),
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          )
        ],
      ),
    );
  }
}
