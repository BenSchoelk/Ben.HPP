import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/tournament/cubits/tournamentBattleCubit.dart';
import 'package:flutterquiz/features/tournament/cubits/tournamentCubit.dart';
import 'package:flutterquiz/features/tournament/model/tournamentBattle.dart';
import 'package:flutterquiz/features/tournament/model/tournamentDetails.dart';
import 'package:flutterquiz/ui/widgets/exitGameDailog.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class TournamentScreen extends StatefulWidget {
  final TournamentDetails tournamentDetails;
  TournamentScreen({Key? key, required this.tournamentDetails}) : super(key: key);

  @override
  _TournamentScreenState createState() => _TournamentScreenState();

  static Route<TournamentScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => TournamentScreen(
        tournamentDetails: routeSettings.arguments as TournamentDetails,
      ),
    );
  }
}

class _TournamentScreenState extends State<TournamentScreen> {
  @override
  void initState() {
    super.initState();
    searchTournament();
  }

  void searchTournament() {
    Future.delayed(Duration.zero, () {
      UserDetailsCubit userDetailsCubit = context.read<UserDetailsCubit>();
      context.read<TournamentCubit>().serachTournament(
            tournamentTitle: widget.tournamentDetails.title,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            entryFee: widget.tournamentDetails.entryFee.toString(),
            uid: userDetailsCubit.getUserId(),
            profileUrl: userDetailsCubit.getUserProfile().profileUrl!,
            name: userDetailsCubit.getUserName(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tournamentCubit = context.read<TournamentCubit>();
    final tournamentBattleCubit = context.read<TournamentBattleCubit>();
    return MultiBlocListener(
        listeners: [
          BlocListener<TournamentCubit, TournamentState>(
              bloc: tournamentCubit,
              listener: (context, state) {
                print("Tournament state is ${state.toString()}");
                //if tournament started
                if (state is TournamentStarted) {
                  //
                  ///
                  //
                  if (state.tournament.semiFinals.isEmpty) {
                    int userIndex = tournamentCubit.getUserIndex(context.read<UserDetailsCubit>().getUserId());
                    if (userIndex == 0 || userIndex == 2 || userIndex == 4 || userIndex == 6) {
                      //this will determine that quater finals created only once
                      if (tournamentBattleCubit.state is TournamentBattleInitial) {
                        // && state.tournament.quaterFinals.length != 4
                        //
                        //then create quater final
                        tournamentBattleCubit.createTournamentBattle(
                          tournamentBattleType: TournamentBattleType.quaterFinal,
                          tournamentId: state.tournament.id,
                          user1: state.tournament.players[userIndex],
                          user2: state.tournament.players[userIndex + 1],
                        );
                      }
                    } else {
                      //subscribe to tournament battle
                      if (tournamentBattleCubit.state is TournamentBattleInitial) {
                        print("Join user");
                        // && state.tournament.quaterFinals.length <= 4

                        //user2 uid will be the user who will join or will not created the quater final battle
                        tournamentBattleCubit.joinTournamentBattle(
                            tournamentBattleType: TournamentBattleType.quaterFinal, tournamentBattleId: tournamentCubit.getQuaterFinalBattleId(state.tournament.players[userIndex].uid), uid: state.tournament.players[userIndex].uid);
                      }
                    }
                  }
                }
              }),
          BlocListener<TournamentBattleCubit, TournamentBattleState>(
            listener: (context, state) {
              print("Tournament Battle state is ${state.toString()}");
            },
            bloc: tournamentBattleCubit,
          )
        ],
        child: WillPopScope(
          onWillPop: () {
            showDialog(
                context: context,
                builder: (_) {
                  return ExitGameDailog(
                    onTapYes: () {
                      //reset tournament resource
                      context.read<TournamentCubit>().removeUserFromTournament(userId: context.read<UserDetailsCubit>().getUserId());
                      context.read<TournamentCubit>().resetTournamentResource();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  );
                });

            return Future.value(false);
          },
          child: Scaffold(
            body: Stack(
              children: [
                PageBackgroundGradientContainer(),
                BlocBuilder(
                  bloc: tournamentBattleCubit,
                  builder: (context, state) {
                    if (state is TournamentBattleStarted) {
                      return Container(
                        color: Colors.black26,
                        child: Center(child: Text("Quater final started")),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
