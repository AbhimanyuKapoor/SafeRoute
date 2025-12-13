package env

import (
	"log"

	"github.com/joho/godotenv"
)

func Load() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}
}
