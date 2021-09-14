import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationHandler {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static final NotificationHandler _singleton = new NotificationHandler._internal();
  late BuildContext context;

  factory NotificationHandler() {
    return _singleton;
  }
   NotificationHandler._internal();

  initializeFcmNotification(BuildContext context) async {
    try {
      this.context = context;
      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    } on Exception catch (e) {
      print("////////////////////////////////////////////////////////////$e");

    }
  }
  Future onSelectNotification(String ?payload) async {
    try{
      if (payload != null && payload.isNotEmpty) {
        debugPrint('notification payload:::::::::::::::::::::::::::::::::::::::::: ' + payload);
      }
    } on Exception catch (_) {
    }
  }

  Future<void> onDidReceiveLocalNotification(int ?id, String ?title, String ?body, String ?payload) async {
    print("onDidReceiveLocalNotification.............................");
    // display a dialog with the notification details, tap ok to go to another page
  }
}