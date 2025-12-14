package dto

type LatLng struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

type AnalyzeRouteRequest struct {
	From LatLng `json:"from"`
	To   LatLng `json:"to"`
}

type RouteSummary struct {
	Polyline     string            `json:"polyline"`
	DistanceKm   float64           `json:"distance_km"`
	DurationMin  int               `json:"duration_min"`
	SafetyScore  int               `json:"safety_score"`
	RiskLevel    string            `json:"risk_level"`
	Explanations map[string]string `json:"explanations"`
}

type SegmentResult struct {
	Coordinate              LatLng `json:"coordinate"`
	LightingScore           int    `json:"lighting_score"`
	CrowdScore              int    `json:"crowd_score"`
	TimeOfDayScore          int    `json:"time_of_day_score"`
	RoadTypeScore           int    `json:"road_type_score"`
	ActivityLikelihoodScore int    `json:"activity_likelihood_score"`
	SegmentSafetyScore      int    `json:"segment_safety_score"`
}

type AnalyzeRouteResponse struct {
	Route    RouteSummary    `json:"route"`
	Segments []SegmentResult `json:"segments"`
}
