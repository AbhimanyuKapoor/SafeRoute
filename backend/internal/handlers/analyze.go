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

// Maximum allowed route length
const MaxRouteDistanceMeters = 10000

func AnalyzeRoute(c *gin.Context) {

	var req dto.AnalyzeRouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	apiKey := os.Getenv("GOOGLE_MAPS_API_KEY")

	// Fetching routes details from google maps api
	routes, err := maps.FetchRoute(
		req.From,
		req.To,
		apiKey,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "route fetch failed"})
		return
	}

	// Multiple possible routes from point A to B
	var resp []dto.AnalyzeRouteResponse

	for _, route := range routes {

		if route.DistanceMeters > MaxRouteDistanceMeters {
			continue
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
		for i, p := range segments {

			imgURL := maps.BuildStreetViewURL(p, apiKey, i == 0)

			var (
				modelScore ml.SafetySignals
				hasVision  bool
			)

			// Image fetch
			imgBase64, err := utils.FetchImageAsBase64(imgURL)
			if err != nil {
				hasVision = false
			} else {
				// Model inference
				modelScore, err = mlClient.Predict(imgBase64)
				if err != nil {
					hasVision = false
				} else {
					hasVision = true
				}
			}

			timeScore := safety.TimeOfDayScore(time.Now())

			roadScore, err := safety.ComputeRoadSafetyScore(p.Position, apiKey)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error in ComputeRoadSafetyScore:": err})
				return
			}

			// Radius 100 -> Slightly more than immediate environment per segment
			activityScore, err := safety.ComputeActivityScore(p.Position, 100, apiKey)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error in ComputeActivityScore:": err})
				return
			}

			// Segment safety indicators
			signals := safety.SegmentSignals{
				ActivityLikelihood: activityScore,
				TimeOfDay:          timeScore,
				RoadType:           roadScore,
				HasVision:          hasVision,
			}

			if hasVision {
				signals.Lighting = int(modelScore.Lighting * 100)
				signals.Crowd = int(modelScore.Crowd * 100)
			}

			// Segment score based on safety indicators
			segmentScore := safety.SegmentSafetyScore(signals)

			segmentSignals = append(segmentSignals, signals)
			segmentScores = append(segmentScores, segmentScore)

			lighting := 0
			crowd := 0
			if hasVision {
				lighting = signals.Lighting
				crowd = signals.Crowd
			}

			segmentResults = append(segmentResults, dto.SegmentResult{
				Coordinate: dto.LatLng{
					Lat: p.Position.Lat,
					Lng: p.Position.Lng,
				},
				LightingScore:           lighting,
				CrowdScore:              crowd,
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

		resp = append(resp, dto.AnalyzeRouteResponse{
			Route: dto.RouteSummary{
				Polyline:     route.Polyline,
				DistanceKm:   float64(route.DistanceMeters) / 1000,
				DurationMin:  route.DurationSec / 60,
				SafetyScore:  routeScore,
				RiskLevel:    risk,
				Explanations: explanations,
			},
			Segments: segmentResults,
		})
	}

	if len(resp) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "All available routes exceed the maximum supported distance (10 km)",
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}
