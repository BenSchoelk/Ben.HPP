import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  static Route<BadgesScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => BadgesScreen());
  }

  void showBadgeDetails(BuildContext context, Badge badge) {
    showModalBottomSheet(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                Text(
                  "${badge.badgeLabel}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.5,
                  ),
                ),
                SizedBox(
                  height: 2.5,
                ),
                Text(
                  "${badge.badgeNote}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.03),
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
          );
        });
  }

  Widget _buildBadges(BuildContext context) {
    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        if (state is BadgesFetchInProgress || state is BadgesInitial) {
          return Center(
            child: CircularProgressContainer(
              useWhiteLoader: false,
            ),
          );
        }
        if (state is BadgesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: () {
                context.read<BadgesCubit>().getBadges(userId: context.read<UserDetailsCubit>().getUserId());
              },
              showErrorImage: true,
            ),
          );
        }
        final List<Badge> badges = (state as BadgesFetchSuccess).badges;
        return GridView.builder(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage + 0.025),
              left: 15.0,
              right: 15.0,
              bottom: 20.0,
            ),
            itemCount: badges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 7.5,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.575,
            ),
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTap: () {
                      showBadgeDetails(context, badges[index]);
                    },
                    child: Container(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: constraints.maxWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight * (0.425),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      badges[index].badgeLabel,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: badges[index].status == "0" ? badgeLockedColor : Theme.of(context).primaryColor, //
                                        fontSize: 14,
                                        height: 1.175,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              height: constraints.maxHeight * (0.65),
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: constraints.maxHeight * (0.075),
                              ),
                              child: CustomPaint(
                                painter: HexagonCustomPainter(color: badges[index].status == "0" ? badgeLockedColor : Theme.of(context).primaryColor, paintingStyle: PaintingStyle.fill),
                                child: Container(
                                  width: constraints.maxWidth * (0.875),
                                  height: constraints.maxHeight * (0.65),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: constraints.maxHeight * (0.125), //outer hexagon top padding + differnce of inner and outer height
                              ),
                              child: CustomPaint(
                                painter: HexagonCustomPainter(color: Theme.of(context).backgroundColor, paintingStyle: PaintingStyle.stroke), //
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.5),
                                    child: CachedNetworkImage(imageUrl: badges[index].badgeIcon),
                                  ),
                                  width: constraints.maxWidth * (0.725),
                                  height: constraints.maxHeight * (0.55),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildBadges(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: RoundedAppbar(
              title: AppLocalization.of(context)!.getTranslatedValues(badgesKey)!,
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonCustomPainter extends CustomPainter {
  final Color color;
  final PaintingStyle paintingStyle;
  HexagonCustomPainter({required this.color, required this.paintingStyle});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = paintingStyle;

    if (paintingStyle == PaintingStyle.stroke) {
      paint.strokeWidth = 2.5;
    }
    Path path = Path();
    path.moveTo(size.width * (0.5), 0);
    path.lineTo(size.width, size.height * (0.25));
    path.lineTo(size.width, size.height * (0.75));
    path.lineTo(size.width * (0.5), size.height);
    path.lineTo(0, size.height * (0.75));
    path.lineTo(0, size.height * (0.25));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
