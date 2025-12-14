package safety

import "time"

func TimeOfDayScore(now time.Time) int {
	hour := now.Hour()

	// Daytime: 6am – 7pm
	if hour >= 6 && hour < 19 {
		return 100
	}

	// Nighttime
	return 40
}
