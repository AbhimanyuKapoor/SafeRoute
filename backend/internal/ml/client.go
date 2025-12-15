package ml

type SafetySignals struct {
	Lighting float64
	Crowd    float64
}

type Client interface {
	Predict(imageURL string) (SafetySignals, error)
}
