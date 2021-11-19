import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentPlayerDetails {
  final String name;
  final String uid;
  final String profileUrl;
  final int points;
  final List answers;

  TournamentPlayerDetails({
    required this.answers,
    required this.uid,
    required this.name,
    required this.points,
    required this.profileUrl,
  });

  static TournamentPlayerDetails fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return TournamentPlayerDetails(
      answers: data['answers'] == null ? [] : data['answers'] as List,
      uid: data['uid'] ?? "",
      name: data['name'] ?? "",
      points: data['points'] ?? 0,
      profileUrl: data['profileUrl'] ?? "",
    );
  }
}
