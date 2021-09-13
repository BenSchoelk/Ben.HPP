import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
class NotificationHandler {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static final NotificationHandler _singleton = new NotificationHandler._internal();
  late BuildContext context;

  factory NotificationHandler() {
    return _singleton;
  }
   NotificationHandler._internal();

  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    print("onMessage-background: $message");
    showNotification(message);
    // Or do other work.
  }
  initializeFcmNotification(BuildContext context) async {
    print("in notification handler.............................................");
    try {
      print("in try........................................");
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

  void showNotification(Map<String, dynamic> message) async {
    try{
      var data = message['data'];
      //var datamain = message['data'];

      String image = "";
      String title,body;

      title = data['title'].toString();
      body = data['message'].toString();

      if (message.containsKey('data')) {
        var datamain = message['data'];
        image = datamain["image"];
        print("1..............................................."+datamain.toString());
      } else {
        if (message.containsKey('image'))
          image = message["image"];
        print("2..............................................."+image.toString());
      }

      String payload = "";

      if(image == null || image == "null") {
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'com.wrteam.flutterquiz',
          'wrteam.flutterquiz',
          'flutterquiz',
          playSound: true,
          enableVibration: true,
          importance: Importance.max,
          priority: Priority.high,
        );
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        var platformChannelSpecifics = new NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(0, '$title', '$body', platformChannelSpecifics, payload: payload);
      print("3.........................................");

      }else{
         var bigPicturePath = await _downloadAndSaveImage(Uri.parse(image), 'bigPicture');
        var bigPictureStyleInformation = BigPictureStyleInformation(
            bigPicturePath,
            hideExpandedLargeIcon: true,
            contentTitle: '$title',
            htmlFormatContentTitle: true,
            summaryText: '$body',
            htmlFormatSummaryText: true);
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'com.wrteam.flutterquiz',
            'wrteam.flutterquiz',
            'flutterquiz',
            largeIcon: bigPicturePath,
            styleInformation: bigPictureStyleInformation);
        var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(0, '$title', '$body', platformChannelSpecifics);
         print("4.........................................");
      }
    } on Exception catch (e) {
      print("5.........................................");
      print(e.toString());

    }
  }
  Future onSelectNotification(String ?payload) async {
    try{
      if (payload != null && payload.isNotEmpty) {
        debugPrint('notification payload: ' + payload);

        debugPrint('notification payload notempty: ' + payload);
      }
    } on Exception catch (_) {

    }
    // await Navigator.push(
    //   context,
    //   new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    // );
  }

  Future<void> onDidReceiveLocalNotification(int ?id, String ?title, String ?body, String ?payload) async {
    print("onDidReceiveLocalNotification.............................");
    // display a dialog with the notification details, tap ok to go to another page
  }

   _downloadAndSaveImage(Uri url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }


}