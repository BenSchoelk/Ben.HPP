class Comprehension {
  final String? id, languageId, title, detail, status, noOfQue, isPlayed;

  Comprehension(
      {required this.isPlayed,
      this.id,
      this.languageId,
      this.title,
      this.detail,
      this.status,
      this.noOfQue});
  factory Comprehension.fromJson(Map<String, dynamic> jsonData) {
    return Comprehension(
        isPlayed: jsonData['is_play'] ?? "",
        id: jsonData["id"],
        languageId: jsonData["language_id"],
        title: jsonData["title"],
        detail: jsonData["detail"],
        status: jsonData["status"],
        noOfQue: jsonData["no_of_que"]);
  }
}
