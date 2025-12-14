package handlers

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/maps"
	"SafeRoute/internal/utils"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func AnalyzeRoute(c *gin.Context) {

	var req dto.AnalyzeRouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	apiKey := os.Getenv("GOOGLE_MAPS_API_KEY")

	// Fetching route details from google maps api
	route, err := maps.FetchRoute(
		req.From,
		req.To,
		apiKey,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "route fetch failed"})
		return
	}

	// Getting {Lat, Lng} points from google maps polyline
	points := utils.DecodePolyline(route.Polyline)

	// Sampling points every 500 metres
	segments := utils.SampleRoute(points, 500)

	var segmentResults []dto.SegmentResult

	for _, p := range segments {

		imgURL := maps.BuildStreetViewURL(
			dto.LatLng{
				Lat: p.Lat,
				Lng: p.Lng,
			},
			apiKey,
		)

		segmentResults = append(segmentResults, dto.SegmentResult{
			Coordinate: dto.LatLng{
				Lat: p.Lat,
				Lng: p.Lng,
			},
			StreetViewURL: imgURL,
		})
	}

	resp := dto.AnalyzeRouteResponse{
		Route: dto.RouteSummary{
			DistanceKm:  float64(route.DistanceMeters) / 1000,
			DurationMin: route.DurationSec / 60,
			SafetyScore: 0,
			RiskLevel:   "UNKNOWN",
		},
		Segments: segmentResults,
	}

	// Mock response
	// resp := dto.AnalyzeRouteResponse{
	// 	Route: dto.RouteSummary{
	// 		DistanceKm:  5.2,
	// 		DurationMin: 18,
	// 		SafetyScore: 76,
	// 		RiskLevel:   "MEDIUM",
	// 	},
	// 	Segments: []dto.SegmentResult{
	// 		{
	// 			Coordinate: dto.LatLng{
	// 				Lat: req.From.Lat,
	// 				Lng: req.From.Lng,
	// 			},
	// 			LightingScore: 80,
	// 			CrowdScore:    65,
	// 			SegmentScore:  73,
	// 		},
	// 	},
	// }

	c.JSON(http.StatusOK, resp)
}
