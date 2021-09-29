import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'apiBodyParameterLabels.dart';
import 'apiUtils.dart';
import 'constants.dart';

//notification handle in this class

class NotificationHandler {
  FirebaseMessaging _fcm;

  NotificationHandler(this._fcm);

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future initialise() async {
    if (Platform.isIOS) {
      iosPermission();
    }

    _fcm.getToken().then((token) async {
      _registerToken(token!);
    });
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(myForgroundMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(myForgroundMessageHandler);
  }

  void iosPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerToken(String token) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        "token": token,
      };
      Response response =
      await post(Uri.parse(updateFcmId), body: body, headers: ApiUtils.getHeaders());
      var getdata = json.decode(response.body);
      print(getdata);
    } on Exception catch (_) {}
  }

  static Future<dynamic> myForgroundMessageHandler(
      RemoteMessage message) async {
    if (message.data != null) {
      var data = message.data;
      print("data notification*********************************$data");
      var title = data['title'].toString();
      var body = data['message'].toString();
      var image = data['image'];

      String payload = "";
      if (image != null || image != "") {
        generateImageNotication(title, body, image, payload);
      } else {
        generateSimpleNotication(title, body, payload);
      }
    }
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> generateImageNotication(
      String title, String msg, String image, String type) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.flutterquiz',
      'flutterquiz',
      'flutterquiz',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }

  static Future<void> generateSimpleNotication(
      String title, String msg, String type) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.flutterquiz',
      'flutterquiz',
      'flutterquiz',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }
}








/*
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterquiz/app/routes.dart';
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
        print('notification payload:::::::::::::::::::::::::::::::::::::::::: ' + payload);
      }
      await Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
    } on Exception catch (e) {
      print("                                    "+e.toString());
    }
  }

  Future<void> onDidReceiveLocalNotification(int ?id, String ?title, String ?body, String ?payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              await Navigator.of(context).pushReplacementNamed(Routes.notification, arguments: false);
            },
          )
        ],
      ),
    );
    print("onDidReceiveLocalNotification.............................");
    // display a dialog with the notification details, tap ok to go to another page
  }
}*/
