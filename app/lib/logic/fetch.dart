import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/screens/home.dart';
import 'package:app/model/task_model.dart';

enum HttpMethods { mGet, mPost, mPatch, mPut, mDelete }

class Fetch {
  BuildContext context;
  Map<String, dynamic> data;
  HttpMethods method;
  bool auth;
  String? path;
  Uri? customUrl;
  Map<String, String>? customHeaders;
  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8'
  };
  late Map<String, String> headers;

  Fetch(
      {required this.context,
      required this.data,
      this.method = HttpMethods.mGet,
      this.auth = false,
      this.path,
      this.customUrl,
      this.customHeaders}) {
    headers = {...defaultHeaders, ...?customHeaders};
  }

  Uri _defaultUrl([String? path]) {
    return Uri.http('localhost:5050', path ?? '/');
  }

  void _redirect() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) => AppModel(),
                  child: const Home(),
                )));
  }

  void _showProcessing() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Processando...')));
  }

  void _hideProcessing() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void printResponseMap(Map<dynamic, dynamic> obj) {
    for (var o in obj.entries) {
      // ignore: avoid_print
      print([o.key, o.value]);
    }
  }

  void _analyzeResponseBody(Map<dynamic, dynamic> body, [Toast? length]) {
    Fluttertoast.showToast(
      msg: body['message'],
      toastLength: length ?? Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    return;
  }

  void _allocateUser(Map<String, String> user) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.setString('email', user['email']!);
    storage.setString('username', user['username']!);
    storage.setString('id', user['id']!);
  }

  dynamic exec() async {
    switch (method) {
      case HttpMethods.mGet:
        http.Response res = await http.get(
          customUrl ?? _defaultUrl(path),
          headers: headers,
        );
        return res.body;

      case HttpMethods.mPost:
        _showProcessing();

        http.Response res = await http.post(customUrl ?? _defaultUrl(path),
            headers: headers, body: jsonEncode(data));

        final Map<dynamic, dynamic> body =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map;

        _analyzeResponseBody(body, Toast.LENGTH_LONG);

        _hideProcessing();

        if (auth) {
          if (res.statusCode == 200) {
            _allocateUser({
              'email': data['email']!,
              'username': body['data']['username'],
              'id': body['data']['id'].toString()
            });

            _redirect();
            return;
          }

          if (res.statusCode == 201) {
            _allocateUser({
              'email': data['email']!,
              'username': data['username']!,
              'id': body['data']['id'].toString()
            });

            _redirect();
            return;
          }
        }
        return body;

      case HttpMethods.mPatch:
        _showProcessing();

        http.Response res = await http.patch(customUrl ?? _defaultUrl(path),
            headers: headers, body: jsonEncode(data));

        final Map<dynamic, dynamic> body =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map;

        _hideProcessing();

        _analyzeResponseBody(body);
        break;

      case HttpMethods.mPut:
        http.Response res = await http.put(customUrl ?? _defaultUrl(path),
            headers: headers, body: data);
        break;

      case HttpMethods.mDelete:
        _showProcessing();

        http.Response res = await http.delete(customUrl ?? _defaultUrl(path),
            headers: customHeaders, body: data);

        final Map<dynamic, dynamic> body =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map;

        _hideProcessing();

        _analyzeResponseBody(body);
        break;
    }
  }
}
