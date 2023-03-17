import 'dart:convert';

import 'package:app/components/dialog.dart';
import 'package:app/logic/fetch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModel extends ChangeNotifier {
  final List<List<dynamic>> _taskList = [
    // ['Exemplo', false],
    // ['Exemplo 2', true],
  ];

  List<List<dynamic>> get taskList {
    return _taskList;
  }

  void Function()? createTask(
      BuildContext context, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: controller,
            onSave: () async {
              var body = await Fetch(
                      context: context,
                      data: {'body': controller.text, 'completed': false},
                      method: HttpMethods.mPost,
                      customHeaders: {
                        'authorization': (await SharedPreferences.getInstance())
                            .getString('id')!
                      },
                      path: '/api/v1/create-task')
                  .exec();
              print(body);
              _taskList.add(
                [body['data']['taskId'], controller.text, false],
              );
              controller.clear();
              Navigator.of(context).pop();
              notifyListeners();
            },
            onCancel: () => Navigator.of(context).pop(),
          );
        });

    return null;
  }

  void setTasks(List<dynamic>? tasks) {
    if (tasks == null) {
      return;
    }

    for (var task in tasks) {
      _taskList.add([
        task['taskId'],
        task['body'],
        task['completed'] == 0 ? false : true
      ]);
    }
  }

  void updateTask(BuildContext context, int index,
      TextEditingController controller, int id) {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: controller,
            onSave: () async {
              await Fetch(
                      context: context,
                      data: {'body': controller.text},
                      method: HttpMethods.mPatch,
                      customHeaders: {
                        'authorization': (await SharedPreferences.getInstance())
                            .getString('id')!
                      },
                      path: '/api/v1/update-task/$id')
                  .exec();
              _taskList[index][1] = controller.text;
              controller.clear();
              Navigator.of(context).pop();
              notifyListeners();
            },
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  void deleteTask(int index, BuildContext context, int id) async {
    await Fetch(
            context: context,
            data: {},
            method: HttpMethods.mDelete,
            customHeaders: {
              'authorization':
                  (await SharedPreferences.getInstance()).getString('id')!
            },
            path: '/api/v1/task/$id')
        .exec();

    _taskList.removeAt(index);
    notifyListeners();
  }

  checkBoxChange(BuildContext context, bool? val, int index, int id) async {
    var currEl = _taskList.elementAt(index);

    await Fetch(
            context: context,
            data: {'completed': !currEl[2]},
            method: HttpMethods.mPatch,
            customHeaders: {
              'authorization':
                  (await SharedPreferences.getInstance()).getString('id')!
            },
            path: '/api/v1/update-completed/$id')
        .exec();

    currEl[2] = !currEl[2];
    notifyListeners();
  }
}
