import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/providers/tasks.dart';
import 'newTodotoKid.dart';

class TaskList extends StatefulWidget {
  final String selectedKid;

  const TaskList({Key key, this.selectedKid}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState(selectedKid);
}

class _TaskListState extends State<TaskList> {
  final String selectedKid;
  Tasks tasks = new Tasks();
  TextEditingController nameController = TextEditingController();
  List<Map<String, Object>> taskList = [];
  List<Map<String, Object>> extractedKidsData = [];
  String selectedKidName = "";

  _TaskListState(this.selectedKid);

  @override
  void initState() {
    var name = getTaskList();
    name.then((name) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<void> getTaskList() async {
    String retVal = null;
    taskList.clear();
    await tasks.getTasksApi().then((value) {
      final pref = SharedPreferences.getInstance().then((pref) {
        List<String> decoded = pref.getStringList('tasks');
        for (int i = 0; i < decoded.length; i++) {
          var tmp = json.decode(decoded[i]) as Map<String, Object>;
          taskList.add(tmp);
          retVal = "OK";
        }
        getKidsData();
      });
    });
    return retVal;
  }

  Future<String> getKidsData() async {
    String retVal = null;
    final pref2 = await SharedPreferences.getInstance().then((pref2) {
      List<String> decoded = pref2.getStringList('kidsData');
      for (int i = 0; i < decoded.length; i++) {
        var tmp = json.decode(decoded[i]) as Map<String, Object>;
        if (tmp['id'] == selectedKid) {
          selectedKidName = tmp['name'];
        }
        extractedKidsData.add(tmp);
        retVal = "OK";
      }
    });
    return retVal;
  }

  dynamic taskListBuilder() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: taskList.length,
      itemBuilder: (context, i) {
        return Card(
          shadowColor: Colors.black,
          margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            child: ListTile(
//              leading: CircleAvatar(
//                  child: Image.network("https://via.placeholder.com/150")),
              title: Text(
                taskList[i]['task'],
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  Icon(Icons.linear_scale, color: Colors.greenAccent),
                  Text("Id: " + taskList[i]['id'],
                      style: TextStyle(color: Colors.black87))
                ],
              ),
              onTap: () {
                //selectTask(context, taskList[i]['id'], taskList[i]['task']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => newTodoToKid(
                            kidsId: selectedKid,
                            taskId: taskList[i]['id'],
                            taskName: taskList[i]['task'])));
              },
            ),
          ),
        );
      },
    );
  }

  dynamic newTask() {
    nameController.text = "";
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text("Új feladat neve:", style: TextStyle(color: Colors.white70),),
        actions: [
          TextField(
            controller: nameController,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
              ),
              labelText: 'Task neve',
            ),
          ),
          Row(
            children: [
              TextButton(
                child: Text("Rögzít", style: TextStyle(color: Colors.white70),),
                onPressed: () async {
                  await tasks.insertTodo(nameController.text).then((value) {
                    var name = getTaskList();
                    name.then((name) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  });
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Mégsem", style: TextStyle(color: Colors.white70),),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  dynamic ujTetelGomb() {
    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () {
        newTask();
      },
      child: Text('Új task hozzáadása'),
    );
  }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: Colors.grey[300],
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            textDirection: TextDirection.rtl,
            children: [
                ujTetelGomb(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration: Duration(seconds: 5),
          child: Column(children: <Widget>[
            SizedBox(
              height: 10,
            ),
            taskListBuilder(),
          ]),
        ),
      ),
    );
  }
}
