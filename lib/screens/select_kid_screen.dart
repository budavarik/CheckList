import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:provider/provider.dart';
import 'package:Kid_checkList/providers/kids.dart';
import '../providers/auth.dart';
import 'task_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/models.dart';

class SelectKidScreen extends StatefulWidget {
  @override
  State<SelectKidScreen> createState() => _SelectKidScreenState();
}

class _SelectKidScreenState extends State<SelectKidScreen> {
  Map<String, Object> extractedUserData;
  List<Map<String, Object>> extractedKidsData = [];
  List<Map<String, Object>> extractedKidTodoDatas = [];
  Kids kids = new Kids();
  String selectedKid = null;
  List<String> kidsMenu = [];
  List<KidTodoList> kidTodoList = [];
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool toggleFrom = false;
  bool toggleTo = false;
  bool voltSzures = false;

  @override
  void initState() {
    var name = getUserData();
    name.then((name) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Future<String> getUserData() async {
    final pref = await SharedPreferences.getInstance().then((pref) {
      extractedUserData =
          json.decode(pref.getString('userData')) as Map<String, Object>;
      kids.getKids(extractedUserData['id']).then((value) {
        var name = getKidsData();
        name.then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
    });
    return extractedUserData['name'];
  }

  Future<String> getKidsData() async {
    String retVal = null;
    kidsMenu = [];
    final pref2 = await SharedPreferences.getInstance().then((pref2) {
      List<String> decoded = pref2.getStringList('kidsData');
      for (int i = 0; i < decoded.length; i++) {
        var tmp = json.decode(decoded[i]) as Map<String, Object>;
        extractedKidsData.add(tmp);
        kidsMenu.add(tmp['name']);
        retVal = "OK";
      }
    });
    return retVal;
  }

  Future<String> getKidTasks() async {
    String retVal = null;
    voltSzures = true;
    var index;
    for (var value in extractedKidsData) {
      if (value.values.contains(selectedKid)) {
        index = value['id'];
      }
    }
    kids
        .getKidsTodos(
            index, selectedFromDate.toString(), selectedToDate.toString())
        .then((value) {
      extractedKidTodoDatas.clear();
      final pref = SharedPreferences.getInstance().then((pref) {
        List<String> decoded = pref.getStringList('kidTodoList');
        for (int i = 0; i < decoded.length; i++) {
          var tmp = json.decode(decoded[i]) as Map<String, Object>;
          extractedKidTodoDatas.add(tmp);
        }
        if (mounted) {
          setState(() {});
        }
      });
    });
    return retVal;
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Colors.grey,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey,
            ),
            child: child,
          );
        },
        cancelText: "Mégsem",
        confirmText: "Kiválaszt",
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Colors.grey,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey,
            ),
            child: child,
          );
        },
        cancelText: "Mégsem",
        confirmText: "Kiválaszt",
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
      });
  }

  dynamic todoListBuilder() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: extractedKidTodoDatas.length,
      itemBuilder: (context, i) {
        return Card(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
          shadowColor: Colors.black,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            child: SingleChildScrollView(
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: (extractedKidTodoDatas[i]['checkDate'] ==
                            '0000-00-00 00:00:00'
                        ? Image.network(
                            "https://crossapp.hu/todoList/images/pirosFelkijaltojel.png")
                        : Image.network(
                            "https://crossapp.hu/todoList/images/zoldPipa.png"))),
                title: Text(
                  extractedKidTodoDatas[i]['task'],
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Icon(Icons.linear_scale, color: Colors.greenAccent),
                    Text(extractedKidTodoDatas[i]['dateFull'],
                        style: TextStyle(color: Colors.black87))
                  ],
                ),
                trailing: Icon(Icons.delete, color: Colors.black87, size: 30.0),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      titleTextStyle: TextStyle(
                        color: Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      title: Text(
                        "Biztos vagy benne?",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          child: Text("Mégsem"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                          ),
                          child: Text("Törlés"),
                          onPressed: () async {
                            Navigator.pop(context);
                            if (extractedKidTodoDatas[i]['id'] != null) {
                              await kids
                                  .delKidTodoData(extractedKidTodoDatas[i]['id'])
                                  .then((value) {
                                getKidTasks();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Kilépés':
        final pref = await SharedPreferences.getInstance();
        pref.clear();
        Provider.of<Auth>(context, listen: false).logout();
        Navigator.of(context).pushReplacementNamed("/");
        break;
      case 'Új gyerek':
        break;
    //Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  dynamic setAppBar() {
    return AppBar(
      title: Row(
        children: <Widget>[
          Text(extractedUserData != null ? extractedUserData['name'] : "Home"),
        ],
      ),
      actions: <Widget>[
        PopupMenuButton<String>(
          color: Colors.transparent,
          elevation: 10.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.0),
              side: BorderSide(
                width: 0.5,
                color: Colors.black,
              )),
          padding: EdgeInsets.all(0.0),
          offset: Offset(-10.0, kToolbarHeight),
          onSelected: handleClick,
          itemBuilder: (BuildContext context) {
            return {'Új gyerek', 'Kilépés'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  dynamic szuresGomb() {
/*
    return AnimatedButton(
      width: 60,
      height: 30,
      text: '',
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: Colors.transparent,
      selectedTextColor: Colors.greenAccent,
      transitionType: TransitionType.BOTTOM_TO_TOP,
      isReverse: true,
      onPress: () {
        voltSzures = true;
        getKidTasks().then((value) => {
              if (mounted) {setState(() {})}
            });
      },
      textStyle: TextStyle(
          fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.w900),
    );
 */
    return IconButton(
        iconSize: 40,
        icon: Icon(Icons.where_to_vote_outlined),
        onPressed: () {
          voltSzures = true;
          getKidTasks().then((value) => {
            if (mounted) {setState(() {})}
          });
        });
  }

  dynamic ujTetelGomb() {
    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () {
        var index;
        for (var value in extractedKidsData) {
          if (value.values.contains(selectedKid)) {
            index = value['id'];
          }
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskList(selectedKid: index)))
            .then((value) {
          getKidTasks().then((value) => {
            if (mounted) {setState(() {})}
          });
        });
      },
      child: Text('Új tétel hozzáadása'),
    );
  }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.black87,
    primary: Colors.grey[300],
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: setAppBar(),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 1, 10, 0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white12,
                    Colors.white,
                  ],
                )),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      hint: Text('Gyerek neve'),
                      value: selectedKid,
                      onChanged: (newValue) {
                        setState(() {
                          selectedKid = newValue;
                          getKidTasks().then((value) => {
                            if (mounted) {setState(() {})}
                          });
                        });
                      },
                      items: kidsMenu.map((location) {
                        return DropdownMenuItem(
                          child: Text(location),
                          value: location,
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    //szuresGomb(),

                    Container(
                        width: MediaQuery.of(context).size.width - 220,
                        height: 60,
                        alignment: Alignment.topRight,
                        child: Column(
                          children: [
                            ((selectedKid != null &&
                                    selectedKid != "" &&
                                    voltSzures)
                                ? ujTetelGomb() : Text("")),
                          ],
                        )),
                  ],
                ),
                Row(
                  children: [
                    Text("Dátumtól: " +
                        "${selectedFromDate.toLocal()}".split(' ')[0]),
                    SizedBox(
                      width: 1.0,
                    ),
                    IconButton(
                        iconSize: 30,
                        tooltip: "Dátumtól",
                        icon: Icon(Icons.analytics_outlined),
                        onPressed: () {
                          _selectFromDate(context);
                          getKidTasks().then((value) => {
                            if (mounted) {setState(() {})}
                          });
                        }),
                    Text("Dátumig: " +
                        "${selectedToDate.toLocal()}".split(' ')[0]),
                    SizedBox(
                      width: 1.0,
                    ),
                    IconButton(
                        iconSize: 30,
                        tooltip: "Dátumig",
                        icon: Icon(Icons.analytics_outlined),
                        onPressed: () {
                          _selectToDate(context);
                          getKidTasks().then((value) => {
                            if (mounted) {setState(() {})}
                          });
                        }),
                  ],
                ),
              ],
            ),
          ),
          todoListBuilder(),
        ]),
      )),
    );
  }
}
