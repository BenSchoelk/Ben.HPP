import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/utils/apiBodyParameterLabels.dart';
import 'package:flutterquiz/utils/apiUtils.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

import 'notificationException.dart';

class NotificationRemoteDataSource {
  Future<dynamic> getNotification() async {
    try {
      //body of post request
      final body = {accessValueKey: accessValue};
      final response = await http.post(Uri.parse(getNotificationUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);

      if (responseJson['error']) {
        throw NotificationException(errorMessageCode: responseJson['message']);
      }
      return responseJson["data"];
    } on SocketException catch (_) {
      throw NotificationException(errorMessageCode: noInternetCode);
    }
      on NotificationException catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    } catch (e) {
      throw NotificationException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }
}
