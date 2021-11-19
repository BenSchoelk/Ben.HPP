import 'package:flutterquiz/features/tournament/model/tournamentPlayerDetails.dart';

class Tournament {
  final String title;
  final int entryFee;
  final String createdAt;
  final String id;
  final String createdBy;
  final String status;
  final List<TournamentPlayerDetails> players;

  Tournament({
    required this.createdAt,
    required this.entryFee,
    required this.title,
    required this.id,
    required this.createdBy,
    required this.status,
    required this.players,
  });
}
