import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:golf_tracker/initializer.dart';
import 'package:flutter/cupertino.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map swingDistanceData = {};
  final _formKey = GlobalKey<FormState>();
  var msgController = TextEditingController();
  List clubs = [];
  JSONReader initilizer = JSONReader();
  bool reordered = false;
  bool completed = false;

  setUpFunction() {
    if (completed == false) {
      swingDistanceData = ModalRoute.of(context).settings.arguments;
      clubs = swingDistanceData.keys.toList();
    }
    setState(() {
      completed = true;
    });
  }

  Map reorderedFunction() {
    if (reordered == true) {
      Map holderMap = {};
      for (String item in clubs) {
        holderMap[item] = swingDistanceData[item];
      }
      initilizer.writeJSON(holderMap);
      return holderMap;
    } else {
      return swingDistanceData;
    }
  }

  @override
  Widget build(BuildContext context) {
    setUpFunction();
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.lightGreen[50],
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white70,
                onPressed: () {
                  Navigator.pop(context, reorderedFunction());
                }),
            backgroundColor: Colors.lightGreen,
            title: Text('Settings',
                style: TextStyle(fontSize: 28, color: Colors.white))),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                                title: new Text("Clear Data"),
                                content: new Text(
                                    "Warning: This will clear all swing data and is irreversible."),
                                actions: <Widget>[
                                  new CupertinoDialogAction(
                                      child: const Text('Cancel'),
                                      isDefaultAction: false,
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Cancel");
                                      }),
                                  new CupertinoDialogAction(
                                      child: const Text("Confirm"),
                                      isDestructiveAction: false,
                                      onPressed: () {
                                        for (String entry
                                            in swingDistanceData.keys) {
                                          swingDistanceData[entry] = [];
                                        }
                                        initilizer.writeJSON(swingDistanceData);
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Confirm");
                                        setState(() {});
                                      }),
                                ],
                              ));
                    },
                    child: Text('Clear swing data',
                        style: TextStyle(fontSize: 16))),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                                title: new Text("Clear Data"),
                                content: new Text(
                                    "Warning: This will restore all data to initial version and is irreversible."),
                                actions: <Widget>[
                                  new CupertinoDialogAction(
                                      child: const Text('Cancel'),
                                      isDefaultAction: false,
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Cancel");
                                      }),
                                  new CupertinoDialogAction(
                                      child: const Text("Confirm"),
                                      isDestructiveAction: false,
                                      onPressed: () async {
                                        initilizer.writeJSON(
                                            initilizer.initialClubDataMap);
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop("Confirm");
                                        swingDistanceData =
                                            await initilizer.readJSON();
                                        setState(() {
                                          clubs =
                                              swingDistanceData.keys.toList();
                                        });
                                      }),
                                ],
                              ));
                    },
                    child: Text('Restore to original',
                        style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height * .7),
            child: ReorderableListView(
              children: clubs
                  .map(
                    (entry) => ListTile(
                      key: Key('$entry'),
                      tileColor: (clubs.indexOf(entry) % 2 == 0
                          ? Colors.white70
                          : Colors.lightGreen[50]),
                      contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      title: Text(entry,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          )),
                      trailing: SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CupertinoAlertDialog(
                                              title: new Text("Confirm Delete"),
                                              content: new Text(
                                                  "By selecting confirm you will be deleting all data associated with the $entry. Press cancel to avoid deleting."),
                                              actions: <Widget>[
                                                new CupertinoDialogAction(
                                                    child: const Text('Cancel'),
                                                    isDefaultAction: false,
                                                    isDestructiveAction: true,
                                                    onPressed: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop("Cancel");
                                                    }),
                                                new CupertinoDialogAction(
                                                    child:
                                                        const Text("Confirm"),
                                                    isDestructiveAction: false,
                                                    onPressed: () {
                                                      clubs.remove(entry);
                                                      swingDistanceData
                                                          .remove(entry);
                                                      initilizer.writeJSON(
                                                          swingDistanceData);
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop("Confirm");
                                                      setState(() {});
                                                    }),
                                              ],
                                            ));
                                  }),
                              Icon(Icons.menu),
                            ],
                          )),
                    ),
                  )
                  .toList(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = clubs.removeAt(oldIndex);
                  clubs.insert(newIndex, item);
                  reordered = true;
                });
              },
            ),
          ),
          ListTile(
            tileColor: Colors.white70,
            contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            title: Form(
              key: _formKey,
              child: Container(
                width: 300,
                child: TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Enter Club(s) Here',
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 20.0,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        )),
                    controller: msgController,
                    validator: (text) {
                      String toSendString = text.trim();
                      if (toSendString == null || toSendString.isEmpty) {
                        return 'Text is empty';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    onFieldSubmitted: (String value) {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          swingDistanceData[value] = [];
                          initilizer.writeJSON(swingDistanceData);
                          msgController.clear();
                          completed = false;
                        });
                      }
                    }),
              ),
            ),
          ),
        ]));
  }
}
