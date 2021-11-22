import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/tournament/model/tournamentPlayerDetails.dart';

enum TournamentBattleType { quaterFinal, semiFinal, finalBattle }

class TournamentBattle {
  final String tournamentId;
  final TournamentBattleType battleType;
  final String createdBy;
  final TournamentPlayerDetails player1;
  final TournamentPlayerDetails player2;
  final String createdAt;

  //
  TournamentBattle({
    required this.battleType,
    required this.createdAt,
    required this.createdBy,
    required this.player1,
    required this.player2,
    required this.tournamentId,
  });
  //

  static TournamentBattle fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return TournamentBattle(
      battleType: convertTournamentBattleTypeFromStringToEnum(data['battleType']),
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      player1: TournamentPlayerDetails.fromJson(Map.from(data['player1'])),
      player2: TournamentPlayerDetails.fromJson(Map.from(data['player2'])),
      tournamentId: documentSnapshot.id,
    );
  }

  static String convertTournamentBattleTypeFromEnumToString(TournamentBattleType tournamentBattleType) {
    if (tournamentBattleType == TournamentBattleType.quaterFinal) {
      return "quaterFinal";
    }
    if (tournamentBattleType == TournamentBattleType.semiFinal) {
      return "semiFinal";
    }
    return "final";
  }

  static TournamentBattleType convertTournamentBattleTypeFromStringToEnum(String tournamentBattleType) {
    if (tournamentBattleType == "quaterFinal") {
      return TournamentBattleType.quaterFinal;
    }
    if (tournamentBattleType == "semiFinal") {
      return TournamentBattleType.semiFinal;
    }
    return TournamentBattleType.finalBattle;
  }
}
