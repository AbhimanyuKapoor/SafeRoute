package safety

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/maps"
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
		return 40, err
	}

	types, err := maps.GetRoadTypesFromPlaceID(placeID, apiKey)
	if err != nil {
		return 40, err
	}

	category := MapGoogleRoadType(types)
	score := RoadTypeScore(category)

	return score, nil
}

// Safety score (0–100) based on the category of road
func RoadTypeScore(category RoadCategory) int {
	switch category {
	case Highway:
		return 90
	case MainRoad:
		return 80
	case Residential:
		return 65
	case ServiceRoad:
		return 55
	case UnknownRoad:
		return 40
	default:
		return 60
	}
}

// Map road type returned from google roads api to known categories
func MapGoogleRoadType(googleTypes []string) RoadCategory {
	for _, t := range googleTypes {
		switch t {
		case "highway", "motorway":
			return Highway
		case "route":
			return MainRoad
		case "street_address":
			return Residential
		case "intersection":
			return ServiceRoad
		}
	}
	return UnknownRoad
}
