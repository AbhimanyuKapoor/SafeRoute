package safety

type RouteAverages struct {
	Lighting  int
	Crowd     int
	Activity  int
	TimeOfDay int
	RoadType  int
}

func AggregateRouteSignals(segments []SegmentSignals) RouteAverages {
	var sum RouteAverages

	for _, s := range segments {
		sum.Lighting += s.Lighting
		sum.Crowd += s.Crowd
		sum.Activity += s.ActivityLikelihood
		sum.TimeOfDay += s.TimeOfDay
		sum.RoadType += s.RoadType
	}

	count := len(segments)

	return RouteAverages{
		Lighting:  sum.Lighting / count,
		Crowd:     sum.Crowd / count,
		Activity:  sum.Activity / count,
		TimeOfDay: sum.TimeOfDay / count,
		RoadType:  sum.RoadType / count,
	}
}

// Explanations provided by app based on average of different parameters
func ExplainRoute(avg RouteAverages) map[string]string {
	explain := map[string]string{}

	// Lighting
	switch {
	case avg.Lighting >= 75:
		explain["lighting"] = "Mostly well-lit streets"
	case avg.Lighting >= 50:
		explain["lighting"] = "Moderately lit areas"
	default:
		explain["lighting"] = "Poor lighting in some segments"
	}

	// Activity likelihood
	switch {
	case avg.Activity >= 70:
		explain["activity"] = "High likelihood of human activity"
	case avg.Activity >= 40:
		explain["activity"] = "Moderate likelihood of human activity"
	default:
		explain["activity"] = "Low activity expected in this area"
	}

	// Crowd (visual ML)
	switch {
	case avg.Crowd >= 70:
		explain["crowd"] = "Likely presence of people"
	case avg.Crowd >= 40:
		explain["crowd"] = "Some people likely present"
	default:
		explain["crowd"] = "Few people expected along the route"
	}

	// Time of day
	if avg.TimeOfDay < 60 {
		explain["time_of_day"] = "Night-time increases risk"
	} else {
		explain["time_of_day"] = "Day & evening travel has less risk"
	}

	// Road type
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
