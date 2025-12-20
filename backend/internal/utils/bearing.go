package utils

import (
	"SafeRoute/internal/dto"
	"math"
)

// To calculate the direction in which streetview image taker is heading
func Bearing(coordinate1, coordinate2 dto.LatLng) float64 {
	// Convert degrees to radians
	lat1Rad := coordinate1.Lat * math.Pi / 180
	lat2Rad := coordinate2.Lat * math.Pi / 180
	deltaLonRad := (coordinate2.Lng - coordinate1.Lng) * math.Pi / 180

	y := math.Sin(deltaLonRad) * math.Cos(lat2Rad)
	x := math.Cos(lat1Rad)*math.Sin(lat2Rad) -
		math.Sin(lat1Rad)*math.Cos(lat2Rad)*math.Cos(deltaLonRad)

	theta := math.Atan2(y, x)

	return math.Mod(theta*180/math.Pi+360, 360)
}
