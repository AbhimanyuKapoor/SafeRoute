import 'package:flutter/material.dart';
import 'package:saferoute/dto/route_response.dart';

class RouteInfoCard extends StatelessWidget {
  final RouteResponse route;
  final Color riskColor;

  const RouteInfoCard({required this.route, required this.riskColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade900.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Risk: ${route.riskLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Safety Score: ${route.safetyScore}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Distance: ${route.distance} km',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'ETA: ${route.duration} mins',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Activity: ${route.explanations['activity']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Crowd: ${route.explanations['crowd']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Lighting: ${route.explanations['lighting']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Road Type: ${route.explanations['road_type']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Icon(Icons.route, color: riskColor, size: 32),
          ],
        ),
      ),
    );
  }
}