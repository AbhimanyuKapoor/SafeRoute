package ml

import "SafeRoute/internal/dto"

type Client interface {
	Predict(imageURL string) (dto.SafetySignals, error)
}
