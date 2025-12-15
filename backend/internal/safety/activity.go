package safety

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/maps"
	"log"
	"strconv"
)

var activityWeights = map[string]int{
	// Emergency & safety
	"police":   40,
	"hospital": 35,
	"pharmacy": 25,

	// Transport & fuel
	"gas_station":     25,
	"transit_station": 20,
	"bus_station":     15,

	// Commerce
	"shopping_mall":     30,
	"supermarket":       25,
	"convenience_store": 20,
	"store":             10,

	// Food & social
	"restaurant": 15,
	"cafe":       10,
	"bakery":     10,
	"bar":        15,
	"night_club": 20,

	// Finance
	"atm":  15,
	"bank": 10,
}

func ComputeActivityScore(coordinate dto.LatLng, radius int, apiKey string) (int, error) {

	placesResponse, err := maps.GetNearbyPlaces(coordinate, radius, apiKey)
	if err != nil {
		return 0, err
	}

	score := 0
	places := placesResponse.Results

	for _, place := range places {

		log.Println("\n\nPlace:")
		log.Printf("\n%+v", place)

		if place.BusinessStatus != "OPERATIONAL" {
			continue
		}

		for _, t := range place.Types {
			weight, ok := activityWeights[t]
			if !ok {
				continue
			}

			log.Println("\n\nType: " + t)
			log.Println("\nWeight Ok: " + strconv.Itoa(activityWeights[t]))

			// Time-aware weightage:
			// open_now == true -> full weight
			// operational but closed -> 40% weight
			if place.OpeningHours.OpenNow {
				score += weight
			} else {
				score += int(float64(weight) * 0.4)
			}

			break // double-counting
		}
	}

	// Score cap
	if score > 100 {
		return 100, nil
	}

	return score, nil
}
