package safety

type RouteAverages struct {
	Lighting  int
	Crowd     int
	Activity  int
	TimeOfDay int
	RoadType  int

	VisionCoverage float64
}

func AggregateRouteSignals(segments []SegmentSignals) RouteAverages {
	var sum RouteAverages
	var visionCount int

	for _, s := range segments {
		sum.Activity += s.ActivityLikelihood
		sum.TimeOfDay += s.TimeOfDay
		sum.RoadType += s.RoadType

		if s.HasVision {
			sum.Lighting += s.Lighting
			sum.Crowd += s.Crowd
			visionCount++
		}
	}

	total := len(segments)

	avg := RouteAverages{
		Activity:  sum.Activity / total,
		TimeOfDay: sum.TimeOfDay / total,
		RoadType:  sum.RoadType / total,
	}

	if visionCount > 0 {
		avg.Lighting = sum.Lighting / visionCount
		avg.Crowd = sum.Crowd / visionCount
		avg.VisionCoverage = float64(visionCount) / float64(total)
	}

	return avg
}

// Explanations provided by app based on average of different parameters
func ExplainRoute(avg RouteAverages) map[string]string {
	explain := map[string]string{}

	if avg.VisionCoverage < 0.5 {
		explain["vision"] = "Limited visual data available for this route"
	}

	if avg.VisionCoverage >= 0.5 {
		switch {
		case avg.Lighting >= 75:
			explain["lighting"] = "Mostly well-lit streets"
		case avg.Lighting >= 50:
			explain["lighting"] = "Moderately lit areas"
		default:
			explain["lighting"] = "Some poorly lit segments"
		}

		switch {
		case avg.Crowd >= 70:
			explain["crowd"] = "Likely presence of people"
		case avg.Crowd >= 40:
			explain["crowd"] = "Some people likely present"
		default:
			explain["crowd"] = "Few people expected"
		}
	}

	switch {
	case avg.Activity >= 70:
		explain["activity"] = "High likelihood of human activity"
	case avg.Activity >= 40:
		explain["activity"] = "Moderate activity expected"
	default:
		explain["activity"] = "Low activity expected"
	}

	if avg.TimeOfDay < 60 {
		explain["time_of_day"] = "Night-time increases risk"
	} else {
		explain["time_of_day"] = "Day & evening travel has lower risk"
	}

	switch {
	case avg.RoadType >= 75:
		explain["road_type"] = "Mostly main roads"
	case avg.RoadType >= 60:
		explain["road_type"] = "Mostly residential roads"
	default:
		explain["road_type"] = "Includes narrow or less-used roads"
	}

	return explain
}
