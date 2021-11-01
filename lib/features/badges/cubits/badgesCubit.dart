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

  void getBadges({required String userId, bool? refreshBadges}) async {
    bool callRefreshBadge = refreshBadges ?? false;
    emit(BadgesFetchInProgress());
    badgesRepository.getBadges(userId: userId).then((value) {
      //call this
      if (!callRefreshBadge) {
        setBadge(badgeType: "streak", userId: userId);
      }
      emit(BadgesFetchSuccess(value));
    }).catchError((e) {
      emit(BadgesFetchFailure(e.toString()));
    });
  }

  //update badges
  void updateBadge(String badgeType) {
    if (state is BadgesFetchSuccess) {
      List<Badge> currentBadges = (state as BadgesFetchSuccess).badges;
      List<Badge> updatedBadges = List.from(currentBadges);
      int badgeIndex = currentBadges.indexWhere((element) => element.type == badgeType);
      updatedBadges[badgeIndex] = currentBadges[badgeIndex].copyWith(updatedStatus: "1");
      emit(BadgesFetchSuccess(updatedBadges));
    }
  }

  //
  bool isBadgeLocked(String badgeType) {
    if (state is BadgesFetchSuccess) {
      final badge = (state as BadgesFetchSuccess).badges.where((element) => element.type == badgeType).toList().first;
      return badge.status == "0";
    }
    return true;
  }

  void setBadge({required String badgeType, required String userId}) async {
    badgesRepository.setBadge(userId: userId, badgeType: badgeType);
  }

  List<Badge> getAllBadges() {
    if (state is BadgesFetchSuccess) {
      return (state as BadgesFetchSuccess).badges;
    }
    return [];
  }

  List<Badge> getRewards() {
    List<Badge> rewards = getAllBadges().where((element) => element.status != "0").toList();
    List<Badge> scratchedRewards = rewards.where((element) => element.status == "2").toList();
    List<Badge> unscratchedRewards = rewards.where((element) => element.status == "1").toList();
    unscratchedRewards.addAll(scratchedRewards);
    return unscratchedRewards;
  }
}
