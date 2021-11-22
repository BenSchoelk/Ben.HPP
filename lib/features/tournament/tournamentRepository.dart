import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/tournament/model/tournament.dart';
import 'package:flutterquiz/features/tournament/model/tournamentDetails.dart';
import 'package:flutterquiz/features/tournament/tournamentException.dart';
import 'package:flutterquiz/features/tournament/tournamentRemoteDataSource.dart';
import 'package:flutterquiz/utils/constants.dart';

class TournamentRepository {
  static final TournamentRepository _tournamentRepository = TournamentRepository._internal();
  late TournamentRemoteDataSource _tournamentRemoteDataSource;

  factory TournamentRepository() {
    _tournamentRepository._tournamentRemoteDataSource = TournamentRemoteDataSource();
    return _tournamentRepository;
  }

  TournamentRepository._internal();

  Future<List<TournamentDetails>> getTournaments() async {
    _tournamentRemoteDataSource.getTournaments();
    return [];
  }

  Future<List<Tournament>> searchTournament({required String questionLanguageId, required String title}) async {
    try {
      final result = await _tournamentRemoteDataSource.searchTournament(questionLanguageId: questionLanguageId, title: title);
      return result.map((e) => Tournament.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Stream<DocumentSnapshot> listenToTournamentUpdates(String tournamentId) {
    return _tournamentRemoteDataSource.listenToTournamentUpdates(tournamentId);
  }

  Future<bool> joinTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String tournamentId,
  }) async {
    try {
      return await _tournamentRemoteDataSource.joinTournament(tournamentId: tournamentId, name: name, uid: uid, profileUrl: profileUrl);
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }

  Future<void> startTournament(String tournamentId) async {
    try {
      _tournamentRemoteDataSource.updateTournament(tournamentId: tournamentId, data: {
        "status": Tournament.convertStatusFromEnumToString(TournamentStatus.started),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> createQuaterFinal({required int userIndex, required Tournament tournament}) async {
    try {} catch (e) {}
  }

  Future<String> createTournament({
    required String name,
    required String uid,
    required String profileUrl,
    required String languageId,
    required String title,
    required String entryFee,
  }) async {
    try {
      return await _tournamentRemoteDataSource.createTournament(data: {
        "totalPlayers": 1,
        "languageId": languageId,
        "createdAt": Timestamp.now(),
        "title": title,
        "entryFee": entryFee,
        "status": Tournament.convertStatusFromEnumToString(TournamentStatus.notStarted),
        "createdBy": uid,
        "players": [
          {
            "name": name,
            "profileUrl": profileUrl,
            "uid": uid,
          }
        ],
      });
    } catch (e) {
      throw TournamentException(errorMessageCode: e.toString());
    }
  }
}
