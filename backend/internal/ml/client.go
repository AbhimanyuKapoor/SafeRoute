package ml

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type SafetySignals struct {
	Lighting float64 `json:"lighting_score"`
	Crowd    float64 `json:"crowd_score"`
}

func GetModelScore(imgBase64 string) (SafetySignals, error) {

	var result SafetySignals

	payload := map[string]string{
		"image_base64": imgBase64,
	}

	jsonData, _ := json.Marshal(payload)

	req, _ := http.NewRequest(
		"POST",
		"https://saferoute-ml-608073325522.asia-south2.run.app/predict",
		bytes.NewBuffer(jsonData),
	)

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return SafetySignals{}, err
	}

	return result, nil
}
