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
  Map<String, String> data;
  HttpMethods method;
  bool auth;
  String? path;
  Uri? customUrl;
  Map<String, String>? customHeaders;

  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=utf-8'
  };
  // Uri defaultUrl = Uri.http("localhost:5050");
  Uri defaultUrl([String? path]) {
    return Uri.http('localhost:5050', path ?? '/');
  }

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
    // old();
  }

  // Future<http.Response> exec() async {
  void exec() async {
    switch (method) {
      case HttpMethods.mGet:
        http.Response res =
            await http.get(customUrl ?? defaultUrl(path), headers: headers);
        break;

      case HttpMethods.mPost:
        showProcessing();

        http.Response res = await http.post(customUrl ?? defaultUrl(path),
            headers: headers, body: jsonEncode(data));
        final Map<dynamic, dynamic> body =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map;

        analyzeResponseBody(body, Toast.LENGTH_LONG);

        // printResponseMap(body);

        hideProcessing();
        if (auth) {
          // + logado
          if (res.statusCode == 200) {
            allocateUser({
              'email': data['email']!,
              'username': body['data']['username'],
              'id': body['data']['id'].toString()
            });
            redirect();
            return;
          }

          // + criado
          if (res.statusCode == 201) {
            allocateUser({
              'email': data['email']!,
              'username': data['username']!,
              'id': body['data']['id'].toString()
            });
            redirect();
            return;
          }
        }
        break;

      case HttpMethods.mPatch:
        http.Response res = await http.patch(customUrl ?? defaultUrl(path),
            headers: headers, body: data);
        break;

      case HttpMethods.mPut:
        http.Response res = await http.put(customUrl ?? defaultUrl(path),
            headers: headers, body: data);
        break;

      case HttpMethods.mDelete:
        http.Response res = await http.delete(customUrl ?? defaultUrl(path),
            headers: headers, body: data);
        break;
    }
  }

  void redirect([Object? user]) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) => AppModel(),
                  child: const Home(),
                )));
  }

  void showProcessing() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Processando...')));
  }

  void hideProcessing() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void printResponseMap(Map<dynamic, dynamic> obj) {
    for (var o in obj.entries) {
      // ignore: avoid_print
      print([o.key, o.value]);
    }
  }

  void analyzeResponseBody(Map<dynamic, dynamic> body, [Toast? length]) {
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

  void allocateUser(Map<String, String> user) async {
    // Provider.of<AppModel>(context, listen: false).user = user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', user['email']!);
    prefs.setString('username', user['username']!);
    prefs.setString('id', user['id']!);
  }
}

void old() {
  // * construtor para instânciar a request e um membro static para executar
  // * afinal o constructor não pode retornar nada e não se pode ser async
  // Map<String, String> headers = {...defaultHeaders, ...?customHeaders};
  // switch (method) {
  //   case HttpMethods.mGet:
  //     http.get(customUrl ?? defaultUrl(path), headers: headers);
  //     break;

  //   case HttpMethods.mPost:
  //     http.post(customUrl ?? defaultUrl(path), headers: headers, body: data);
  //     break;

  //   case HttpMethods.mPatch:
  //     http.patch(customUrl ?? defaultUrl(path), headers: headers, body: data);
  //     break;

  //   case HttpMethods.mPut:
  //     http.put(customUrl ?? defaultUrl(path), headers: headers, body: data);
  //     break;

  //   case HttpMethods.mDelete:
  //     http.delete(customUrl ?? defaultUrl(path),
  //         headers: headers, body: data);
  //     break;
  //   default:
  // }
}

// ! TESTES
// ! TESTES
// ! TESTES
Uri url = Uri.parse('localhost');

extension HttpMethodsExtension on HttpMethods {
  get method {
    switch (this) {
      case HttpMethods.mGet:
        return http.get(url);

      case HttpMethods.mPost:
        return http.post(url);

      case HttpMethods.mPatch:
        return http.patch(url);

      case HttpMethods.mPut:
        return http.put(url);

      case HttpMethods.mDelete:
        return http.delete(url);
      default:
    }
  }
}
// ! TESTES
// ! TESTES
// ! TESTES