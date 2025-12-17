import 'package:flutter/material.dart';
import 'package:saferoute/views/map_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapView(),
    ),
  );
}
