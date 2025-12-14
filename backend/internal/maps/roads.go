package maps

import (
	"SafeRoute/internal/dto"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
)

type RoadsResponse struct {
	SnappedPoints []struct {
		PlaceID string `json:"placeId"`
	} `json:"snappedPoints"`
}

type PlaceDetailsResponse struct {
	Result struct {
		Types []string `json:"types"`
	} `json:"result"`
	Status string `json:"status"`
}

// Getting place ID of nearest road from given Lat, Lng points
func GetNearestRoadPlaceID(coordinate dto.LatLng, apiKey string) (string, error) {
	url := fmt.Sprintf(
		"https://roads.googleapis.com/v1/nearestRoads?points=%f,%f&key=%s",
		coordinate.Lat,
		coordinate.Lng,
		apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result RoadsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if len(result.SnappedPoints) == 0 {
		return "", errors.New("no road found")
	}

	return result.SnappedPoints[0].PlaceID, nil
}

// Getting the road type from the determined place ID
func GetRoadTypesFromPlaceID(placeID string, apiKey string) ([]string, error) {
	url := fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/place/details/json?place_id=%s&fields=types&key=%s",
		placeID,
		apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result PlaceDetailsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	if result.Status != "OK" {
		return nil, errors.New("places api error")
	}

	return result.Result.Types, nil
}
