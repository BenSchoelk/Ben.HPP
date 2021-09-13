import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/statistic/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';

@immutable
abstract class StatisticState {}

class StatisticInitial extends StatisticState {}

class StatisticFetchInProgress extends StatisticState {}

class StatisticFetchSuccess extends StatisticState {
  final StatisticModel statisticModel;

  StatisticFetchSuccess(this.statisticModel);
}

class StatisticFetchFailure extends StatisticState {
  final String errorMessageCode;
  StatisticFetchFailure(this.errorMessageCode);
}

class StatisticCubit extends Cubit<StatisticState> {
  final StatisticRepository _statisticRepository;
  StatisticCubit(this._statisticRepository) : super(StatisticInitial());

  void getStatistic(String userId) async {
    emit(StatisticFetchInProgress());
    try {
      final result = await _statisticRepository.getStatistic(userId);

      emit(StatisticFetchSuccess(result));
    } catch (e) {
      emit(StatisticFetchFailure(e.toString()));
    }
  }
}
