package safety

import (
	"math"
)

type SegmentSignals struct {
	Lighting           int
	Crowd              int
	ActivityLikelihood int
	TimeOfDay          int
	RoadType           int
}

func SegmentSafetyScore(s SegmentSignals) int {

	score :=
		0.30*float64(s.Lighting) +
			0.25*float64(s.Crowd) +
			0.20*float64(s.ActivityLikelihood) +
			0.15*float64(s.TimeOfDay) +
			0.10*float64(s.RoadType)

	return int(math.Round(score))
}

func RouteSafetyScore(segmentScores []int) int {

	if len(segmentScores) == 0 {
		return 0
	}

	sum := 0
	min := segmentScores[0]

	for _, s := range segmentScores {
		sum += s
		if s < min {
			min = s
		}
	}

	avg := float64(sum) / float64(len(segmentScores))

	// One unsafe stretch makes the route unsafe
	score := 0.6*avg + 0.4*float64(min)
	return int(math.Round(score))
}

func RiskLevel(score int) string {
	switch {
	case score >= 70:
		return "LOW"
	case score >= 40:
		return "MEDIUM"
	default:
		return "HIGH"
	}
}
