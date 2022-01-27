import 'dart:convert';
import 'dart:io';
import 'package:hpp/features/systemConfig/systemCongifException.dart';
import 'package:hpp/utils/apiBodyParameterLabels.dart';
import 'package:hpp/utils/apiUtils.dart';
import 'package:hpp/utils/constants.dart';
import 'package:hpp/utils/errorMessageKeys.dart';
import 'package:http/http.dart' as http;

class SystemConfigRemoteDataSource {
  Future<dynamic> getSystemConfing() async {
    try {
      final body = {accessValueKey: accessValue};
      final response = await http.post(Uri.parse(getSystemConfigUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        print(responseJson);
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<List> getSupportedQuestionLanguages() async {
    try {
      final body = {accessValueKey: accessValue};

      final response = await http.post(Uri.parse(getSupportedQuestionLanguageUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {accessValueKey: accessValue, typeKey: type};
      final response = await http.post(Uri.parse(getAppSettingsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: noInternetCode);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
