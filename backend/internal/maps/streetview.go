package maps

import (
	"SafeRoute/internal/dto"
	"fmt"
)

func BuildStreetViewURL(p dto.LatLng, apiKey string) string {

	return fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/streetview?size=640x640&location=%f,%f&fov=90&pitch=0&key=%s",
		p.Lat,
		p.Lng,
		apiKey,
	)
}
