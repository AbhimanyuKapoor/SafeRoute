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

//   if (response.statusCode == 201) {
//     final List<dynamic> jsonList = jsonDecode(response.body);

//     List<RouteResponse> routes = jsonList
//         .map((json) => RouteResponse.fromJson(json as Map<String, dynamic>))
//         .toList();
//     return routes;
//   } else {
//     throw Exception('Failed to create album.');
//   }
// }

Future<List<RouteResponse>> mockGetRoutes(
  LatLng from,
  LatLng to,
) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  final List<dynamic> jsonList =
      jsonDecode(mockRouteResponseJson);

  return jsonList
      .map((e) => RouteResponse.fromJson(e as Map<String, dynamic>))
      .toList();
}
