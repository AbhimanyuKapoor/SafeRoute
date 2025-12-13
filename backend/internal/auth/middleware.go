package auth

import (
	"SafeRoute/internal/firebase"
	"context"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func FirebaseAuth() gin.HandlerFunc {
	return func(c *gin.Context) {

		header := c.GetHeader("Authorization")
		if header == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "missing authorization header",
			})
			return
		}

		token := strings.TrimPrefix(header, "Bearer ")

		client, _ := firebase.App.Auth(context.Background())
		decoded, err := client.VerifyIDToken(context.Background(), token)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid token",
			})
			return
		}

		c.Set("uid", decoded.UID)
		c.Next()
	}
}
