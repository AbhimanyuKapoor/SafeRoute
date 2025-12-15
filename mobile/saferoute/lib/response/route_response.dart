class RouteResponse {
  final String polyline;
  final double distanceKm;
  final int durationMin;
  final int safetyScore;
  final String riskLevel;

  RouteResponse({
    required this.polyline,
    required this.distanceKm,
    required this.durationMin,
    required this.safetyScore,
    required this.riskLevel,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      polyline: json['route']['polyline'],
      distanceKm: json['route']['distance_km'].toDouble(),
      durationMin: json['route']['duration_min'],
      safetyScore: json['route']['safety_score'],
      riskLevel: json['route']['risk_level'],
    );
  }
}
