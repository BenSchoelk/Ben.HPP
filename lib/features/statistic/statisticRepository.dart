import 'package:flutterquiz/features/statistic/statisticException.dart';
import 'package:flutterquiz/features/statistic/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticRemoteDataSource.dart';

class StatisticRepository {
  static final StatisticRepository _statisticRepository = StatisticRepository._internal();
  late StatisticRemoteDataSource _statisticRemoteDataSource;

  factory StatisticRepository() {
    _statisticRepository._statisticRemoteDataSource = StatisticRemoteDataSource();

    return _statisticRepository;
  }

  StatisticRepository._internal();

  Future<StatisticModel> getStatistic(String userId) async {
    try {
      final result = await _statisticRemoteDataSource.getStatistic(userId);

      return StatisticModel.fromJson(Map.from(result));
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateStatistic({String? userId, int? answeredQuestion, int? correctAnswers, double? winPercentage, String? categoryId}) async {
    try {
      await _statisticRemoteDataSource.updateStatistic(
        answeredQuestion: answeredQuestion.toString(),
        categoryId: categoryId,
        correctAnswers: correctAnswers.toString(),
        userId: userId,
        winPercentage: winPercentage.toString(),
      );
    } catch (e) {
      throw StatisticException(errorMessageCode: e.toString());
    }
  }
}
