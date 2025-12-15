package ml

import "math/rand"

type MockClient struct{}

func NewMockClient() *MockClient {
	return &MockClient{}
}

func (s *MockClient) Predict(imageURL string) (SafetySignals, error) {
	return SafetySignals{
		Lighting: 0.55 + rand.Float64()*0.35,
		Crowd:    0.40 + rand.Float64()*0.40,
	}, nil
}
