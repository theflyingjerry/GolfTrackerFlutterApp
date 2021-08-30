import 'package:flutter/material.dart';
import 'package:golf_tracker/initializer.dart';
import 'package:flutter/cupertino.dart';

class Distance extends StatefulWidget {
  @override
  _DistanceState createState() => _DistanceState();
}

class _DistanceState extends State<Distance> {
  Map swingDistanceData = {};

  var msgController = TextEditingController();
  Map<String, String> average = {};
  Map<String, bool> settings = {};

  Map<String, String> history = {};
  JSONReader initilizer = JSONReader();

  bool completed = false;

  setUpFunction() {
    if (completed == false) {
      swingDistanceData = (swingDistanceData.isEmpty)
          ? ModalRoute.of(context).settings.arguments
          : swingDistanceData;

      for (String entry in swingDistanceData.keys) {
        average[entry] = 'N/A';

        history[entry] = '';
        if (swingDistanceData[entry] != null) {
          if (swingDistanceData[entry].length > 1) {
            average[entry] = ((swingDistanceData[entry]
                            .reduce((value, element) => value + element) /
                        swingDistanceData[entry].length)
                    .round()
                    .toString() +
                ' yd');
          } else if (swingDistanceData[entry].length == 1) {
            average[entry] =
                (swingDistanceData[entry][0].round().toString() + ' yd');
          }
          settings[entry] = false;

          history[entry] = "History: ";
          int length = swingDistanceData[entry].length;
          if (length < 5) {
            length = 0;
          } else {
            length -= 5;
          }

          for (int j = (swingDistanceData[entry].length - 1);
              length <= j;
              j--) {
            history[entry] =
                history[entry] + swingDistanceData[entry][j].round().toString();
            if (j != length) {
              history[entry] = history[entry] + ', ';
            }
          }
        }
      }
    }
    setState(() {
      completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    setUpFunction();

    return Scaffold(
        backgroundColor: Colors.lightGreen[50],
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white70,
                onPressed: () {
                  Navigator.pop(context, swingDistanceData);
                }),
            backgroundColor: Colors.lightGreen,
            title: Text('Swing Distance',
                style: TextStyle(fontSize: 28, color: Colors.white))),
        body: ListView(
          children: [
            Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Column(
                    children: swingDistanceData.entries.map((entry) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 4.0),
                      child: Card(
                        child: ListTile(
                          tileColor: Colors.white70,
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 20.0,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(height: 10)
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${average[entry.key]}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 24.0),
                              ),
                              Visibility(
                                  visible: settings[entry.key] &&
                                      entry.value.isNotEmpty,
                                  child: SizedBox(
                                    height: 10,
                                  )),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible: settings[entry.key] &&
                                        entry.value.isNotEmpty,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${history[entry.key]}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: settings[entry.key] &&
                                        entry.value.isNotEmpty,
                                    child: Text(
                                      'Shots: ${entry.value.length}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              if (settings[entry.key] == true) {
                                settings[entry.key] = false;
                              } else {
                                settings[entry.key] = true;
                              }
                            });
                          },
                        ),
                      ));
                }).toList())),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () async {
              dynamic result = await Navigator.pushNamed(context, '/settings',
                  arguments: swingDistanceData);
              setState(() {
                swingDistanceData = result;
                completed = false;
              });
            }));
  }
}
