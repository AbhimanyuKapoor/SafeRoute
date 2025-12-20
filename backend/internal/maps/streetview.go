package maps

import (
	"SafeRoute/internal/dto"
	"SafeRoute/internal/utils"
	"fmt"
)

func BuildStreetViewURL(segment dto.Segment, apiKey string, isFirst bool) string {
	var heading float64

	if isFirst {
		// First point -> outgoing direction
		heading = utils.Bearing(segment.Position, segment.HeadingRef)
	} else {
		// Normal case -> incoming direction
		heading = utils.Bearing(segment.HeadingRef, segment.Position)
	}

	return fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/streetview"+
			"?size=640x640"+
			"&location=%f,%f"+
			"&heading=%f"+
			"&fov=90"+
			"&pitch=0"+
			"&key=%s",
		segment.Position.Lat,
		segment.Position.Lng,
		heading,
		apiKey,
	)
}
