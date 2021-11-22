import 'package:flutterquiz/features/tournament/model/tournamentDetails.dart';
import 'package:flutterquiz/features/tournament/tournamentRemoteDataSource.dart';

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
}
