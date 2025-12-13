package server

import (
	"SafeRoute/internal/routes"

	"github.com/gin-gonic/gin"
)

func New() *gin.Engine {
	r := gin.Default()
	routes.Register(r)
	return r
}
