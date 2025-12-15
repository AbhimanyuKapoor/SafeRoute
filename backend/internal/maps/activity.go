package maps

import (
	"SafeRoute/internal/dto"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
)

type NearbyPlacesResponse struct {
	Results []struct {
		Name           string   `json:"name"`
		Types          []string `json:"types"`
		BusinessStatus string   `json:"business_status"`
		OpeningHours   struct {
			OpenNow bool `json:"open_now"`
		} `json:"opening_hours,omitempty"`
	} `json:"results"`
	Status string `json:"status"`
}

func GetNearbyPlaces(coordinate dto.LatLng, radius int, apiKey string) (NearbyPlacesResponse, error) {

	url := fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&type=establishment&key=%s",
		coordinate.Lat, coordinate.Lng, radius, apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return NearbyPlacesResponse{}, err
	}
	defer resp.Body.Close()

	var result NearbyPlacesResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return NearbyPlacesResponse{}, err
	}

	log.Printf("\n\nLat, Lng: %f, %f", coordinate.Lat, coordinate.Lng)
	log.Printf("\nNearby Places:\n%+v", result)

	if result.Status != "OK" && result.Status != "ZERO_RESULTS" {
		return NearbyPlacesResponse{}, errors.New("places nearby api error")
	}

	return result, nil
}
