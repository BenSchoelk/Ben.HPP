import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examKeyBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamsScreen extends StatefulWidget {
  ExamsScreen({Key? key}) : super(key: key);

  @override
  _ExamsScreenState createState() => _ExamsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => ExamsScreen(),
    );
  }
}

class _ExamsScreenState extends State<ExamsScreen> {
  int _currentSelectedTab = 1; //1 and 2

  void showExamKeyBottomSheet(BuildContext context) //Accept exam object as parameter
  {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return ExamKeyBottomSheetContainer();
        });
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
                isShowDialog: false,
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
                _buildTabContainer("Today", 1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                _buildTabContainer("Completed", 2),
              ],
            ),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(boxShadow: [UiUtils.buildAppbarShadow()], color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
    );
  }

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
            color: Theme.of(context).primaryColor.withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildExamResults() {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * (0.05),
        left: MediaQuery.of(context).size.width * (0.05),
        top: MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage + 10,
        bottom: MediaQuery.of(context).size.height * 0.075,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildResultContainer(index);
      },
    );
  }

  Widget _buildTodayExams() {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * (0.05),
        left: MediaQuery.of(context).size.width * (0.05),
        top: MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage + 10,
        bottom: MediaQuery.of(context).size.height * 0.075,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildTodayExamContainer(index);
      },
    );
  }

  Widget _buildTodayExamContainer(int index) {
    return GestureDetector(
      onTap: () {
        showExamKeyBottomSheet(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10.0)),
        height: MediaQuery.of(context).size.height * (0.1),
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    "Exam Title",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 17.25,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "25 Marks",
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 17.25,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    "Exam Date",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor.withOpacity(0.8),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "25 Minutes",
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer(int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10.0)),
      height: MediaQuery.of(context).size.height * (0.1),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * (0.5),
                child: Text(
                  "Exam Title",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 17.25,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width * (0.5),
                child: Text(
                  "Exam Date",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Marks 25/25",
              style: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1 ? _buildTodayExams() : _buildExamResults(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
          Align(alignment: Alignment.bottomCenter, child: BannerAdContainer()),
        ],
      ),
    );
  }
}
