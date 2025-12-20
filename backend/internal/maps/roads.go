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
		AddressComponents []struct {
			LongName  string   `json:"long_name"`
			ShortName string   `json:"short_name"`
			Types     []string `json:"types"`
		} `json:"address_components"`
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

// Getting the road name from the determined place ID
func GetRoadNameFromPlaceID(placeID string, apiKey string) (string, error) {
	url := fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/place/details/json?place_id=%s&fields=address_components&key=%s",
		placeID,
		apiKey,
	)

	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result PlaceDetailsResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if result.Status != "OK" {
		return "", errors.New("places api error")
	}

	// log.Printf("%+v", result)

	// `route` preferred
	for _, comp := range result.Result.AddressComponents {
		for _, t := range comp.Types {
			if t == "route" {
				return comp.LongName, nil
			}
		}
	}

	// `street_address` fallback
	for _, comp := range result.Result.AddressComponents {
		for _, t := range comp.Types {
			if t == "street_address" {
				return comp.LongName, nil
			}
		}
	}

	return "", errors.New("road name not found in place details")
}
