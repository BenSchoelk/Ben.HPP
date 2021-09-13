import 'package:flutterquiz/features/notificatiion/NotificationModel.dart';

import 'notificationException.dart';
import 'notificationRemoteDataSource.dart';

class NotificationRepository {
  static final NotificationRepository _notificationRepository = NotificationRepository._internal();
  late NotificationRemoteDataSource _notificationRemoteDataSource;

  factory NotificationRepository() {
    _notificationRepository._notificationRemoteDataSource = NotificationRemoteDataSource();

    return _notificationRepository;
  }

  NotificationRepository._internal();

  Future<List<NotificationModel>> getNotification() async {
    try {
      List<NotificationModel> notificationList = [];
      List result = await (_notificationRemoteDataSource.getNotification() /*as Future<List<dynamic>>*/);
      notificationList = result.map((category) => NotificationModel.fromJson(Map.from(category))).toList();
      return notificationList;
    } catch (e) {
      print(e.toString());
      throw NotificationException(errorMessageCode: e.toString());
    }
  }
}
