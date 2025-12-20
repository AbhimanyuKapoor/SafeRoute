package utils

import (
	"SafeRoute/internal/dto"
	"math"
)

// Haversine distance in meters (Standard)
func distance(a, b dto.LatLng) float64 {
	const R = 6371000

	lat1 := a.Lat * math.Pi / 180
	lat2 := b.Lat * math.Pi / 180
	dLat := (b.Lat - a.Lat) * math.Pi / 180
	dLng := (b.Lng - a.Lng) * math.Pi / 180

	x := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1)*math.Cos(lat2)*
			math.Sin(dLng/2)*math.Sin(dLng/2)

	return 2 * R * math.Asin(math.Sqrt(x))
}

// Appends points every `stepMeters` along the route
func SampleRoute(points []dto.LatLng, stepMeters float64) []dto.Segment {

	// Fallback
	if len(points) == 1 {
		return []dto.Segment{
			{
				Position:   points[0],
				HeadingRef: points[0],
			},
		}
	}

	var sampled []dto.Segment
	sampled = append(sampled, dto.Segment{
		Position:   points[0],
		HeadingRef: points[1],
	})

	accumulated := 0.0

	for i := 1; i < len(points); i++ {
		d := distance(points[i-1], points[i])
		accumulated += d

		if accumulated >= stepMeters {
			sampled = append(sampled, dto.Segment{
				Position:   points[i],
				HeadingRef: points[i-1],
			})
			accumulated -= stepMeters
		}
	}

	// Last point should be included
	last := points[len(points)-1]
	prev := points[len(points)-2]

	if sampled[len(sampled)-1].Position != last {
		sampled = append(sampled, dto.Segment{
			Position:   last,
			HeadingRef: prev,
		})
	}

	return sampled
}
