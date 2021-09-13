import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/notificatiion/notificationRepository.dart';

import '../NotificationModel.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notificationList;
  /*final List notificationList;
  final int totalData;
  final bool hasMore;*/
  NotificationSuccess(
    this.notificationList,
    /*this.totalData, this.hasMore*/
  );
}

class NotificationFailure extends NotificationState {
  final String errorMessageCode;
  NotificationFailure(this.errorMessageCode);
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationCubit;
  NotificationCubit(this._notificationCubit) : super(NotificationInitial());
  getNotification() async {
    emit(NotificationProgress());
    _notificationCubit
        .getNotification()
        .then(
          (val) => emit(NotificationSuccess(val)),
        )
        .catchError((e) {
      print("fail in Notification");
      emit(NotificationFailure(e.toString()));
    });
  }
}
/*
void fetchNotification(String limit) {
  emit(NotificationProgress());
  _fetchData(limit: limit).then((value) {
    final usersDetails = value['data'] as List;
    final total = int.parse(value['total'].toString());
    print(total);
    emit(NotificationSuccess(
      usersDetails,
      total,
      total > usersDetails.length,
    ));
  }).catchError((e) {
    print(e.toString());
    emit(NotificationFailure(defaultErrorMessageCode));
  });
}
  }*/



