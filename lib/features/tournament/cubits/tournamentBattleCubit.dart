import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/tournament/cubits/tournamentCubit.dart';
import 'package:flutterquiz/features/tournament/model/tournamentBattle.dart';
import 'package:flutterquiz/features/tournament/model/tournamentPlayerDetails.dart';
import 'package:flutterquiz/features/tournament/tournamentRepository.dart';

abstract class TournamentBattleState {}

class TournamentBattleInitial extends TournamentBattleState {}

class TournamentBattleCreationInProgress extends TournamentBattleState {
  final TournamentBattleType tournamentBattleType;
  TournamentBattleCreationInProgress(this.tournamentBattleType);
}

class TournamentBattleJoinInProgress extends TournamentBattleState {
  final TournamentBattleType tournamentBattleType;
  TournamentBattleJoinInProgress(this.tournamentBattleType);
}

class TournamentBattleCreationSuccess extends TournamentBattleState {
  final TournamentBattle tournamentBattle;
  TournamentBattleCreationSuccess(this.tournamentBattle);
}

class TournamentBattleCreationFailure extends TournamentBattleState {
  final String errorCode;
  TournamentBattleCreationFailure(this.errorCode);
}

class TournamentBattleStarted extends TournamentBattleState {
  final TournamentBattle tournamentBattle;
  TournamentBattleStarted(this.tournamentBattle);
}

class TournamentBattleCubit extends Cubit<TournamentBattleState> {
  final TournamentRepository _tournamentRepository;
  TournamentBattleCubit(this._tournamentRepository) : super(TournamentBattleInitial());

  StreamSubscription<DocumentSnapshot>? _tournamentBattleSubscription;

  void _subscribeTournamentBattle({required String tournamentBattleId, required String uid}) {
    _tournamentBattleSubscription = _tournamentRepository.listenToTournamentBattleUpdates(tournamentBattleId).listen((event) {
      if (event.exists) {
        TournamentBattle tournamentBattle = TournamentBattle.fromDocumentSnapshot(event);

        //if tournament battle is quater final
        if (tournamentBattle.battleType == TournamentBattleType.quaterFinal) {
          //need to check if question is available or not
          //person who creates the tournament battle will fetch the question

          //if questions is available
          if (!tournamentBattle.questions.isNotEmpty) {
            //Initially readyToPlay is false once other user will join the tournament battle
            //he/she will start tournament battle

            //
            //if it is not ready to play
            //
            if (!tournamentBattle.readyToPlay) {
              // start tournament battle or quater final
              if (tournamentBattle.createdBy != uid) {
                _tournamentRepository.startTournamentBattle(tournamentBattleId);
              }
            } else {
              emit(TournamentBattleStarted(tournamentBattle));
            }
          }
        } else if (tournamentBattle.battleType == TournamentBattleType.semiFinal) {
        } else {
          //
        }
      }
    });
  }

  void createTournamentBattle({
    required TournamentBattleType tournamentBattleType,
    required String tournamentId,
    required TournamentPlayerDetails user1,
    required TournamentPlayerDetails user2,
  }) {
    emit(TournamentBattleCreationInProgress(tournamentBattleType));
    _tournamentRepository.createQuaterFinal(tournamentBattleType: tournamentBattleType, tournamentId: tournamentId, user1: user1, user2: user2).then((quaterFinalBattleId) {
      //update quater final details
      _tournamentRepository.addQuaterFinalDetails(tournamentId: tournamentId, quaterFinalBattleId: quaterFinalBattleId, user1Uid: user1.uid, user2Uid: user2.uid);
      _subscribeTournamentBattle(tournamentBattleId: quaterFinalBattleId, uid: user1.uid);
      // TODO : fetch questions
    }).catchError((e) {
      emit(TournamentBattleCreationFailure(e.toString()));
    });
  }

  void joinTournamentBattle({required TournamentBattleType tournamentBattleType, required String tournamentBattleId, required String uid}) {
    emit(TournamentBattleJoinInProgress(tournamentBattleType));
    _subscribeTournamentBattle(tournamentBattleId: tournamentBattleId, uid: uid);
  }

  void cancelTournamentBattleSubscription() {
    _tournamentBattleSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    _tournamentBattleSubscription?.cancel();
    return super.close();
  }
}
