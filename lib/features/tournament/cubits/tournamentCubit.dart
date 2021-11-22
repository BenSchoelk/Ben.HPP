import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TournamentState {}

class TournamentInitial extends TournamentState {}

class TournamentCreating extends TournamentState {}

class TournamentCreated extends TournamentState {}

class TournamentSearchInProgress extends TournamentState {}

class TournamentCreationFailure extends TournamentState {}

class TournamentJoining extends TournamentState {}

class TournamentJoined extends TournamentState {}

class TournamentJoiningFailure extends TournamentState {}

class TournamentStarted extends TournamentState {}

class TournamentCubit extends Cubit<TournamentState> {
  TournamentCubit() : super(TournamentInitial());

  void _subscribeTournament() {}

  void serachTournament({required String tournamentTitle, required languageId, required entryFee}) {}

  void _createTournament() {}

  void _joinTournament() {}

  void startTournament() {
    //start tournament by createdUser it will create four quater finals
  }

  void joinFinal() {}

  void joinSemiFinal() {}
}
