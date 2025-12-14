package safety

import "time"

func TimeOfDayScore(now time.Time) int {
	hour := now.Hour()

	switch {
	case hour >= 6 && hour < 9:
		// Morning (people going out)
		return 90

	case hour >= 9 && hour < 17:
		// Peak daytime
		return 100

	case hour >= 17 && hour < 20:
		// Evening (still active)
		return 80

	case hour >= 20 && hour < 23:
		// Night (activity dropping)
		return 60

	case hour >= 23 || hour < 5:
		// Late night / early morning
		return 40

	default:
		return 50
	}
}
