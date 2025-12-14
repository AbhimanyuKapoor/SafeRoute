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
	DistanceKm  float64 `json:"distance_km"`
	DurationMin int     `json:"duration_min"`
	SafetyScore int     `json:"safety_score"`
	RiskLevel   string  `json:"risk_level"`
}

// type SegmentResult struct {
// 	Coordinate    LatLng `json:"coordinate"`
// 	LightingScore int    `json:"lighting_score"`
// 	CrowdScore    int    `json:"crowd_score"`
// 	SegmentScore  int    `json:"segment_score"`
// }

type SegmentResult struct {
	Coordinate    LatLng `json:"coordinate"`
	LightingScore int    `json:"lighting_score"`
	StreetViewURL string `json:"street_view_url"`
}

type AnalyzeRouteResponse struct {
	Route    RouteSummary    `json:"route"`
	Segments []SegmentResult `json:"segments"`
}

type SafetySignals struct {
	Lighting float64
	Crowd    float64
}
