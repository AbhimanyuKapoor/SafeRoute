package handlers

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/maps"
	"SafeRoute/internal/ml"
	"SafeRoute/internal/safety"
	"SafeRoute/internal/utils"
	"net/http"
	"os"
	"time"

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

	var segmentSignals []safety.SegmentSignals
	var segmentResults []dto.SegmentResult
	var segmentScores []int
	mlClient := ml.NewMockClient()

	// Calculating segment wise safety scores
	for _, p := range segments {

		imgURL := maps.BuildStreetViewURL(
			dto.LatLng{
				Lat: p.Lat,
				Lng: p.Lng,
			},
			apiKey,
		)

		modelScore, _ := mlClient.Predict(imgURL)
		timeScore := safety.TimeOfDayScore(time.Now())

		roadScore, err := safety.ComputeRoadSafetyScore(p, apiKey)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error in ComputeRoadSafetyScore:": err})
			return
		}

		// Radius 100 -> Slightly more than immediate environment per segment
		activityScore, err := safety.ComputeActivityScore(p, 100, apiKey)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error in ComputeActivityScore:": err})
			return
		}

		// Segment safety indicators
		signals := safety.SegmentSignals{
			Lighting:           int(modelScore.Lighting * 100),
			Crowd:              int(modelScore.Crowd * 100),
			ActivityLikelihood: activityScore,
			TimeOfDay:          timeScore,
			RoadType:           roadScore,
		}
		segmentSignals = append(segmentSignals, signals)

		// Segment score based on safety indicators
		segmentScore := safety.SegmentSafetyScore(signals)
		segmentScores = append(segmentScores, segmentScore)

		segmentResults = append(segmentResults, dto.SegmentResult{
			Coordinate: dto.LatLng{
				Lat: p.Lat,
				Lng: p.Lng,
			},
			LightingScore:           int(modelScore.Lighting * 100),
			CrowdScore:              int(modelScore.Crowd * 100),
			TimeOfDayScore:          timeScore,
			RoadTypeScore:           roadScore,
			ActivityLikelihoodScore: activityScore,
			SegmentSafetyScore:      segmentScore,
		})
	}

	// Getting final route score
	routeScore := safety.RouteSafetyScore(segmentScores)
	risk := safety.RiskLevel(routeScore)

	avgSignals := safety.AggregateRouteSignals(segmentSignals)
	explanations := safety.ExplainRoute(avgSignals)

	resp := dto.AnalyzeRouteResponse{
		Route: dto.RouteSummary{
			Polyline:     route.Polyline,
			DistanceKm:   float64(route.DistanceMeters) / 1000,
			DurationMin:  route.DurationSec / 60,
			SafetyScore:  routeScore,
			RiskLevel:    risk,
			Explanations: explanations,
		},
		Segments: segmentResults,
	}

	c.JSON(http.StatusOK, resp)
}
