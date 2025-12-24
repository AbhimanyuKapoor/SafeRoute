import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:saferoute/dto/route_response.dart';
import 'package:saferoute/mock/mock_routes.dart';

// Future<List<RouteResponse>> getRoutes(LatLng from, LatLng to) async {
//   final response = await http.post(
//     Uri.parse(""),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, Map<String, double>>{
//       'from': {'lat': from.latitude, 'lng': from.longitude},
//       'to': {'lat': to.latitude, 'lng': to.longitude},
//     }),
//   );

//   final decoded = jsonDecode(response.body);

//   if (response.statusCode == 200) {
//     final List<dynamic> jsonList = decoded;

//     List<RouteResponse> routes = jsonList
//         .map((json) => RouteResponse.fromJson(json as Map<String, dynamic>))
//         .toList();
//     return routes;
//   } else {
//     final errorMessage =
//         decoded is Map<String, dynamic> && decoded.containsKey('error')
//             ? decoded['error']
//             : 'Failed to fetch routes';

//     throw Exception(errorMessage);
//   }
// }

Future<List<RouteResponse>> mockGetRoutes(LatLng from, LatLng to) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Toggle this to test success / error
  const bool shouldFail = false; // <-- change to true to test error flow

  if (shouldFail) {
    final decoded = jsonDecode(mockRouteErrorJson);

    final errorMessage =
        decoded is Map<String, dynamic> && decoded.containsKey('error')
            ? decoded['error']
            : 'Unknown error occurred';

    throw Exception(errorMessage);
  }

  final decoded = jsonDecode(mockRouteResponseJson);

  final List<dynamic> jsonList = decoded as List<dynamic>;

  return jsonList
      .map((e) => RouteResponse.fromJson(e as Map<String, dynamic>))
      .toList();
}
