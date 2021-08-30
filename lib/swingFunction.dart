import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SwingFun {
  Map<MarkerId, Marker> markersSwing = <MarkerId, Marker>{};
  Position position0;
  Position position1;
  Position position2;
  double distance;
  String distanceLabel = "Distance: -- yd";
  bool calculated = false;

  placeMarkerFunction(LatLng latLng) async {
    //To Do - Get location

    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng currentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);

    //To Do - Add Marker

    var markerIdVal = markersSwing.length;
    String mar = markersSwing.length == 0 ? "tee" : markerIdVal.toString();
    final MarkerId markerId = MarkerId(mar);
    final Marker marker = Marker(
        markerId: markerId,
        position: currentLocation,
        infoWindow: InfoWindow(title: mar));
    markersSwing[markerId] = marker;

    //To Do - Add Markers, Lines, and Calculate Distance

    if (markersSwing.length == 1) {
      //Add Inital Marker
      // String mar = "tee";
      // final MarkerId markerId = MarkerId(mar);
      // final Marker marker = Marker(
      //     markerId: markerId,
      //     position: latLng,
      //     infoWindow: InfoWindow(title: mar));
      // markersSwing[markerId] = marker;
      // print("placed first marker");

      position1 = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      position0 = position1;
    }

    //To Do - If Subsequent Marker Add Connecting Line And Calculate Distance
    else {
      //Calculate Distance
      position2 = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      distance = Geolocator.distanceBetween(position1.latitude,
              position1.longitude, position2.latitude, position2.longitude)
          .roundToDouble();

      //Add Polyline

      //House Keeping for Display
      distance = (distance * 1.09361).roundToDouble();
      distanceLabel = "Distance: $distance yd";
      calculated = true;
      position1 = position2;
    }
  }
}
