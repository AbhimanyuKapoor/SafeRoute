import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:saferoute/response/route_response.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeMapView()),
  );
}

class HomeMapView extends StatefulWidget {
  const HomeMapView({super.key});

  @override
  State<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends State<HomeMapView> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  final LatLng _applePark = const LatLng(12.9567, 77.6969);

  LatLng? _currentPosition;
  bool _routeFetched = false;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await initializeMap(),
    );
  }

  Future<void> initializeMap() async {
    await getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('from'),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('to'),
                  position: _applePark,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
              zoomControlsEnabled: true,
              myLocationEnabled: true,
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 16);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude == null ||
          currentLocation.longitude == null) {
        return;
      }

      final LatLng pos = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      setState(() {
        _currentPosition = pos;
      });

      _cameraToPosition(pos);

      if (!_routeFetched && _currentPosition != null) {
        _routeFetched = true;
        fetchAndDrawRoute(from: pos, to: _applePark);
      }
    });
  }

  List<LatLng> decodeEncodedPolyline(String encodedPolyline) {
    final decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

    return decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  Color getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case "LOW":
        return Colors.green;
      case "MEDIUM":
        return Colors.orange;
      case "HIGH":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> fetchAndDrawRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      // final response = await http.post(
      //   Uri.parse("https://your-backend-url/route"),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "from": {"lat": from.latitude, "lng": from.longitude},
      //     "to": {"lat": to.latitude, "lng": to.longitude},
      //   }),
      // );

      // if (response.statusCode == 200) {
      if (true) {
        // final data = jsonDecode(response.body);
        // final route = RouteResponse.fromJson(data);

        // final points = decodeEncodedPolyline(route.polyline);
        final points = decodeEncodedPolyline(
          "wranAa~fyMc@ECd@MjCKxCBhARhB\\bDRtBBX",
        );

        final polylineId = const PolylineId("safe_route");
        final polyline = Polyline(
          polylineId: polylineId,
          points: points,
          // color: getRiskColor(route.riskLevel),
          color: getRiskColor('MEDIUM'),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        );

        setState(() {
          polylines[polylineId] = polyline;
        });
      } else {
        // debugPrint("Route fetch failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    }
  }
}
