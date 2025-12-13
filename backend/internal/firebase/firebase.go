package firebase

import (
	"context"
	"log"
	"os"

	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

var App *firebase.App

func Init() {
	ctx := context.Background()

	credPath := os.Getenv("FIREBASE_CREDENTIALS")
	if credPath == "" {
		log.Fatal("FIREBASE_CREDENTIALS not set")
	}

	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(credPath))
	if err != nil {
		log.Fatalf("error initializing firebase app: %v", err)
	}

	App = app
}
