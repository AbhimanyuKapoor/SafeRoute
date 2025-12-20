package maps

import (
	"SafeRoute/internal/dto"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type RouteResult struct {
	DistanceMeters int
	DurationSec    int
	Polyline       string
}

func FetchRoute(from, to dto.LatLng, apiKey string) ([]RouteResult, error) {

	url := fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=walking&alternatives=true&key=%s",
		from.Lat, from.Lng,
		to.Lat, to.Lng,
		apiKey,
	)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var data struct {
		Routes []struct {
			OverviewPolyline struct {
				Points string `json:"points"`
			} `json:"overview_polyline"`
			Legs []struct {
				Distance struct {
					Value int `json:"value"`
				} `json:"distance"`
				Duration struct {
					Value int `json:"value"`
				} `json:"duration"`
			} `json:"legs"`
		} `json:"routes"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return nil, err
	}

	if len(data.Routes) == 0 {
		return nil, fmt.Errorf("no routes found")
	}

	results := make([]RouteResult, 0, len(data.Routes))

	for _, route := range data.Routes {
		if len(route.Legs) == 0 {
			continue
		}

		leg := route.Legs[0]

		results = append(results, RouteResult{
			DistanceMeters: leg.Distance.Value,
			DurationSec:    leg.Duration.Value,
			Polyline:       route.OverviewPolyline.Points,
		})
	}

	if len(results) == 0 {
		return nil, fmt.Errorf("no valid routes found")
	}

	return results, nil
}
