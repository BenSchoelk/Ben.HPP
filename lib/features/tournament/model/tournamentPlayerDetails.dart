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

  static TournamentPlayerDetails fromDocumentSnapshot(Map<String, dynamic> data) {
    return TournamentPlayerDetails(
      answers: data['answers'] == null ? [] : data['answers'] as List,
      uid: data['uid'] ?? "",
      name: data['name'] ?? "",
      points: data['points'] ?? 0,
      profileUrl: data['profileUrl'] ?? "",
    );
  }
}
