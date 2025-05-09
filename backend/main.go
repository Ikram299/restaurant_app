package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// Route pour la route /api/bonjour
	r.GET("/api/bonjour", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Bonjour depuis le backend Go !",
		})
	})

	// Lancer le serveur sur le port 8080
	r.Run(":8080")
}
