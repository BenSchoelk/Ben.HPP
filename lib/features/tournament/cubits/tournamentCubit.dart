import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/tournament/model/tournament.dart';
import 'package:flutterquiz/features/tournament/tournamentRepository.dart';
import 'package:flutterquiz/utils/constants.dart';

abstract class TournamentState {}

class TournamentInitial extends TournamentState {}

class TournamentCreating extends TournamentState {}

class TournamentCreated extends TournamentState {
  final Tournament tournament;

  TournamentCreated(this.tournament);
}

class TournamentSearchInProgress extends TournamentState {}

class TournamentCreationFailure extends TournamentState {
  final String errorMessageCode;
  TournamentCreationFailure(this.errorMessageCode);
}

class TournamentJoining extends TournamentState {}

class TournamentJoined extends TournamentState {
  final Tournament tournament;

  TournamentJoined(this.tournament);
}

class TournamentJoiningFailure extends TournamentState {
  final String errorMessageCode;
  TournamentJoiningFailure(this.errorMessageCode);
}

class TournamentSearchFailure extends TournamentState {
  final String errorMessageCode;
  TournamentSearchFailure(this.errorMessageCode);
}

class TournamentStarted extends TournamentState {
  final Tournament tournament;
  TournamentStarted(this.tournament);
}

class TournamentCubit extends Cubit<TournamentState> {
  final TournamentRepository _tournamentRepository;
  TournamentCubit(this._tournamentRepository) : super(TournamentInitial());

  StreamSubscription<DocumentSnapshot>? _tournamentSubscription;

  void _subscribeTournament({required String tournamentId, required String uid}) {
    _tournamentSubscription = _tournamentRepository.listenToTournamentUpdates(tournamentId).listen((event) {
      if (event.exists) {
        Tournament tournament = Tournament.fromDocumentSnapshot(event);

        //check if tournament is started or not
        if (tournament.status == TournamentStatus.started) {
          //update state to tournament started
          if (state is! TournamentStarted) {
            //create quater finals
            int userIndex = tournament.players.indexWhere((element) => element.uid == uid);
            if (userIndex == 0 || userIndex == 2 || userIndex == 4 || userIndex == 6) {
              //create quater final room

            }
          }

          emit(TournamentStarted(tournament));
        } else {
          //update state
          if (tournament.createdBy == uid) {
            emit(TournamentCreated(tournament));
          } else {
            emit(TournamentJoined(tournament));
          }
          //
          //update tournament detials if there are 8 players
          //
          if (tournament.totalPlayers == numberOfPlayerForTournament) {
            if (tournament.createdBy == uid) {
              //or if state is TournamentCreated
              //start tournament
              _tournamentRepository.startTournament(tournamentId);
            }
          }
        }
      }
    });
  }

  Future<void> serachTournament({
    required String tournamentTitle,
    required String languageId,
    required String entryFee,
    required String uid,
    required String profileUrl,
    required String name,
  }) async {
    emit(TournamentSearchInProgress());

    try {
      List<Tournament> tournaments = await _tournamentRepository.searchTournament(questionLanguageId: languageId, title: tournamentTitle);
      //TODO : Ensure that user does not join the tournament which is created by him/her self
      //remove any previously created tournament by user
      //tournaments.removeWhere((element) => element.createdBy == uid);

      if (tournaments.isEmpty) {
        //create tournament
        _createTournament(
          entryFee: entryFee,
          languageId: languageId,
          name: name,
          profileUrl: profileUrl,
          title: tournamentTitle,
          uid: uid,
        );
      } else {
        //find out how many total players are in tournaments
        List<int> totalPlayers = tournaments.map((e) => e.totalPlayers).toSet().toList();
        //sort in descinding order
        totalPlayers.sort((first, second) => second.compareTo(first));
        //join user in tournament where there is high chance of starting a tournament
        String tournamentId = tournaments.where((element) => element.totalPlayers == totalPlayers.first).toList().first.id;
        _joinTournament(name: name, uid: uid, profileUrl: profileUrl, tournamentId: tournamentId, tournamentTitle: tournamentTitle, languageId: languageId, entryFee: entryFee);
      }
    } catch (e) {
      emit(TournamentSearchFailure(e.toString()));
    }
  }

  void _createTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String languageId,
    required String title,
    required String entryFee,
  }) async {
    emit(TournamentCreating());
    try {
      String tournamentId = await _tournamentRepository.createTournament(name: name, uid: uid, profileUrl: profileUrl, languageId: languageId, title: title, entryFee: entryFee);

      _subscribeTournament(tournamentId: tournamentId, uid: uid);
    } catch (e) {
      emit(TournamentCreationFailure(e.toString()));
    }
  }

  void _joinTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String tournamentId,
    required String tournamentTitle,
    required String languageId,
    required String entryFee,
  }) async {
    emit(TournamentJoining());
    try {
      bool searchAgain = await _tournamentRepository.joinTournament(
        name: name,
        profileUrl: profileUrl,
        tournamentId: tournamentId,
        uid: uid,
      );
      //if somehow user failed to join the tournament
      if (searchAgain) {
        serachTournament(
          entryFee: entryFee,
          languageId: languageId,
          name: name,
          profileUrl: profileUrl,
          tournamentTitle: tournamentTitle,
          uid: uid,
        );
      } else {
        _subscribeTournament(uid: uid, tournamentId: tournamentId);
      }
    } catch (e) {
      emit(TournamentJoiningFailure(e.toString()));
    }
  }

  void startTournament() {
    //start tournament by createdUser it will create four quater finals
  }

  void createQuaterFinal({required Tournament tournament, required int userIndex}) {}

  void createFinal() {}

  void createSemiFinal() {}

  void joinFinal() {}

  void joinSemiFinal() {}

  @override
  Future<void> close() async {
    await _tournamentSubscription?.cancel();
    return super.close();
  }
}
