package ml

type MockClient struct{}

func NewMockClient() *MockClient {
	return &MockClient{}
}

func (s *MockClient) Predict(imageBase64 string) (SafetySignals, error) {
	return SafetySignals{
		Lighting: 0.5,
		Crowd:    0.5,
	}, nil
}
