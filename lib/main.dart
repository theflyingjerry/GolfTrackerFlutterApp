import 'package:flutter/material.dart';
import 'package:golf_tracker/mapView.dart';
import 'package:golf_tracker/distancePage.dart';
import 'package:golf_tracker/settings.dart';
import 'package:golf_tracker/scorePage.dart';

void main() {
  runApp(
    MaterialApp(
        title: 'Golf Tracker',
        theme: ThemeData(
            primarySwatch: Colors.lightGreen,
            textButtonTheme: TextButtonThemeData()),
        initialRoute: '/',
        routes: {
          '/': (context) => MapView(),
          '/distance': (context) => Distance(),
          '/score': (context) => Score(),
          '/settings': (context) => Settings(),
        }),
  );
}
