package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func AnalyzeRoute(c *gin.Context) {
	uid, _ := c.Get("uid")

	c.JSON(http.StatusOK, gin.H{
		"message": "SafeRoute backend working",
		"user_id": uid,
	})
}
