class LeaderBoardException implements Exception {
  final String errorMessageCode;

  LeaderBoardException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
