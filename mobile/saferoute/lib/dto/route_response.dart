class RouteResponse {
  final String polyline;
  final double distance;
  final int duration;
  final int safetyScore;
  final String riskLevel;
  final Map<String, String> explanations;

  const RouteResponse({
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.safetyScore,
    required this.riskLevel,
    required this.explanations,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    final route = json['route'];
    return RouteResponse(
      polyline: route['polyline'],
      distance: route['distance_km'],
      duration: route['duration_min'],
      safetyScore: route['safety_score'],
      riskLevel: route['risk_level'],
      explanations: Map<String, String>.from(route['explanations']),
    );
  }
}
