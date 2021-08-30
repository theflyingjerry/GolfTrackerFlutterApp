import 'package:flutter/material.dart';
import 'package:golf_tracker/initializer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf_tracker/swingFunction.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController mapController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng _center;

  int selectitem = 0;
  SwingFun swingObj = SwingFun();
  Position currentPosition;
  List scores = [0];
  List clubs = [];
  String displayData = '';
  Map swingDistanceData = {};
  JSONReader initializeSwingData = JSONReader();
  bool serviceEnabled;
  LocationPermission permission;
  String errorMessage = '';

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  setUpData() async {
    swingDistanceData = await initializeSwingData.readJSON();
    clubs = swingDistanceData.keys.toList();
  }

  setUpScore() {
    if (scores.length == 1 && scores[0] == 0) {
      scores[0] = (swingObj.markersSwing.length - 1);
    } else if (scores.length != 18) {
      scores.add((swingObj.markersSwing.length - 1));
    } else {
      for (int i = 0; i < scores.length; i++) {
        if (scores[i] == 0) {
          scores[i] = (swingObj.markersSwing.length - 1);

          break;
        }
      }
    }
  }

  setCenter() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _center = LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }

  setFrame() {
    Position _northeastCoordinates;
    Position _southwestCoordinates;

    // Calculating to check that
    // southwest coordinate <= northeast coordinate
    if (swingObj.position0.latitude <= swingObj.position2.latitude) {
      _southwestCoordinates = swingObj.position0;
      _northeastCoordinates = swingObj.position2;
    } else {
      _southwestCoordinates = swingObj.position2;
      _northeastCoordinates = swingObj.position0;
    }

    // Accomodate the two locations within the
    // camera view of the map
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            _northeastCoordinates.latitude,
            _northeastCoordinates.longitude,
          ),
          southwest: LatLng(
            _southwestCoordinates.latitude,
            _southwestCoordinates.longitude,
          ),
        ),
        100.0,
      ),
    );
  }

  locationEnabledChecker() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      errorMessage = 'Awaiting location services';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        errorMessage = ('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      errorMessage =
          'Location permissions are permanently denied, we cannot request permissions.';
    }
  }

  @override
  initState() {
    super.initState();

    setUpData();
    setCenter();
    locationEnabledChecker();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width; //
    return (_center == null ||
            swingDistanceData == null ||
            serviceEnabled == false)
        ? Container(
            height: height,
            width: width,
            child: Scaffold(
                body: (Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SpinKitDoubleBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
                SafeArea(
                    child:
                        Align(alignment: Alignment.topCenter, child: Text('')))
              ],
            ))))
        : Container(
            height: height,
            width: width,
            child: Scaffold(
              key: _scaffoldKey,
              body: Stack(
                children: <Widget>[
                  // Map View
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: Set<Marker>.of(swingObj.markersSwing.values),
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.satellite,
                    initialCameraPosition:
                        CameraPosition(target: _center, zoom: 12.0),
                    onTap: (LatLng latLng) async {
                      await swingObj.placeMarkerFunction(latLng);
                      if (swingObj.markersSwing.length >= 2) {
                        setFrame();
                      }
                      setState(() {});
                    },
                    onLongPress: (LatLng latLng) async {
                      if (swingObj.markersSwing.length > 1) {
                        String scoreDisplay =
                            'Score: ${(swingObj.markersSwing.length - 1).toString()}';

                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoAlertDialog(
                                  title: new Text("Hole Data"),
                                  content:
                                      new Text('$displayData $scoreDisplay'),
                                  actions: <Widget>[
                                    new CupertinoDialogAction(
                                        child: const Text('Cancel'),
                                        isDefaultAction: false,
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop("Hole Data");
                                        }),
                                    new CupertinoDialogAction(
                                        child: const Text("Okay"),
                                        isDestructiveAction: false,
                                        onPressed: () {
                                          setUpScore();
                                          displayData = '';
                                          swingObj.markersSwing = {};
                                          swingObj.distanceLabel =
                                              "Distance: --yd";
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop("Okay");
                                          setState(() {
                                            displayData = '';
                                          });
                                        }),
                                  ],
                                ));
                      }
                    },
                  ),
                  // Show zoom buttons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: Colors.white70, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: Colors.white70, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.remove),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Show the place input fields & button for
                  // showing the route
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          width: width * 0.9,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CupertinoPicker(
                                  magnification: 1.5,
                                  children: swingDistanceData.entries
                                      .map((entry) => Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Text(
                                              entry.key,
                                              style: TextStyle(
                                                  color: Colors.grey[900]),
                                              textAlign: TextAlign.center,
                                            ),
                                          ))
                                      .toList(),

                                  itemExtent: 50, //height of each item
                                  looping: true,
                                  onSelectedItemChanged: (int index) {
                                    selectitem = index;
                                  },
                                ),
                                SizedBox(height: 10),
                                Text(
                                  swingObj.distanceLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      style: ButtonStyle(
                                          enableFeedback: true,
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.blue
                                                    .withOpacity(0.04);
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.green
                                                    .withOpacity(0.5);
                                              return null; // Defer to the widget's default.
                                            },
                                          )),
                                      onPressed: () {
                                        if (swingObj.distance != null) {
                                          displayData +=
                                              '${clubs[selectitem]}: ${swingObj.distance} yd\n';
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Add to hole'.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                          enableFeedback: true,
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.hovered))
                                                return Colors.blue
                                                    .withOpacity(0.04);
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed))
                                                return Colors.green
                                                    .withOpacity(0.5);
                                              return null; // Defer to the widget's default.
                                            },
                                          )),
                                      onPressed: () async {
                                        if (swingObj.distance != null) {
                                          swingDistanceData[clubs[selectitem]]
                                              .add(swingObj.distance);
                                          displayData +=
                                              '${clubs[selectitem]}: ${swingObj.distance} yd\n';
                                          initializeSwingData
                                              .writeJSON(swingDistanceData);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Save & add'.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Show current location button
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ClipOval(
                              child: Material(
                                color: Colors.lightGreen[100], // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.my_location),
                                  ),
                                  onTap: () {
                                    setCenter();
                                    mapController.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: _center,
                                          zoom: 18.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ClipOval(
                              child: Material(
                                color: Colors.lightGreen[100], // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(Icons.flag)),
                                  onTap: () async {
                                    dynamic result = await Navigator.pushNamed(
                                        context, '/distance',
                                        arguments: swingDistanceData);
                                    setState(() {
                                      selectitem = 0;
                                      swingDistanceData = result;
                                      clubs = swingDistanceData.keys.toList();
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ClipOval(
                              child: Material(
                                color: Colors.lightGreen[100], // button color
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(Icons.format_list_numbered)),
                                  onTap: () async {
                                    dynamic score = await Navigator.pushNamed(
                                        context, "/score",
                                        arguments: scores);

                                    setState(() {
                                      scores = score;
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
