import "package:flutter/material.dart";

class Score extends StatefulWidget {
  @override
  _ScoreState createState() => _ScoreState();
}

class _ScoreState extends State<Score> {
  TextStyle general = TextStyle(fontSize: 24);
  Map<String, dynamic> scoreListFront = {};
  Map scoreListBack = {};
  List scores = [];
  List frontNine = [];
  List backNine = [];
  int frontNineTotal = 0;
  int backNineTotal = 0;
  int total = 0;
  bool completed = false;

  setUp() {
    if (completed == false) {
      scores = ModalRoute.of(context).settings.arguments;
      for (int i = 0; i < 9; i++) {
        if (i < scores.length) {
          frontNine.add(scores[i]);
        } else {
          frontNine.add(0);
        }

        scoreListFront['Hole ${(i + 1)}'] = frontNine[i];
      }
      for (int i = 9; i < 18; i++) {
        if (i < scores.length) {
          backNine.add(scores[i]);
        } else {
          backNine.add(0);
        }

        scoreListBack['Hole ${(i + 1)}'] = backNine[(i - 9)];
      }
    }
  }

  totalFunction() {
    if (completed == false) {
      for (int j = 0; j <= frontNine.length - 1; j++) {
        frontNineTotal += frontNine[j];
        total += frontNine[j];
      }
      for (int k = 0; k <= backNine.length - 1; k++) {
        total += backNine[k];
      }
      backNineTotal = total - frontNineTotal;
    }
  }

  @override
  Widget build(BuildContext context) {
    setUp();
    totalFunction();
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white70,
              onPressed: () {
                scores = [];
                for (String entry in scoreListFront.keys) {
                  scores.add(scoreListFront[entry]);
                }
                for (String entry in scoreListBack.keys) {
                  scores.add(scoreListBack[entry]);
                }

                Navigator.pop(context, scores);
              }),
          backgroundColor: Colors.lightGreen,
          title: Text('Score Card',
              style: TextStyle(fontSize: 28, color: Colors.white))),
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: scoreListFront.entries
                    .map(
                      (entry) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4.0),
                          child: Card(
                            child: ListTile(
                              tileColor: Colors.white70,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 20.0,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Visibility(
                                    visible: entry.value != 0,
                                    child: Text(entry.value.toString(),
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 20.0,
                                        )),
                                  )
                                ],
                              ),
                              onTap: () {
                                scoreListFront[entry.key] =
                                    scoreListFront[entry.key] + 1;

                                frontNineTotal += 1;
                                total += 1;
                                setState(() {
                                  completed = true;
                                });
                              },
                              onLongPress: () {
                                frontNineTotal -= scoreListFront[entry.key];
                                total -= scoreListFront[entry.key];
                                setState(() {
                                  completed = true;
                                  scoreListFront[entry.key] = 0;
                                });
                              },
                            ),
                          )),
                    )
                    .toList(),
              )),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                child: ListTile(
                  tileColor: Colors.white70,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Front Nine Total',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          )),
                      Visibility(
                        visible: frontNineTotal != 0,
                        child: Text(frontNineTotal.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20.0,
                            )),
                      )
                    ],
                  ),
                ),
              )),
          Column(
            children: scoreListBack.entries
                .map(
                  (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 4.0),
                      child: Card(
                        child: ListTile(
                            tileColor: Colors.white70,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 20.0,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Visibility(
                                  visible: entry.value != 0,
                                  child: Text(entry.value.toString(),
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 20.0,
                                      )),
                                )
                              ],
                            ),
                            onTap: () {
                              scoreListBack[entry.key] =
                                  scoreListBack[entry.key] + 1;
                              backNineTotal += 1;
                              total += 1;
                              setState(() {
                                completed = true;
                              });
                            },
                            onLongPress: () {
                              backNineTotal -= scoreListBack[entry.key];
                              total -= scoreListBack[entry.key];
                              setState(() {
                                completed = true;
                                scoreListBack[entry.key] = 0;
                              });
                            }),
                      )),
                )
                .toList(),
          ),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                child: ListTile(
                  tileColor: Colors.white70,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Back Nine Total',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          )),
                      Visibility(
                        visible: backNineTotal != 0,
                        child: Text((backNineTotal).toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20.0,
                            )),
                      )
                    ],
                  ),
                ),
              )),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                child: ListTile(
                  tileColor: Colors.white70,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 20.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          )),
                      Visibility(
                        visible: total != 0,
                        child: Text(total.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 20.0,
                            )),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
