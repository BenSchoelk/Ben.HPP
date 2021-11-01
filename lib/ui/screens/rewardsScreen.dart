import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:scratcher/scratcher.dart';

class RewardsScreen extends StatefulWidget {
  RewardsScreen({Key? key}) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              child: RewardsScreen(),
              create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
            ));
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Map<String, GlobalKey<ScratcherState>> _scratchKeys = {};

  bool _rewardsLoading = true;
  @override
  void initState() {
    loadRewards();
    super.initState();
  }

  void loadRewards() {
    Future.delayed(Duration.zero, () {
      context.read<BadgesCubit>().getRewards().forEach((element) {
        print(element.status);
        if (element.status == "1") {
          _scratchKeys.addAll({element.type: GlobalKey<ScratcherState>()});
        }
      });

      _rewardsLoading = false;
      setState(() {});
    });
  }

  Widget _buildRewards() {
    return CustomScrollView(
      // padding: EdgeInsets.only(
      //   left: MediaQuery.of(context).size.width * (0.075),
      //   right: MediaQuery.of(context).size.width * (0.075),
      //   top: MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage + 25.0,
      // ),
      slivers: [
        //MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage + 25.0
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage + 25.0,
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("107 Coins"),
                  Text("Total Rewards Earned"),
                ],
              ),
              Spacer(),
              Container(
                color: Colors.orange,
                height: 50.0,
                width: 50.0,
              )
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Divider(
              color: Theme.of(context).primaryColor,
              height: 5,
            ),
          ),
        ),
        BlocBuilder<BadgesCubit, BadgesState>(
          bloc: context.read<BadgesCubit>(),
          builder: (context, state) {
            if (state is BadgesFetchFailure) {
              return SliverToBoxAdapter(
                child: Center(
                  child: ErrorContainer(
                      errorMessage: AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!,
                      onTapRetry: () {
                        context.read<BadgesCubit>().getBadges(userId: context.read<UserDetailsCubit>().getUserId());
                      },
                      showErrorImage: true),
                ),
              );
            }

            if (state is BadgesFetchSuccess) {
              final rewards = context.read<BadgesCubit>().getRewards();
              //ifthere is no rewards
              if (rewards.isEmpty) {
                return SliverToBoxAdapter(
                  child: Text("No rewards"),
                );
              }

              //create grid count
              return SliverGrid.count(
                children: [
                  ...rewards
                      .map((reward) => ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Scratcher(
                              key: _scratchKeys[reward.type],
                              brushSize: 25,
                              threshold: 50,
                              accuracy: ScratchAccuracy.low,
                              color: Colors.red,
                              onChange: (value) => print("Scratch progress: $value%"),
                              onThreshold: () => print("Threshold reached, you won!"),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                ),
                                child: Center(child: Text("Aeeee safed kapda")),
                              ),
                            ),
                          ))
                      .toList(),
                ],
                crossAxisCount: 2,
              );
            }

            return SliverToBoxAdapter(
              child: Center(
                child: CircularProgressContainer(useWhiteLoader: false),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BadgesCubit, BadgesState>(
        listener: (context, state) {
          if (state is BadgesFetchSuccess) {
            setState(() {});
          }
        },
        child: Stack(
          children: [
            _rewardsLoading
                ? Center(
                    child: CircularProgressContainer(
                      useWhiteLoader: false,
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (0.075)),
                    child: _buildRewards(),
                  ),
            Align(
              alignment: Alignment.topCenter,
              child: RoundedAppbar(
                title: AppLocalization.of(context)!.getTranslatedValues(rewardsLbl)!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Scratcher(
              key: scratchKey,
              brushSize: 25,
              threshold: 50,
              accuracy: ScratchAccuracy.low,
              color: Colors.red,
              onChange: (value) => print("Scratch progress: $value%"),
              onThreshold: () => print("Threshold reached, you won!"),
              child: Container(
                height: 300,
                width: 300,
                child: Center(child: Text("Aeeee safed kapda")),
                color: Colors.blue,
              ),
            ),

 */
