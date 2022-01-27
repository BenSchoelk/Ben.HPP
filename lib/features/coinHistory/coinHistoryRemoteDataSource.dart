import 'dart:convert';
import 'dart:io';

import 'package:hpp/features/coinHistory/coinHistoryException.dart';
import 'package:hpp/utils/apiBodyParameterLabels.dart';
import 'package:hpp/utils/apiUtils.dart';
import 'package:hpp/utils/constants.dart';
import 'package:hpp/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class CoinHistoryRemoteDataSource {
  Future<dynamic> getCoinHistory(
      {required String userId,
      required String limit,
      required String offset}) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        limitKey: limit,
        offsetKey: offset,
      };

      if (limit.isEmpty) {
        body.remove(limitKey);
      }

      if (offset.isEmpty) {
        body.remove(offsetKey);
      }

      final response = await http.post(Uri.parse(getCoinHistoryUrl),
          body: body, headers: ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw CoinHistoryException(
          errorMessageCode: responseJson['message'],
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw CoinHistoryException(errorMessageCode: noInternetCode);
    } on CoinHistoryException catch (e) {
      throw CoinHistoryException(errorMessageCode: e.toString());
    } catch (e) {
      throw CoinHistoryException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
