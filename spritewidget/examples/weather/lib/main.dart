import 'package:flutter/material.dart';
import 'weather_demo.dart';

// Create a new MaterialApp with the WeatherDemo as its main Widget.
void main() => runApp(WeatherDemoApp());

class WeatherDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherDemo(),
    );
  }
}
