package safety

func RoadTypeScore(roadHint string) int {
	switch roadHint {
	case "HIGHWAY":
		return 90
	case "MAIN_ROAD":
		return 75
	case "RESIDENTIAL":
		return 60
	case "ALLEY":
		return 40
	default:
		return 55
	}
}
