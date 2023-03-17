import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/logic/fetch.dart';
import 'package:app/components/task.dart';
import 'package:app/components/dialog.dart';
import 'package:app/model/task_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List todoList;
  final controller = TextEditingController();
  late SharedPreferences storage;
  bool alreadyExecuted = false;

  void getLocalStorageInstance() async {
    storage = await SharedPreferences.getInstance();
    print(storage.getString('email'));
    print(storage.getString('username'));
    print(storage.getString('id'));
  }

  @override
  void initState() {
    // ignore: avoid_print
    print('use effect');
    super.initState();
  }

  Future<List<dynamic>> fetchTasks() async {
    String tasks = await Fetch(
            context: context,
            data: {},
            customHeaders: {
              'authorization':
                  (await SharedPreferences.getInstance()).getString('id')!
            },
            path: '/api/v1/tasks')
        .exec();

    return jsonDecode(tasks)['data']['tasks'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchTasks(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Consumer<AppModel>(builder: (context, model, child) {
              todoList = model.taskList;

              if (!alreadyExecuted) {
                model.setTasks(snapshot.data);
                alreadyExecuted = true;
              }

              return Scaffold(
                  appBar: AppBar(
                    title: const Text('To - Do'),
                    elevation: 0,
                    centerTitle: true,
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => model.createTask(context, controller),
                    child: const Icon(Icons.add),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: ListView.builder(
                      itemCount: todoList.length,
                      itemBuilder: (context, index) {
                        return Task(
                          taskName: todoList[index][1],
                          completed: todoList[index][2],
                          onChanged: (val) => model.checkBoxChange(
                              context, val, index, todoList[index][0]),
                          deleteFn: (context) => model.deleteTask(
                              index, context, todoList[index][0]),
                          updateFn: (context) => model.updateTask(
                              context, index, controller, todoList[index][0]),
                        );
                      },
                    ),
                  ));
            });
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
