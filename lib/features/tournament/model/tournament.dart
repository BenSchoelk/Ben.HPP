import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/tournament/model/tournamentPlayerDetails.dart';

enum TournamentStatus { notStarted, started, completed }

//TODO : add quater finals , semi finals and final
class Tournament {
  final String title;
  final int entryFee;
  final String createdAt;
  final String id;
  final String createdBy;
  final TournamentStatus status;
  final List<TournamentPlayerDetails> players;
  final int totalPlayers;
  final String languageId;

  Tournament({
    required this.createdAt,
    required this.entryFee,
    required this.title,
    required this.id,
    required this.createdBy,
    required this.status,
    required this.players,
    required this.totalPlayers,
    required this.languageId,
  });

  static Tournament fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;

    return Tournament(
      createdAt: data['createdAt'] ?? "",
      entryFee: data['entryFee'] ?? 0,
      totalPlayers: data['totalPlayers'] ?? 1,
      title: data['title'] ?? "",
      id: documentSnapshot.id,
      createdBy: data['createdBy'] ?? "",
      status: convertStatusFromStringToEnum(data['status'] ?? ""),
      languageId: data['languageId'] ?? "",
      players: data['players'] == null ? ([] as List<TournamentPlayerDetails>) : (data['players'] as List).map((e) => TournamentPlayerDetails.fromJson(Map.from(e))).toList(),
    );
  }

  static String convertStatusFromEnumToString(TournamentStatus tournamentStatus) {
    if (tournamentStatus == TournamentStatus.notStarted) {
      return "notStarted";
    }
    if (tournamentStatus == TournamentStatus.started) {
      return "started";
    }
    return "completed";
  }

  static TournamentStatus convertStatusFromStringToEnum(String tournamentStatus) {
    if (tournamentStatus == "notStarted") {
      return TournamentStatus.notStarted;
    }
    if (tournamentStatus == "started") {
      return TournamentStatus.started;
    }
    return TournamentStatus.completed;
  }
}
