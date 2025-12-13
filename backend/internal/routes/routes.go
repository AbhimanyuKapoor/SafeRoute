package routes

import (
	"SafeRoute/internal/auth"
	"SafeRoute/internal/handlers"

	"github.com/gin-gonic/gin"
)

func Register(r *gin.Engine) {

	api := r.Group("/api")
	api.Use(auth.FirebaseAuth())
	{
		api.POST("/analyze-route", handlers.AnalyzeRoute)
	}
}
