package main

import (
	"log"
	"os"

	"SafeRoute/internal/env"
	"SafeRoute/internal/firebase"
	"SafeRoute/internal/server"
)

func main() {
	env.Load()
	firebase.Init()

	r := server.New()

	port := os.Getenv("PORT")
	log.Println("Server running on port", port)
	log.Fatal(r.Run(":" + port))
}
