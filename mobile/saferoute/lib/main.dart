import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:saferoute/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeMapView(),
    ),
  );
}

class HomeMapView extends StatefulWidget {
  const HomeMapView({super.key});

  @override
  State<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends State<HomeMapView> {
  Location _locationController = new Location();

  final _center = const LatLng(15.366103, 75.152841);
  final _applePark = const LatLng(15.355181, 75.141412);

  LatLng? _currentPosition;

  @override
  void initState() {
    getLocationUpdates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green[700]),
      home: Scaffold(
        body: _currentPosition == null
            ? const Center(child: Text('Loading...'))
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 13.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _currentPosition!,
                  ),
                  Marker(
                    markerId: MarkerId('sourceLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _center,
                  ),
                  Marker(
                    markerId: MarkerId('destinationLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _applePark,
                  ),
                },
                zoomControlsEnabled: true,
              ),
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
          print(_currentPosition);
        });
      }
    });
  }
}
