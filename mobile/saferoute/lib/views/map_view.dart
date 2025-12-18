import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:location/location.dart';
import 'package:saferoute/dto/route_request.dart';
import 'package:saferoute/dto/route_response.dart';
import 'package:saferoute/services/auth/bloc/auth_bloc.dart';
import 'package:saferoute/services/auth/bloc/auth_event.dart';
import 'package:saferoute/utilities/dialogs/logout_dialog.dart';
import 'package:saferoute/utilities/display_cards/route_info_card.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? fromLocation;
  LatLng? toLocation;
  LatLng? _currentLocation;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  bool _routeDrawn = false;
  bool _showInputs = true;

  RouteResponse? _selectedRoute;
  Timer? _routeInfoTimer;

  @override
  void initState() {
    super.initState();

    _fromController = TextEditingController();
    _toController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
    _fromController.addListener(() {
      if (_fromController.text.isEmpty) {
        fromLocation = null;
      }
    });

    _toController.addListener(() {
      if (_toController.text.isEmpty) {
        toLocation = null;
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                  },
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: _showInputs ? 20 : -220,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPlacesField(
                            controller: _fromController,
                            hint: 'From',
                            icon: Icons.my_location,
                            onLocationSelected: (latLng) {
                              fromLocation = latLng;
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildPlacesField(
                            controller: _toController,
                            hint: 'To',
                            icon: Icons.location_on,
                            onLocationSelected: (latLng) {
                              toLocation = latLng;
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onNavigatePressed,
                              child: const Text('Get Routes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recenter button
                Positioned(
                  bottom: 24,
                  left: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'recenter',
                        onPressed: _recenterMap,
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 5),
                      FloatingActionButton(
                        heroTag: 'logout',
                        onPressed: () async {
                          final shouldLogout = await (showLogoutDialog(
                            context,
                          ));
                          if (shouldLogout) {
                            context.read<AuthBloc>().add(
                              const AuthEventLogout(),
                            );
                          }
                        },
                        child: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),

                if (!_showInputs)
                  Positioned(
                    top: 40,
                    left: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _showInputs = true;
                          _polylines.clear();
                          _routeDrawn = false;
                          _markers.clear();
                          _markers.add(
                            Marker(
                              markerId: const MarkerId('curr'),
                              position: LatLng(12.95589, 77.71239),
                              infoWindow: const InfoWindow(title: 'You'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure,
                              ),
                            ),
                          );
                          _fromController.clear();
                          _toController.clear();
                        });
                        _recenterMap();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),

                if (_selectedRoute != null)
                  Positioned(
                    bottom: 25,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 200),
                      child: RouteInfoCard(
                        route: _selectedRoute!,
                        riskColor: getRiskColor(_selectedRoute!.riskLevel),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPlacesField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required void Function(LatLng?) onLocationSelected,
  }) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: dotenv.env['GOOGLE_API_KEY']!,

      debounceTime: 400,
      isLatLngRequired: true,

      inputDecoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onLocationSelected(null);
                },
              )
            : null,
      ),

      itemClick: (prediction) {
        controller.text = prediction.description ?? '';
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },

      getPlaceDetailWithLatLng: (prediction) {
        final lat = double.parse(prediction.lat!);
        final lng = double.parse(prediction.lng!);

        onLocationSelected(LatLng(lat, lng));
      },
    );
  }

  void _onNavigatePressed() async {
    final LatLng? effectiveFrom = fromLocation ?? _currentLocation;

    if (effectiveFrom == null || toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select destination')),
      );
      return;
    }

    setState(() {
      _showInputs = false;
    });

    await _fetchAndDrawRoutes(from: effectiveFrom, to: toLocation!);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController
        .hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final Set<Marker> newMarkers = {};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('curr'),
        position: LatLng(12.95589, 77.71239),
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Hardcoded current location for testing (same as 'from')
    setState(() {
      _currentLocation = LatLng(12.95589, 77.71239);
      _markers = newMarkers;
    });
    _cameraToPosition(_currentLocation!);

    /* Comment out real location tracking for testing
    _locationController.onLocationChanged.listen((location) {
      if (location.latitude == null || location.longitude == null) return;
      setState(() {
        _currentLocation = LatLng(location.latitude!, location.longitude!);
      });
      if (!_routeDrawn) {
        _cameraToPosition(_currentLocation!);
      }
    });
    */
  }

  void _recenterMap() async {
    await _cameraToPosition(_currentLocation!);
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 16);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> _fetchAndDrawRoutes({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      // Hardcoded for testing
      from = LatLng(12.95589, 77.71238);
      to = LatLng(12.95207, 77.72091);

      print(
        'Fetching routes from ${from.latitude},${from.longitude} to ${to.latitude},${to.longitude}',
      );

      _showFromToMarkers(from: from, to: to);

      final routes = await mockGetRoutes(from, to);

      if (routes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No routes found')));
        }
        return;
      }

      print('Received ${routes.length} routes');
      _drawPolylines(routes);

      await _fitCameraToPoints(from, to);
    } catch (e) {
      print("FAILED TO FETCH ROUTES: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch routes: $e')));
      }
    }
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

  void _showFromToMarkers({required LatLng from, required LatLng to}) {
    final Set<Marker> newMarkers = {};

    newMarkers.add(
      Marker(
        markerId: const MarkerId('curr'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // From marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('from'),
        position: from,
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // To marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('to'),
        position: to,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    setState(() {
      _markers = newMarkers;
    });
  }

  Future<void> _fitCameraToPoints(LatLng a, LatLng b) async {
    final controller = await _mapController.future;

    final bounds = LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _drawPolylines(List<RouteResponse> routes) {
    final Set<Polyline> newPolylines = {};

    for (int i = 0; i < routes.length; i++) {
      try {
        final points = decodeEncodedPolyline(routes[i].polyline);

        if (points.isEmpty) {
          print('Warning: Route $i has no points');
          continue;
        }

        print(
          'Drawing route $i with ${points.length} points, color: ${routes[i].riskLevel}',
        );

        newPolylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: points,
            color: getRiskColor(routes[i].riskLevel),
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            consumeTapEvents: true,
            onTap: () {
              _onRouteTapped(routes[i]);
            },
          ),
        );
      } catch (e) {
        print('Error drawing route $i: $e');
      }
    }

    setState(() {
      _routeDrawn = true;
      _polylines = newPolylines;
    });

    print('Total polylines drawn: ${_polylines.length}');
  }

  void _onRouteTapped(RouteResponse route) {
    _routeInfoTimer?.cancel();

    setState(() {
      _selectedRoute = route;
    });

    _routeInfoTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _selectedRoute = null;
        });
      }
    });
  }

  List<LatLng> decodeEncodedPolyline(String encodedPolyline) {
    try {
      final decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);
      return decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (e) {
      print('Error decoding polyline: $e');
      return [];
    }
  }
}
