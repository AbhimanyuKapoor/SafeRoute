package safety

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/maps"
	"strings"
)

type RoadCategory string

const (
	Highway     RoadCategory = "highway"
	MainRoad    RoadCategory = "main_road"
	Residential RoadCategory = "residential"
	ServiceRoad RoadCategory = "service_road"
	UnknownRoad RoadCategory = "unknown"
)

func ComputeRoadSafetyScore(coordinate dto.LatLng, apiKey string) (int, error) {
	placeID, err := maps.GetNearestRoadPlaceID(coordinate, apiKey)
	if err != nil {
		return 0, err
	}

	name, err := maps.GetRoadNameFromPlaceID(placeID, apiKey)
	if err != nil {
		return 0, err
	}

	category := InferRoadCategory(name)
	score := RoadTypeScore(category)

	return score, nil
}

// Safety score (0–100) based on the category of road
func RoadTypeScore(category RoadCategory) int {
	switch category {

	case MainRoad:
		// High activity, visibility
		return 80

	case Residential:
		// People present, moderate lighting
		return 65

	case Highway:
		// Lit but isolated
		return 55

	case ServiceRoad:
		// Often isolated
		return 50

	case UnknownRoad:
		return 40

	default:
		return 50
	}
}

// Safety score (0–100) based on the category of road
// func RoadTypeScore(category RoadCategory) int {
// 	switch category {
// 	case Highway:
// 		return 90
// 	case MainRoad:
// 		return 80
// 	case Residential:
// 		return 65
// 	case ServiceRoad:
// 		return 55
// 	case UnknownRoad:
// 		return 40
// 	default:
// 		return 50
// 	}
// }

// Map road type returned from google roads api to known categories
// func MapGoogleRoadType(googleTypes []string) RoadCategory {
// 	for _, t := range googleTypes {
// 		switch t {
// 		case "highway", "motorway":
// 			return Highway
// 		case "route":
// 			return MainRoad
// 		case "street_address":
// 			return Residential
// 		case "intersection":
// 			return ServiceRoad
// 		}
// 	}
// 	return UnknownRoad
// }

// Infer the road category from google places api road name
func InferRoadCategory(name string) RoadCategory {
	// log.Println("RoadName: " + name)

	n := strings.ToLower(name)

	// Service roads
	if strings.Contains(n, "service") {
		return ServiceRoad
	}

	// Residential
	if strings.Contains(n, "gali") ||
		strings.Contains(n, "cross") ||
		strings.Contains(n, "lane") ||
		strings.Contains(n, "street") ||
		strings.Contains(n, "layout") {
		return Residential
	}

	// Highways
	if strings.HasPrefix(n, "nh") ||
		strings.HasPrefix(n, "sh") ||
		strings.Contains(n, "highway") ||
		strings.Contains(n, "expressway") {
		return Highway
	}

	// Main roads
	if strings.Contains(n, "main") ||
		strings.Contains(n, "road") {
		return MainRoad
	}

	return UnknownRoad
}
