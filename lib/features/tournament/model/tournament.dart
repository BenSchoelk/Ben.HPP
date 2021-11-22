import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/tournament/model/tournamentPlayerDetails.dart';

class Tournament {
  final String title;
  final int entryFee;
  final String createdAt;
  final String id;
  final String createdBy;
  final String status;
  final List<TournamentPlayerDetails> players;
  final int totalPlayers;

  Tournament({
    required this.createdAt,
    required this.entryFee,
    required this.title,
    required this.id,
    required this.createdBy,
    required this.status,
    required this.players,
    required this.totalPlayers,
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
      status: data['status'] ?? "",
      players: data['players'] == null ? ([] as List<TournamentPlayerDetails>) : (data['players'] as List).map((e) => TournamentPlayerDetails.fromDocumentSnapshot(Map.from(e))).toList(),
    );
  }
}
