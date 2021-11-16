import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examTimerContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamScreen extends StatefulWidget {
  ExamScreen({Key? key}) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => ExamScreen(),
    );
  }
}

class _ExamScreenState extends State<ExamScreen> {
  final GlobalKey<ExamTimerContainerState> timerKey = GlobalKey<ExamTimerContainerState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      timerKey.currentState?.startTimer();
    });
  }

  Widget _buildBottomMenu() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).backgroundColor),
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0, left: 20, right: 20),
      child: Row(
        children: [
          Opacity(
            opacity: 1.0,
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                )),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset(UiUtils.getImagePath("moveto_icon.svg")),
              ),
            ),
          ),
          Spacer(),
          Opacity(
            opacity: 1.0,
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).primaryColor,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 20.0, bottom: 30.0),
              child: CustomBackButton(
                removeSnackBars: false,
                isShowDialog: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * (0.65),
                    child: Text(
                      "Exam Title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.5,
                  ),
                  Text(
                    "25 Marks",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 20.0, bottom: 30.0),
              child: ExamTimerContainer(
                examDurationInMinutes: 60,
                key: timerKey,
              ),
            ),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(boxShadow: [UiUtils.buildAppbarShadow()], color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          _buildAppBar(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomMenu(),
          )
        ],
      ),
    );
  }
}
