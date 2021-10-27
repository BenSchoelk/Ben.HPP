import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/badgesRepository.dart';

abstract class BadgesState {}

class BadgesInitial extends BadgesState {}

class BadgesFetchInProgress extends BadgesState {}

class BadgesFetchSuccess extends BadgesState {
  final List<Badge> badges;

  BadgesFetchSuccess(this.badges);
}

class BadgesFetchFailure extends BadgesState {
  final String errorMessage;

  BadgesFetchFailure(this.errorMessage);
}

class BadgesCubit extends Cubit<BadgesState> {
  final BadgesRepository badgesRepository;
  BadgesCubit(this.badgesRepository) : super(BadgesInitial());

  void getBadges({required String userId}) async {
    emit(BadgesFetchInProgress());
    badgesRepository.getBadges(userId: userId).then((value) {
      print(value.toString());
      emit(BadgesFetchSuccess(value));
    }).catchError((e) {
      emit(BadgesFetchFailure(e.toString()));
    });
  }

  void setBadge({required String badgeType, required String userId}) async {
    badgesRepository.setBadge(userId: userId, badgeType: badgeType);
  }
}
